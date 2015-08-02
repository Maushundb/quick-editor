DirectoryCSSSearcher = require '../lib/directory-css-searcher'
File = require 'atom'

describe "DirectoryCSSSearcher", ->
  dcs = null

  beforeEach ->
    dcs = new DirectoryCSSSearcher

  it "should find files containing a specific Regex", ->
    waitsForPromise -> dcs.findFilesThatContain(".test-class")
    runs ->
      expect(dcs.file.getBaseName()).toBe("test.less")

  it "should return the proper range of a selector", ->
    waitsForPromise -> dcs.findFilesThatContain(".test-class")
    runs ->
      dcs.getSelectorText().then (success, result) ->
        expect(result.start).toBe(1)
        expect(result.end).toBe(5)
