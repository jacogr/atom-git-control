GitControlView = require './git-control-view'
{CompositeDisposable} = require 'atom'

CMD_TOGGLE = 'git-control:toggle'
EVT_SWITCH = 'pane-container:active-pane-item-changed'

views = []

module.exports = GitControl =
  activate: (state) ->
    console.log 'GitControl: activate'

    atom.workspaceView.command CMD_TOGGLE, => @newView()
    atom.workspaceView.on EVT_SWITCH, => @updateViews()
    return

  deactivate: ->
    console.log 'GitControl: deactivate'
    return

  newView: ->
    console.log 'GitControl: toggle'

    view = new GitControlView()
    views.push view

    pane = atom.workspace.getActivePane()
    item = pane.addItem view, 0
    pane.activateItem item
    return

  updateViews: ->
    for view in views when view.active
      view.loadDetails()

  serialize: ->
