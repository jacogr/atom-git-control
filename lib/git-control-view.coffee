{View} = require 'atom'

git = require './git'

module.exports =
class GitControlView extends View
  @content: ->
    @div class: 'git-control', =>

      @div class: 'menu', outlet: 'menu', =>
        @div class: 'item inactive', =>
          @div class: 'icon compare'
          @div 'Compare'
        @div class: 'item', =>
          @div class: 'icon commit'
          @div 'Commit'
        @div class: 'item inactive', =>
          @div class: 'icon clone'
          @div 'Clone'
        @div class: 'item inactive', =>
          @div class: 'icon pull'
          @div 'Pull'
        @div class: 'item', =>
          @div class: 'icon push'
          @div 'Push'
        @div class: 'item inactive', =>
          @div class: 'icon merge'
          @div 'Merge'
        @div class: 'item inactive', =>
          @div class: 'icon branch'
          @div 'Branch'
        @div class: 'item inactive', =>
          @div class: 'icon tag'
          @div 'Tag'

      @div class: 'content', =>
        @div class: 'sidebar', =>
          @div class: 'heading', 'Local'
          @div class: 'branches', outlet: 'localBranches'
          @div class: 'heading', 'Remote'
          @div class: 'branches', outlet: 'remoteBranches'
        @div class: 'domain', outlet: 'content'

  serialize: ->

  initialize: ->
    console.log 'GitControlView: initialize'

    git.getRemoteBranches()
      .then (branches) =>
        for branch in branches
          @remoteBranches.append "<div class='branch'>#{branch.name}</div>"
      .catch (e) ->
        console.error e

    git.getLocalBranches()
      .then (branches) =>
        for branch in branches
          klass = "branch#{if branch.active then ' active' else ''}"
          @localBranches.append "<div class='#{klass}'>#{branch.name}</div>"
      .catch (e) ->
        console.error e

    return

  destroy: ->
    console.log 'GitControlView: destroy'
    return

  getTitle: ->
    return 'git:control'
