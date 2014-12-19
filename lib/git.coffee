git = require 'git-promise'
q = require 'q'

logcb = (log, error) ->
  console[if error then 'error' else 'log'] log

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

parseDefault = (data) -> q.fcall ->
  return true

callGit = (cmd, parser) ->
  logcb "> git #{cmd}"

  return git(cmd, cwd: cwd)
    .then (data) ->
      logcb data
      return parser(data)
    .catch (e) =>
      logcb e, true
      return

module.exports =
  isInitialised: ->
    return repo

  setLogger: (cb) ->
    logcb = cb
    return

  count: (branch) ->
    return repo.getAheadBehindCount(branch)

  getLocalBranch: ->
    return repo.getShortHead()

  getRemoteBranch: ->
    return repo.getUpstreamBranch()

  getBranches: getBranches

  commit: (message, files) ->
    return callGit "commit -m '#{message}' -- #{files}", parseDefault

  diff: (file) ->
    return callGit "--no-pager diff #{file or ''}", parseDiff

  fetch: ->
    return callGit "fetch", parseDefault

  log: (branch) ->
    return callGit "log origin/#{branch}..#{branch}", parseDefault

  reset: (files) ->
    return callGit "checkout -- #{files}", parseDefault

  status: ->
    return callGit 'status --porcelain', parseStatus
