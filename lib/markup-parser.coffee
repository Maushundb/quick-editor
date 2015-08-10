module.exports =
class MarkupParser
  constructor: (@textEditor = null) ->

  setEditor: (editor) ->
    @textEditor = editor

  parse: ->
    [bufferPos, line] = @getCurrentLine()
    @parseLine(bufferPos.column, line)

  getCurrentLine: ->
    bufferPos = @textEditor.getCursorBufferPosition()
    line = @textEditor.getBuffer().lineForRow(bufferPos.row)
    return [bufferPos, line]

  parseLine: (startCol, line) ->
    ###
    Does not support the following id or class types:
      id = "id1 i|d2", which isn't valid CSS
      class = "class='Th|is", which is technically valid CSS, but stupid
    Where "|" is the specified cursor position, if it matters
    ###
    outOfSelector = false
    lastQuote = null
    outerQuote = null

    # Determine is selection is a class or id and what the outer delim is
    `outer: //`
    for i in [startCol..-1]
      @textNotCSSIdentifier() if i is "-1"
      # covers the case where multiple types of quotations are used
      lastQuote = line[i] if line[i] is "\"" or line[i] is "\'"
      if outOfSelector
        switch line[i]
          when "s"
            prefix = "\\."
            `break outer`
          when "d"
            prefix = "#"
            `break outer`
          else continue
      if (line[i] is "=" and lastQuote)
        outOfSelector = true
        outerQuote = lastQuote

    @textNotCSSIdentifier() if not prefix?

    # set i to beginning of the selected class or id
    for i in [startCol..0]
      if line[i] is outerQuote or line[i] is " "
        i++
        break

    # capture the class or id
    selector=""
    for j in [i..line.length]
      @textNotCSSIdentifier() if j is line.length
      break if line[j] is outerQuote or line[j] is " "
      selector += line[j]

    return prefix + selector

  textNotCSSIdentifier: ->
    e = new Error "Selected text is not a CSS identifier"
    throw e
