{View} = require 'atom'

git = require '../git'

class BranchItem extends View
  @content: (branch) ->
    bklass = if branch.current then 'active' else ''
    cklass = if branch.count.total then '' else 'invisible'
    dclass = if branch.current or !branch.local then 'invisible' else ''

    console.log branch, dclass

    @div class: "branch #{bklass}", 'data-name': branch.name, =>
      @i class: 'icon chevron-right'
      @span class: 'clickable', click: 'click', branch.name
      @div class: "right-info #{dclass}", =>
        @i class: 'icon x clickable', click: 'delete'
      @div class: "right-info count #{cklass}", =>
        @span branch.count.ahead
        @i class: 'icon cloud-upload'
        @span branch.count.behind
        @i class: 'icon cloud-download'

  initialize: (branch) ->
    @branch = branch

  click: ->
    @branch.click(@branch.name)

  delete: ->
    @branch.delete(@branch.name)

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

  clearAll: ->
    @find('>.branch').remove()
    return

  addAll: (branches) ->
    @selectedBranch = git["get#{if @params.local then 'Local' else 'Remote'}Branch"]()
    @clearAll()

    click = (name) => @click(name)

    branches.forEach (branch) =>
      current = @params.local and branch is @selectedBranch
      count = total: 0

      if current
        count = git.count(branch)
        count.total = count.ahead + count.behind

        @parentView.branchCount(count)

      @append new BranchItem(name: branch, count: count, current: current, click: click, local: @params.local)
      return
    return

  click: (name) ->
    @parentView.checkoutBranch(name, !@params.local)
    return

  delete: (name) ->
    console.log 'deleting', name
