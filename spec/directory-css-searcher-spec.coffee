DirectoryCSSSearcher = require '../lib/directory-css-searcher'
File = require 'atom'

describe "DirectoryCSSSearcher", ->
  dcs = null


  beforeEach ->
    waitsForPromise ->
      atom.workspace.open()
    runs ->
      atom.config.set('quick-editor.stylesDirectory', atom.project.getPaths()[0])
      dcs = new DirectoryCSSSearcher

  it "finds files containing a specific Regex", ->
    waitsForPromise -> dcs.findFilesThatContain(".test-class")
    runs ->
      expect(dcs.file.getBaseName()).toBe("test.less")

  it "returns the proper range of a selector", ->
    waitsForPromise -> dcs.findFilesThatContain(".test-class")
    runs ->
      dcs.getSelectorText().then (success, result) ->
        expect(result.start).toBe(1)
        expect(result.end).toBe(5)

  it "only searches the specified styles directory", ->
    waitsForPromise -> dcs.findFilesThatContain(".false-class")
    runs ->
      dcs.getSelectorText().then (success, result) ->
        expect(result.success).toBe(false)
