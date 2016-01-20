{View, $} = require 'atom-space-pen-views'

items = [
  { id: 'project', menu: 'Project', icon: 'icon-repo', type: 'active'}
  { id: 'compare', menu: 'Compare', icon: 'compare', type: 'active'}
  { id: 'commit', menu: 'Commit', icon: 'commit', type: 'file merging'}
  { id: 'reset', menu: 'Reset', icon: 'sync', type: 'file'}
  #{ id: 'clone', menu: 'Clone', icon: 'clone'}
  { id: 'fetch', menu: 'Fetch', icon: 'cloud-download', type: 'remote'}
  { id: 'pull', menu: 'Pull', icon: 'pull', type: 'upstream'}
  { id: 'pullup', menu: 'Pull Upstream', icon: 'desktop-download', type: 'active'}
  { id: 'push', menu: 'Push', icon: 'push', type: 'downstream'}
  { id: 'merge', menu: 'Merge', icon: 'merge', type: 'active'}
  { id: 'branch', menu: 'Branch', icon: 'branch', type: 'active'}
  #{ id: 'tag', menu: 'Tag', icon: 'tag'}
  { id: 'flow', menu: 'GitFlow', icon: 'flow', type: 'active', showConfig: 'git-control.showGitFlowButton'}
]

class MenuItem extends View
  @content: (item) ->
    klass = if item.type is 'active' then '' else 'inactive'
    klass += if item.showConfig? && !atom.config.get(item.showConfig) then ' hide' else ''

    @div class: "item #{klass} #{item.type}", id: "menu#{item.id}", click: 'click', =>
      @div class: "icon large #{item.icon}"
      @div item.menu

  initialize: (item) ->
    @item = item

    if item.showConfig?
      atom.config.observe item.showConfig, (show) ->
        if show then $("#menu#{item.id}").removeClass('hide')
        else $("#menu#{item.id}").addClass('hide')

  click: ->
    @parentView.click(@item.id)

module.exports =
class MenuView extends View
  @content: (item) ->
    @div class: 'menu', =>
      for item in items
        @subview item.id, new MenuItem(item)

  click: (id) ->
    if !(@find("#menu#{id}").hasClass('inactive'))
      @parentView["#{id}MenuClick"]()

  activate: (type, active) ->
    menuItems = @find(".item.#{type}")
    if active
      menuItems.removeClass('inactive')
    else
      menuItems.addClass('inactive')

    return
