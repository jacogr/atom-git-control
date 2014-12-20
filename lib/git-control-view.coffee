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
            @textarea outlet: 'commitMsg'
            @button click: 'commitCancel', 'Cancel'
            @button class: 'active', click: 'commitPost', 'Commit'

      @div class: 'logger', outlet: 'logView'

  serialize: ->

  initialize: ->
    console.log 'GitControlView: initialize'

    git.setLogger (log, iserror) => @log(log, iserror)

    @active = true
    @branchSelected = null
    @files = {}
    @count = 900000
    @filesSelected = []

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

  selectAllFiles: ->
    val = !!!@allFilesCb.prop('checked')
    @allFilesCb.prop('checked', val)

    @filesSelected = []

    for input in @filesView.find(".file input").toArray()
      cb = $(input)
      cb.prop('checked', val)
      if val
        @filesSelected.push @files[cb.attr('id')]

    @activateMenu('file', @filesSelected.length)
    return

  selectFile: ->
    @filesSelected = []
    @allFilesCb.prop('checked', false)

    for input in @filesView.find(".file input").toArray()
      cb = $(input)
      if !!cb.prop('checked')
        @filesSelected.push @files[cb.attr('id')]

    return

  addFile: (file) ->
    id = undefined
    for f in @files when file.name is f.name
      id = f.id

    id = "file#{@count++}" unless id
    file.id = id
    @files[id] = file

    @filesView.append $$ ->
      @div class: "file #{file.type}", =>
        @input type: 'checkbox', id: id, 'data-name': file.name
        @i class: "icon file-#{file.type}"
        @span file.name

    for input in @filesView.find(".file input##{id}").toArray()
      $(input).on 'change', => @selectFile()

    return

  showStatus: ->
    oldSelected = @filesSelected
    @filesSelected = []

    git.status().then (files) =>
      @filesView.find('.file').remove()

      if files.length
        @filesView.removeClass('none')

        for file in files
          @addFile(file)

        for input in @filesView.find(".file input").toArray()
          input = $(input)
          name = input.attr('data-name')

          for sel in oldSelected when sel.name is name
            input.prop('checked', true)
            @filesSelected.push @files[input.attr('id')]

      else
        @filesView.addClass('none')
        @filesView.append $$ ->
          @div class: 'file deleted', 'No local working copy changes detected'

      @activateMenu('file', @filesSelected.length)
      return
    return

  compareMenuClick: ->
    return unless @filesSelected.length

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
    return unless @filesSelected.length

    @commitView.addClass('active')
    @commitMsg.val('')
    return

  commitCancel: ->
    @commitView.removeClass('active')
    return

  commitPost: ->
    @commitCancel()
    return unless @filesSelected.length

    msg = @commitMsg.val()
    files =
      all: []
      add: []
      rem: []

    for file in @filesSelected
      files.all.push file.name
      switch file.type
        when 'new' then files.add.push file.name
        when 'deleted' then files.rem.push file.name

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
    return unless @filesSelected.length

    files = []
    for f in @filesSelected
      files.push f.name

    git.reset(files).then =>
      @update()
      return

    return
