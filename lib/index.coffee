path = require 'path'
helpers = require 'atom-linter'
escapeHtml = require 'escape-html'

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
