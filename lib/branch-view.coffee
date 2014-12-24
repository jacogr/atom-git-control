{View, $} = require 'atom'

git = require './git'

BranchViewItem = require './branch-view-item'

module.exports =
class BranchView extends View
  @content: (params) ->
    @div class: 'branches', =>
      @div class: 'heading', =>
        @i class: 'icon branch'
        @span params.name

  initialize: (params) ->
    @params = params
    @branches = []
    @view = $(@element)

  addAll: (branches) ->
    @selectedBranch = git["get#{if @params.local then 'Local' else 'Remote'}Branch"]()
    @view.find('>.branch').remove()

    click = (name) => @click(name)

    branches.forEach (branch) =>
      current = @params.local and branch is @selectedBranch
      count = klass: 'hidden'

      if current
        count = git.count(branch)
        count.total = count.ahead + count.behind
        count.klass = 'invisible' unless count.total

        @parentView.branchCount(count)

      @view.append new BranchViewItem(name: branch, count: count, current: current, click: click)
      return
    return

  click: (name) ->
    @parentView.checkoutBranch(name, !@params.local)
    return
