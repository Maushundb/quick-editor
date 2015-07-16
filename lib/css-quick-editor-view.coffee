module.exports =
class CssQuickEditorView
  constructor: (serializedState) ->
    # Create root element
    @element = document.createElement('div')
    @element.classList.add('css-quick-editor')

    textEditorElement = document.createElement('atom-text-editor')
    textEditor = textEditorElement.getModel()
    grammarReg = atom.grammars

    rootDir = atom.project.getDirectories()[0]
    fileOpen = rootDir.getSubdirectory("lib").getFile("css-quick-editor-view.coffee")
    textEditor.setText(fileOpen.readSync())
    textEditor.setGrammar(grammarReg.selectGrammar(fileOpen.getPath(), fileOpen.readSync()))
    #textEditor.setCursorScreenPosition({10, 1})

    @element.appendChild(textEditorElement)


  # Returns an object that can be retrieved when package is activated
  serialize: ->

  # Tear down any state and detach
  destroy: ->
    @element.remove()

  getElement: ->
    @element
