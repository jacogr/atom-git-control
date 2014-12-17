GitControlView = require './git-control-view'
{CompositeDisposable} = require 'atom'

views = []

module.exports = GitControl =
  activate: (state) ->
    console.log 'GitControl: activate'

    atom.workspaceView.command "git-control:toggle", => @newView()
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

  serialize: ->
