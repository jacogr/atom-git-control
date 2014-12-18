{View, $$} = require 'atom'

git = require './git'

module.exports =
class GitControlView extends View
  @content: ->
    @div class: 'git-control', =>

      @div class: 'menu', outlet: 'menu', =>
        @div class: 'item', id: 'menu-compare', click: 'clickCompare', =>
          @div class: 'icon large compare'
          @div 'Compare'
        @div class: 'item inactive', id: 'menu-commit', click: 'clickCommit', =>
          @div class: 'icon large commit'
          @div 'Commit'
        @div class: 'item inactive', id: 'menu-clone', =>
          @div class: 'icon large clone'
          @div 'Clone'
        @div class: 'item inactive', id: 'menu-pull', =>
          @div class: 'icon large pull'
          @div 'Pull'
        @div class: 'item inactive', id: 'menu-push', =>
          @div class: 'icon large push'
          @div 'Push'
        @div class: 'item inactive', id: 'menu-merge', =>
          @div class: 'icon large merge'
          @div 'Merge'
        @div class: 'item inactive', id: 'menu-branch', =>
          @div class: 'icon large branch'
          @div 'Branch'
        @div class: 'item inactive', id: 'menu-tag', =>
          @div class: 'icon large tag'
          @div 'Tag'

      @div class: 'content', =>
        @div class: 'sidebar', =>

          @div class: 'heading', =>
            @i class: 'icon forked'
            @span 'Workspace'
          @div class: 'files', outlet: 'viewFiles'

          @div class: 'heading', =>
            @i class: 'icon branch'
            @span 'Local'
          @div class: 'branches', outlet: 'viewLocalBranches'

          @div class: 'heading', =>
            @i class: 'icon branch'
            @span 'Remote'
          @div class: 'branches', outlet: 'viewRemoteBranches'

        @div class: 'domain', =>
          @div class: 'diff', outlet: 'viewDiff'

  serialize: ->

  initialize: ->
    console.log 'GitControlView: initialize'
    @active = true
    @loadBranches()
    return

  destroy: ->
    console.log 'GitControlView: destroy'
    @active = false
    return

  getTitle: ->
    return 'git:control'

  loadBranches: ->
    append = (location) -> (branches) ->
      location.find('.branch').remove()
      for branch in branches
        klass = if branch.active then 'active' else ''
        location.append $$ ->
          @div class: "branch #{klass}", branch.name
      return

    git.remoteBranches()
      .then append(@viewRemoteBranches)
      .catch console.error

    git.localBranches()
      .then append(@viewLocalBranches)
      .catch console.error

    return

  showStatus: ->
    git.status()
      .then (files) =>
        @viewFiles.find('.file').remove()
        for file in files
          @viewFiles.append $$ ->
            @div class: "file #{file.type}", =>
              @input type: 'checkbox'
              @i class: "icon file-#{file.type}"
              @span file.name
        return
      .catch console.error

  clickCompare: ->
    fmtNum = (num) ->
      return "     #{num or ''} ".slice(-6)

    git.diff()
      .then (diffs) =>
        @viewDiff.find('.line').remove()
        for diff in diffs
          @viewDiff.append $$ ->
            @div class: 'line heading', =>
              #@pre class: 'lineno', "#{fmtNum 0}#{fmtNum 0}"
              @pre "#{diff['+++']}"
            #@div class: 'line green', =>
              #@pre class: 'lineno', "#{fmtNum 0}#{fmtNum 0}"
              #@pre "#{diff['+++']}"

          noa = 0
          nob = 0

          for line in diff.lines
            if /^@@ /.test(line)
              # @@ -100,11 +100,13 @@
              [atstart, linea, lineb, atend] = line.replace(/-|\+/g, '').split(' ')
              noa = parseInt(linea, 10)
              nob = parseInt(lineb, 10)
              @viewDiff.append $$ ->
                @div class: 'line subtle', =>
                  #@pre class: 'lineno', "#{fmtNum 0}#{fmtNum 0}"
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

              @viewDiff.append $$ ->
                @div class: "line #{klass}", =>
                  @pre class: 'lineno', lineno
                  @pre line

        return
      .catch console.error

  clickCommit: (event, element) ->
