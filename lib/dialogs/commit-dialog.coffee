Dialog = require './dialog'

module.exports =
class CommitDialog extends Dialog
  @content: ->
    @div class: 'dialog', =>
      @div class: 'heading', =>
        @i class: 'icon x clickable', click: 'cancel'
        @strong 'Commit'
      @div class: 'body', =>
        @label 'Commit Message'
        @textarea class: 'native-key-bindings', outlet: 'msg', keyUp: 'colorLength'
      @div class: 'buttons', =>
        @button class: 'active', click: 'commit', =>
          @i class: 'icon commit'
          @span 'Commit'
        @button click: 'cancel', =>
          @i class: 'icon x'
          @span 'Cancel'

  activate: ->
    @msg.val('')
    return super()

  colorLength: ->
    if @msg.val().length > 50
      @msg.addClass('over-fifty')
    else
      @msg.removeClass('over-fifty')

  commit: ->
    @deactivate()
    @parentView.commit()
    return

  getMessage: ->
    return @msg.val()
