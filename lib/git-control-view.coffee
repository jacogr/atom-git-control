{View, $, $$} = require 'atom'

git = require './git'

BranchView = require './views/branch-view'
DiffView = require './views/diff-view'
FileView = require './views/file-view'
LogView = require './views/log-view'
MenuView = require './views/menu-view'

BranchDialog = require './dialogs/branch-dialog'
CommitDialog = require './dialogs/commit-dialog'
ConfirmDialog = require './dialogs/confirm-dialog'
MergeDialog = require './dialogs/merge-dialog'

module.exports =
class GitControlView extends View
  @content: ->
    @div class: 'git-control', =>
      @subview 'menuView', new MenuView()
      @div class: 'content', outlet: 'contentView', =>
        @div class: 'sidebar', =>
          @subview 'filesView', new FileView()
          @subview 'localBranchView', new BranchView(name: 'Local', local: true)
          @subview 'remoteBranchView', new BranchView(name: 'Remote')
        @div class: 'domain', =>
          @subview 'diffView', new DiffView()
        @subview 'branchDialog', new BranchDialog()
        @subview 'commitDialog', new CommitDialog()
        @subview 'mergeDialog', new MergeDialog()
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

    unless nofetch
      @fetchMenuClick()
      @diffView.clearAll()

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
    remotes = git.hasOrigin()

    @menuView.activate('upstream', remotes and count.behind)
    @menuView.activate('downstream', remotes and (count.ahead or !git.getRemoteBranch()))
    @menuView.activate('remote', remotes)
    return

  loadBranches: ->
    @selectedBranch = git.getLocalBranch()

    git.getBranches().then (branches) =>
      @branches = branches
      @remoteBranchView.addAll(branches.remote)
      @localBranchView.addAll(branches.local, true)
      return

    return

  showSelectedFiles: ->
    @menuView.activate('file', @filesView.hasSelected())
    @menuView.activate('file.merging', @filesView.hasSelected() or git.isMerging())
    return

  showStatus: ->
    git.status().then (files) =>
      @filesView.addAll(files)
      return
    return

  branchMenuClick: ->
    @branchDialog.activate()
    return

  compareMenuClick: ->
    git.diff().then (diffs) => @diffView.addAll(diffs)
    return

  commitMenuClick: ->
    return unless @filesView.hasSelected() or git.isMerging()

    @commitDialog.activate()
    return

  commit: ->
    return unless @filesView.hasSelected()

    msg = @commitDialog.getMessage()

    files = @filesView.getSelected()
    @filesView.unselectAll()

    git.add(files.add)
      .then -> git.remove(files.rem)
      .then -> git.commit(msg)
      .then => @update()
    return

  createBranch: (branch) ->
    git.createBranch(branch).then => @update()
    return

  deleteBranch: (branch) ->
    confirmCb = (params) =>
      git.deleteBranch(params.branch).then => @update()
      return

    @contentView.append new ConfirmDialog
      hdr: 'Delete Branch'
      msg: "Are you sure you want to delete the local branch '#{branch}'?"
      cb: confirmCb
      branch: branch
    return

  fetchMenuClick: ->
    return unless git.hasOrigin()

    git.fetch().then => @loadBranches()
    return

  mergeMenuClick: ->
    @mergeDialog.activate(@branches.local)
    return

  merge: (branch) =>
    git.merge(branch).then => @update()
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
