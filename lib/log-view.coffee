{View} = require 'atom'

module.exports =
class LogView extends View
  @content: (params) ->
    @div class: 'logger'

  initialize: (params) ->

  log: (log, iserror) ->
    @append "<pre class='#{if iserror then 'error' else ''}'>#{log}</pre>"
    @scrollToBottom()
    return
