

class Keyboard

  ## this class will be added to the 'body' tag
  OPEN_KEYBOARD_CLASS = 'keyboard-open'

  initWindowSize =
    height: 0
    width: 0

  ###
  # If there is focused input element, this variable will contain it unique id
  # otherwise it will be 'false'
  ###
  hasFocusedInput = false

  ###
  # Blur will fire with timeout, in case user select again element that will be blured timeout should be canceled
  ###
  blurTimeout = null;

  constructor: () ->
    ###
    # I'm using timeout case if page is loaded and keyboard is still open it will capture the size of small window
    # Keyboard will be opened if page was reloaded while input element was focused
    ###
    setTimeout(
      () ->
        initWindowSize.height = window.innerHeight
        initWindowSize.width = window.innerWidth
        return true
      600
    )
    this.bindListeners()

  bindListeners: () ->
    ## I need both window and focus listeners, case only one of them isn't providing enough data
    this.windowResizeListener()
    this.focusListeners();

  ###
  # Bind listener to window resizing
  ###
  windowResizeListener: () ->
    window.addEventListener 'resize', () ->
      bodyTag = document.getElementsByTagName('body')[0]
      if ( initWindowSize.height > window.innerHeight )
        if bodyTag.className.indexOf( OPEN_KEYBOARD_CLASS ) == -1
          bodyTag.className += bodyTag.className + ' ' + OPEN_KEYBOARD_CLASS
          keyboardOpen()
      else
        keyboardClose()

  ###
  # Binding focus and blur listeners to input and textarea elements
  ###
  focusListeners: () ->
    inputs = document.getElementsByTagName 'input'
    textareas = document.getElementsByTagName 'textarea'

    for input in inputs
      setUniqueId( input );
      input.addEventListener 'focus', () -> focusAction.apply( this )
      input.addEventListener 'blur', () -> blurAction.apply( this )

    for textarea in textareas
      setUniqueId( textarea );
      textarea.addEventListener 'focus', () -> focusAction.apply( this )
      textarea.addEventListener 'blur', () -> blurAction.apply( this )

    return true

  ###
  # This function will fired when input or textarea will get focus
  ###
  focusAction = () ->
    bodyTag = document.getElementsByTagName('body')[0]
    if bodyTag.className.indexOf( OPEN_KEYBOARD_CLASS ) == -1
      if this.type != 'checkbox' && this.type != 'radio' && this.type != 'submit'
        bodyTag.className += bodyTag.className + ' ' + OPEN_KEYBOARD_CLASS
        keyboardOpen()
    ###
    # I'm using unique id because blur has timeout and will fired with delay
    # and if user only moved focus from one input to another I don't want to change class to 'closed keyboard'
    ###
    hasFocusedInput = getUniqueId( this )

    if ( hasFocusedInput == getUniqueId( this ) && blurTimeout != null )
      clearTimeout( blurTimeout )

  ###
  # This function will fired when input or textarea will lose it focus
  ###
  blurAction = () ->
    thisInput = this
    blurTimeout = setTimeout(
      () ->
        if hasFocusedInput == getUniqueId( thisInput )
          keyboardClose()
          hasFocusedInput = false
          blurTimeout = null
      500
    )

  ###
  # This function will fire when keyboard is opening
  ###
  keyboardOpen  = () ->
    return true;

  ###
  # This function will fire when keyboard is closing
  ###
  keyboardClose  = () ->
    bodyTag = document.getElementsByTagName('body')[0]
    bodyTag.className = bodyTag.className.replace( OPEN_KEYBOARD_CLASS, '' )

  ###
  # Adding unique id to the given element
  ###
  setUniqueId = ( elm ) ->
    elm.setAttribute( 'data-unique-id', getRandomId() )

  ###
  # Return unique id of the given element
  ###
  getUniqueId = ( elm ) ->
    elm.getAttribute( 'data-unique-id' )

  ###
  # Creating random ID
  # I need this ID in order to allow delay in blur function
  # (delay I need, case keyboard is opening and closing with animation)
  ###
  getRandomId = () ->
    return Math.floor((Math.random() * 9999999) + 1);




window.onload = () ->
  new Keyboard