Dialog = require './dialog'

git = require '../git'

module.exports =
class BranchDialog extends Dialog
  @content: ->
    @div class: 'dialog', =>
      @label 'Current Branch'
      @input class: 'native-key-bindings', type: 'text', readonly: true, outlet: 'fromBranch'
      @label 'New Branch'
      @input class: 'native-key-bindings', type: 'text', outlet: 'toBranch'
      @button click: 'cancel', =>
        @i class: 'icon x'
        @span 'Cancel'
      @button class: 'active', click: 'branch', =>
        @i class: 'icon branch'
        @span 'Branch'

  activate: ->
    @fromBranch.val(git.getLocalBranch())
    @toBranch.val('')
    return super()

  branch: ->
    @deactivate()
    #@parentView.commit()
    return
