{View} = require 'atom'

module.exports =
class MenuViewItem extends View
  @content: (params) ->
    klass = if params.type is 'active' then '' else 'inactive'

    @div class: "item #{klass} type-#{params.type}", id: "menu#{params.id}", click: 'click', =>
      @div class: "icon large #{params.icon}"
      @div params.menu

  initialize: (params) ->
    @id = params.id

  click: ->
    @parentView.click(@id)
