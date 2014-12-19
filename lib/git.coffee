git = require 'git-promise'
q = require 'q'

repo = undefined
cwd = undefined
project = atom.project

if project
  repo = project.getRepo()
  cwd = repo.getWorkingDirectory()

getBranches = -> q.fcall ->
  branches = local: [], remote: [], tags: []
  refs = repo.getReferences()

  for h in refs.heads
    branches.local.push h.replace('refs/heads/', '')

  for h in refs.remotes
    branches.remote.push h.replace('refs/remotes/', '')

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

parseLog = (data) -> q.fcall ->
  console.log data
  return []

parseReset = (data) -> q.fcall ->
  console.log data
  return []

callGit = (cmd, parser) ->
  console.log "git #{cmd}"
  return git cmd, cwd: cwd
    .then (data) ->
      console.log data
      return parser(data)

module.exports =
  isInitialised: ->
    return repo

  count: (branch) ->
    return repo.getAheadBehindCount(branch)

  getLocalBranch: ->
    return repo.getShortHead()

  getRemoteBranch: ->
    return repo.getUpstreamBranch()

  getBranches: getBranches

  diff: (file) ->
    return callGit "--no-pager diff #{file or ''}", parseDiff

  log: (branch) ->
    return callGit "log origin/#{branch}..#{branch}", parseLog

  reset: (files) ->
    return callGit "checkout -- #{files}", parseReset

  status: ->
    return callGit 'status --porcelain', parseStatus
