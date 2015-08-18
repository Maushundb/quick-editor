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
  # * `selectorGroup`              the entire selector group containing this
  #                                selector, or undefined if there is only one
  #                                selector in the rule.
  # * `selectorStartRow` {Int}     the row the selector text starts
  # * `selectorStartCol` {Int}     the column  the selector text starts
  # * `selectorEndRow` {Int}       the row the selector text ends
  # * `selectorEndCol` {Int}       the column  the selector text ends
  # * `ruleStartRow` {Int}         the row the style rule i.e. "{" begins
  # * `ruleStartCol` {Int}         the column the style rule ends
  # * `filePath` {String}          the path to the file containing this selector
  parse: (text) ->
    row = col = openBraces = 0
    inRule = inValue = false

    sif = new SelectorInfoFactory
    selectorInfos = []

    for c in text
      switch c
        when '\n'
          row++
          continue
        when '.'
          if not inValue then sif.setClass() else continue
        when '#'
          if not inValue then sif.setId() else continue
        when ":"
          inValue = true
        when ';'
          inValue = false
        when '{'
          inRule = true unless inRule
          openBraces += 1
        when '}'
          openBraces -= 1
          if openBraces is 0
            inRule = false
            selectorInfos.push sif.create()
        else continue

    @malformedCSSRule() if openBraces isnt 0
    return selectorInfos


  malformedCSSRule: ->
    throw new Error "malformed css rule"
