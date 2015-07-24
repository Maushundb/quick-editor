# Change to use https://discuss.atom.io/t/how-to-import-and-use-directorysearch-in-atom/19205/3
# if performance is better
module.exports = DirectoryCSSSearcher =

    supportedFileExtensions: [
        "css"
        "scss"
        "less"
        "sass"
    ]

    findFilesThatContain:(identifier) ->
      id_reg = new RegExp(identifier)
      directories = atom.project.getDirectories()
      filePromises = directories.map (f) => @searchDirectory(f, id_reg)
      filePromises = Promise.all(filePromises).then (files) =>
        files = @flattenArray(files).filter((i) -> i isnt null)
      return filePromises

    searchDirectory: (dir, regex) ->
      new Promise (resolve, reject) =>
        results = []
        dir.getEntries (err, entries) =>
          reject(err) if err isnt null
          for entry in entries
            result = null
            name = entry.getBaseName()
            if name.slice(0, 1) isnt "."
              if entry.isFile() and name.split(".").pop() in @supportedFileExtensions
                result = @searchFile(entry, regex)
              else if entry.isDirectory()
                result = @searchDirectory(entry, regex)
            # This pushes promises that resolve to null as well TODO
            results.push result if result isnt null
          resolve(Promise.all(results))

    searchFile: (file, regex) ->
      new Promise (resolve, reject) ->
        file.read(true)
          .then (content) ->
            result = regex.test(content)
            resolve(if result then file else null)
          .catch (e) ->
            console.error "Error occured when searching file", e

    #Solution from https://gist.github.com/th507/5158907
    arrayEqual: (a, b) ->
      i = Math.max(a.length, b.length, 1)
      continue while(i-- >= 0 and a[i] is b[i])
      return (i is -2)

    flattenArray: (arr) ->
    	r = []
    	while (!@arrayEqual(r, arr))
    		r = arr
    		arr = [].concat.apply([], arr)
    	return arr
