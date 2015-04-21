Dialog = require './dialog'

git = require '../git'

module.exports =
class FlowDialog extends Dialog
  @content: ->
    @div class: 'dialog', =>
      @div class: 'heading', =>
        @i class: 'icon x clickable', click: 'cancel'
        @strong 'Workflow - GitFlow'
      @div class: 'body', =>
        @label 'Git Flow '
        @select class: 'native-key-bindings', outlet: 'flowType', change: 'flowTypeChange'
        @select class: 'native-key-bindings', outlet: 'flowAction'
        @label 'Branch Name:'
        @input class: 'native-key-bindings', type: 'text', outlet: 'branchName'
      @div class: 'buttons', =>
        @button class: 'active', click: 'flow', =>
          @i class: 'icon flow'
          @span 'Ok'
        @button click: 'cancel', =>
          @i class: 'icon x'
          @span 'Cancel'

  activate: (branches) ->
    current = git.getLocalBranch()

    @flowType.find('option').remove()
    @flowType.append "<option value='feature'>feature</option>"
    @flowType.append "<option value='release'>release</option>"
    @flowType.append "<option value='hotfix'>hotfix</option>"
    @flowType.append "<option value='init'>init</option>"

    @flowAction.find('option').remove()
    @flowAction.append "<option value='start'>start</option>"
    @flowAction.append "<option value='finish'>finish</option>"
    @flowAction.append "<option value='publish'>publish</option>"
    @flowAction.append "<option value='pull'>pull</option>"

    return super()

  flow: ->
    @deactivate()
    #init with default branch name
    if (@flowType.val() == "init")
      @parentView.flow(@flowType.val(),'-d','')
    else
      @parentView.flow(@flowType.val(),@flowAction.val(),@branchName.val())

    return

  flowTypeChange: ->
    if (@flowType.val() == "init")
      @flowAction.hide()
    else
      @flowAction.show()
    return
