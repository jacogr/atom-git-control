{View} = require 'atom'

module.exports =
class FileItemView extends View
  @content: (params) ->
    @div class: 'files', =>
      @div class: 'heading', =>
        @i class: 'icon forked'
        @span 'Workspace'
        @div class: 'action', click: 'selectAllFiles', =>
          @span 'Select'
          @i class: 'icon check'
          @input class: 'invisible', type: 'checkbox', outlet: 'allFilesCb'

  selectAllFiles: ->
    @parentView.selectAllFiles()
