{View, $, $$} = require 'atom-space-pen-views'

git = require './git'

BranchView = require './views/branch-view'
DiffView = require './views/diff-view'
FileView = require './views/file-view'
LogView = require './views/log-view'
MenuView = require './views/menu-view'

BranchDialog = require './dialogs/branch-dialog'
CommitDialog = require './dialogs/commit-dialog'
ConfirmDialog = require './dialogs/confirm-dialog'
DeleteDialog = require './dialogs/delete-dialog'
MergeDialog = require './dialogs/merge-dialog'
FlowDialog = require './dialogs/flow-dialog'
PushDialog = require './dialogs/push-dialog'

module.exports =
class GitControlView extends View
  @content: ->
    if git.isInitialised()
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
          @subview 'flowDialog', new FlowDialog()
          @subview 'pushDialog', new PushDialog()
        @subview 'logView', new LogView()
    else #This is so that no error messages can be created by pushing buttons that are unavailable.
        @div class: 'git-control', =>
          @subview 'logView', new LogView()

  serialize: ->

  initialize: ->
    console.log 'GitControlView: initialize'

    git.setLogger (log, iserror) => @logView.log(log, iserror)

    @active = true
    @branchSelected = null

    if !git.isInitialised()
      git.alert "> This project is not a git repository. Either open another project or create a repository."

    return

  destroy: ->
    console.log 'GitControlView: destroy'
    @active = false
    return

  getTitle: ->
    return 'git:control'

  update: (nofetch) ->
    if git.isInitialised()
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
    if git.isInitialised()
      remotes = git.hasOrigin()

      @menuView.activate('upstream', remotes and count.behind)
      @menuView.activate('downstream', remotes and (count.ahead or !git.getRemoteBranch()))
      @menuView.activate('remote', remotes)
    return

  loadBranches: ->
    if git.isInitialised()
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
    git.diff(@filesView.getSelected().all.join(' ')).then (diffs) => @diffView.addAll(diffs)
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

    forceDeleteCallback = (params) =>
      git.forceDeleteBranch(params.branch).then => @update()

    @contentView.append new DeleteDialog
      hdr: 'Delete Branch'
      msg: "Are you sure you want to delete the local branch '#{branch}'?"
      cb: confirmCb
      fdCb: forceDeleteCallback
      branch: branch
    return

  fetchMenuClick: ->
    if git.isInitialised()
      return unless git.hasOrigin()

    git.fetch().then => @loadBranches()
    return

  mergeMenuClick: ->
    @mergeDialog.activate(@branches.local)
    return

  merge: (branch,noff) =>
    git.merge(branch,noff).then => @update()
    return

  flowMenuClick: ->
    @flowDialog.activate(@branches.local)
    return

  flow: (type,action,branch) =>
    git.flow(type,action,branch).then => @update()
    return

  pullMenuClick: ->
    git.pull().then => @update(true)
    return

  pushMenuClick: ->
    git.getBranches().then (branches) =>  @pushDialog.activate(branches.remote)
    return

  push: (remote, branches) ->
    git.push(remote,branches).then => @update()

  resetMenuClick: ->
    return unless @filesView.hasSelected()

    files = @filesView.getSelected()

    atom.confirm
      message: "Reset will erase changes since the last commit in the selected files. Are you sure?"
      buttons:
        Cancel: =>
          return
        Reset: =>
          git.reset(files.all).then => @update()
          return
