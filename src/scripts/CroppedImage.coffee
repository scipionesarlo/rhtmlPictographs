'use strict'

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

      throw new Error "Must specify 'baseImageUrl'" unless input.baseImageUrl?
      throw new Error "Must specify 'variableImageUrl'" unless input.variableImageUrl?

      throw new Error "Must specify 'percent'" unless input.percentage?
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

      return input

    generateClip = (input) ->
      if input.direction == 'horizontal'
        x = input.percentage * instance.width
        return "rect(auto, #{x}px, auto, auto)"
      else if input.direction == 'vertical'
        x = instance.height - input.percentage * instance.height
        return "rect(#{x}px, auto, auto, auto)"
      else
        throw new Error "Invalid direction: '#{input.direction}'"

    input = normalizeInput(params)

    baseImage = $('<img class="base-image">')
      .attr('src', input.baseImageUrl)
      .css('width', instance.width)
      .css('height', instance.height)

    variableImage = $('<img class="variable-image">')
      .attr('src', input.variableImageUrl)
      .css('width', instance.width)
      .css('height', instance.height)
      #NB 'clip' will eventually be deprecated in favour of 'clip-path', but at present
      #clip-path is not well supported : https://developer.mozilla.org/en/docs/Web/CSS/clip
      .css('clip', generateClip(input))

    divContainer = $('<div class="cropped-image-container">')
      .css('width', instance.width)
      .css('height', instance.height)

    divContainer.append(baseImage).append(variableImage)

    if input['text-overlay']
      textContainer = $('<div>').addClass('text-container')
        .css('width', instance.width)
        .css('height', instance.height)
        .css('line-height', "#{instance.height}px") #@TODO must have px ...

      formattedPercentage = (100 * input.percentage).toFixed(0)
      text = $('<span class="text-overlay">')
        .css('transform', "translate(#{instance.height / 2}px") #@TODO not a good solution
        .css('margin-left', '-16px') #@TODO not a good solution
        .html("#{formattedPercentage}%")

      text.css('color', input['font-color']) if _.has input, 'font-color'
      for cssAttribute in ['font-family', 'font-size', 'font-weight']
        text.css(cssAttribute, input[cssAttribute]) if _.has input, cssAttribute

      textContainer.append(text)
      divContainer.append(textContainer)

    $(el).append(divContainer)
