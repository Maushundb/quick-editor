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
      @cache[key] = []
    @cache[key].push(value)
