Dialog = require './dialog'

git = require '../git'

module.exports =
class MergeDialog extends Dialog
  @content: ->
    @div class: 'dialog', =>
      @div class: 'heading', =>
        @i class: 'icon x clickable', click: 'cancel'
        @strong 'Merge'
      @div class: 'body', =>
        @label 'Current Branch'
        @input class: 'native-key-bindings', type: 'text', readonly: true, outlet: 'toBranch'
        @label 'Merge From Branch'
        @select class: 'native-key-bindings', outlet: 'fromBranch'
        @div =>
          @input type: 'checkbox',class: 'checkbox',outlet: 'noff'
          @label 'No Fast-Forward'
      @div class: 'buttons', =>
        @button class: 'active', click: 'merge', =>
          @i class: 'icon merge'
          @span 'Merge'
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

  merge: ->
    @deactivate()
    @parentView.merge(@fromBranch.val(),@noFF())
    return

  noFF: ->
     return @noff.is(':checked')
