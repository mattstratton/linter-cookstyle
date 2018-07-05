path = require 'path'
helpers = require 'atom-linter'
escapeHtml = require 'escape-html'

COMMAND_CONFIG_KEY = 'linter-cookstyle.command'
DISABLE_CONFIG_KEY = 'linter-cookstyle.disableWhenNoConfigFile'
DEFAULT_LOCATION = {line: 1, column: 1, length: 0}
DEFAULT_ARGS = [
  '--cache', 'false',
  '--force-exclusion',
  '--format', 'json',
  '--display-style-guide',
  '--extra-details',
  '--display-cop-names',
  '--stdin',
]
DEFAULT_MESSAGE = 'Unknown Error'
WARNINGS = new Set(['refactor', 'convention', 'warning'])

extractUrl = (message) ->
  [message, url] = message.split /\ \((.*)\)/, 2
  {message, url}

formatMessage = ({message, cop_name, url}) ->
  formatted_message = escapeHtml(message or DEFAULT_MESSAGE)
  formatted_cop_name =
    if cop_name?
      if url?
        " (<a href=\"#{escapeHtml url}\">#{escapeHtml cop_name}</a>)"
      else
        " (#{escapeHtml cop_name})"
    else
      ''
  formatted_message + formatted_cop_name

lint = (editor) ->
  command = atom.config.get(COMMAND_CONFIG_KEY).split(/\s+/).filter((i) -> i)
    .concat(DEFAULT_ARGS, filePath = editor.getPath())
  if atom.config.get(DISABLE_CONFIG_KEY) is true
    config = helpers.find(filePath, 'metadata.rb')
    return [] if config is null
  cwd = path.dirname helpers.find filePath, '.'
  stdin = editor.getText()
  stream = 'both'
  helpers.exec(command[0], command[1..], {cwd, stream, stdin}).then (result) ->
    {stdout, stderr} = result
    parsed = try JSON.parse(stdout)
    throw new Error stderr or stdout unless typeof parsed is 'object'
    (parsed.files?[0]?.offenses or []).map (offense) ->
      {cop_name, location, message, severity} = offense
      {message, url} = extractUrl message
      {line, column, length} = location or DEFAULT_LOCATION
      severity: if WARNINGS.has(severity) then 'warning' else 'error'
      description: formatMessage {cop_name, message, url}
      filePath: filePath
      location: {
        file: filePath,
        position: [[line - 1, column - 1], [line - 1, column + length - 1]]
      },
      excerpt: cop_name

linter =
  name: 'cookstyle'
  grammarScopes: [
    'source.chef.metadata',
    'source.chef.recipes'
  ]
  scope: 'file'
  lintsOnChange: true
  lint: lint

module.exports =
  config:
    command:
      type: 'string'
      title: 'Command'
      default: 'cookstyle'
      description: '
        This is the absolute path to your `cookstyle` command. You may need to run
        `which cookstyle` or `rbenv which cookstyle` to find this. Examples:
        `/opt/chefdk/bin/cookstyle`.
      '
    disableWhenNoConfigFile:
      type: 'boolean'
      title: 'Require metadata.rb for cookstyle linting'
      default: true
      description: '
        Only run linter if metadata.rb file is found somewhere in the path
        for the current file.
      '
  activate: ->
    require('atom-package-deps').install('linter-cookstyle')

  provideLinter: -> linter
