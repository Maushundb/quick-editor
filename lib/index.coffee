
module.exports =
class Index
  ###
  An index for storing a mapping between:
    key -> set of values
  ###

  constructor: ->
    @index = {}

  put: (key, val) ->
    unless @index[key]?
      @index[key] = new Set()
    @index[key].add val

  get: (key) ->
    ###
    Returns an array of all the values in the key's associated set.
    ###
    valueArray = []
    if @index[key]?
      it = @index[key].values()
      next = it.next()
      while not next.done
        valueArray.push(next.value)
        next = it.next()
    return valueArray

  removeValue: (key, val) ->
    @index[key].delete(val)
