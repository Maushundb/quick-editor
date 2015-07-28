module.exports =
class MarkupParser
  constructor: (@textEditor = null) ->

  setEditor: (editor) ->
    @textEditor = editor

  parse: ->
    @moveCursorToIndentifierBoundary()
    @getFirstIdentifier()

  moveCursorToIndentifierBoundary:() ->
    originalPosition = 
    @textEditor.selectLeft()
    word = @textEditor.getSelectedText()
    while word isnt "\"" and word isnt "\'"
      @textEditor.selectRight()
      @textEditor.moveLeft()
      @textEditor.selectLeft()
      word = @textEditor.getSelectedText()
      @textNotCSSIdentifier() if word is "\n"
    @textEditor.selectRight()

  getFirstIdentifier:() ->
    @textEditor.selectRight()
    word = @textEditor.getSelectedText()
    while word.slice(-1) isnt "\"" and word.slice(-1) isnt "\'"
      @textEditor.selectRight()
      word = @textEditor.getSelectedText()
      @textNotCSSIdentifier() if word.slice(-1) is "\n"
    @textEditor.selectLeft()
    return word.slice(0,-1)

  textNotCSSIdentifier: ->
    atom.beep()
    throw new Error "Selected text is not a CSS identifier"
