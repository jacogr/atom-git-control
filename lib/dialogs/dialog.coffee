{View} = require 'atom-space-pen-views'

module.exports =
class Dialog extends View
  activate: ->
    @addClass('active')
    return

  deactivate: ->
    @removeClass('active')
    return

  cancel: ->
    @deactivate()
    return
