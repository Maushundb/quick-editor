{Range, Point, CompositeDisposable} = require 'atom'
$ = require 'jquery'

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


  destroy: ->
    @subscriptions.dispose()
    @element.remove()

  getElement: ->
    @element

  close: ->
    @subscriptions.remove @textEditor.getBuffer().onDidChange(
      @onBufferChangeCallback.bind(@)
    )
    @file.read().then (content) =>
      modifyingTextEditor = document.createElement('atom-text-editor').getModel()
      modifyingTextEditor.getBuffer().setPath @file.getPath()
      modifyingTextEditor.setText content

      modifiedSelector = @textEditor.getText()
      modifyingTextEditor.setTextInBufferRange(@editRange, modifiedSelector)
      modifyingTextEditor.save()

  ### State Getter / Setter Methods ###

  setFile: (file) ->
    @file = file

  setText: (text) ->
    @text = text
    @textEditor.setText(@text)

  setGrammar:  ->
    throw new Error "Must set text & file" if @fill is null or @text is null
    grammar = @grammarReg.selectGrammar @file.getPath(), @text
    @textEditor.setGrammar grammar

  setEditRange: (range) ->
    @editRange = range

  setHeight: ->
    lineHeight = atom.workspace.getActiveTextEditor().getLineHeightInPixels()
    numLines = @editRange.end.row - @editRange.start.row + 1 + @lineDelta
    @element.style.height = (lineHeight * numLines) + "px"

  ### View Methods ###
  attachEditor: ->
    @element.appendChild @textEditorView

  setGutterNumbers: (num) ->
    i = 0
    for j in [@editRange.start.row + 1..(@editRange.end.row + @lineDelta + 1)]
       @setRowNumber(@getRowElementByLineNumber(i), j)
       i++

    if num < 10
      cb = -> @setGutterNumbers(num + 1)
      window.setTimeout(cb.bind(@), 5)

  getRowElementByLineNumber: (lineNumber) ->
    $(@textEditorView.shadowRoot).find('.line-number[data-screen-row="'+ lineNumber+ '"]')

  setRowNumber: (rowElement, newNumber) ->
    $(rowElement).html("#{newNumber}")

  open: () ->
    throw new Error "Must choose a file to quick-edit" if @file is null
    @subscriptions.add @textEditor.getBuffer().onDidChange(
      @onBufferChangeCallback.bind(@)
    )

    @lineDelta = 0
    @setHeight()
    # HACK
    @setGutterNumbers(0)


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
      @setGutterNumbers(0)
