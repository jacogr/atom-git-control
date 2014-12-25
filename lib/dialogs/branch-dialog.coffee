Dialog = require './dialog'

git = require '../git'

module.exports =
class BranchDialog extends Dialog
  @content: ->
    @div class: 'dialog', =>
      @div class: 'heading', =>
        @i class: 'icon x clickable', click: 'cancel'
        @strong 'Branch'
      @div class: 'body', =>
        @label 'Current Branch'
        @input class: 'native-key-bindings', type: 'text', readonly: true, outlet: 'fromBranch'
        @label 'New Branch'
        @input class: 'native-key-bindings', type: 'text', outlet: 'toBranch'
      @div class: 'buttons', =>
        @button class: 'active', click: 'branch', =>
          @i class: 'icon branch'
          @span 'Branch'
        @button click: 'cancel', =>
          @i class: 'icon x'
          @span 'Cancel'

  activate: ->
    @fromBranch.val(git.getLocalBranch())
    @toBranch.val('')
    return super()

  branch: ->
    @deactivate()
    @parentView.createBranch(@toBranch.val())
    return
