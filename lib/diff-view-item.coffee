{View} = require 'atom'

module.exports =
class DiffViewItem extends View
  @content: (params) ->
    @div class: "line #{params.type}", =>
      @pre class: "lineno #{unless params.lineno then 'invisible' else ''}", params.lineno
      @pre params.text

  initilize: (params) ->
    console.log params
