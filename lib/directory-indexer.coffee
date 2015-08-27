Index = require './index'
CssLessScssParser = require './CSS-LESS-SCSS-parser'
chokidar = require 'chokidar'
{File, Directory} = require 'atom'

module.exports =
class DirectoryIndexer

  supportedFileExtensions: [
      "css"
      "scss"
      "less"
  ]

  # A class that indexes the current project on style selectors and file name
  #
  # It produces mappings
  #   Selector -> {SelectorInfo}
  #   File -> {SelectorInfo}
  # for every selector and style file in the project path.
  #
  # Only one copy of each {SelectorInfo} object is retained but can be queried
  # in constant time by either the selector text or by the file which contains
  # it.
  constructor: ->
    @selectorIndex = new Index
    @fileIndex = new Index
    @selectorInfos = {}
    @nextInfoIndex = 0

  # Indexes the current project
  indexProject: ->
    if atom.config.get('quick-editor.stylesDirectory') is ''
      directories = atom.project.getDirectories()
    else
      directories = [new Directory(atom.config.get('quick-editor.stylesDirectory'))]
    @indexDirectory(dir) for dir in directories

  # Indexes the given directory
  # * `dir` the {Directory} to be indexed
  #
  # Throws error if directory cannot be opened
  indexDirectory: (dir) ->
    dir.getEntries (error, entries) =>
      if error isnt null
        console.error(error, error.stack)
        throw error
      for entry in entries
        if entry.isFile()
          @indexFile(entry)
        else
          @indexDirectory(entry)


  # Creates a mapping of all the selectors in the given file
  # * `file` the {File} to index
  indexFile: (file) ->
    ext = file.getBaseName().split(".").pop()
    return if not (ext in @supportedFileExtensions)
    file.read().then (text) => file.getRealPath().then (path) =>
      selectorList = @extractAllSelectors(text, ext, path)
      for selectorInfo in selectorList
        i = @nextInfoIndex++
        @selectorInfos[i] = selectorInfo
        @selectorIndex.put(selectorInfo.selector, i)
        @fileIndex.put(file, i)
    .catch (e) ->
      console.error(e, e.stack)

  # Extracts all the selectors from the given file text
  # * `text` {String} the text of a given style file
  # * `ext` {String} the extension representing the syntax of the text
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
  # * `ruleStartRow` {Int}         the row the style rule starts
  # * `ruleStartCol` {Int}         the column the style rule starts
  # * `ruleEndRow' {Int}           row where the rule ends
  # * `ruleEndCol` {Int}           column where the rule ends
  # * `filePath` {String}          the path to the file containing this selector
  extractAllSelectors: (text, ext, path) ->
    if ext is "sass"
      return #TODO
    else
      parser = new CssLessScssParser(path)
    return parser.parse(text)

  # Returns all instances of {SelectorInfo} whose file property is a given file
  queryByFile: (file) ->
    result = []
    result.push(@selectorInfos[i]) for i in @fileIndex.get(file)
    return result

  # Returns all instances of {SelectorInfo} whose refencing a given selector
  queryBySelector: (selector) ->
    result = []
    result.push(@selectorInfos[i]) for i in @selectorIndex.get(selector)
    return result
