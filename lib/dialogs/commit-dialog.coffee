Dialog = require './dialog'

module.exports =
class CommitDialog extends Dialog
  @content: ->
    @div class: 'dialog', =>
      @textarea class: 'native-key-bindings', outlet: 'msg'
      @button click: 'cancel', =>
        @i class: 'icon x'
        @span 'Cancel'
      @button class: 'active', click: 'commit', =>
        @i class: 'icon commit'
        @span 'Commit'

  activate: ->
    @msg.val('')
    return super()

  commit: ->
    @deactivate()
    @parentView.commit()
    return

  getMessage: ->
    return @msg.val()
