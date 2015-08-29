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
        when '\n', '\r\n'
          @row++; @col = -1
          @comment = false
        when '/'
          if @text[@i+1] is '/'
            @comment = true
        when ' ' then break
        else
          break if @comment
          @parseSelector()
      @col++
      @i++

    return @selectorInfos


  # Responsible for parsing one or more selectors up until '{', creating
  # nessesary factories, then passing control to @parseRule
  parseSelector: ->
    f = new SelectorInfoFactory(@path)
    factories = []
    currLine = ''

    while @i < @text.length
      currLine += @text[i]

      switch @text[@i]
        when '\n', '\r\n'
          @newLine()
          currLine = ''
        when '/'
          if @text[@i + 1] is '/'
            @comment = true
        when '{'
          offSet = currLine.replace(/^\s+/g,'').length - 1
          break if @comment
          rawSelector = currLine.replace(/^\s+|\s+$|\s*\{/g, '')
          f.setSelectorStartRow(@row)
          # remove leading but not trailing spaces
          f.setSelectorStartCol(@col - offSet)
          f.setSelectorEndRow(@row)
          # do not include '{' and any preceding spaces
          f.setSelectorEndCol(@col - (currLine.match(/\s*{/)[0].length - 1))

          if rawSelector.split(/,\s*/g).length > 1 # "h1, h2, h3 {"
            selector = rawSelector.split(/,\s*/g)[0].trim()
            multipleSelectors = true
          else if rawSelector.split(/\s+/g).length > 1 # .id h1 {
            # only care about last selector
            selector = rawSelector.split(/\s+/g).pop()
          else
            selector = rawSelector

          f.addSelectorGroupText rawSelector

          if multipleSelectors
            # Creates a factory for each individual selector
            selectors = rawSelector.split(/,\s*/g)
            for j in [1...selectors.length]
              otherSelector = selectors[j]
              factoryCopy = f.clone()
              factoryCopy.addSelectorText otherSelector
              switch otherSelector[0]
                when "." then factoryCopy.setClass()
                when "#" then factoryCopy.setId()
                else factoryCopy.setTag()
              factories.push factoryCopy

          switch selector[0]
            when "." then f.setClass()
            when "#" then f.setId()
            else f.setTag()

          f.addSelectorText selector
          factories.push f
          @next()
          @parseRule()

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
      switch @text[@i]
        when '\n', '\r\n'
          @newLine()
          currLine = ''
        when '/'
          if @text[@i + 1] is '/'
            @comment = true
        when ';'
          if not leadFactory.ruleStartSet()
            f.setRuleStartRow(@row) for f in factories
            # should include indent or spaces since last open brace
            if currLine.indexOf('{') > 0 #single line selector
              j = 0; j++ while (currLine[(currLine.length-1) - j] isnt '{')
              f.setRuleStartCol(@col - j + 1) for f in factories
            else f.setRuleStartCol(0) for f in factories
          lastRuleLoc = [@row, @col]
        when '{'
          # recurse on nested classes
          @i = 1 # TODO MOVE BACK
          @parseSelector()
        when '}'
          f.setRuleEndRow(lastRuleLoc[0]) for f in factories
          f.setRuleEndCol(lastRuleLoc[1] + 1)for f in factories # +1 ???
          @selectorInfos.push(f.create(@path)) for f in factories
          return

      @next()

  newLine: ->
    @row++; @col = -1; @comment = false

  next: ->
    @col++; @i++

  malformedCSSRule: ->
    throw new Error "malformed css rule"
