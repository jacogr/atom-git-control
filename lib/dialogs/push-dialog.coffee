Dialog = require './dialog'
git = require '../git'

module.exports =
class PushDialog extends Dialog
  @content: ->
    @div class: 'dialog', =>
      @div class: 'heading', =>
        @i class: 'icon x clickable',click: 'cancel'
        @strong 'Push'
      @div class: 'body', =>
        @div =>
          @button click: 'upstream',=>
            @p 'Push upstream', =>
              @i class: 'icon push'
        @label 'Push from branch'
        @input class: 'native-key-bindings',readonly: true,outlet: 'fromBranch'
        @label 'To branch'
        @select class: 'native-key-bindings',outlet: 'toBranch'
      @div class: 'buttons', =>
        @button class: 'active', click: 'push', =>
          @i class: 'icon push'
          @span 'Push'
        @button click: 'cancel', =>
          @i class: 'icon x'
          @span 'Cancel'

  activate: (remotes) ->
    @fromBranch.val(git.getLocalBranch())
    @toBranch.find('option').remove()
    # add simple origin branch
    @toBranch.append "<option value='origin'>origin</option>"
    for remote in remotes
      @toBranch.append "<option value='#{remote}'>#{remote}</option>"
    return super()

  push: ->
    @deactivate()
    remote = @toBranch.val().split('/')[0]
    # branch = @toBranch.val().split('/')[1]
    branch = git.getLocalBranch()
    @parentView.push(remote,branch)
    return

  upstream: ->
    @deactivate()
    @parentView.push('','')
