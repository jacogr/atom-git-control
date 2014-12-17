GitControlView = require './git-control-view'
{CompositeDisposable} = require 'atom'

module.exports = GitControl =
  gitControlView: null
  modalPanel: null
  subscriptions: null

  activate: (state) ->
    @gitControlView = new GitControlView(state.gitControlViewState)
    @modalPanel = atom.workspace.addModalPanel(item: @gitControlView.getElement(), visible: false)

    # Events subscribed to in atom's system can be easily cleaned up with a CompositeDisposable
    @subscriptions = new CompositeDisposable

    # Register command that toggles this view
    @subscriptions.add atom.commands.add 'atom-workspace', 'git-control:toggle': => @toggle()

  deactivate: ->
    @modalPanel.destroy()
    @subscriptions.dispose()
    @gitControlView.destroy()

  serialize: ->
    gitControlViewState: @gitControlView.serialize()

  toggle: ->
    console.log 'GitControl was toggled!'

    if @modalPanel.isVisible()
      @modalPanel.hide()
    else
      @modalPanel.show()
