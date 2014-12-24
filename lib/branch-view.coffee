{View} = require 'atom'

git = require './git'

class BranchItem extends View
  @content: (params) ->
    klass = if params.current then 'active' else ''

    @div class: "branch #{klass}", 'data-name': params.name, =>
      @i class: 'icon chevron-right'
      @span class: 'clickable', click: 'click', params.name
      @div class: "right-info count #{params.count.klass}", =>
        @span params.count.ahead
        @i class: 'icon cloud-upload'
        @span params.count.behind
        @i class: 'icon cloud-download'

  initialize: (params) ->
    @branch = params

  click: ->
    @branch.click(@branch.name)

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

  addAll: (branches) ->
    @selectedBranch = git["get#{if @params.local then 'Local' else 'Remote'}Branch"]()
    @find('>.branch').remove()

    click = (name) => @click(name)

    branches.forEach (branch) =>
      current = @params.local and branch is @selectedBranch
      count = klass: 'hidden'

      if current
        count = git.count(branch)
        count.total = count.ahead + count.behind
        count.klass = 'invisible' unless count.total

        @parentView.branchCount(count)

      @append new BranchItem(name: branch, count: count, current: current, click: click)
      return
    return

  click: (name) ->
    @parentView.checkoutBranch(name, !@params.local)
    return
