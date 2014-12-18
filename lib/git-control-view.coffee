{View} = require 'atom'

git = require './git'

escapeHtml = (unsafe) ->
  return unsafe
    .replace(/&/g, "&amp;")
    .replace(/</g, "&lt;")
    .replace(/>/g, "&gt;")
    .replace(/"/g, "&quot;")
    .replace(/'/g, "&#039;");

module.exports =
class GitControlView extends View
  @content: ->
    @div class: 'git-control', =>

      @div class: 'menu', outlet: 'menu', =>
        @div class: 'item', id: 'menu-compare', click: 'clickCompare', =>
          @div class: 'icon compare'
          @div 'Compare'
        @div class: 'item inactive', id: 'menu-commit', click: 'clickCommit', =>
          @div class: 'icon commit'
          @div 'Commit'
        @div class: 'item inactive', id: 'menu-clone', =>
          @div class: 'icon clone'
          @div 'Clone'
        @div class: 'item inactive', id: 'menu-pull', =>
          @div class: 'icon pull'
          @div 'Pull'
        @div class: 'item inactive', id: 'menu-push', =>
          @div class: 'icon push'
          @div 'Push'
        @div class: 'item inactive', id: 'menu-merge', =>
          @div class: 'icon merge'
          @div 'Merge'
        @div class: 'item inactive', id: 'menu-branch', =>
          @div class: 'icon branch'
          @div 'Branch'
        @div class: 'item inactive', id: 'menu-tag', =>
          @div class: 'icon tag'
          @div 'Tag'

      @div class: 'content', =>
        @div class: 'sidebar', =>
          @div class: 'heading', 'Local'
          @div class: 'branches', outlet: 'localBranches'
          @div class: 'heading', 'Remote'
          @div class: 'branches', outlet: 'remoteBranches'
        @div class: 'domain', =>
          @div class: 'files', outlet: 'localFiles'
          @div class: 'diff', outlet: 'diff'

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
        klass = "branch#{if branch.active then ' active' else ''}"
        location.append "<div class='#{klass}'>#{branch.name}</div>"
      return

    git.remoteBranches()
      .then append(@remoteBranches)
      .catch console.error

    git.localBranches()
      .then append(@localBranches)
      .catch console.error

    return

  showStatus: ->
    git.status()
      .then (files) =>
        @localFiles.find('.file').remove()
        for file in files
          @localFiles.append "<div class='line'>#{file.name}</div>"
        return
      .catch console.error

  clickCompare: ->
    git.diff()
      .then (diffs) =>
        @diff.find('pre.line').remove()
        for diff in diffs
          for line in diff.lines
            klass = switch
              when /^-/.test(line) then 'red'
              when /^\+/.test(line) then 'green'
              else ''
            @diff.append "<pre class='line #{klass}'>#{escapeHtml line}</pre>"
        return
      .catch console.error

  clickCommit: (event, element) ->
