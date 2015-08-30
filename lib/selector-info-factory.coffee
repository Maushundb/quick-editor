
module.exports =
class SelectorInfoFactory

  # Creates a SelectorInfo {Object} with the following properties:
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
  constructor: (@path, @data) ->
    unless @data
      @data = {
        selector: null
        selectorGroup: null
        selectorStartRow: null
        selectorStartCol: null
        selectorEndRow: null
        selectorEndCol: null
        ruleStartRow: null
        ruleStartCol: null
        ruleEndRow: null
        ruleEndCol: null
        filePath: @path
      }

    @id = @clss = @tag = false

  setId: ->
    @valueSet() if (@clss or @tag)
    @id = on

  setClass: ->
    @valueSet() if (@id or @tag)
    @clss = on

  setTag: ->
    @valueSet() if (@clss or @id)
    @tag = on

  typeSet: ->
    return @id or @clss or @tag

  set: (key, val) ->
    @valueSet(key) if @data[key]?
    @data[key] = val

  get: (key) ->
    @data[key]

  selectorStartSet: ->
    return @data["selectorStartRow"]?

  ruleStartSet: ->
    return @data["ruleStartRow"]?

  create: ->
    for key, val in @data
      throw new Error "incomplete selector info" if not val?
    return @data

  clone: ->
    return new SelectorInfoFactory(@path, JSON.parse(JSON.stringify(@data)))

  valueSet: (val)->
    throw new Error("value has already been set: " + val)
