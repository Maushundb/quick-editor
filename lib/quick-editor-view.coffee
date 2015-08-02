{Range, Point, CompositeDisposable} = require 'atom'
{$, View} = require 'atom-space-pen-views'
AddSelectorView = require './add-selector-view'


module.exports =
class QuickEditorView extends View

  ### Life Cycle Methods ###
  @content: ->
    @div class: "quick-editor"

  initialize: ->
    [@file, @text, @editRange, @lastObj] = []
    @lineDelta = 0

    @textEditorView = document.createElement 'atom-text-editor'
    @textEditor = @textEditorView.getModel()

    @addSelectorView = new AddSelectorView

    @grammarReg = atom.grammars
    @subscriptions = new CompositeDisposable

  attached: ->

  destroy: ->
    @subscriptions.dispose()

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

  setHeight: (edit)->
    if edit
      lineHeight = atom.workspace.getActiveTextEditor().getLineHeightInPixels()
      numLines = @editRange.end.row - @editRange.start.row + 1 + @lineDelta
      @element.style.height = (lineHeight * numLines) + "px"
    else
      @element.style.height = "90px"

  setOnSelectorAdded: (callback) ->
    @addSelectorView.onSelectorAdded = callback

  ### View Methods ###
  attachEditorView: ->
    throw new Error "Must choose a file to quick-edit" if @file is null
    this.append @textEditorView
    @setGutterNumbers(-1)
    @subscriptions.add @textEditor.getBuffer().onDidChange(
      @onBufferChangeCallback.bind(@)
    )

    @lineDelta = 0
    @setHeight(true)

  attachAddSelectorView: (selector, path)->
    @addSelectorView.setSelector(selector)
    @addSelectorView.setInitialPath(path)
    this.append @addSelectorView
    @setHeight(false)

  detachEditorView: ->
    @detachPreviousView()
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

  detachAddSelectorView: ->
    @detachPreviousView()
    return

  detachPreviousView: -> #might want to make this remove isntead
    previousView = $(@element).children()
    if previousView.length
      previousView.detach()

  setGutterNumbers: (num) ->
    i = 0
    for j in [@editRange.start.row + 1..(@editRange.end.row + @lineDelta + 1)]
       @setRowNumber(@getRowElementByLineNumber(i), j)
       i++

    if num > 0
      # This is s horrible hack. There is no callback to listen to
      # when gutter numbers change, so this had to be done to keep the
      # gutter numbers updated.
      cb = -> @setGutterNumbers(num - 1)
      window.setTimeout(cb.bind(@), 5)

  getRowElementByLineNumber: (lineNumber) ->
    $(@textEditorView.shadowRoot).find('.line-number[data-screen-row="'+ lineNumber+ '"]')

  setRowNumber: (rowElement, newNumber) ->
    $(rowElement).html("#{newNumber}")

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
      @setHeight(true)
      @setGutterNumbers(5)
