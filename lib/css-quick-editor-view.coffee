module.exports =
class CssQuickEditorView
  constructor: ->
    @file = null
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
    @textEditor.save()

  setFile: (file) ->
    @file = file

  scroll: ->
    @textEditor.scrollToCursorPosition(false)

  setHeight: ->
    @textEditor.displayBuffer.setHeight(200)
    @textEditorView.style.height = "200px"

  open: (identifier) ->
    throw new Error "Must choose a file to quick-edit" if @file is null

    path = @file.getPath()
    @textEditor.getBuffer().setPath path
    regex = new RegExp(identifier)
    @file.read(false) #Cached copies are not okay, TODO think more about this
    .then (content) =>
      grammar = @grammarReg.selectGrammar path, content
      @textEditor.setGrammar grammar
      @textEditor.setText content
      @range = null
      @textEditor.scan regex, (it) =>
        @range = it.range
        it.stop()
      @textEditor.setCursorBufferPosition(@range.start)
      @textEditor.scrollToCursorPosition(true)
    , (e) =>
      console.error "File could not be opened", e
