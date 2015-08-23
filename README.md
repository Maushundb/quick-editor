# Quick Editor
[![Build Status](https://travis-ci.org/Maushundb/quick-editor.svg?branch=master)](https://travis-ci.org/Maushundb/quick-editor)

Quickly select and edit CSS/LESS/SCSS styles from the context of your markup instead of cluttering up your coding environment with extra panes.
Inspired by [Brackets](http://brackets.io/)'s quick edit feature.

![Quick Edit Demo](https://github.com/Maushundb/quick-editor/blob/master/quick-edit.gif?raw=true)

# Install
```
apm install quick-editor
```

Or search for <code>quick-editor</code> in Atom settings view.

# Key Bindings
The default <code>shift-cmd-e</code> or <code>shift-ctrl-e</code>will toggle quick-edit while the cursor is over a CSS id or class

This can be edited by defining a keybinding as follows

```coffee
'.platform-darwin atom-text-editor':
  'shift-cmd-e': 'quick-editor:quick-edit'

'.platform-linux atom-text-editor, .platform-win32 atom-text-editor':
  'shift-ctrl-e': 'quick-editor:quick-edit'
```

# Settings
#### Styles Directory
Specify an absolute path to your styles directory when working in a large project to improve performance.


# Release Notes:

## 0.4.1
* Added keybindings for Windows and Linux

## 0.4.0
* Added the ability to specify a styles directory to improve performance on larger projects
* Fixed bug with context menu not working
* Fixed bug with markup parsing

## 0.3.0
* Added the ability to add a new selector

### Full change log [here](./CHANGELOG.md)

# Coming Soon:
  * Multiple files with same selector
  * Caching for larger projects
  * Show the name of CSS file
  * Link to open in new tab
  * Editor updates when changed in another file at the same time
  * Support SASS and Stylus
  * Multiple matches in the same file
  * Support Jade
  * Add support for javascript functions
  * Add support for color picking
