Dialog = require './dialog'

git = require '../git'

module.exports =
class ProjectDialog extends Dialog
  @content: ->
    @div class: 'dialog', =>
      @div class: 'heading', =>
        @i class: 'icon x clickable', click: 'cancel'
        @strong 'Project'
      @div class: 'body', =>
        @label 'Current Project'
        @select outlet: 'projectList'
      @div class: 'buttons', =>
        @button class: 'active', click: 'changeProject', =>
          @i class: 'icon icon-repo-pull'
          @span 'Change'
        @button click: 'cancel', =>
          @i class: 'icon x'
          @span 'Cancel'

  activate: ->
    projectIndex = 0
    projectList = @projectList
    projectList.html ''
    for repo in atom.project.getRepositories()
      do(repo) ->
        if repo
          option = document.createElement("option")
          option.value = projectIndex
          option.text = repo.path.split('/').reverse()[1]
          projectList.append(option)
        projectIndex = projectIndex + 1

    projectList.val(git.getProjectIndex)

    return super()

  changeProject: ->
    @deactivate()
    git.setProjectIndex(@projectList.val())
    repo = git.getRepository()

    @parentView.setWorkspaceTitle(repo.path.split('/').reverse()[1])
    @parentView.update()
    return
