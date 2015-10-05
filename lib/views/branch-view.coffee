{View} = require 'atom-space-pen-views'

git = require '../git'

class BranchItem extends View
  @content: (branch) ->
    bklass = if branch.current then 'active' else ''
    cklass = if branch.count.total then '' else 'invisible'
    dclass = if branch.current or !branch.local then 'invisible' else ''

    @div class: "branch #{bklass}", 'data-name': branch.name, =>
      @div class: 'info', =>
        @i class: 'icon chevron-right'
        @span class: 'clickable', click: 'checkout', branch.name
      @div class: "right-info #{dclass}", =>
        @i class: 'icon trash clickable', click: 'deleteThis'
      @div class: "right-info count #{cklass}", =>
        @span branch.count.ahead
        @i class: 'icon cloud-upload'
        @span branch.count.behind
        @i class: 'icon cloud-download'

  initialize: (branch) ->
    @branch = branch

  checkout: ->
    @branch.checkout(@branch.name)

  deleteThis: ->
    @branch.delete(@branch.name)

module.exports =
class BranchView extends View
  @content: (params) ->
    @div class: 'branches', =>
      @div click: 'toggleBranch', class: 'heading clickable', =>
        @i class: 'icon branch'
        @span params.name

  initialize: (params) ->
    @params = params
    @branches = []
    @hidden = false

  toggleBranch : ->
    if @hidden then @addAll @branches else do @clearAll
    @hidden = !@hidden

  clearAll: ->
    @find('>.branch').remove()
    return

  addAll: (branches) ->
    @branches = branches
    @selectedBranch = git["get#{if @params.local then 'Local' else 'Remote'}Branch"]()
    @clearAll()

    remove = (name) => @deleteBranch(name)
    checkout = (name) => @checkoutBranch(name)

    branches.forEach (branch) =>
      current = @params.local and branch is @selectedBranch
      count = total: 0

      if current
        count = git.count(branch)
        count.total = count.ahead + count.behind

        @parentView.branchCount(count)

      @append new BranchItem
        name: branch
        count: count
        current: current
        local: @params.local
        delete: remove
        checkout: checkout

      return
    return

  checkoutBranch: (name) ->
    @parentView.checkoutBranch(name, !@params.local)
    return

  deleteBranch: (name) ->
    @parentView.deleteBranch(name)
    return
