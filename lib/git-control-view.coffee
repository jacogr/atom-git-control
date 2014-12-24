{View, $, $$} = require 'atom'

git = require './git'

BranchView = require './views/branch-view'
DiffView = require './views/diff-view'
FileView = require './views/file-view'
LogView = require './views/log-view'
MenuView = require './views/menu-view'

CommitDialog = require './dialogs/commit-dialog'

module.exports =
class GitControlView extends View
  @content: ->
    @div class: 'git-control', =>
      @subview 'menuView', new MenuView()
      @div class: 'content', =>
        @subview 'commitDialog', new CommitDialog()
        @div class: 'sidebar', =>
          @subview 'filesView', new FileView()
          @subview 'localBranchView', new BranchView(name: 'Local', local: true)
          @subview 'remoteBranchView', new BranchView(name: 'Remote')
        @div class: 'domain', =>
          @subview 'diffView', new DiffView()
      @subview 'logView', new LogView()

  serialize: ->

  initialize: ->
    console.log 'GitControlView: initialize'

    git.setLogger (log, iserror) => @logView.log(log, iserror)

    @active = true
    @branchSelected = null

    return

  destroy: ->
    console.log 'GitControlView: destroy'
    @active = false
    return

  getTitle: ->
    return 'git:control'

  update: (nofetch) ->
    @loadBranches()
    @showStatus()
    @fetchMenuClick() unless nofetch

    return

  loadLog: ->
    git.log(@selectedBranch).then (logs) ->
      console.log 'git.log', logs
      return
    return

  checkoutBranch: (branch, remote) ->
    git.checkout(branch, remote).then => @update()
    return

  branchCount: (count) ->
    @menuView.activate('upstream', count.behind)
    @menuView.activate('downstream', count.ahead)
    return

  loadBranches: ->
    @selectedBranch = git.getLocalBranch()

    git.getBranches().then (branches) =>
      @remoteBranchView.addAll(branches.remote)
      @localBranchView.addAll(branches.local, true)
      return

    return

  showSelectedFiles: ->
    @menuView.activate('file', @filesView.hasSelected())
    return

  showStatus: ->
    git.status().then (files) =>
      @filesView.addAll(files)
      return
    return

  compareMenuClick: ->
    return unless @filesView.hasSelected()

    git.diff().then (diffs) =>
      @diffView.addAll(diffs)
      return
    return

  commitMenuClick: ->
    return unless @filesView.hasSelected()

    @commitDialog.activate()
    return

  commit: ->
    return unless @filesView.hasSelected()

    msg = @commitDialog.getMessage()

    files = @filesView.getSelected()
    @filesView.unselectAll()

    git.add(files.add)
      .then -> git.remove(files.rem)
      .then -> git.commit(files.all, msg)
      .then => @update()
    return

  fetchMenuClick: ->
    git.fetch().then => @loadBranches()
    return

  pullMenuClick: ->
    git.pull().then => @update(true)
    return

  pushMenuClick: ->
    git.push().then => @update(true)
    return

  resetMenuClick: ->
    return unless @filesView.hasSelected()

    files = @filesView.getSelected()

    git.reset(files.all).then => @update()

    return
