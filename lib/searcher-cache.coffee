QuickEditorCache = require './quick-editor-cache'

module.exports =
class SearcherCache extends QuickEditorCache
  ###
  A cache for storing a mapping between:
    html files -> a list of all the style files that reference selectors used in
                  the html files used as a key
  ###
  put: (key, value) ->
    unless @containsKey(key)
      @cache[key] = new Set()
    @cache[key].add(value)

  get: (key) ->
    ###
    Returns an array of all the values in the key's associated set.
    ###
    if @cache[key] isnt undefined
      valueArray = []
      it = @cache[key].values()
      next = it.next()
      while not next.done
        valueArray.push(next.value)
        next = it.next()
      return valueArray
    else null
