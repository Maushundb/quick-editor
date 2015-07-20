module.exports =
class CssQuickEditorView
  constructor: (serializedState) ->
    # Create root element
    @file = null
    @element = document.createElement('div')
    @element.classList.add('css-quick-editor')

    @textEditorView = document.createElement('atom-text-editor')
    @textEditor = @textEditorView.getModel()
    @grammarReg = atom.grammars

    styleFile = @findFileFromCSSIdentifier "."
    path = styleFile.getPath()
    content = styleFile.readSync()
    @textEditor.getBuffer().setPath path
    grammar = @grammarReg.selectGrammar path, content
    @textEditor.setGrammar grammar
    @textEditor.setText content


    @element.appendChild(@textEditorView)



  # Returns an object that can be retrieved when package is activated
  serialize: ->

  # Tear down any state and detach
  destroy: ->
    @element.remove()

  getElement: ->
    @element

  save: ->
    @textEditor.save()

  setFile: (file) ->
    @file = file

  findFileFromCSSIdentifier: (identifier)->
    rootDir = atom.project.getDirectories()[0]
    return rootDir.getSubdirectory("styles").getFile("css-quick-editor.less")
