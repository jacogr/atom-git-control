{View} = require 'atom'

class LogLine extends View
  @content: (line) ->
    @pre class: "#{if line.iserror then 'error' else ''}", line.log

module.exports =
class LogView extends View
  @content: ->
    @div class: 'logger'

  log: (log, iserror) ->
    @append new LogLine(iserror: iserror, log: log)
    @scrollToBottom()
    return
