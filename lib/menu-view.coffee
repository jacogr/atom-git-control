{View} = require 'atom'

MenuViewItem = require './menu-view-item'

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

module.exports =
class MenuView extends View
  @content: (params) ->
    @div class: 'menu', =>
      for item in items
        @subview item.id, new MenuViewItem(item)

  click: (id) ->
    @parentView["#{id}MenuClick"]()
