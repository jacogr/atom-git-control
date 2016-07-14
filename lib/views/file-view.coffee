{View, $} = require 'atom-space-pen-views'
git = require '../git'

class FileItem extends View
  @content: (file) ->
    console.log('file', file)
    @div class: "file #{file.type}", 'data-name': file.name, =>
      @span class: 'clickable text', click: 'select', title: file.name, file.name
      @i class: 'icon check clickable', click: 'select'
      @i class: "icon #{if (file.type == 'modified') then 'clickable' else ''} file-#{file.type}", click: 'showFileDiff'

  initialize: (file) ->
    @file = file

  showFileDiff: ->
    if @file.type == 'modified'
      @file.showFileDiff(@file.name)

  select: ->
    @file.select(@file.name)

module.exports =
class FileView extends View
  @content: ->
    @div class: 'files', =>
      @div class: 'heading clickable', =>
        @i click: 'toggleBranch', class: 'icon forked'
        @span click: 'toggleBranch', 'Workspace:'
        @span '', outlet: 'workspaceTitle'
        @div class: 'action', click: 'selectAll', =>
          @span 'Select all'
          @i class: 'icon check'
          @input class: 'invisible', type: 'checkbox', outlet: 'allCheckbox', checked: true
      @div class: 'placeholder', 'No local working copy changes detected'

  initialize: ->
    @files = {}
    @arrayOfFiles = new Array
    @hidden = false

  toggleBranch: ->
    if @hidden then @addAll @arrayOfFiles else do @clearAll
    @hidden = !@hidden

  hasSelected: ->
    for name, file of @files when file.selected
      return true
    return false

  getSelected: ->
    files =
      all: []
      add: []
      rem: []

    for name, file of @files when file.selected
      files.all.push file.name
      switch file.type
        when 'deleted' then files.rem.push file.name
        else files.add.push file.name

    return files

  showSelected: ->
    fnames = []
    @arrayOfFiles = Object.keys(@files).map((file) => @files[file]);
    @find('.file').toArray().forEach (div) =>
      f = $(div)

      if name = f.attr('data-name')
        if @files[name].selected
          fnames.push name
          f.addClass('active')
        else
          f.removeClass('active')
      return

    for name, file of @files
      unless name in fnames
        file.selected = false

    @parentView.showSelectedFiles()
    return

  clearAll: ->
    @find('>.file').remove()
    return

  addAll: (files) ->
    fnames = []

    @clearAll()

    if files.length
      @removeClass('none')

      select = (name) => @selectFile(name)
      showFileDiff = (name) => @showFileDiff(name)

      files.forEach (file) =>
        fnames.push file.name

        file.select = select
        file.showFileDiff = showFileDiff

        tempName = file.name
        if tempName.indexOf(' ') > 0 then tempName = '\"' + tempName + '\"'

        @files[file.name] or= name: tempName
        @files[file.name].type = file.type
        @files[file.name].selected = file.selected
        @append new FileItem(file)
        return

    else
      @addClass('none')

    for name, file of @files
      unless name in fnames
        file.selected = false

    @showSelected()
    return

  showFileDiff: (name) ->
    git.diff(name).then (diffs) =>
      @parentView.diffView.clearAll()
      @parentView.diffView.addAll(diffs)


  selectFile: (name) ->
    if name
      @files[name].selected = !!!@files[name].selected

    @allCheckbox.prop('checked', false)
    @showSelected()
    return

  selectAll: ->
    return if @hidden
    val = !!!@allCheckbox.prop('checked')
    @allCheckbox.prop('checked', val)

    for name, file of @files
      file.selected = val

    @showSelected()
    return

  unselectAll: ->
    for name, file in @files when file.selected
      file.selected = false

    return

  setWorkspaceTitle: (title) ->
    @workspaceTitle.text(title)
    return
