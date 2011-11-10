fs = require 'fs'
_ = require 'underscore'

# This a weirdo file. We don't create a Window class, we just add stuff to
# the DOM window.
windowAdditions =
  appRoot: OSX.NSBundle.mainBundle.resourcePath

  path: null

  startup: ->
    @path = $atomController.path.toString()
    @setTitle (_.last @path.split '/') or 'Untitled Document'

    # Remember sizing!
    defaultFrame = x: 0, y: 0, width: 600, height: 800
    frame = atom.storage.get "window.frame.#{@path}", defaultFrame
    rect = OSX.CGRectMake(frame.x, frame.y, frame.width, frame.height)
    $atomController.window.setFrame_display rect, true

    $atomController.window.makeKeyWindow
    atom.trigger 'window:load'

  shutdown: ->
    frame = $atomController.window.frame
    x = frame.origin.x
    y = frame.origin.y
    width = frame.size.width
    height = frame.size.height

    atom.storage.set "window.frame.#{@path}", {x:x, y:y, width:width, height:height}

  showConsole: ->
    $atomController.webView.inspector.showConsole true

  setTitle: (title) ->
    $atomController.window.title = title

  reload: ->
    @close()
    OSX.NSApp.createController @path

  open: (path) ->
    $atomController.window.makeKeyAndOrderFront $atomController
    if atom.document.open path
      atom.trigger 'window:open', path
    else
      atom.app.open path

  close: (path) ->
    @shutdown()
    $atomController.close
    atom.trigger 'window:close', path

  handleKeyEvent: ->
    atom.keybinder.handleEvent arguments...

  triggerEvent: ->
    atom.trigger arguments...

  canOpen: (path) ->
    false

for key, value of windowAdditions
  console.warn "DOMWindow already has a key named `#{key}`" if window[key]
  window[key] = value
