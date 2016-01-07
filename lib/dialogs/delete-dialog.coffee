Dialog = require './dialog'

module.exports =
class DeleteDialog extends Dialog
  @content: (params) ->
    @div class: 'dialog active', =>
      @div class: 'heading', =>
        @i class: 'icon x clickable', click: 'cancel'
        @strong params.hdr
      @div class: 'body', =>
        @div params.msg
      @div class: 'buttons', =>
        @button class: 'active', click: 'delete', =>
          @i class: 'icon check'
          @span 'Yes'
        @button click: 'cancel', =>
          @i class: 'icon x'
          @span 'No'
        @button class: 'warningText', click: 'forceDelete', =>
            @i class: 'icon trash'
            @span  'FORCE DELETE'

  initialize: (params) ->
    @params = params

  delete: ->
    @deactivate()
    @params.cb(@params)
    return

  forceDelete: ->
    @deactivate()
    @params.fdCb(@params)
    return
