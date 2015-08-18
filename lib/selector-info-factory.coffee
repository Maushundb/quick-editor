
module.exports =
class SelectorInfoFactory

  # Creates a SelectorInfo {Object} with the following properties:
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
  constructor: ->
    @reset()

  reset: ->
    selector, selectorGroup,
    selectorStartRow, selectorStartCol, selectorEndRow, selectorEndCol,
    ruleStartRow, ruleStartCol, filePath = []

    id = clss = tag = off

  setId: ->
    @valueSet() if (clss or tag)
    @id = on

  setClass: ->
    @valueSet() if (id or tag)
    @clss = on

  setTag: ->
    @valueSet() if (clss or id)
    @tag = on

  addSelectorText: (c) ->
    @selector ?= ''
    @selector += c

  addSelectorGroupText: (c) ->
    @selectorGroup ?= ''
    @selectorGroup += c

  setSelectorStartRow: (r) ->
    @valueSet("selectorStartRow") if @selectorStartRow?
    @selectorStartRow = r

  setSelectorStartCol: (c) ->
    @valueSet("selectorStartCol") if @selectorStartCol?
    @selectorStartCol = c

  setSelectorEndRow: (r) ->
    @valueSet("selectorEndRow") if @selectorEndRow?
    @selectorEndRow = r

  setSelectorEndCol: (c) ->
    @valueSet("selectorEndCol") if @selectorEndCol?
    @selectorEndCol = c

  setRuleStartRow: (r) ->
    @valueSet("ruleStartRow") if @ruleStartRow?
    @ruleStartRow = r

  setRuleStartCol: (c) ->
    @valueSet("ruleStartCol") if @ruleStartCol?
    @ruleStartCol = c

  setFilePath: (p) ->
    @valueSet("filePath") if @filePath?
    @filePath = p

  create: ->
    #IMPLEMENT ME


  valueSet: (val)->
    throw new Error("value has already been set: " + val)
