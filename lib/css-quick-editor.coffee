CssQuickEditorView = require './css-quick-editor-view'
DirectoryCSSSearcher = require './directory-css-searcher'
{CompositeDisposable} = require 'atom'

module.exports = CssQuickEditor =
  cssQuickEditorView: null
  panel: null
  subscriptions: null
  first: true

  activate: (state) ->

    @cssQuickEditorView = new CssQuickEditorView()
    @panel = atom.workspace.addBottomPanel(item: @cssQuickEditorView.getElement(), visible: false)

    # Events subscribed to in atom's system can be easily cleaned up with a CompositeDisposable
    @subscriptions = new CompositeDisposable

    # Register command that toggles the editor
    @subscriptions.add atom.commands.add 'atom-workspace', 'css-quick-editor:quick-edit': =>
      @quickEdit()


  deactivate: ->
    @panel.destroy()
    @subscriptions.dispose()
    @cssQuickEditorView.destroy()


  quickEdit: ->
    if @panel.isVisible()
      @cssQuickEditorView.save()
      @panel.hide()
    else
      identifier = @parseSelectedCSSIdentifier()
      @findFilesFromCSSIdentifier(identifier)
      .then (files) =>
        @cssQuickEditorView.setFile(files[0])
        @cssQuickEditorView.open(identifier)
        @panel.show()
        # This is, of course, a terrible hack. Scrolling in the TextEditor
        # only works after the height has been calculated, so the first time the
        # panel is opened it will not scroll. This fixes this fixes that issue
        # for the time being. See:
        # https://discuss.atom.io/t/scrolling-the-text-editor-in-bottom-pane-and-getting-line-height/19171/2
        # if @first
        #   @first = false
        #   terribleHackCallback = => @cssQuickEditorView.scroll()
        #   setTimeout terribleHackCallback, 500



  findFilesFromCSSIdentifier:(identifier) ->
    DirectoryCSSSearcher.findFilesThatContain identifier

  parseSelectedCSSIdentifier: ->
    activeTextEditor = atom.workspace.getActiveTextEditor()
    @moveCursorToIndentifierBoundary(activeTextEditor)
    return @getFirstIdentifier(activeTextEditor)

  moveCursorToIndentifierBoundary:(activeTextEditor) ->
    activeTextEditor.selectLeft()
    word = activeTextEditor.getSelectedText()
    while word isnt "\"" and word isnt "\'"
      activeTextEditor.selectRight()
      activeTextEditor.moveLeft()
      activeTextEditor.selectLeft()
      word = activeTextEditor.getSelectedText()
      @textNotCSSIdentifier() if word is "\n"
    activeTextEditor.selectRight()

  getFirstIdentifier:(activeTextEditor) ->
    activeTextEditor.selectRight()
    word = activeTextEditor.getSelectedText()
    while word.slice(-1) isnt "\"" and word isnt "\'"
      activeTextEditor.selectRight()
      word = activeTextEditor.getSelectedText()
      @textNotCSSIdentifier() if word.slice(-1) is "\n"
    activeTextEditor.selectLeft()
    return word.slice(0,-1)

  textNotCSSIdentifier: ->
    throw new Error "Selected text is not a CSS identifier"
