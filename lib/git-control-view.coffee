{View, $, $$} = require 'atom'

git = require './git'

menuItems = [
  { id: 'compare', menu: 'Compare', icon: 'compare', type: 'file'}
  { id: 'commit', menu: 'Commit', icon: 'commit', type: 'file'}
  { id: 'reset', menu: 'Reset', icon: 'sync', type: 'file'}
  #{ id: 'clone', menu: 'Clone', icon: 'clone'}
  { id: 'pull', menu: 'Pull', icon: 'pull'}
  { id: 'push', menu: 'Push', icon: 'push'}
  { id: 'merge', menu: 'Merge', icon: 'merge'}
  { id: 'branch', menu: 'Branch', icon: 'branch'}
  { id: 'tag', menu: 'Tag', icon: 'tag'}
]

count = 0

module.exports =
class GitControlView extends View
  @content: ->
    @div class: 'git-control', =>
      @div class: 'menu', outlet: 'menuView'
      @div class: 'content', =>
        @div class: 'sidebar', =>

          @div class: 'heading', =>
            @i class: 'icon forked'
            @span 'Workspace'
          @div class: 'files', outlet: 'filesView'

          @div class: 'heading', =>
            @i class: 'icon branch'
            @span 'Local'
          @div class: 'branches', outlet: 'localBranchView'

          @div class: 'heading', =>
            @i class: 'icon branch'
            @span 'Remote'
          @div class: 'branches', outlet: 'remoteBranchView'

        @div class: 'domain', =>
          @div class: 'diff', outlet: 'diffView'

  serialize: ->

  initialize: ->
    console.log 'GitControlView: initialize'

    @active = true
    @branchSelected = null
    @files = {}
    @filesSelected = []

    @createMenu()

    return

  destroy: ->
    console.log 'GitControlView: destroy'
    @active = false
    return

  getTitle: ->
    return 'git:control'

  update: ->
    @loadBranches()
    @showStatus()
    return

  addMenuItem: (item) ->
    id = "menu#{item.id}"

    @menuView.append $$ ->
      @div class: "item inactive type-#{item.type}", id: id, =>
        @div class: "icon large #{item.icon}"
        @div item.menu

    @menuView.find(".item##{id}").toArray().forEach (item) =>
      $(item).on 'click', => @["#{id}Click"]()
      return
    return

  createMenu: ->
    for item in menuItems
      @addMenuItem(item)
    return

  loadLog: ->
    console.log 'git.count', git.count(@selectedBranch)
    console.log 'git.getLocalBranch', git.getLocalBranch()
    console.log 'git.getRemoteBranch', git.getRemoteBranch()

    git.log(@selectedBranch)
      .then (logs) ->
        console.log 'git.log', logs
        return
      .catch console.error
    return

  loadBranches: ->
    @selectedBranch = git.getLocalBranch()

    append = (location, branches, local) =>
      location.find('.branch').remove()
      for branch in branches
        current = branch is @selectedBranch
        count = klass: 'hidden'
        if local and current
          count = git.count(branch)
          count.total = count.ahead + count.behind
          count.klass = 'hidden' unless count.total

        klass = if current then 'active' else ''

        location.append $$ ->
          @div class: "branch #{klass}", =>
            @span branch
            @div class: "count #{count.klass}", =>
              @span count.ahead
              @i class: 'icon cloud-upload'
              @span count.behind
              @i class: 'icon cloud-download'

      return

    git.getBranches()
      .then (branches) =>
        console.log 'branches', branches
        append(@remoteBranchView, branches.remote)
        append(@localBranchView, branches.local, true)
      .catch console.error

    return

  selectFile: (id) ->
    @filesSelected = []

    @filesView.find(".file input").toArray().forEach (input) =>
      input = $(input)
      if !!input.prop('checked')
        @filesSelected.push @files[input.attr('id')]
      return

    menuItems = @menuView.find('.item.type-file')
    if @filesSelected.length
      menuItems.removeClass('inactive')
    else
      menuItems.addClass('inactive')

    return

  addFile: (file) ->
    id = "file#{Date.now()}-#{++count}"

    @files[id] = file

    @filesView.append $$ ->
      @div class: "file #{file.type}", =>
        @input type: 'checkbox', id: id
        @i class: "icon file-#{file.type}"
        @span file.name

    @filesView.find(".file input##{id}").toArray().forEach (input) =>
      $(input).on 'change', => @selectFile(id)
      return
    return

  showStatus: ->
    git.status()
      .then (files) =>
        @filesView.find('.file').remove()
        for file in files
          @addFile(file)
        return
      .catch console.error
    return

  menucompareClick: ->
    return unless @filesSelected.length

    fmtNum = (num) ->
      return "     #{num or ''} ".slice(-6)

    git.diff()
      .then (diffs) =>
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
      .catch console.error
    return

  menucommitClick: ->
    return unless @filesSelected.length

  menuresetClick: ->
    return unless @filesSelected.length

    files = []
    for f in @filesSelected
      files.push f.name

    git.reset(files.join(' '))
      .then => @update()
      .catch console.error

    return
