git = require 'git-promise'
q = require 'q'

cwd = atom.project.getPath()

parseBranches = (data) ->
  branches = []
  for branch in data.split('\n') when branch.length
    active = branch.indexOf('*') isnt -1
    branches.push
      name: branch.replace('*', '').trim()
      active: active

  return branches

module.exports =
  getRemoteBranches: ->
    return git 'branch -r', cwd: cwd
      .then (data) ->
        return q.fcall -> parseBranches data

  getLocalBranches: ->
    return git 'branch', cwd: cwd
      .then (data) ->
        return q.fcall -> parseBranches data
