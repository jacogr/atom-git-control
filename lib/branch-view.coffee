{View, $} = require 'atom'

BranchViewItem = require './branch-view-item'

module.exports =
class BranchView extends View
  @content: (params) ->
    @div class: 'branches', =>
      @div class: 'heading', =>
        @i class: 'icon branch'
        @span params.name

  initialize: ->
    @branches = []
    @view = $(@element)
