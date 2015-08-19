SelectorInfoFactory = require './selector-info-factory'

module.exports =
class CssLessScssParser

  constructor: (@path) ->

  # Extracts all the selectors from the given file text
  # * `text` {String} the text of a given style file
  #
  # Returns an array of SelectorInfo {Object}s with the following properties:
  # * `selector` {String}          the text of the selector (note: comma
  #                                separated selector groups like "h1, h2"
  #                                are broken into separate selectors)
  # * `selectorGroup` {String}     the entire selector group containing this
  #                                selector, or undefined if there is only one
  #                                selector in the rule.
  # * `selectorStartRow` {Int}     the row the selector text starts
  # * `selectorStartCol` {Int}     the column  the selector text starts
  # * `selectorEndRow` {Int}       the row the selector text ends
  # * `selectorEndCol` {Int}       the column  the selector text ends
  # * `ruleStartRow` {Int}         the row the style rule i.e. "{" begins
  # * `ruleStartCol` {Int}         the column the style rule ends
  # * `declListStartRow' {Int}     row where the declaration list for the rule
  #                                starts
  # * `declListStartCol` {Int}     column in line where the declaration list for
  #                                the rule starts
  # * `declListEndRow` {Int}       line where the declaration list for the rule
  #                                ends
  # * `declListEndCol` {Int}       column in the line where the declaration list
  #                                for the rule ends
  # * `filePath` {String}          the path to the file containing this selector
  parse: (text) ->
    row = col = openBraces = 0
    oneSlash = comment = false

    selectorInfos = []

    # Only handles outer level rules and comments
    for (i = row = col = 0, i < text.length; i++, col++)
      switch text[i]
        when '\n'
          row++
          col = -1
          comment = oneSlash = false
        when '/'
          if oneSlash
            comment = true
            oneSlash = false
          else
            oneSlash = true
        when ' ' then continue
        else
          continue if comment
          infos, row, col, i = parseRule(text, {row: row, col: col, i: i})
          selectorInfos.push(si) for si in infos


    return selectorInfos

  # Responsible for parsing a single css rule with possible nesting
  parseRule: (text, loc, cont=true, group=undefined) ->
    f = new SelectorInfoFactory(@path)
    selectorInfos = []
    inRule = inValue = oneSlash = comment = multiSel = false
    row = loc.row
    col = loc.col      #h1,h2,h3 {   }
    currLine = group if group? else ''

    for (i = loc.i; i < text.length; i++, col++)
      currLine += text[i]
      switch text[i]
        when '\n'
          row++
          col = -1
          comment = oneSlash = false
          currLine = ''
        when '/'
          if oneSlash
            comment = true
            oneSlash = false
          else
            oneSlash = true
        when '{'
          continue if comment
          if not f.typeSet() # the first rule seen
            f.ruleStartRow = row
            f.ruleStartCol = col
            if currLine.trim().split(" ").length > 1
              switch currLine[0]
                when "." then f.setClass row, col - currLine.length
                when "#" then f.setId row, col - currLine.length
                else f.setTag row, col - currLine.length
              split = currLine.trim().split(" ")
              f.addSelectorText split[split.length - 1]
              f.addSelectorGroupText currLine.trim()
            if currLine.trim().split(",").length > 1
              if group? #the current call is the second or above selector
                selector = currLine.substring(group.length, currLine.length).split(",")[0].trim()

              switch selector[0]
                when "." then f.setClass row, col - currLine.length
                when "#" then f.setId row, col - currLine.length
                else f.setTag row, col - currLine.length
              f.addSelectorText selector
              f.addSelectorGroupText currLine.trim()

              if not group?


          else # the current selector is nested within another


          inRule = true


        # else
        #   continue if comment
        #   if not inRule
        #     f.addSelectorText text[i]
        #     if not f.typeSet()
        #       if text[i] is '.'
        #         f.setClass r, c
        #       if text[i] is '#'
        #         f.setId r, c
        #       else
        #         f.setTag r, c
        #     if f.typeSet() and text[i] is ' '
        #   if not inRule and text[i] is ','



  malformedCSSRule: ->
    throw new Error "malformed css rule"
