class BaseCell

  #static defaults that cant be represented solely by CSS (e.g., fontsize is needed to compute heights)
  @defaults = {}
  @setDefault = (k,v) -> @defaults[k] = v
  @getDefault = (k) -> @defaults[k]

  #@TODO I want to pull all the CssCollector bits into a seperate module and have BaseCell Extend that class

  constructor: (@parentSvg, myCssSelector, width, height) ->
    #@TODO validate width and height are numerics with no px pct etc.
    @width = parseInt(width)
    @height = parseInt(height)
    @cssBucket = {}

    if _.isString myCssSelector
      @myCssSelector = [myCssSelector]
    else if _.isArray myCssSelector
      @myCssSelector = myCssSelector
    else
      throw new Error "Invalid myCssSelector: " + myCssSelector

  setConfig: (@config) ->

  draw: () ->
    @_draw()
    @_generateDynamicCss()

  setCss: (cssLocation, cssAttr, cssValue) ->

    # NB we are only supporting class and id based selector parts for now
    # and we cast strings to class selectors by default
    ensurePartsAreSupportedCss = (cssSelectorParts) ->
      cssSelectorParts.map (part) ->
        return part if _.startsWith(part, '.')
        return part if _.startsWith(part, '#')
        return '.' + part

    cssLocationKey = null
    if cssLocation is ''
      cssLocationKey = @myCssSelector
    else if _.isString cssLocation
      cssLocationKey = @myCssSelector.concat(cssLocation)
    else if _.isArray cssLocation
      cssLocationKey = @myCssSelector.concat(cssLocation)
    else
      throw new Error "Invalid cssLocation: " + JSON.stringify(cssLocation)

    validCssLocationKey = ensurePartsAreSupportedCss cssLocationKey

    transformedInstructions = @_transformCssInstructions validCssLocationKey, cssAttr, cssValue
    _.forEach transformedInstructions, (i) =>
      cssSelector = i.location.join ' '
      @cssBucket[cssSelector] = {} unless _.has @cssBucket, cssSelector
      @cssBucket[cssSelector][i.attribute] = i.value

  _transformCssInstructions: (inLocation, inAttr, inValue) ->
    instructions = []

    #@TODO refactor into a test/run chain

    if inAttr is 'font-color'
      setFillOnThisElement = { attribute: 'fill', value: inValue}
      thisLocation = _.clone inLocation
      finalCssComponent = thisLocation[thisLocation.length-1]
      thisLocation[thisLocation.length-1] = "text#{finalCssComponent}"
      setFillOnThisElement.location = thisLocation

      setFillOnAllChildElements = { attribute: 'fill', value: inValue, location: inLocation.concat('text') }

      instructions.push setFillOnThisElement
      instructions.push setFillOnAllChildElements

    else
      instructions.push { location: inLocation, attribute: inAttr, value: inValue}

    return instructions

  _draw: () ->
    throw new Error "BaseCell._draw must be overridden by child"

  _generateDynamicCss: () ->

    cssBlocks = _.map @cssBucket, (cssDefinition, cssSelector) ->
      cssDefinitionString = _.map(cssDefinition, (cssValue, cssAttr) -> "#{cssAttr}: #{cssValue};").join('\n')
      "#{cssSelector} { #{cssDefinitionString} }"

    style = $('<style>')
      .attr 'type', 'text/css'
      .html cssBlocks.join('\n')

    $('head').append style

  _verifyKeyIsFloat: (input, key, defaultValue, message='Must be float') ->
    if !_.isUndefined defaultValue
      unless _.has input, key
        input[key] = defaultValue
        return

    if _.isNaN parseFloat input[key]
      throw new Error "invalid '#{key}': #{input[key]}. #{message}."

    input[key] = parseFloat input[key]
    return

  _verifyKeyIsInt: (input, key, defaultValue, message='Must be integer') ->
    if !_.isUndefined defaultValue
      unless _.has input, key
        input[key] = defaultValue
        return

    if _.isNaN parseInt input[key]
      throw new Error "invalid '#{key}': #{input[key]}. #{message}."

    input[key] = parseInt input[key]
    return

  _verifyKeyIsRatio: (input, key) ->
    throw new Error "#{key} must be >= 0" unless input[key] >= 0
    throw new Error "#{key} must be <= 1" unless input[key] <= 1
