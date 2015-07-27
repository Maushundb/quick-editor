# Change to use https://discuss.atom.io/t/how-to-import-and-use-directorysearch-in-atom/19205/3
# if performance is better
{File} = require 'atom'
module.exports = DirectoryCSSSearcher =
    searchResults: []
    file: null
    matchStartLine: null
    supportedFileExtensions: [
        "*.css"
        "*.scss"
        "*.less"
        "*.sass"
    ]

    findFilesThatContain:(selector) ->
      id_reg = new RegExp(selector)
      atom.workspace.scan id_reg, {paths: @supportedFileExtensions}, @matchCallback.bind(@)
      .then () =>
        filePath = @searchResults[0].filePath
        @matchStartLine = @searchResults[0].matches[0].range[0][0]
        @file = new File(filePath, false)

    matchCallback: (match) ->
      @searchResults.push(match)

    getSelectorText: () ->
      @file.read().then (content) =>
        lineNumber = 0
        text = ""
        for ch, i in content
          lineNumber++ if ch is "\n" or ch is "\r\n"
          if lineNumber >= @matchStartLine
            text += ch
            if ch is "{"
              if not stack?
                stack = 1
              else
                stack++
            if ch is "}" and stack
              stack--
              break if stack is 0
        return [text, @matchStartLine, lineNumber,  @file]
