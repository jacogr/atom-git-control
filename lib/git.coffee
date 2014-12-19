git = require 'git-promise'
q = require 'q'

cwd = atom.project.getPath()

parseBranches = (data) -> q.fcall ->
  branches = []
  for branch in data.split('\n') when branch.length
    active = branch.indexOf('*') isnt -1
    branches.push
      name: branch.replace('*', '').trim()
      active: active

  return branches

parseDiff = (data) -> q.fcall ->
  diffs = []
  diff = {}
  for line in data.split('\n') when line.length
    switch
      when /^diff --git /.test(line)
        diff =
          lines: []
          added: 0
          removed: 0
        diff['diff'] = line.replace(/^diff --git /, '')
        diffs.push diff
      when /^index /.test(line)
        diff['index'] = line.replace(/^index /, '')
      when /^--- /.test(line)
        diff['---'] = line.replace(/^--- [a|b]\//, '')
      when /^\+\+\+ /.test(line)
        diff['+++'] = line.replace(/^\+\+\+ [a|b]\//, '')
      else
        diff['lines'].push line
        diff['added']++ if /^\+/.test(line)
        diff['removed']++ if /^-/.test(line)

  return diffs

parseStatus = (data) -> q.fcall ->
  console.log data
  files = []
  for line in data.split('\n') when line.length
    [type, name] = line.trim().split(' ')
    files.push
      name: name
      type: switch type
        when 'A' then 'added'
        when 'D' then 'deleted'
        when 'M' then 'modified'
        when '??' then 'new'
        else 'unknown'

  return files

callGit = (cmd, parser) ->
  return git cmd, cwd: cwd
    .then parser

module.exports =
  remoteBranches: ->
    return callGit 'branch -r', parseBranches

  localBranches: ->
    return callGit 'branch', parseBranches

  diff: (file) ->
    return callGit "--no-pager diff #{file or ''}", parseDiff

  status: ->
    return callGit 'status --porcelain', parseStatus
