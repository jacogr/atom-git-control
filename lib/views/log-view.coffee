{View} = require 'atom'

class LogLine extends View
  @content: (params) ->
    @pre class: "#{if params.iserror then 'error' else ''}", params.log

module.exports =
class LogView extends View
  @content: (params) ->
    @div class: 'logger'

  initialize: (params) ->

  log: (log, iserror) ->
    @append new LogLine(iserror: iserror, log: log)
    @scrollToBottom()
    return
