# Quick Editor
[![Build Status](https://travis-ci.org/Maushundb/quick-editor.svg?branch=master)](https://travis-ci.org/Maushundb/quick-editor)

Quickly select and edit CSS/LESS/SCSS styles from the context of your markdown instead of cluttering up your coding environment with extra panes.
Inspired by [Brackets](http://brackets.io/)'s quick edit feature.

![Quick Edit Demo](https://github.com/Maushundb/quick-editor/blob/master/quick-edit.gif?raw=true)

# Install
```
apm install quick-editor
```

Or search for <code>quick-editor</code> in Atom settings view.

# Key Bindings
The default <code>shift-cmd-e</code> will toggle quick-edit while the cursor is over a CSS id or class

This can be edited by defining a keybinding as follows

```coffee
'atom-text-editor':
  'shift-cmd-e': 'quick-editor:quick-edit'
```


# Release Notes: [here](./CHANGELOG.md)

# Coming Soon:
  * Refactor to use space-pen View
  * Create a selector
  * Support SASS and Stylus
  * Multiple files with same selector
  * Multiple matches in the same file
  * Support Jade
  * Hash option for larger projects
  * Specifying a styles directory for larger projects to reduce search time
  * Add support for javascript functions
  * Add support for color picking
