ProjectDialog = require '../../lib/dialogs/project-dialog'

describe "ProjectDialog", ->
  projectDialog = null
  stashSaveSpy = null
  stashPopSpy = null
  gitControlView = null

  beforeEach ->
    projectDialog = new ProjectDialog()

  it "should correctly set projectList when repo path is unix-style", ->
    spyOn(atom.project, 'getRepositories').andReturn([{
      path:'/some/path/repository-name/.git'
    }]);
    projectDialog.activate()
    expect(projectDialog.projectList).toBeTruthy()
    expect(projectDialog.projectList.length).toBe(1)
    expect(projectDialog.projectList[0].textContent).toBe('repository-name')

  it "should correctly set projectList when repo path is windows-style", ->
    spyOn(atom.project, 'getRepositories').andReturn([{
      path:'c:\\some\\path\\repository-name\\.git'
    }]);
    projectDialog.activate()
    expect(projectDialog.projectList).toBeTruthy()
    expect(projectDialog.projectList.length).toBe(1)
    expect(projectDialog.projectList[0].textContent).toBe('repository-name')
