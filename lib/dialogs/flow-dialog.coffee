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
        @select class: 'native-key-bindings', outlet: 'flowType'
        @select class: 'native-key-bindings', outlet: 'flowAction'
        @label 'Branch Name:'
        @input class: 'native-key-bindings', type: 'text', outlet: 'branchName'
      @div class: 'buttons', =>
        @button class: 'active', click: 'flowfeature', =>
          @i class: 'icon flowfeature'
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
    #@flowType.append "<option value='init'>init</option>"

    @flowAction.find('option').remove()
    @flowAction.append "<option value='start'>start</option>"
    @flowAction.append "<option value='finish'>finish</option>"
    @flowAction.append "<option value='publish'>publish</option>"
    @flowAction.append "<option value='pull'>pull</option>"

    return super()

  flowfeaturee: ->
    @deactivate()
    @parentView.flow(@flowType.val(),@flowAction.val(),@branchName.val());
    return
