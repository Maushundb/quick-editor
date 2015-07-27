{Point} = require 'atom'
module.exports =
class CssQuickEditorView
  constructor: ->
    @file = null
    @text = null
    @editRange = null

    @element = document.createElement 'div'
    @element.classList.add 'css-quick-editor'

    @textEditorView = document.createElement 'atom-text-editor'
    @textEditor = @textEditorView.getModel()

    @grammarReg = atom.grammars

    @element.appendChild @textEditorView

  # Tear down any state and detach
  destroy: ->
    @element.remove()

  getElement: ->
    @element

  save: ->
    @file.read().then (content) =>
      modifyingTextEditor = document.createElement('atom-text-editor').getModel()
      modifyingTextEditor.getBuffer().setPath @file.getPath()
      modifyingTextEditor.setText content

      modifiedSelector = @textEditor.getText()
      modifyingTextEditor.setTextInBufferRange(@editRange, modifiedSelector)



  setFile: (file) ->
    @file = file

  setText: (text) ->
    @text = text

  setup: (text, start, end, file) ->
    @setText(text)
    @setFile(file)

    grammar = @grammarReg.selectGrammar @file.getPath(), @text
    @textEditor.setGrammar grammar
    @textEditor.setText @text

    @editRange = new Range(new Point(start, 0), new Point(end, 0))

  scroll: ->
    @textEditor.scrollToCursorPosition(false)

  open: (identifier) ->
    throw new Error "Must choose a file to quick-edit" if @file is null

    @lineHeight = atom.workspace.getActiveTextEditor().getLineHeightInPixels()
