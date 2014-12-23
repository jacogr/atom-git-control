{View, $, $$} = require 'atom'

git = require './git'

BranchView = require './branch-view'
FileView = require './file-view'
MenuView = require './menu-view'

module.exports =
class GitControlView extends View
  @content: ->
    @div class: 'git-control', =>
      @subview 'menuView', new MenuView()

      @div class: 'content', =>

        @div class: 'dialog', outlet: 'commitView', =>
          @textarea class: 'native-key-bindings', outlet: 'commitMsg'
          @button click: 'commitCancel', =>
            @i class: 'icon x'
            @span 'Cancel'
          @button class: 'active', click: 'commitPost', =>
            @i class: 'icon commit'
            @span 'Commit'

        @div class: 'sidebar', =>
          @subview 'filesView', new FileView()
          @subview 'localBranchView', new BranchView(name: 'Local', local: true)
          @subview 'remoteBranchView', new BranchView(name: 'Remote')

        @div class: 'domain', =>
          @div class: 'diff', outlet: 'diffView'

      @div class: 'logger', outlet: 'logView'

  serialize: ->

  initialize: ->
    console.log 'GitControlView: initialize'

    git.setLogger (log, iserror) => @log(log, iserror)

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

  log: (log, iserror) ->
    @logView.append "<pre class='#{if iserror then 'error' else ''}'>#{log}</pre>"
    @logView.scrollToBottom()
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

    fmtNum = (num) ->
      return "     #{num or ''} ".slice(-6)

    git.diff().then (diffs) =>
      @diffView.find('.line').remove()
      for diff in diffs
        if (file = diff['+++']) is '+++ /dev/null'
          file = diff['---']

        @diffView.append $$ ->
          @div class: 'line heading', =>
            @pre "#{file}"

        noa = 0
        nob = 0

        for line in diff.lines
          if /^@@ /.test(line)
            # @@ -100,11 +100,13 @@
            [atstart, linea, lineb, atend] = line.replace(/-|\+/g, '').split(' ')
            noa = parseInt(linea, 10)
            nob = parseInt(lineb, 10)
            @diffView.append $$ ->
              @div class: 'line subtle', =>
                @pre line
          else
            klass = ''
            lineno = "#{fmtNum noa}#{fmtNum nob}"

            if /^-/.test(line)
              klass = 'red'
              lineno = "#{fmtNum noa}#{fmtNum 0}"
              noa++
            else if /^\+/.test(line)
              klass = 'green'
              lineno = "#{fmtNum 0}#{fmtNum nob}"
              nob++
            else
              noa++
              nob++

            @diffView.append $$ ->
              @div class: "line #{klass}", =>
                @pre class: 'lineno', lineno
                @pre line

      return
    return

  commitMenuClick: ->
    return unless @filesView.hasSelected()

    @commitView.addClass('active')
    @commitMsg.val('')
    return

  commitCancel: ->
    @commitView.removeClass('active')
    return

  commitPost: ->
    @commitCancel()
    return unless @filesView.hasSelected()

    msg = @commitMsg.val()

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
    return unless @hasSelectedFiles()

    files = @filesView.getSelected()

    git.reset(files.all).then => @update()

    return
