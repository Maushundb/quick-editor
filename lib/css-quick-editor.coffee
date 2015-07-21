CssQuickEditorView = require './css-quick-editor-view'
{CompositeDisposable} = require 'atom'

module.exports = CssQuickEditor =
  cssQuickEditorView: null
  panel: null
  subscriptions: null

  activate: (state) ->

    @cssQuickEditorView = new CssQuickEditorView()
    @panel = atom.workspace.addBottomPanel(item: @cssQuickEditorView.getElement(), visible: false)

    # Events subscribed to in atom's system can be easily cleaned up with a CompositeDisposable
    @subscriptions = new CompositeDisposable

    # Register command that toggles the editor
    @subscriptions.add atom.commands.add 'atom-workspace', 'css-quick-editor:quick-edit': =>
      @quickEdit()

  deactivate: ->
    @panel.destroy()
    @subscriptions.dispose()
    @cssQuickEditorView.destroy()

  serialize: ->
    cssQuickEditorViewState: @cssQuickEditorView.serialize()

  supportedFileExtensions: [
    "css"
    "scss"
    "less"
    "sass"
  ]

  quickEdit: ->
    if @panel.isVisible()
      @cssQuickEditorView.save()
      @panel.hide()
    else
      @findFilesFromCSSIdentifier(@parseSelectedCSSIdentifier())
      .then (files) =>
        @cssQuickEditorView.setFile(files[1])
        @cssQuickEditorView.open()
        @panel.show()

  findFilesFromCSSIdentifier:(identifier) ->
    id_reg = new RegExp(identifier)
    directories = atom.project.getDirectories()
    filePromises = directories.map((f) =>
      return @searchDirectory(f, id_reg)
    )
    filePromises = Promise.all(filePromises).then (files) =>
      files = @flattenArray(files).filter((i) -> i isnt null)
    return filePromises

  parseSelectedCSSIdentifier: ->
    activeTextEditor = atom.workspace.getActiveTextEditor()
    @moveCursorToIndentifierBoundary(activeTextEditor)
    return @getFirstIdentifier(activeTextEditor)

  moveCursorToIndentifierBoundary:(activeTextEditor) ->
    activeTextEditor.selectLeft()
    word = activeTextEditor.getSelectedText()
    while word isnt "\"" and word isnt "\'"
      activeTextEditor.selectRight()
      activeTextEditor.moveLeft()
      activeTextEditor.selectLeft()
      word = activeTextEditor.getSelectedText()
      @textNotCSSIdentifier() if word is "\n"
    activeTextEditor.selectRight()

  getFirstIdentifier:(activeTextEditor) ->
    activeTextEditor.selectRight()
    word = activeTextEditor.getSelectedText()
    while word.slice(-1) isnt "\"" and word isnt "\'"
      activeTextEditor.selectRight()
      word = activeTextEditor.getSelectedText()
      @textNotCSSIdentifier() if word.slice(-1) is "\n"
    activeTextEditor.selectLeft()
    return word.slice(0,-1)

  textNotCSSIdentifier: ->
    throw new Error "Selected text is not a CSS identifier"

  searchDirectory: (dir, regex) ->
    new Promise (resolve, reject) =>
      results = []
      dir.getEntries (err, entries) =>
        reject(err) if err isnt null
        for entry in entries
          result = null
          name = entry.getBaseName()
          if name.slice(0, 1) isnt "."
            if entry.isFile() and name.split(".").pop() in @supportedFileExtensions
              result = @searchFile(entry, regex)
            else if entry.isDirectory()
              result = @searchDirectory(entry, regex)
          # This pushes promises that resolve to null as well TODO
          results.push result if result isnt null
        resolve(Promise.all(results))

  searchFile: (file, regex) ->
    new Promise (resolve, reject) ->
      file.read(true)
        .then (content) ->
          result = content.search(regex)
          resolve(if result > 0 then [result, file] else null)


  #Solution from https://gist.github.com/th507/5158907
  arrayEqual: (a, b) ->
    i = Math.max(a.length, b.length, 1)
    continue while(i-- >= 0 and a[i] is b[i])
    return (i is -2)

  flattenArray: (arr) ->
  	r = []
  	while (!@arrayEqual(r, arr))
  		r = arr
  		arr = [].concat.apply([], arr)
  	return arr
