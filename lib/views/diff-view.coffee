{View} = require 'atom'

class DiffLine extends View
  @content: (params) ->
    @div class: "line #{params.type}", =>
      @pre class: "lineno #{unless params.lineno then 'invisible' else ''}", params.lineno
      @pre params.text

fmtNum = (num) ->
  return "     #{num or ''} ".slice(-6)

module.exports =
class DiffView extends View
  @content: ->
    @div class: 'diff'

  addAll: (diffs) ->
    @find('.line').remove()

    for diff in diffs
      if (file = diff['+++']) is '+++ /dev/null'
        file = diff['---']

      @append new DiffLine(type: 'heading', text: file)

      noa = 0
      nob = 0

      for line in diff.lines
        if /^@@ /.test(line)
          # @@ -100,11 +100,13 @@
          [atstart, linea, lineb, atend] = line.replace(/-|\+/g, '').split(' ')
          noa = parseInt(linea, 10)
          nob = parseInt(lineb, 10)

          @append new DiffLine(type: 'subtle', text: line)

        else
          klass = ''
          lineno = "#{fmtNum noa}#{fmtNum nob}"

          if /^-/.test(line)
            klass = 'red'
            lineno = "#{fmtNum noa}#{fmtNum 0}"
            noa++
          else if /^\+/.test(line)
            klass = 'green'
            lineno = "#{fmtNum 0}#{fmtNum nob}"
            nob++
          else
            noa++
            nob++

          @append new DiffLine(type: klass, text: line, lineno: lineno)

    return
