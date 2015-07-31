{$, View, TextEditorView} = require 'atom-space-pen-views'

module.exports =
class AddSelectorView extends View

  path: "/styles/test.less"

  @content: ->
    @div class: "add-selector-view", =>
      @div class: "top-container", =>
        @div class: "top-container-left", =>
          @h2 "Add New Selector"
          @div class: "no-selector-container", =>
            @div class: "no-selector-text", "No selector was found for: "
            @div class: "selector", ".test-class"
        @div class: "top-container-right", =>
          @div class: "btn", "Add"
      @div class: "add-new-style-container", =>
        @div class: "add-new-selector-text", "Add new selector in:"
        @subview 'pathEditorView', new TextEditorView(mini: true)




  initialize: ->
    @pathEditor = @pathEditorView.getModel()
    @pathEditor.setText @path


  attached: ->


  detached: ->
