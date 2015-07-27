{File} = require 'atom'
module.exports =
class DirectoryCSSSearcher
  constructor: ->
    @searchResults = []
    @file = null
    @matchStartLine = null

  supportedFileExtensions: [
      "*.css"
      "*.scss"
      "*.less"
  ]

  findFilesThatContain:(selector) ->
    id_reg = new RegExp(selector)
    atom.workspace.scan id_reg, {paths: @supportedFileExtensions}, @matchCallback.bind(@)
    .then () =>
      filePath = @searchResults[0].filePath
      @matchStartLine = @searchResults[0].matches[0].range[0][0]
      @file = new File filePath, false

  matchCallback: (match) ->
    @searchResults.push(match)

  getSelectorText: () ->
    @file.read().then (content) =>
      lineNumber = 0
      text = ""
      for ch in content
        if lineNumber >= @matchStartLine
          text += ch
          if ch is "{"
            if not stack? then stack = 1 else stack++
          if ch is "}" and stack
            stack--
            break if stack is 0
        lineNumber++ if ch is "\n" or ch is "\r\n"
      return [text, @matchStartLine, lineNumber,  @file]

  clear: ->
    @searchResults = []
    @file = null
    @matchStartLine = null
