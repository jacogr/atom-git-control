git = require '../../lib/git'
FlowDialog = require '../../lib/dialogs/flow-dialog'

describe "FlowDialog", ->
  flowDialog = null
  stashSaveSpy = null
  stashPopSpy = null
  gitControlView = null

  beforeEach ->
    flowDialog = new FlowDialog()
    spyOn(git, 'getLocalBranch').andReturn('master');
    flowDialog.activate(['master'])

  it "should not show 'No Tag' option when 'init' flow type is selected", ->
    flowDialog.flowType.val('init')
    flowDialog.flowTypeChange()
    expect(flowDialog.noTag.css('display')).toBe('none');
    expect(flowDialog.labelNoTag.css('display')).toBe('none');

  it "should not show 'No Tag' option when 'feature' flow type is selected", ->
    flowDialog.flowType.val('feature')
    flowDialog.flowTypeChange()
    expect(flowDialog.noTag.css('display')).toBe('none');
    expect(flowDialog.labelNoTag.css('display')).toBe('none');

  it "should not show 'No Tag' option when 'hotfix' type and 'start' flow action is selected", ->
    flowDialog.flowType.val('hotfix')
    flowDialog.flowTypeChange()
    flowDialog.flowAction.val('start')
    flowDialog.flowActionChange()
    expect(flowDialog.noTag.css('display')).toBe('none');
    expect(flowDialog.labelNoTag.css('display')).toBe('none');

  it "should not show 'No Tag' option when 'hotfix' type and 'publish' flow action is selected", ->
    flowDialog.flowType.val('hotfix')
    flowDialog.flowTypeChange()
    flowDialog.flowAction.val('publish')
    flowDialog.flowActionChange()
    expect(flowDialog.noTag.css('display')).toBe('none');
    expect(flowDialog.labelNoTag.css('display')).toBe('none');

  it "should not show 'No Tag' option when 'hotfix' type and 'pull' flow action is selected", ->
    flowDialog.flowType.val('hotfix')
    flowDialog.flowTypeChange()
    flowDialog.flowAction.val('pull')
    flowDialog.flowActionChange()
    expect(flowDialog.noTag.css('display')).toBe('none');
    expect(flowDialog.labelNoTag.css('display')).toBe('none');

  it "should not show 'No Tag' option when 'release' type and 'start' flow action is selected", ->
    flowDialog.flowType.val('release')
    flowDialog.flowTypeChange()
    flowDialog.flowAction.val('start')
    flowDialog.flowActionChange()
    expect(flowDialog.noTag.css('display')).toBe('none');
    expect(flowDialog.labelNoTag.css('display')).toBe('none');

  it "should not show 'No Tag' option when 'release' type and 'publish' flow action is selected", ->
    flowDialog.flowType.val('release')
    flowDialog.flowTypeChange()
    flowDialog.flowAction.val('publish')
    flowDialog.flowActionChange()
    expect(flowDialog.noTag.css('display')).toBe('none');
    expect(flowDialog.labelNoTag.css('display')).toBe('none');

  it "should not show 'No Tag' option when 'release' type and 'pull' flow action is selected", ->
    flowDialog.flowType.val('release')
    flowDialog.flowTypeChange()
    flowDialog.flowAction.val('pull')
    flowDialog.flowActionChange()
    expect(flowDialog.noTag.css('display')).toBe('none');
    expect(flowDialog.labelNoTag.css('display')).toBe('none');

  it "should show 'No Tag' option when 'hotfix' type and 'finish' flow action is selected", ->
    flowDialog.flowType.val('hotfix')
    flowDialog.flowTypeChange()
    flowDialog.flowAction.val('finish')
    flowDialog.flowActionChange()
    expect(flowDialog.noTag.css('display')).not.toBe('none');
    expect(flowDialog.labelNoTag.css('display')).not.toBe('none');

  it "should show 'No Tag' option when 'release' type and 'finish' flow action is selected", ->
    flowDialog.flowType.val('release')
    flowDialog.flowTypeChange()
    flowDialog.flowAction.val('finish')
    flowDialog.flowActionChange()
    expect(flowDialog.noTag.css('display')).not.toBe('none');
    expect(flowDialog.labelNoTag.css('display')).not.toBe('none');

  it "should hide the 'No Tag' option when switched away from 'finish' flow action", ->
    flowDialog.flowType.val('release')
    flowDialog.flowTypeChange()
    flowDialog.flowAction.val('finish')
    flowDialog.flowActionChange()
    expect(flowDialog.noTag.css('display')).not.toBe('none');
    expect(flowDialog.labelNoTag.css('display')).not.toBe('none');
    flowDialog.flowAction.val('start')
    flowDialog.flowActionChange()
    expect(flowDialog.noTag.css('display')).toBe('none');
    expect(flowDialog.labelNoTag.css('display')).toBe('none');

  it "should call git with -n option when 'No tag' is checked", ->
    flowDialog.flowType.val('release')
    flowDialog.flowTypeChange()
    flowDialog.flowAction.val('finish')
    flowDialog.flowActionChange()
    flowDialog.branchName.val('master')
    flowDialog.noTag.click()
    flowSpy = jasmine.createSpy('flow')
    flowDialog.parentView =
      flow: flowSpy
    flowDialog.flow()
    expect(flowSpy).toHaveBeenCalledWith('release', 'finish -n', 'master');

  it "should call git without -n option when 'No tag' is not checked", ->
    flowDialog.flowType.val('release')
    flowDialog.flowTypeChange()
    flowDialog.flowAction.val('finish')
    flowDialog.flowActionChange()
    flowDialog.branchName.val('master')
    flowSpy = jasmine.createSpy('flow')
    flowDialog.parentView =
      flow: flowSpy
    flowDialog.flow()
    expect(flowSpy).toHaveBeenCalledWith('release', 'finish', 'master');
