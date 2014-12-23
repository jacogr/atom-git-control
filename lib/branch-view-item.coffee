{View} = require 'atom'

module.exports =
class BranchViewItem extends View
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
