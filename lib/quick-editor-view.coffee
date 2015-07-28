{Point, Range, CompositeDisposable} = require 'atom'

module.exports =
class QuickEditorView

  ### Life Cycle Methods ###

  constructor: ->
    [@file, @text, @editRange, @lastObj] = []
    @lineDelta = 0

    @element = document.createElement 'div'
    @element.classList.add 'quick-editor'

    @textEditorView = document.createElement 'atom-text-editor'
    @textEditor = @textEditorView.getModel()

    @grammarReg = atom.grammars
    @subscriptions = new CompositeDisposable

    @element.appendChild @textEditorView

  destroy: ->
    @subscriptions.dispose()
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
      modifyingTextEditor.save()

  ### State Setter Methods ###

  setFile: (file) ->
    @file = file

  setText: (text) ->
    @text = text

  setHeight: () ->
    lineHeight = atom.workspace.getActiveTextEditor().getLineHeightInPixels()
    numLines = @editRange.end.row - @editRange.start.row + 1 + @lineDelta
    @element.style.height = (lineHeight * numLines) + "px"

  ### View Methods ###

  setup: (text, start, end, file) ->
    @setText(text)
    @setFile(file)

    grammar = @grammarReg.selectGrammar @file.getPath(), @text
    @textEditor.setGrammar grammar
    @textEditor.setText @text

    @subscriptions.add @textEditor.getBuffer().onDidChange(
      @onBufferChangeCallback.bind(@)
    )

    @editRange = new Range(new Point(start, 0), new Point(end, Infinity))

  open: () ->
    throw new Error "Must choose a file to quick-edit" if @file is null
    @lineDelta = 0
    @setHeight()

  onBufferChangeCallback: (obj) ->
    if obj.newRange.isEqual @lastObj?.newRange
      if obj.oldRange.isEqual @lastObj?.oldRange
        return
    @lastObj = obj
    # Sometimes the textBuffer likes to call this callback twice with the same obj

    newRows = obj.newRange.end.row - obj.newRange.start.row
    oldRows = obj.oldRange.end.row - obj.oldRange.start.row
    if newRows isnt oldRows
      if newRows > oldRows then @lineDelta++ else @lineDelta--
      @setHeight()
