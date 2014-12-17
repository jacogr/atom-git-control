{View} = require 'atom'

module.exports =
class GitControlView extends View
  @content: ->
    @div class: 'git-control', =>
      @div class: 'menu', outlet: 'menu', =>
        @div class: 'item', 'An item'
        @div class: 'item', 'Another item'
      @div class: 'content', =>
        @div class: 'sidebar', =>
          @div class: 'branch', =>
            @strong 'Local'
            @ul outlet: 'localBranches', =>
              @li 'master'
          @div class: 'branch', =>
            @strong 'Remote'
            @ul outlet: 'remoteBranches', =>
              @li 'master'
        @div class: 'domain', outlet: 'content'

  serialize: ->

  initialize: ->
    console.log 'GitControlView: initialize'
    return

  destroy: ->
    console.log 'GitControlView: destroy'
    return

  getTitle: ->
    return 'git:control'
