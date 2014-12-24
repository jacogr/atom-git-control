Dialog = require './dialog'

module.exports =
class ConfirmDialog extends Dialog
  @content: (params) ->
    @div class: 'dialog active', =>
      @div class: 'heading', =>
        @i class: 'icon x clickable', click: 'cancel'
        @strong params.hdr
      @div class: 'body', =>
        @div params.msg
      @div class: 'buttons', =>
        @button class: 'active', click: 'confirm', =>
          @i class: 'icon check'
          @span 'Yes'
        @button click: 'cancel', =>
          @i class: 'icon x'
          @span 'No'

  initialize: (params) ->
    @params = params

  confirm: ->
    @deactivate()
    @params.cb(@params)
    return
