quickEditorView = require './quick-editor-view'
DirectoryCSSSearcher = require './directory-css-searcher'
MarkupParser = require './markup-parser'
{Range, Point, CompositeDisposable, TextBuffer, File} = require 'atom'

module.exports = QuickEditor =

  ### Life Cycle Methods ###
  quickEditorView : null
  panel : null
  subscriptions : null
  searcher : null
  parser: null

  activate: ->
    @quickEditorView = new quickEditorView()
    @quickEditorView.setOnSelectorAdded(@selectorAdded.bind(@))
    @panel = atom.workspace.addBottomPanel(item: @quickEditorView, visible: false)

    @searcher = new DirectoryCSSSearcher
    @parser = new MarkupParser

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
    else
      @selector = @parseSelectedCSSSelector()
      @findFilesFromCSSIdentifier(@selector)
      .then ([found, result]) =>
        @found = found
        @searcher.clear()
        if @found
          @setupForEditing(result.text, result.start, result.end, result.file)
          @edit()
        else
          @addNewSelector(@selector)
      .catch (e) ->
        console.error(e.message, e.stack)

  findFilesFromCSSIdentifier:(identifier) ->
    @searcher.findFilesThatContain identifier
    .then () =>
        @searcher.getSelectorText()
    .catch (e) ->
      throw e

  parseSelectedCSSSelector: ->
    editor = atom.workspace.getActiveTextEditor()
    @parser.setEditor(editor)
    @parser.parse()

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
    @quickEditorView.attachAddSelectorView(selector, "/Users/BrandonM/Documents/Personal/quick-editor/spec/fixtures/test.less")
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
      @findFilesFromCSSIdentifier(selector)
      .then ([found, result]) =>
        @found = found
        @searcher.clear()
        @setupForEditing(result.text, result.start, result.end, result.file)
        @edit()


  closeView: (edit) ->
    if edit
      @quickEditorView.detachEditorView()
    else
      @quickEditorView.detachAddSelectorView()
