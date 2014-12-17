{View} = require 'atom'

git = require './git'

module.exports =
class GitControlView extends View
  @content: ->
    @div class: 'git-control', =>
      @div class: 'menu', outlet: 'menu', =>
        @div class: 'item', 'An item'
        @div class: 'item', 'Another item'
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
