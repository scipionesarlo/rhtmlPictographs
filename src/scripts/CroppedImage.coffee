'use strict'

#TODO:
#-local image support
#-local image assets - who generates them ?
#-"correct" horizontal text scaling
#-use an actual class
#-continue using coffeescript ?

HTMLWidgets.widget
  name: 'CroppedImage'
  type: 'output'
  resize: (el, width, height, instance) ->
    console.log 'resize not implemented'

  initialize: (el, width, height) ->
    return {
      width: width
      height: height
    }

  renderValue: (el, params, instance) ->

    normalizeInput = (params) ->
      input = null

      try
        input = JSON.parse params.settingsJsonString
        input.percentage = params.percentage
      catch err
        msg =  "CroppedImage HTMLWidget error : Cannot parse 'settingsJsonString'"
        console.err msg
        throw new Error err

      input.percentage = parseFloat input.percentage
      throw new Error "percentage must be a number" if _.isNaN input.percentage
      throw new Error "percentage must be >= 0" unless input.percentage >= 0
      throw new Error "percentage must be <= 1" unless input.percentage <= 1

      input['direction'] = 'horizontal' unless input['direction']?
      input['text-overlay'] = true unless input['text-overlay']?
      input['font-family'] = 'Verdana,sans-serif' unless input['font-family']?
      input['font-weight'] = '900' unless input['font-weight']?
      input['font-size'] = '20px' unless input['font-size']?
      input['font-color'] = 'white' unless input['font-color']?

      throw new Error "Must specify 'baseImageUrl'" unless input.baseImageUrl?
      throw new Error "Must specify 'variableImageUrl'" unless input.variableImageUrl?

      return input

    generateClip = (input) ->
      if input.direction == 'horizontal'
        x = input.percentage * instance.width
        return "rect(auto, #{x}px, auto, auto)"
      else if input.direction == 'vertical'
        x = instance.height - input.percentage * instance.height
        return "rect(#{x}px, auto, auto, auto)"
      else
        throw new Error "Boom !"

    input = normalizeInput(params)

    baseImage = $('<img>')
      .addClass('base-image')
      .attr('src', input.baseImageUrl)
      .css('width', instance.width)
      .css('height', instance.height)

    variableImage = $('<img>')
      .addClass('variable-image')
      .attr('src', input.variableImageUrl)
      .css('width', instance.width)
      .css('height', instance.height)
      #NB 'clip' will eventually be deprecated in favour of 'clip-path', but at present
      #clip-path is not well supported : https://developer.mozilla.org/en/docs/Web/CSS/clip
      .css('clip', generateClip(input))

    divContainer = $('<div>')
      .addClass('cropped-image-container')
      .css('width', instance.width)
      .css('height', instance.height)

    divContainer.append(baseImage).append(variableImage)

    if input['text-overlay']
      console.log "in the text overlay section"
      textContainer = $('<div>').addClass('text-container')
        .css('width', instance.width)
        .css('height', instance.height)
        .css('line-height', "#{instance.height}px") #@TODO must have px ...

      text = $('<span>').addClass('text-overlay')
        .css('transform', "translate(#{instance.height / 2}px") #@TODO not a good solution
        .css('margin-left', '-16px') #@TODO even worse

      textContainer.append(text)

      for cssAttribute in ['font-family', 'font-size', 'font-weight']
        text.css(cssAttribute, input[cssAttribute]) if _.has input, cssAttribute

      text.css('color', input['font-color']) if _.has input, 'font-color'

      formattedPercentage = (100 * input.percentage).toFixed(0)
      text.html("#{formattedPercentage}%")

      divContainer.append(textContainer)

    $(el).append(divContainer)

