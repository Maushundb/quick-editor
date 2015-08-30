SelectorInfoFactory = require './selector-info-factory'

module.exports =
class CssLessScssParser

  constructor: (@path) ->
    @comment = false
    @row = @col = @i = 0
    @selectorInfos = []
    @text = ''

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
  # * `ruleStartRow` {Int}         the row the style rule
  # * `ruleStartCol` {Int}         the column the style rule starts
  # * `ruleEndRow' {Int}           row where the rule ends
  # * `ruleEndCol` {Int}           column where the rule ends
  # * `filePath` {String}          the path to the file containing this selector
  parse: (text) ->
    ## TODO NESTED CLASSES SHOULD APPEAR AS PARENT CHILD if PARENT { CHILD {}}
    @text = text

    # Only handles outer level rules and comments
    while @i < @text.length
      switch @text[@i]
        when '\n', '\r\n', '\r'
          @newLine()
        when '/'
          if @text[@i + 1] is '/'
            @comment = true
        when ' ' then break
        else
          break if @comment
          @parseSelector()
      @next()

    return @selectorInfos


  # Responsible for parsing one or more selectors up until '{', creating
  # nessesary factories, then passing control to @parseRule
  parseSelector: ->
    f = new SelectorInfoFactory(@path)
    factories = []
    currLine = ''

    while @i < @text.length
      currLine += @text[@i]

      switch @text[@i]
        when '\n', '\r\n', '\r'
          @newLine()
        when '/'
          if @text[@i + 1] is '/'
            @comment = true
        when '{'
          break if @comment
          rawSelector = currLine.replace(/^\s+|\s+$|\s*\{/g, '')

          f.set "selectorEndRow", lastSelLoc[0]
          # do not include '{' and any preceding spaces
          f.set "selectorEndCol", lastSelLoc[1] + 1 # exclusive upper bound

          if rawSelector.split(/,\s*/g).length > 1 # "h1, h2, h3 {"
            selector = rawSelector.split(/,\s*/g)[0].trim()
            multipleSelectors = true
          else if rawSelector.split(/\s+/g).length > 1 # .id h1 {
            # only care about last selector
            selector = rawSelector.split(/\s+/g).pop()
          else
            selector = rawSelector

          f.set "selectorGroup", rawSelector

          if multipleSelectors
            # Creates a factory for each individual selector
            selectors = rawSelector.split(/,\s*/g)
            for j in [1...selectors.length]
              otherSelector = selectors[j]
              fCopy = f.clone()
              fCopy.set "selector", otherSelector
              switch otherSelector[0]
                when "." then fCopy.setClass()
                when "#" then fCopy.setId()
                else fCopy.setTag()
              factories.push fCopy

          switch selector[0]
            when "." then f.setClass()
            when "#" then f.setId()
            else f.setTag()

          f.set "selector", selector
          factories.push f
          @next()
          @parseRule(factories)
          return

        else
          unless @text[@i].match(/\s/)
            lastSelLoc = [@row, @col]
            unless f.selectorStartSet()
              f.set "selectorStartRow", lastSelLoc[0]
              f.set "selectorStartCol", lastSelLoc[1]

      @next()

  # Responsible for parsing a single selector rule with possible nesting
  # * `factories` [SelectorInfoFactory]     An array of one or more factories
  #                                         that need to be updated with info
  #                                         about the preceeding rule, and then
  #                                         created
  parseRule: (factories) ->
    currLine = ''
    # All factories share the same state, so any can be used for control flow
    leadFactory = factories[0]

    while @i < @text.length
      currLine += @text[@i] #TODO might wanna do this after and remove -1s
      switch @text[@i]
        when '\n', '\r\n', '\r'
          @newLine()
          currLine = ''
        when '/'
          if @text[@i + 1] is '/'
            @comment = true
        when ';'
          if not leadFactory.ruleStartSet()
            f.set "ruleStartRow", @row for f in factories
            f.set "ruleStartCol", (@col - (currLine.length - 1)) for f in factories
          lastRuleLoc = [@row, @col]
        when '{'
          # recurse on nested classes
          @i -= (currLine.length - 1)
          @col = 0
          @parseSelector()
        when '}'
          f.set "ruleEndRow", lastRuleLoc[0] for f in factories
          f.set "ruleEndCol", lastRuleLoc[1] + 1 for f in factories # +1 ???
          @selectorInfos.push(f.create(@path)) for f in factories
          return

      @next()

  newLine: ->
    @row++; @col = -1; @comment = false

  next: ->
    @col++; @i++

  malformedCSSRule: ->
    throw new Error "malformed css rule"
