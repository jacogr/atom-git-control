{View, $, $$} = require 'atom'

git = require './git'

menuItems = [
  { id: 'compare', menu: 'Compare', icon: 'compare', type: 'file'}
  { id: 'commit', menu: 'Commit', icon: 'commit', type: 'file'}
  { id: 'reset', menu: 'Reset', icon: 'sync', type: 'file'}
  #{ id: 'clone', menu: 'Clone', icon: 'clone'}
  { id: 'fetch', menu: 'Fetch', icon: 'cloud-download', type: 'active'}
  { id: 'pull', menu: 'Pull', icon: 'pull', type: 'upstream'}
  { id: 'push', menu: 'Push', icon: 'push', type: 'downstream'}
  { id: 'merge', menu: 'Merge', icon: 'merge'}
  { id: 'branch', menu: 'Branch', icon: 'branch'}
  { id: 'tag', menu: 'Tag', icon: 'tag'}
]

module.exports =
class GitControlView extends View
  @content: ->
    @div class: 'git-control', =>
      @div class: 'menu', outlet: 'menuView'

      @div class: 'content', =>
        @div class: 'sidebar', =>

          @div class: 'files', outlet: 'filesView', =>
            @div class: 'heading', =>
              @i class: 'icon forked'
              @span 'Workspace'
              @div class: 'action', click: 'selectAllFiles', =>
                @span 'Select'
                @i class: 'icon check'
                @input class: 'invisible', type: 'checkbox', outlet: 'allFilesCb'

          @div class: 'branches', outlet: 'localBranchView', =>
            @div class: 'heading', =>
              @i class: 'icon branch'
              @span 'Local'
              @div class: 'action', =>
                @span 'Select'
                @i class: 'icon chevron-down'

          @div class: 'branches', outlet: 'remoteBranchView', =>
            @div class: 'heading', =>
              @i class: 'icon branch'
              @span 'Remote'
              @div class: 'action', =>
                @span 'Select'
                @i class: 'icon chevron-down'

        @div class: 'domain', =>
          @div class: 'diff', outlet: 'diffView'
          @div class: 'commit-msg', outlet: 'commitView', =>
            @textarea class: 'native-key-bindings', outlet: 'commitMsg'
            @button click: 'commitCancel', =>
              @i class: 'icon x'
              @span 'Cancel'
            @button class: 'active', click: 'commitPost', =>
              @i class: 'icon commit'
              @span 'Commit'

      @div class: 'logger', outlet: 'logView'

  serialize: ->

  initialize: ->
    console.log 'GitControlView: initialize'

    git.setLogger (log, iserror) => @log(log, iserror)

    @active = true
    @branchSelected = null
    @files = {}

    @createMenu()

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

  addMenuItem: (item) ->
    id = item.id
    active = if item.type is 'active' then '' else 'inactive'

    @menuView.append $$ ->
      @div class: "item #{active} type-#{item.type}", id: "menu#{id}", =>
        @div class: "icon large #{item.icon}"
        @div item.menu

    @menuView.find(".item#menu#{id}").toArray().forEach (item) =>
      $(item).on 'click', => @["#{id}MenuClick"]()
      return
    return

  createMenu: ->
    for item in menuItems
      @addMenuItem(item)
    return

  loadLog: ->
    git.log(@selectedBranch).then (logs) ->
      console.log 'git.log', logs
      return
    return

  loadBranches: ->
    @selectedBranch = git.getLocalBranch()

    append = (location, branches, local) =>
      location.find('>.branch').remove()
      for branch in branches
        current = branch is @selectedBranch
        klass = if current then 'active' else ''
        count = klass: 'hidden'

        if local and current
          count = git.count(branch)
          count.total = count.ahead + count.behind
          count.klass = 'hidden' unless count.total

          @activateMenu('upstream', count.behind)
          @activateMenu('downstream', count.ahead)

        location.append $$ ->
          @div class: "branch #{klass}", =>
            @i class: 'icon chevron-right'
            @span branch
            @div class: "count #{count.klass}", =>
              @span count.ahead
              @i class: 'icon cloud-upload'
              @span count.behind
              @i class: 'icon cloud-download'

      return

    git.getBranches().then (branches) =>
      append(@remoteBranchView, branches.remote)
      append(@localBranchView, branches.local, true)
      return

    return

  activateMenu: (type, active) ->
    menuItems = @menuView.find(".item.type-#{type}")
    if active
      menuItems.removeClass('inactive')
    else
      menuItems.addClass('inactive')
    return

  hasSelectedFiles: ->
    for name, file of @files when file.selected
      return true

    return false

  showSelectedFiles: ->
    fnames = []
    for div in @filesView.find('.file').toArray()
      f = $(div)
      name = f.attr('data-name')

      if @files[name].selected
        fnames.push name
        f.addClass('active')
      else
        f.removeClass('active')

    for name, file of @files
      unless name in fnames
        file.selected = false

    @activateMenu('file', @hasSelectedFiles())

    return

  selectAllFiles: ->
    val = !!!@allFilesCb.prop('checked')
    @allFilesCb.prop('checked', val)

    for name, file of @files
      file.selected = val

    @showSelectedFiles()
    return

  selectFile: (name) ->
    if name
      @files[name].selected = !!!@files[name].selected

    @allFilesCb.prop('checked', false)
    @showSelectedFiles()
    return

  addFile: (file) ->
    @files[file.name] or= name: file.name
    @files[file.name].type = file.type

    @filesView.append $$ ->
      @div class: "file #{file.type}", 'data-name': file.name, =>
        @i class: 'icon check'
        @i class: "icon file-#{file.type}"
        @span file.name

    for div in @filesView.find(".file[data-name='#{file.name}']").toArray()
      $(div).on 'click', => @selectFile(file.name)

    return

  showStatus: ->
    git.status().then (files) =>
      fnames = []
      @filesView.find('.file').remove()

      if files.length
        @filesView.removeClass('none')

        for file in files
          fnames.push file.name
          @addFile(file)

      else
        @filesView.addClass('none')
        @filesView.append $$ ->
          @div class: 'file deleted', 'No local working copy changes detected'

      for name, file of @files
        unless name in fnames
          file.selected = false

      @showSelectedFiles()
      return
    return

  compareMenuClick: ->
    return unless @hasSelectedFiles()

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
    return unless @hasSelectedFiles()

    @commitView.addClass('active')
    @commitMsg.val('')
    return

  commitCancel: ->
    @commitView.removeClass('active')
    return

  commitPost: ->
    @commitCancel()
    return unless @hasSelectedFiles()

    msg = @commitMsg.val()
    files =
      all: []
      add: []
      rem: []

    for name, file of @files when file.selected
      files.all.push name
      switch file.type
        when 'new' then files.add.push name
        when 'deleted' then files.rem.push name

    for name in files.all
      @files[name].selected = false

    git.add(files.add)
      .then -> git.remove(files.rem)
      .then -> git.commit(files.all, msg)
      .then => @update()
    return

  fetchMenuClick: ->
    git.fetch().then =>
      @update(true)
      return
    return

  pullMenuClick: ->
    git.pull().then =>
      @update(true)
      return
    return

  pushMenuClick: ->
    git.push().then =>
      @update(true)
      return
    return

  resetMenuClick: ->
    return unless @hasSelectedFiles()

    files = []
    for f in @filesSelected
      files.push f.name

    git.reset(files).then =>
      @update()
      return

    return
