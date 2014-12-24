{View, $} = require 'atom'

class FileViewItem extends View
  @content: (params) ->
    @div class: "file #{params.type}", 'data-name': params.name, =>
      @i class: 'icon check'
      @i class: "icon file-#{params.type}"
      @span class: 'clickable', click: 'click', params.name

  initialize: (params) ->
    @file = params

  click: ->
    @file.click(@file.name)

module.exports =
class FileView extends View
  @content: (params) ->
    @div class: 'files', =>
      @div class: 'heading', =>
        @i class: 'icon forked'
        @span 'Workspace'
        @div class: 'action', click: 'selectAll', =>
          @span 'Select'
          @i class: 'icon check'
          @input class: 'invisible', type: 'checkbox', outlet: 'allCheckbox'
      @div class: 'placeholder', 'No local working copy changes detected'

  initialize: ->
    @files = {}

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
      files.all.push name
      switch file.type
        when 'new' then files.add.push name
        when 'deleted' then files.rem.push name

    return files

  showSelected: ->
    fnames = []

    @find('.file').toArray().forEach (div) =>
      f = $(div)

      if name = f.attr('data-name')
        if @files[name].selected
          fnames.push name
          f.addClass('active')
        else
          f.removeClass('active')

    for name, file of @files
      unless name in fnames
        file.selected = false

    @parentView.showSelectedFiles()
    return

  addAll: (files) ->
    fnames = []

    @find('.file').remove()

    if files.length
      @removeClass('none')

      click = (name) => @select(name)

      files.forEach (file) =>
        fnames.push file.name

        file.click = click

        @files[file.name] or= name: file.name
        @files[file.name].type = file.type
        @append new FileViewItem(file)
        return

    else
      @addClass('none')

    for name, file of @files
      unless name in fnames
        file.selected = false

    @showSelected()
    return

  select: (name) ->
    if name
      @files[name].selected = !!!@files[name].selected

    @allCheckbox.prop('checked', false)
    @showSelected()
    return

  selectAll: ->
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
