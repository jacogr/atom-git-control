Dialog = require './dialog'
git = require '../git'

module.exports =
class PushTagsDialog extends Dialog
  @content: ->
    @div class: 'dialog', =>
      @div class: 'heading', =>
        @i class: 'icon x clickable',click: 'cancel'
        @strong 'Push Tags'
      @div class: 'body', =>
        @button class: 'active', click: 'ptago',=>
          @i class: 'icon versions'
          @span 'Push tags to origin'
        @button class: 'active', click: 'ptagup',=>
          @i class: 'icon versions'
          @span 'Push tags to upstream'
        @button click: 'cancel', =>
          @i class: 'icon x'
          @span 'Cancel'


  ptago: ->
    @deactivate()
    remote = 'origin'
    @parentView.ptag(remote)

  ptagup: ->
    @deactivate()
    remote = 'upstream'
    @parentView.ptag(remote)
