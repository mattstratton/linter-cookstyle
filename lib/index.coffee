path = require 'path'
helpers = require 'atom-linter'
escapeHtml = require 'escape-html'

COMMAND_CONFIG_KEY = 'linter-cookstyle.command'
DEFAULT_LOCATION = {line: 1, column: 1, length: 0}
DEFAULT_ARGS = [
  '--cache', 'false',
  '--force-exclusion',
  '--format', 'json',
  '--stdin',
  '--display-style-guide',
]
DEFAULT_MESSAGE = 'Unknown Error'
WARNINGS = new Set(['refactor', 'convention', 'warning'])


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
      title: 'Disable when no metadata.rb file is found'
      default: false
      description: '
        Only run linter if a metadata.rb file is found somewhere in the path
        for the current file.
      '

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

provideLinter: ->
  provider =
    name: 'cookstyle'
    grammarScopes: [
      'source.ruby'
      'source.ruby.chef'
    ]
    scope: 'file'
    lintOnFly: true
    lint: (editor) =>
      command = atom.config.get(COMMAND_CONFIG_KEY)
      cwd = path.dirname helpers.find filePath, '.'
      stdin = editor.getText()
      stream = 'both'
      helpers.exec(command, DEFAULT_ARGS, {cwd, stdin, stream}).then (result) ->
        {stdout, stderr} = result
        parsed = try JSON.parse(stdout)
        throw new Error stderr or stdout unless typeof parsed is 'object'
        (parsed.files?[0]?.offenses or []).map (offense) ->
          {cop_name, location, message, severity} = offense
          {message, url} = extractUrl message
          {line, column, length} = location or DEFAULT_LOCATION
          type: if WARNINGS.has(severity) then 'Warning' else 'Error'
          html: formatMessage {cop_name, message, url}
          filePath: filePath
          range: [[line - 1, column - 1], [line - 1, column + length - 1]]
