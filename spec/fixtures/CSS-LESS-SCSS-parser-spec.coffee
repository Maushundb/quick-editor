DirectoryCSSSearcher = require '../lib/CSS-LESS-SCSS-parser'
File = require 'atom'

describe "CssLessScssParser", ->
  selectorList = null

  beforeEach ->
    waitsForPromise ->
      atom.workspace.open()
    runs ->
      parser = new CssLessScssParser
      testSelectors = new Set([
        ".test-class"
        ".test-class-with-nesting"
        ".test-nested-class"
        "#really-long-id"
        ".nestedName"
        ".other-id-3"
      ])
      text = new File(project.getPaths()[0] + '/test.html').readSync()
      selectorList = parser.parse(text)

  describe "after parsing a file", ->

    it "identifies all of the selectors in a style file", ->
      for selector in selectorList
        expect(true).toBe(false) unless testSelectors.delete(selector.selector)
      expect(testSelectors.size).toBe(0)
