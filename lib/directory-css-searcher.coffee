{File, Directory} = require 'atom'
SearcherCache = require './searcher-cache'
chokidar = require('chokidar')

module.exports =
class DirectoryCSSSearcher

  constructor:  ->
    @searchResults = []
    @file = null
    @matchStartLine = null
    @cache = new SearcherCache

  supportedFileExtensions: [
      "*.css"
      "*.scss"
      "*.less"
  ]

  clear: ->
    @searchResults = []
    @file = null
    @matchStartLine = null

  findFilesThatContain:(selector) ->
    re = selector + '\\s*\\{'
    id_reg = new RegExp(re)

    #TODO check the cache

    if atom.config.get('quick-editor.stylesDirectory') is ''
      paths = atom.project.getDirectories()
    else
      paths = [new Directory(atom.config.get('quick-editor.stylesDirectory'))]

    atom.workspace.defaultDirectorySearcher.search(
      paths,
      id_reg,
      {
        didMatch: @matchCallback.bind(@),
        didError: (e) -> console.error e.stack
        didSearchPaths: (n) -> return
        inclusions: @supportedFileExtensions
      }
    )
    .then () =>
      return unless @searchResults.length
      @cacheResult()
      filePath = @searchResults[0].filePath
      @matchStartLine = @searchResults[0].matches[0].range[0][0]
      @file = new File filePath, false

  cacheResult: ->
    markupFilePath = atom.workspace.getActiveTextEditor().getPath()
    for result in @searchResults
      @cache.put(markupFilePath, result.filePath)


  searchCache: ->
    #TODO Implement me


  matchCallback: (match) ->
    @searchResults.push(match)

  getSelectorText: () ->
    if @file
      @file.read().then (content) =>
        lineNumber = 0
        text = ""
        for ch in content
          if lineNumber >= @matchStartLine
            text += ch
            if ch is "{"
              if not openBraces? then openBraces = 1 else openBraces++
            if ch is "}" and openBraces
              openBraces--
              break if openBraces is 0
          lineNumber++ if ch is "\n" or ch is "\r\n"
        return [true,
                {text: text,
                start: @matchStartLine,
                end: lineNumber,
                file: @file}]
    else
      return new Promise (resolve, reject) ->
        resolve([false, {text: null, start: null, end: null, file: null}])
