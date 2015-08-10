MarkupParser = require '../lib/markup-parser'

describe "MarkupParser", ->
  [textEditor, parser] = []

  beforeEach ->
    waitsForPromise ->
      atom.workspace.open()
    runs ->
      textEditor = atom.workspace.getActiveTextEditor()
      parser = new MarkupParser
      parser.setEditor(textEditor)

  setupTextEditor = (text, pos) ->
    textEditor.setText(text)
    textEditor.setCursorBufferPosition(pos)

  it "gets the current line and buffer position", ->
    testLine= "<div id=\"test\"></div>"
    testPos = [0, 0]
    setupTextEditor(testLine, testPos)
    [pos, line] = parser.getCurrentLine()
    expect(pos).toEqual(testPos)
    expect(line).toEqual(testLine)

  it "determines if a selector is an id or class", ->
    testLine = "<div id=\"test\"></div>"
    testPos = [0, 11]
    setupTextEditor(testLine, testPos)
    idResult = parser.parse()

    testLine = "<div class=\"test\"></div>"
    testPos = [0, 13]
    setupTextEditor(testLine, testPos)
    classResult = parser.parse()

    expect(idResult[0]).toBe("#")
    expect(classResult[0..1]).toBe("\\.")


  it "returns the proper selector name for a lone selector", ->
    testLine = "<div id=\"test\"></div>"
    testPos = [0, 11]
    setupTextEditor(testLine, testPos)
    result = parser.parse()
    expect(result).toBe("#test")

  it "returns the class the cursor is over when two are separated by a space", ->
    testLine = "<div class=\"test_1 test_2\"></div>"
    testPos1 = [0, 17]
    testPos2 = [0, 20]

    setupTextEditor(testLine, testPos1)
    result1 = parser.parse()

    setupTextEditor(testLine, testPos2)
    result2 = parser.parse()

    expect(result1).toBe("\\.test_1")
    expect(result2).toBe("\\.test_2")

  it "returns the class or id the cursor is over when the element has both", ->
    testLine = "<div class=\"testc\" id = \"testi\"></div>"
    testPos1 = [0, 14]
    testPos2 = [0, 27]

    setupTextEditor(testLine, testPos1)
    result1 = parser.parse()

    setupTextEditor(testLine, testPos2)
    result2 = parser.parse()

    expect(result1).toBe("\\.testc")
    expect(result2).toBe("#testi")

  it "throws an error when class or id is not present", ->
    testLine = "<h2><%= link_to \"Sign In\", some_path %></h2>"
    testPos = [0, 20]
    setupTextEditor(testLine, testPos)
    expect(parser.parse).toThrow()
