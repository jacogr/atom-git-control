{View, $} = require 'atom'

items = [
  { id: 'compare', menu: 'Compare', icon: 'compare', type: 'file'}
  { id: 'commit', menu: 'Commit', icon: 'commit', type: 'file'}
  { id: 'reset', menu: 'Reset', icon: 'sync', type: 'file'}
  #{ id: 'clone', menu: 'Clone', icon: 'clone'}
  { id: 'fetch', menu: 'Fetch', icon: 'cloud-download', type: 'active'}
  { id: 'pull', menu: 'Pull', icon: 'pull', type: 'upstream'}
  { id: 'push', menu: 'Push', icon: 'push', type: 'downstream'}
  { id: 'merge', menu: 'Merge', icon: 'merge', type: 'active'}
  { id: 'branch', menu: 'Branch', icon: 'branch', type: 'active'}
  #{ id: 'tag', menu: 'Tag', icon: 'tag'}
]

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
    
module.exports =
class MenuView extends View
  @content: (params) ->
    @div class: 'menu', =>
      for item in items
        @subview item.id, new MenuViewItem(item)

  click: (id) ->
    @parentView["#{id}MenuClick"]()

  activate: (type, active) ->
    menuItems = @find(".item.type-#{type}")
    if active
      menuItems.removeClass('inactive')
    else
      menuItems.addClass('inactive')
    return
