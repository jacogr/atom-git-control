Dialog = require './dialog'
git = require '../git'

module.exports =
class PushTagsDialog extends Dialog
  @content: ->
    @div class: 'dialog', =>
      @div class: 'heading', =>
        @i class: 'icon x clickable',click: 'cancel'
        @strong 'Push'
      @div class: 'body', =>
        @button click: 'ptago',=>
          @p 'Push tags to origin', =>
            @i class: 'icon versions'
        @button click: 'ptagup',=>
          @p 'Push tags to upstream', =>
            @i class: 'icon versions'
        @button click: 'cancel', =>
          @i class: 'icon x'
          @span 'Cancel'


  Ptago: ->
    @deactivate()
    @parentView.ptag('origin')

  Ptagup: ->
    @deactivate()
    @parentView.push('upstream')
