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
        console.error msg
        throw new Error err

      throw new Error "Must specify 'baseImageUrl'" unless input.baseImageUrl?
      throw new Error "Must specify 'variableImageUrl'" unless input.variableImageUrl?

      throw new Error "Must specify 'percent'" unless input.percentage?
      input.percentage = parseFloat input.percentage
      throw new Error "percentage must be a number" if _.isNaN input.percentage
      throw new Error "percentage must be >= 0" unless input.percentage >= 0
      throw new Error "percentage must be <= 1" unless input.percentage <= 1

      input['numImages'] = 1 unless input['numImages']?
      input['numRows'] = 1 unless input['numRows']?
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

    generateDataArray = (percentage, numImages) ->
      d3Data = []
      totalArea = percentage * numImages
      for num in [1..numImages]
        percentage = Math.min(1, Math.max(0, 1 + totalArea - num))
        d3Data.push { percentage: percentage }
      return d3Data

    input = normalizeInput params
    d3Data = generateDataArray input.percentage, input.numImages

    #d3.grid is provided by github.com/interactivethings/d3-grid
    gridLayout = d3.layout.grid()
      .bands()
      .size [instance.width, instance.height]
      .padding([0.1, 0.1]); #@TODO control padding ?

    svg = d3.select(el[0]).append("svg")
      .attr 'width': instance.width
      .attr 'height': instance.height

    enteringLeafNodes = svg.selectAll(".node")
      .data gridLayout(d3Data)
      .enter()
      .append "g"
        .attr "class", "node"
        .attr "transform", (d) ->
          return "translate(" + d.x + "," + d.y + ")"

    enteringLeafNodes.append("svg:image")
      .attr 'width', gridLayout.nodeSize()[0]
      .attr 'height', gridLayout.nodeSize()[1]
      .attr 'xlink:href', input.baseImageUrl
      .attr 'class', 'base-image'

    enteringLeafNodes.append("clipPath")
      .attr "id", "my-clip"
      .append "rect"
        .attr "x", 0

        .attr "y", (d) ->
          return 0 if input.direction == 'horizontal'
          return gridLayout.nodeSize()[1] * (1 -d.percentage)

        .attr "width", (d) ->
          return gridLayout.nodeSize()[0] * d.percentage if input.direction == 'horizontal'
          return gridLayout.nodeSize()[0]

        .attr "height", (d) ->
          return gridLayout.nodeSize()[1] * d.percentage if input.direction == 'vertical'
          return gridLayout.nodeSize()[1]

    enteringLeafNodes.append("svg:image")
      .attr 'width', gridLayout.nodeSize()[0]
      .attr 'height', gridLayout.nodeSize()[1]
      .attr 'clip-path', 'url(#my-clip)'
      .attr 'xlink:href', input.variableImageUrl
      .attr 'class', 'variable-image'

    if input['text-overlay']
      displayText = if input['text-override'] then input['text-override'] else "#{(100 * input.percentage).toFixed(0)}%"

      textOverlay = enteringLeafNodes.append("svg:text")
        .attr 'x', (d) -> gridLayout.nodeSize()[0] / 2
        .attr 'y', (d) -> gridLayout.nodeSize()[1] / 2
        .style 'text-anchor', 'middle'
        .attr 'class', 'text-overlay'
        .text displayText

      textOverlay.attr('fill', input['font-color']) if _.has input, 'font-color'
      for cssAttribute in ['font-family', 'font-size', 'font-weight']
        textOverlay.attr(cssAttribute, input[cssAttribute]) if _.has input, cssAttribute
