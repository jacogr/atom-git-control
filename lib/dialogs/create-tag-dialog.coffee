Dialog = require './dialog'

module.exports =
class CreateTagDialog extends Dialog
  @content: ->
    @div class: 'dialog', =>
      @div class: 'heading', =>
        @i class: 'icon x clickable', click: 'cancel'
        @strong 'Tag'
      @div class: 'body', =>
        @label 'Tag name'
        @input class: 'native-key-bindings', type: 'text', outlet: 'name'
        @label 'commit ref'
        @input class: 'native-key-bindings', type: 'text', outlet: 'href'
        @label 'Tag Message'
        @textarea class: 'native-key-bindings', outlet: 'msg'
      @div class: 'buttons', =>
        @button class: 'active', click: 'tag', =>
          @i class: 'icon tag'
          @span 'Create Tag'
        @button click: 'cancel', =>
          @i class: 'icon x'
          @span 'Cancel'

  tag: ->
    @deactivate()
    @parentView.tag(@Name(), @Href(), @Msg())
    return

  Name: ->
    return @name.val()

  Href: ->
    return @href.val()

  Msg: ->
    return @msg.val()
