Dialog = require './dialog'

git = require '../git'

module.exports =
class MidrebaseDialog extends Dialog
  @content: ->
    @div class: 'dialog', =>
      @div class: 'heading', =>
        @i class: 'icon x clickable', click: 'cancel'
        @strong 'It appears that you are in the middle of a rebase, would you like to:'
      @div class: 'body', =>
        @label 'Continue the rebase'
        @input type: 'checkbox',class: 'checkbox',outlet: 'contin'
        @div =>
          @label 'Abort the rebase'
          @input type: 'checkbox',class: 'checkbox',outlet: 'abort'
        @div =>
          @label 'Skip the patch'
          @input type: 'checkbox',class: 'checkbox',outlet: 'skip'
      @div class: 'buttons', =>
        @button class: 'active', click: 'midrebase', =>
          @i class: 'icon circuit-board'
          @span 'Rebase'
        @button click: 'cancel', =>
          @i class: 'icon x'
          @span 'Cancel'

  midrebase: ->
    @deactivate()
    @parentView.midrebase(@Contin(),@Abort(),@Skip())
    return

  Contin: ->
    return @contin.is(':checked')

  Abort: ->
    return @abort.is(':checked')

  Skip: ->
    return @skip.is(':checked')
