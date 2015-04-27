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
        @select class: 'native-key-bindings', outlet: 'flowAction', change: 'flowActionChange'
        @label 'Branch Name:', outlet: 'labelBranchName'
        @input class: 'native-key-bindings', type: 'text', outlet: 'branchName'
        @select class: 'native-key-bindings', outlet: 'branchChoose'
      @div class: 'buttons', =>
        @button class: 'active', click: 'flow', =>
          @i class: 'icon flow'
          @span 'Ok'
        @button click: 'cancel', =>
          @i class: 'icon x'
          @span 'Cancel'

  activate: (branches) ->
    current = git.getLocalBranch()
    @branches = branches;

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

    @flowTypeChange()
    @flowActionChange()

    return super()

  flow: ->
    @deactivate()
    #init with default branch name
    if (@flowType.val() == "init")
      @parentView.flow(@flowType.val(),'-d','')
    else
      branchSelected = if (@branchName.val() != '') then @branchName.val() else @branchChoose.val();
      if(branchSelected? && branchSelected != '')
        @parentView.flow(@flowType.val(),@flowAction.val(),branchSelected)
      else
        git.alert "> No branches selected... Git flow action not valid."
    return

  flowTypeChange: ->
    if (@flowType.val() == "init")
      @flowAction.hide()
      @branchName.hide()
      @branchChoose.hide()
      @labelBranchName.hide()
    else
      @flowAction.show();
      @flowActionChange();
      @labelBranchName.show();
    return

  flowActionChange: ->
    if (@flowAction.val() != "start")
      @branchName.hide()
      @branchName.val('')
      @branchChoose.find('option').remove()
      for branch in @branches
        if (branch.indexOf(@flowType.val()) != -1 )
          value = branch.replace(@flowType.val()+'/','')
          @branchChoose.append "<option value='#{value}'>#{value}</option>"
      if (@branchChoose.find('option').length <= 0)
        @branchChoose.append "<option value=''> --no "+@flowType.val()+" branches--</option>"
      @branchChoose.show()
    else
      @branchName.show()
      @branchChoose.val('')
      @branchChoose.hide()
