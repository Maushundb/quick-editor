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
      ".odd-formatted-class"
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
      ".odd-formatted-class"
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
          expect(s.selectorStartRow).toBe(7)
          expect(s.selectorStartCol).toBe(0)
          expect(s.selectorEndRow).toBe(7)
          expect(s.selectorEndCol).toBe(24)

          expect(s.ruleStartRow).toBe(8)
          expect(s.ruleStartCol).toBe(0)
          expect(s.ruleEndRow).toBe(10)
          expect(s.ruleEndCol).toBe(15)
        when ".test-nested-class"
          expect(s.selectorStartRow).toBe(12)
          expect(s.selectorStartCol).toBe(2)
          expect(s.selectorEndRow).toBe(12)
          expect(s.selectorEndCol).toBe(20)

          expect(s.ruleStartRow).toBe(13)
          expect(s.ruleStartCol).toBe(0)
          expect(s.ruleEndRow).toBe(15)
          expect(s.ruleEndCol).toBe(17)
        when ".lots-of-nesting"
          expect(s.selectorStartRow).toBe(19)
          expect(s.selectorStartCol).toBe(0)
          expect(s.selectorEndRow).toBe(19)
          expect(s.selectorEndCol).toBe(16)

          expect(s.ruleStartRow).toBe(20)
          expect(s.ruleStartCol).toBe(0)
          expect(s.ruleEndRow).toBe(21)
          expect(s.ruleEndCol).toBe(19)
        when ".ln1"
          expect(s.selectorStartRow).toBe(22)
          expect(s.selectorStartCol).toBe(2)
          expect(s.selectorEndRow).toBe(22)
          expect(s.selectorEndCol).toBe(6)

          expect(s.ruleStartRow).toBe(23)
          expect(s.ruleStartCol).toBe(0)
          expect(s.ruleEndRow).toBe(25)
          expect(s.ruleEndCol).toBe(26)
        when "#ln1"
          expect(s.selectorStartRow).toBe(27)
          expect(s.selectorStartCol).toBe(4)
          expect(s.selectorEndRow).toBe(27)
          expect(s.selectorEndCol).toBe(8)

          expect(s.ruleStartRow).toBe(28)
          expect(s.ruleStartCol).toBe(0)
          expect(s.ruleEndRow).toBe(30)
          expect(s.ruleEndCol).toBe(28)
        when ".ln2"
          expect(s.selectorStartRow).toBe(34)
          expect(s.selectorStartCol).toBe(2)
          expect(s.selectorEndRow).toBe(34)
          expect(s.selectorEndCol).toBe(6)

          expect(s.ruleStartRow).toBe(35)
          expect(s.ruleStartCol).toBe(0)
          expect(s.ruleEndRow).toBe(37)
          expect(s.ruleEndCol).toBe(26)
        when "#ln2"
          expect(s.selectorStartRow).toBe(39)
          expect(s.selectorStartCol).toBe(4)
          expect(s.selectorEndRow).toBe(39)
          expect(s.selectorEndCol).toBe(8)

          expect(s.ruleStartRow).toBe(40)
          expect(s.ruleStartCol).toBe(0)
          expect(s.ruleEndRow).toBe(42)
          expect(s.ruleEndCol).toBe(28)
        when "#multiId1" # Care if it separates multi selectors? No for now.
          expect(s.selectorStartRow).toBe(48)
          expect(s.selectorStartCol).toBe(0)
          expect(s.selectorEndRow).toBe(48)
          expect(s.selectorEndCol).toBe(20)

          expect(s.ruleStartRow).toBe(49)
          expect(s.ruleStartCol).toBe(0)
          expect(s.ruleEndRow).toBe(52)
          expect(s.ruleEndCol).toBe(13)
        when "#multiId2"
          expect(s.selectorStartRow).toBe(48)
          expect(s.selectorStartCol).toBe(0)
          expect(s.selectorEndRow).toBe(48)
          expect(s.selectorEndCol).toBe(20)

          expect(s.ruleStartRow).toBe(49)
          expect(s.ruleStartCol).toBe(0)
          expect(s.ruleEndRow).toBe(52)
          expect(s.ruleEndCol).toBe(13)
        when ".test-nested-class2"
          expect(s.selectorStartRow).toBe(54)
          expect(s.selectorStartCol).toBe(2)
          expect(s.selectorEndRow).toBe(54)
          expect(s.selectorEndCol).toBe(21)

          expect(s.ruleStartRow).toBe(55)
          expect(s.ruleStartCol).toBe(0)
          expect(s.ruleEndRow).toBe(56)
          expect(s.ruleEndCol).toBe(14)
        when "#child"
          expect(s.selectorStartRow).toBe(60)
          expect(s.selectorStartCol).toBe(0)
          expect(s.selectorEndRow).toBe(60)
          expect(s.selectorEndCol).toBe(14)

          expect(s.ruleStartRow).toBe(61)
          expect(s.ruleStartCol).toBe(0)
          expect(s.ruleEndRow).toBe(63)
          expect(s.ruleEndCol).toBe(15)
        when ".long-class"
          expect(s.selectorStartRow).toBe(66)
          expect(s.selectorStartCol).toBe(0)
          expect(s.selectorEndRow).toBe(66)
          expect(s.selectorEndCol).toBe(11)

          expect(s.ruleStartRow).toBe(66)
          expect(s.ruleStartCol).toBe(13)
          expect(s.ruleEndRow).toBe(66)
          expect(s.ruleEndCol).toBe(26)
        when ".long-class2"
          expect(s.selectorStartRow).toBe(66)
          expect(s.selectorStartCol).toBe(29)
          expect(s.selectorEndRow).toBe(66)
          expect(s.selectorEndCol).toBe(41)

          expect(s.ruleStartRow).toBe(66)
          expect(s.ruleStartCol).toBe(43)
          expect(s.ruleEndRow).toBe(66)
          expect(s.ruleEndCol).toBe(56)
        when ".odd-formatted-class"
          expect(s.selectorStartRow).toBe(68)
          expect(s.selectorStartCol).toBe(0)
          expect(s.selectorEndRow).toBe(68)
          expect(s.selectorEndCol).toBe(20)

          expect(s.ruleStartRow).toBe(73)
          expect(s.ruleStartCol).toBe(0)
          expect(s.ruleEndRow).toBe(75)
          expect(s.ruleEndCol).toBe(14)

  xdescribe "when scanning a large project", ->
    # timed performance tests
