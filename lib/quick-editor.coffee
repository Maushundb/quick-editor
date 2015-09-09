quickEditorView = require './quick-editor-view'
DirectoryIndexer = require './directory-indexer'
MarkupParser = require './markup-parser'
QuickEditorCache = require './quick-editor-cache'
{Range, Point, CompositeDisposable, TextBuffer, File} = require 'atom'

module.exports = QuickEditor =

  config:
    stylesDirectory:
      type: 'string'
      default: ''

  ### Life Cycle Methods ###
  quickEditorView : null
  panel : null
  subscriptions : null
  searcher : null
  markupParser: null

  activate: ->
    @quickEditorView = new quickEditorView()
    @quickEditorView.setOnSelectorAdded(@selectorAdded.bind(@))
    @panel = atom.workspace.addBottomPanel(item: @quickEditorView, visible: false)

    @cssCache = new QuickEditorCache
    @indexer = new DirectoryIndexer
    @markupParser = new MarkupParser

    # Events subscribed to in atom's system can be easily cleaned up with a CompositeDisposable
    @subscriptions = new CompositeDisposable

    # Register commands
    @subscriptions.add atom.commands.add 'atom-text-editor', 'quick-editor:quick-edit': =>
      @quickEdit()

  deactivate: ->
    @panel.destroy()
    @subscriptions.dispose()
    @quickEditorView.destroy()

  ### Functionality Methods ###

  quickEdit: ->
    if @panel.isVisible()
      @closeView(@found)
      @panel.hide()
    else if not @indexer.projectIndexed()
      @indexer.indexProject().then () =>
        @openEditor()
    else
      @openEditor()

  openEditor: ->
    try
      @selector = @parseSelector()
    catch e
      atom.beep()
      console.warn(e.message)
      return
    @findFilesFromSelector(@selector).then (result) =>
      if @found
        @setupForEditing(result.text, result.start, result.end, result.file)
        @edit()
      else
        @addNewSelector(@selector)
    .catch (e) ->
      console.error(e.message, e.stack)

  findFilesFromSelector: ->
    infos = @indexer.queryBySelector @selector
    if infos.length
      @found = true
      info = infos[0] #TODO deal with multiple
      file = new File info.filePath
      file.read().then (text) =>
        buffer = new TextBuffer()
        buffer.setText(text)
        text = buffer.getTextInRange([
          [info.ruleStartRow, info.ruleStartCol],
          [info.ruleEndRow, info.ruleEndCol]
        ])

        return {text: text,
        start: info.ruleStartRow,
        end: info.ruleEndRow,
        file: new File(info.filePath)}
    else
      return new Promise (resolve, reject) ->
        resolve()



    # .then () => @searcher.getSelectorText().then ([found, result]) =>
    #     @found = found
    #     @searcher.clear()
    #     if found
    #       path = atom.workspace.getActiveTextEditor().getPath()
    #       @cssCache.put(path, result.file.getPath())
    #     return [found, result]
    # .catch (e) ->
    #   console.error(e.message, e.stack)

  parseSelector: ->
    editor = atom.workspace.getActiveTextEditor()
    @markupParser.setEditor(editor)
    @markupParser.parse()

  setupForEditing: (text, start, end, file) ->
    @quickEditorView.setText text
    @quickEditorView.setFile file
    @quickEditorView.setGrammar()

    range = new Range(new Point(start, 0), new Point(end, Infinity))
    @quickEditorView.setEditRange(range)

  edit: ->
    @panel.show()
    @quickEditorView.attachEditorView()

  addNewSelector: (selector) ->
    unless path = @cssCache.get(atom.workspace.getActiveTextEditor().getPath())
      path = atom.project.getPaths()[0]
    @quickEditorView.attachAddSelectorView(selector, path)
    @panel.show()

  selectorAdded: (path, selector) ->
    file = new File(path, false)
    buffer = new TextBuffer()
    buffer.setPath(path)
    file.read()
    .then (text) =>
      buffer.setText(text) #TODO more efficent way to do this without researching
      buffer.append("\n" + selector + " {\n\n}")
      buffer.save()
      @closeView(false)
      @panel.hide()
      @findFilesFromSelector(selector)
      .then ([found, result]) =>
        @setupForEditing(result.text, result.start, result.end, result.file)
        @edit()


  closeView: (edit) ->
    if edit
      @quickEditorView.detachEditorView()
    else
      @quickEditorView.detachAddSelectorView()

  ### Methods for testing ###
  getView: ->
    return @quickEditorView
