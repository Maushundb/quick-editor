{$, View, TextEditorView} = require 'atom-space-pen-views'
{File, Directory} = require 'atom'

module.exports =
class AddSelectorView extends View

  selector: null
  onSelectorAdded: null

  @content: ()->
    @div class: "add-selector-view", =>
      @div class: "top-container", =>
        @div class: "top-container-left", =>
          @h2 "Add New Selector"
          @div class: "no-selector-container", =>
            @div class: "no-selector-text", "No selector was found for: "
            @div class: "selector"
        @div class: "top-container-right", =>
          @div class: "btn", click: "onAddClick", "Add"
      @div class: "add-new-style-container", =>
        @div class: "add-new-selector-text", "Add new selector in:"
        @subview 'pathEditorView', new TextEditorView(mini: true)

  initialize: ->
    @pathEditor = @pathEditorView.getModel()

  attached: ->
    $(".selector").html(@selector)

  setSelector: (selector) ->
    @selector = selector

  setInitialPath: (path) ->
    @pathEditor.setText path

  onAddClick: ->
    path = @pathEditor.getText()
    file = new File(path)
    # TODO could get weird behavior if directory. Refer to
    # https://iojs.org/api/fs.html#fs_fs_statsync_path
    file.exists().then (exists) =>
      if exists
        @onSelectorAdded(path, @selector)
      else
        atom.beep()
        atom.confirm(message: "File does not exist:\n" + path)
