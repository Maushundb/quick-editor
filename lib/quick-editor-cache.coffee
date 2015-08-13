
module.exports =
class QuickEditorCache
  ###
  A cache for storing a mapping between:
    html files -> most recently edited css file that styles it

  TODO: when used for both css and js, extend the class to validate file types
  ###

  constructor: ->
    @cache = {}

  put: (key, value) ->
    @cache[key] = value

  get: (key) ->
    if  @cache[key] isnt undefined then @cache[key] else null

  containsKey: (key) ->
     if @cache[key] isnt undefined then return true else return false

  invalidate: ->
    @cache = {}
