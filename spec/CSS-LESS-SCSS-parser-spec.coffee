CssLessScssParser = require '../lib/CSS-LESS-SCSS-parser'
{File} = require 'atom'

fdescribe "CssLessScssParser", ->
  [selectorInfos] = []

  beforeEach ->
    waitsForPromise ->
      atom.workspace.open()
    runs ->
      path = atom.project.getPaths()[0] + '/test.less'
      parser = new CssLessScssParser(path)
      f = new File path
      text = f.readSync(false)
      selectorInfos = parser.parse(text)

  it "identifies all selectors", ->
    testSelectors = [
      ".test-class"
      ".test-class-with-nesting"
      ".test-nested-class"
      "#multiId1"
      "#multiId2"
      ".test-nested-class2"
      "#child"
      ".long-class"
      ".long-class2"
      ".lots-of-nesting"
      ".ln1"
      "#ln1"
      ".ln2"
      "#ln2"
    ]
    selectors = (selectorInfo.selector for selectorInfo in selectorInfos)
    for selector in selectors #TODO custom matcher?
      expect(testSelectors).toContain(selector)
    for testSelector in testSelectors
      expect(selectors).toContain(testSelector)

  it "identifies all selectorGroups", ->
    testSelectorGroups = [
      ".test-class"
      ".test-class-with-nesting"
      ".test-nested-class"
      "#multiId1, #multiId2"
      "#multiId1, #multiId2"
      ".test-nested-class2"
      "#parent #child"
      ".long-class"
      ".long-class2"
      ".lots-of-nesting"
      ".ln1"
      "#ln1"
      ".ln2"
      "#ln2"
    ]
    groups = (selectorInfo.selectorGroup for selectorInfo in selectorInfos)
    for group in groups
      expect(testSelectorGroups).toContain(group)
    for testGroup in testSelectorGroups
      expect(groups).toContain(testGroup)

  it "identifies the proper placement of selectors", ->
    for s in selectorInfos
      switch s.selector
        when ".test-class"
          expect(s.selectorStartRow).toBe(1)
          expect(s.selectorStartCol).toBe(0)
          expect(s.selectorEndRow).toBe(1)
          expect(s.selectorEndCol).toBe(11)

          expect(s.ruleStartRow).toBe(2)
          expect(s.ruleStartCol).toBe(0)
          expect(s.ruleEndRow).toBe(4)
          expect(s.ruleEndCol).toBe(15)

          expect(s.filePath).toBe(atom.project.getPaths()[0] + '/test.less')
        when ".test-class-with-nesting"
          expect()
        when ".test-nested-class"
          expect()
        when ".lots-of-nesting"
          expect()

  xdescribe "when scanning a large project", ->
    # timed performance tests
