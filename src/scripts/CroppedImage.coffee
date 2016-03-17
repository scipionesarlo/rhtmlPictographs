'use strict'

input =
  direction: 'horizontal'
  percentage: 0.4
  height: 200 #@TODO right now this must be a numeric with no px, em, %, etc.
  width: 200 #@TODO right now this must be a numeric with no px, em, %, etc.
  # baseImageUrl: 'images/black_square.png'
  # variableImageUrl: 'images/blue_square.png'
  baseImageUrl: 'https://s3-ap-southeast-2.amazonaws.com/kyle-public-numbers-assets/htmlwidgets/CroppedImage/black_square_512.png'
  variableImageUrl: 'https://s3-ap-southeast-2.amazonaws.com/kyle-public-numbers-assets/htmlwidgets/CroppedImage/blue_square_512.png'
  'text-overlay': true
  'font-family': 'Verdana,sans-serif'
  'font-weight': '900'
  'font-size': '20px'
  'font-color': 'white'

HTMLWidgets.widget
  name: 'CroppedImage'
  type: 'output'
  factory: (el, width, height) ->
    return {
      resize: () ->
        console.log 'resize not implemented'
      renderValue: (x) ->
        generateClip = () ->
          if input.direction == 'horizontal'
            x = input.percentage * input.width
            console.log "horizontal"
            console.log "rect(auto, #{x}px, auto, auto)"
            return "rect(auto, #{x}px, auto, auto)"
          else if input.direction == 'vertical'
            x = input.height - input.percentage * input.height
            console.log "vertical"
            console.log "rect(#{x}px, auto, auto, auto)"
            return "rect(#{x}px, auto, auto, auto)"
          else
            throw new Error "Boom !"

        # input validation

        baseImage = $('<img>')
          .addClass('base-image')
          .attr('src', input.baseImageUrl)
          .css('width', input.width)
          .css('height', input.height)

        variableImage = $('<img>')
          .addClass('variable-image')
          .attr('src', input.variableImageUrl)
          .css('width', input.width)
          .css('height', input.height)
          .css('clip', generateClip())

        divContainer = $('<div>')
          .addClass('cropped-image-container')
          .css('width', input.width)
          .css('height', input.height)

        divContainer.append(baseImage).append(variableImage)

        if input['text-overlay']

          textContainer = $('<div>').addClass('text-container')
            .css('width', input.width)
            .css('height', input.height)
            .css('line-height', "#{input.height}px") #@TODO must have px ...

          text = $('<span>').addClass('text-overlay')
            .css('transform', "translate(#{input.height / 2}px") #@TODO not a good solution
            .css('margin-left', '-16px') #@TODO even worse

          textContainer.append(text)

          for cssAttribute in ['font-family', 'font-size', 'font-weight']
            text.css(cssAttribute, input[cssAttribute]) if _.has input, cssAttribute

          text.css('color', input['font-color']) if _.has input, 'font-color'

          formattedPercentage = (100 * input.percentage).toFixed(0)
          text.html("#{formattedPercentage}%")

          divContainer.append(textContainer)

        $(el).append(divContainer)
    }
