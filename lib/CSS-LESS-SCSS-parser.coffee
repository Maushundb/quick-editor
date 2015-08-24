SelectorInfoFactory = require './selector-info-factory'

module.exports =
class CssLessScssParser

  constructor: (@path) ->

  # Extracts all the selectors from the given file text
  # * `text` {String}              the text of a given style file
  #
  # Returns an array of SelectorInfo {Object}s with the following properties:
  # * `selector` {String}          the text of the selector (note: comma
  #                                separated selector groups like "h1, h2"
  #                                are broken into separate selectors)
  # * `selectorGroup`              the entire selector group containing this
  #                                selector. Same as selector if only one.
  # * `selectorStartRow` {Int}     the row the selector text starts
  # * `selectorStartCol` {Int}     the column  the selector text starts
  # * `selectorEndRow` {Int}       the row the selector text ends
  # * `selectorEndCol` {Int}       the column  the selector text ends
  # * `ruleStartRow` {Int}         the row the style rule i.e. after "{" starts
  # * `ruleStartCol` {Int}         the column the style rule starts
  # * `ruleEndRow' {Int}           row where the rule ends
  # * `ruleEndCol` {Int}           column where the rule ends
  # * `filePath` {String}          the path to the file containing this selector
  parse: (text) ->
    ## TODO NESTED CLASSES SHOULD APPEAR AS PARENT CHILD if PARENT { CHILD {}}
    comment = false

    selectorInfos = []
    row = col = 0

    i = 0
    # Only handles outer level rules and comments
    while i < text.length
      switch text[i]
        when '\n', '\r\n'
          row++
          col = -1
          comment = false
        when '/'
          if text[i+1] is '/'
            comment = true
        when ' ' then break
        else
          break if comment
          [infos, row, col, i] = @parseRule(text, {row: row, col: col, i: i})
          selectorInfos.push(si) for si in infos
          debugger
      col++
      i++

    return selectorInfos

  # Responsible for parsing a single css rule with possible nesting
  # * `text` {String}      The text being parsed
  # * `loc` {Object}
  #    * `row`             The row in the text the parser is at
  #    * `col`             The column in the text the parser is at
  #    * `i`               The exact position in text's string the parser is at
  # * `cont` {Bool}        A flag telling the function to recurse on nested
  #                        classes. This needs to be turned off when creating
  #                        multiple SelectorInfos for selectors like h1, h2 or
  #                        else any nested classes will be duplicated
  # * `sel` {String}       The selector pre-assigned by a parent call of this
  #                        function in the case of multiple selectors
  # * `group` {String}     The group pre-assigned by a parent call of this
  #                        function in the case of multiple selectors
  #
  # Returns an array of 1 or  more {SelectorInfo}s
  parseRule: (text, loc, cont=true, sel=undefined, group=undefined) ->
    f = new SelectorInfoFactory(@path)
    selectorInfos = []
    comment = false
    row = loc.row
    col = loc.col
    currLine = if group? then group else ''

    i = loc.i
    `outer: //`
    while i < text.length
      debugger if row is 31
      currLine += text[i]
      infos = []
      switch text[i]
        when '\n', '\r\n'
          row++
          col = -1
          comment = false
          currLine = ''
        when '/'
          if text[i+1] is '/'
            comment = true
        when '{'
          offSet = currLine.replace(/^\s+/g,'').length - 1
          break if comment
          rawSelector = currLine.replace(/^\s+|\s+$|\s*\{/g, '')
          if not f.typeSet() #not reaching a nested class
            f.setSelectorStartRow(row)
            # remove leading but not trailing spaces
            f.setSelectorStartCol(col - offSet)
            f.setSelectorEndRow(row)
            f.setSelectorEndCol(col - 1) # do not include '{'

            f.setRuleStartRow(row)
            f.setRuleStartCol(col)

            if not sel
              if rawSelector.split(/,\s*/g).length > 1 # "h1, h2, h3 {"
                if group?
                  #the current call is the second or above selector in the group
                  selector = rawSelector.substring(
                    group.length,
                    currLine.length
                  ).split(/,\s*/g)[0].trim()
                else
                  selector = rawSelector.split(/,\s*/g)[0].trim()
              else if rawSelector.split(/\s+/g).length > 1 # .id h1 {
                # only care about last selector
                debugger
                selector = rawSelector.split(/\s+/g).pop()
              else
                selector = rawSelector

            else
              selector = sel

            switch selector[0]
              when "." then f.setClass()
              when "#" then f.setId()
              else f.setTag()

            f.addSelectorText selector
            f.addSelectorGroupText rawSelector

            if not group?
            # the current call is the first group in multiple and needs to
            # make recursive calls to create SelectorInfos for each proceeding
            # selector
              selectors = rawSelector.split(/,\s*/g)
              for j in [1...selectors.length]
                selector = selectors[j]
                 #only need infos, throw away row col and i
                [infos, xRow, xCol, xI] = @parseRule(
                  text, {row: row, col: col, i: i}, # starts at { again to copy
                  false,
                  selector,
                  rawSelector
                )
          else
            if cont # recurse on nested classes
              [infos, row, col, i] = @parseRule(
                text,
                {row: row, col: col - offSet, i: i - offSet }
              )
        when '}'
          f.setRuleEndRow(row)
          f.setRuleEndCol(col)
          selectorInfos.push(f.create())
          `break outer`

      selectorInfos.push(si) for si in infos
      col += 1
      i++

    if text[i + 1] is '\n' or text[i + 1] is '\r\n'
      return [selectorInfos, row + 1, 0, i + 1]
    else return [selectorInfos, row, col + 1, i + 1]



  malformedCSSRule: ->
    throw new Error "malformed css rule"
