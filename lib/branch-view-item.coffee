{View} = require 'atom'

module.exports =
class BranchViewItem extends View
  @content: (params) ->
    @div class: "file #{params.type}", 'data-name': params.name, =>
      @i class: 'icon check'
      @i class: "icon file-#{params.type}"
      @span class: 'clickable', click: 'click', params.name

  initialize: (params) ->
    @branch = params

  click: ->
    @branch.click(@branch.name)
