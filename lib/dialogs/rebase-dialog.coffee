Dialog = require './dialog'

git = require '../git'

module.exports =
class RebaseDialog extends Dialog
  @content: ->
    @div class: 'dialog', =>
      @div class: 'heading', =>
        @i class: 'icon x clickable', click: 'cancel'
        @strong 'Rebase'
      @div class: 'body', =>
        @label 'Current Branch'
        @input class: 'native-key-bindings', type: 'text', readonly: true, outlet: 'toBranch'
        @label 'Rebase On Branch'
        @select class: 'native-key-bindings', outlet: 'fromBranch'
        
      @div class: 'buttons', =>
        @button class: 'active', click: 'rebase', =>
          @i class: 'icon circuit-board'
          @span 'Rebase'
        @button click: 'cancel', =>
          @i class: 'icon x'
          @span 'Cancel'

  activate: (branches) ->
    current = git.getLocalBranch()

    @toBranch.val(current)
    @fromBranch.find('option').remove()

    for branch in branches when branch isnt current
      @fromBranch.append "<option value='#{branch}'>#{branch}</option>"

    return super()

  rebase: ->
    @deactivate()
    @parentView.rebase(@fromBranch.val())

    return
