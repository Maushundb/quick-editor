quickEditorView = require './quick-editor-view'
DirectoryCSSSearcher = require './directory-css-searcher'
MarkupParser = require './markup-parser'
{CompositeDisposable} = require 'atom'

module.exports = QuickEditor =

  ### Life Cycle Methods ###
  quickEditorView : null
  panel : null
  subscriptions : null
  searcher : null
  parser: null

  activate: (state) ->
    @quickEditorView = new quickEditorView()
    @panel = atom.workspace.addBottomPanel(item: @quickEditorView.getElement(), visible: false)

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
      @quickEditorView.save()
      @panel.hide()
    else
      identifier = @parseSelectedCSSIdentifier()
      @findFilesFromCSSIdentifier(identifier)
      .then ([text, start, end, file]) =>
        @searcher.clear()
        @quickEditorView.setup(text, start, end, file)
        @quickEditorView.open()
        @panel.show()
      .catch (e) ->
        console.error(e.message, e.stack)

  findFilesFromCSSIdentifier:(identifier) ->
    @searcher.findFilesThatContain identifier
    .then () =>
      @searcher.getSelectorText()
    .catch (e) ->
      throw e

  parseSelectedCSSIdentifier: ->
    editor = atom.workspace.getActiveTextEditor()
    @parser.setEditor(editor)
    @parser.parse()
