# Change to use https://discuss.atom.io/t/how-to-import-and-use-directorysearch-in-atom/19205/3
# if performance is better
{File} = require 'atom'
module.exports = DirectoryCSSSearcher =
    searchResults: []
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
        return new File(@searchResults[0].filePath, false)

    matchCallback: (match) ->
      @searchResults.push(match)
      console.log(match)

    getTextForSelector: (selector, file) ->
      file.read()
      .then (content) ->
        
