fs = require 'fs'
path = require 'path'

git = require 'git-promise'
q = require 'q'

logcb = (log, error) ->
  console[if error then 'error' else 'log'] log

repo = undefined
cwd = undefined
project = atom.project

if project
  repo = project.getRepositories()[0]
  cwd = if repo then repo.getWorkingDirectory() #prevent startup errors if repo is undefined



noop = -> q.fcall -> true

atomRefresh = ->
  repo.refreshStatus() # not public/in docs
  return

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
    [type, name] = line.replace(/\ \ /g, ' ').trim().split(' ')
    files.push
      name: name
      selected: switch type[type.length - 1]
        when 'C','M','R','D','A' then true
        else false
      type: switch type[type.length - 1]
        when 'A' then 'added'
        when 'C' then 'modified' #'copied'
        when 'D' then 'deleted'
        when 'M' then 'modified'
        when 'R' then 'modified' #'renamed'
        when 'U' then 'conflict'
        when '?' then 'new'
        else 'unknown'

  return files

parseDefault = (data) -> q.fcall ->
  return true

callGit = (cmd, parser, nodatalog) ->
  logcb "> git #{cmd}"

  return git(cmd, {cwd: cwd})
    .then (data) ->
      logcb data unless nodatalog
      return parser(data)
    .fail (e) ->
      logcb e.stdout, true
      logcb e.message, true
      return

module.exports =
  isInitialised: ->
    return cwd

  alert: (text) -> #making the console available elsewhere
    logcb text
    return

  setLogger: (cb) ->
    logcb = cb
    return

  count: (branch) ->
    return repo.getAheadBehindCount(branch)

  getLocalBranch: ->
    return repo.getShortHead()

  getRemoteBranch: ->
    return repo.getUpstreamBranch()

  isMerging: ->
    return fs.existsSync(path.join(repo.path, 'MERGE_HEAD'))

  getBranches: getBranches

  hasRemotes: ->
    refs = repo.getReferences()
    return refs and refs.remotes and refs.remotes.length

  hasOrigin: ->
    return repo.getOriginURL() isnt null

  add: (files) ->
    return noop() unless files.length
    return callGit "add -- #{files.join(' ')}", (data) ->
      atomRefresh()
      return parseDefault(data)

  commit: (message) ->
    message = message or Date.now()
    message = message.replace(/"/g, '\\"')

    return callGit "commit -m \"#{message}\"", (data) ->
      atomRefresh()
      return parseDefault(data)

  checkout: (branch, remote) ->
    return callGit "checkout #{if remote then '--track ' else ''}#{branch}", (data) ->
      atomRefresh()
      return parseDefault(data)

  createBranch: (branch) ->
    return callGit "branch #{branch}", (data) ->
      return callGit "checkout #{branch}", (data) ->
        atomRefresh()
        return parseDefault(data)

  deleteBranch: (branch) ->
    return callGit "branch -d #{branch}", (data) ->
      atomRefresh()
      return parseDefault

  forceDeleteBranch: (branch) ->
    return callGit "branch -D #{branch}", (data) ->
      atomRefresh()
      return parseDefault

  diff: (file) ->
    return callGit "--no-pager diff #{file or ''}", parseDiff, true

  fetch: ->
    return callGit "fetch --prune", parseDefault

  merge: (branch,noff) ->
    noffOutput = if noff then "--no-ff" else ""
    return callGit "merge #{noffOutput} #{branch}", (data) ->
      atomRefresh()
      return parseDefault(data)

  pull: ->
    return callGit "pull", (data) ->
      atomRefresh()
      return parseDefault(data)

  flow: (type,action,branch) ->
    return callGit "flow #{type} #{action} #{branch}", (data) ->
      atomRefresh()
      return parseDefault(data)

  push: (remote,branch)->
    cmd = "-c push.default=simple push #{remote} #{branch} --porcelain"

    return callGit cmd, (data) ->
      atomRefresh()
      return parseDefault(data)

  log: (branch) ->
    return callGit "log origin/#{repo.getUpstreamBranch() or 'master'}..#{branch}", parseDefault

  reset: (files) ->
    return callGit "checkout -- #{files.join(' ')}", (data) ->
      atomRefresh()
      return parseDefault(data)

  remove: (files) ->
    return noop() unless files.length
    return callGit "rm -- #{files.join(' ')}", (data) ->
      atomRefresh()
      return parseDefault(true)

  status: ->
    return callGit 'status --porcelain --untracked-files=all', parseStatus
