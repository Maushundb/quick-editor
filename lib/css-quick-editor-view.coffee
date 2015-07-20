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

  open: ->
    throw new Error "Must choose a file to quick-edit" if @file is null

    path = @file.getPath()
    @textEditor.getBuffer().setPath path
    @file.read(false) #Cached copies are not okay, TODO think more about this
    .then (content) =>
      grammar = @grammarReg.selectGrammar path, content
      @textEditor.setGrammar grammar
      @textEditor.setText content
    , (e) =>
      console.error "File could not be read", e
