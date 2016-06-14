
class GraphicCell extends BaseCell

  setConfig: (config) ->
    @config = _.cloneDeep config
    throw new Error "Must specify 'variableImage'" unless @config.variableImage?

    if _.isString(@config['proportion']) and @config['proportion'].startsWith('=')
      @config['proportion'] = eval(@config['proportion'].substring(1))

    @_verifyKeyIsFloat @config, 'proportion', 1, 'Must be number between 0 and 1'
    @_verifyKeyIsRatio @config, 'proportion'

    @_verifyKeyIsPositiveInt @config, 'numImages', 1
    @_verifyKeyIsPositiveInt(@config, 'numRows', 1) if @config['numRows']?
    @_verifyKeyIsPositiveInt(@config, 'numCols', 1) if @config['numCols']?
    if @config['numRows']? and @config['numCols']?
      throw new Error "Cannot specify both numRows and numCols. Choose one, and use numImages to control exact dimensions."

    @_verifyKeyIsFloat @config, 'columnGutter', 0.05, 'Must be number between 0 and 1'
    @_verifyKeyIsRatio @config, 'columnGutter'
    @_verifyKeyIsFloat @config, 'rowGutter', 0.05, 'Must be number between 0 and 1'
    @_verifyKeyIsRatio @config, 'rowGutter'

    @_processTextConfig 'text-header'
    @_processTextConfig 'text-overlay'
    @_processTextConfig 'text-footer'

    if (@config.padding)
      [paddingTop, paddingRight, paddingBottom, paddingLeft] = @config.padding.split(" ")

      @config.padding = {
        top: parseInt paddingTop.replace(/(px|em)/, '')
        right: parseInt paddingRight.replace(/(px|em)/, '')
        bottom: parseInt paddingBottom.replace(/(px|em)/, '')
        left: parseInt paddingLeft.replace(/(px|em)/, '')
      }
      for key of @config.padding
        if _.isNaN @config.padding[key]
          throw new Error "Invalid padding #{@config.padding}: #{key} must be Integer"

    else
      @config.padding = { top: 0, right: 0, bottom: 0, left: 0 }

  _processTextConfig: (key) ->
    if @config[key]?
      textConfig = if _.isString(@config[key]) then { text : @config[key] } else @config[key]

      throw new Error "Invalid #{key} config: must have text field" unless textConfig['text']?

      if textConfig? and textConfig['text'].match(/^percentage$/)
        textConfig['text'] = "#{(100 * @config.proportion).toFixed(1).replace(/\.0$/,'')}%"

      if textConfig? and textConfig['text'].match(/^proportion$/)
        textConfig['text'] = "#{(@config.proportion).toFixed(3).replace(/0+$/, '')}"

      #font-size must be present to compute dimensions
      textConfig['font-size'] ?= BaseCell.getDefault('font-size')


      for cssAttribute in ['font-family', 'font-size', 'font-weight', 'font-color']
        @setCss(key, cssAttribute, textConfig[cssAttribute]) if textConfig[cssAttribute]?

      @config[key] = textConfig

  _draw: () ->
    @_computeDimensions()

    if @config['text-header']?
      x = @dimensions.headerXOffset + @dimensions.headerWidth / 2
      y = @dimensions.headerYOffset + @dimensions.headerHeight / 2
      @_addTextTo @parentSvg, @config['text-header']['text'], 'text-header', x, y

    graphicContainer = @parentSvg.append('g')
      .attr('class', 'graphic-container')
      .attr 'transform', "translate(#{@dimensions.graphicXOffset},#{@dimensions.graphicYOffset})"

    if @config['text-footer']?
      x = @dimensions.footerXOffset + @dimensions.footerWidth / 2
      y = @dimensions.footerYOffset + @dimensions.footerHeight / 2
      @_addTextTo @parentSvg, @config['text-footer']['text'], 'text-footer', x, y

    d3Data = @_generateDataArray(@config.proportion, @config.numImages)

    #d3.grid is added to d3 via github.com/NumbersInternational/d3-grid
    gridLayout = d3.layout.grid()
      .bands()
      .size [@dimensions.graphicWidth, @dimensions.graphicHeight]
      .padding([@config['columnGutter'], @config['rowGutter']])

    gridLayout.rows(@config['numRows']) if @config['numRows']?
    gridLayout.cols(@config['numCols']) if @config['numCols']?

    enteringLeafNodes = graphicContainer.selectAll(".node")
      .data gridLayout(d3Data)
      .enter()
      .append "g"
        .attr "class", (d) ->
          cssLocation = "node-index-#{d.i} node-xy-#{d.row}-#{d.col}"
          "node #{cssLocation}"
        .attr "transform", (d) -> return "translate(#{d.x},#{d.y})"

    imageWidth = gridLayout.nodeSize()[0]
    imageHeight = gridLayout.nodeSize()[1]

    backgroundRect = enteringLeafNodes.append("svg:rect")
      .attr 'width', imageWidth
      .attr 'height', imageHeight
      .attr 'class', 'background-rect'
      .attr 'fill', @config['background-color'] || 'none'

    if @config['debugBorder']?
      backgroundRect
        .attr 'stroke', 'black'
        .attr 'stroke-width', '1'

    if @config.baseImage?
      enteringLeafNodes.each _.partial(ImageFactory.addImageTo, @config.baseImage, imageWidth, imageHeight)

    enteringLeafNodes.each _.partial(ImageFactory.addImageTo, @config.variableImage, imageWidth, imageHeight)

    if @config['tooltip']
      enteringLeafNodes.append("svg:title")
        .text @config['tooltip']

    if @config['text-overlay']?
      x = gridLayout.nodeSize()[0] / 2
      y = gridLayout.nodeSize()[1] / 2
      @_addTextTo enteringLeafNodes, @config['text-overlay']['text'], 'text-overlay', x, y

  _computeDimensions: () ->

    @dimensions = {}

    #need these first to calc graphicHeight
    @dimensions.headerHeight = 0 + (if @config['text-header']? then parseInt(@config['text-header']['font-size'].replace(/(px|em)/, '')) else 0)
    @dimensions.footerHeight = 0 + (if @config['text-footer']? then parseInt(@config['text-footer']['font-size'].replace(/(px|em)/, '')) else 0)

    @dimensions.headerWidth = @width - @config.padding.left - @config.padding.right
    @dimensions.headerXOffset = 0 + @config.padding.left
    @dimensions.headerYOffset = 0 + @config.padding.top

    @dimensions.graphicWidth = @width - @config.padding.left - @config.padding.right
    @dimensions.graphicHeight = @height - @dimensions.headerHeight - @dimensions.footerHeight - @config.padding.top - @config.padding.bottom
    @dimensions.graphicXOffset = 0 + @config.padding.left
    @dimensions.graphicYOffset = 0 + @dimensions.headerYOffset + @dimensions.headerHeight

    @dimensions.footerWidth = @width - @config.padding.left - @config.padding.right
    @dimensions.footerXOffset = 0 + @config.padding.left
    @dimensions.footerYOffset = 0 + @dimensions.graphicYOffset + @dimensions.graphicHeight

  _addTextTo: (parent, text, myClass, x, y) ->
    parent.append('svg:text')
      .attr 'class', myClass
      .attr 'x', x # note this is the midpoint not the top/bottom (thats why we divide by 2)
      .attr 'y', y # same midpoint consideration
      .style 'text-anchor', 'middle'
      #alignment-baseline and dominant-baseline should do same thing but are both may be necessary for browser compatability
      .style 'alignment-baseline', 'central'
      .style 'dominant-baseline', 'central'
      .text text

  _generateDataArray: (proportion, numImages) ->
    d3Data = []
    #NB the alg uses terms based on assigning 2D area to an array of shapes
    remainingArea = proportion * numImages
    for i in [0...numImages]
      proportionForImageI = if (remainingArea > 1) then 1 else remainingArea
      remainingArea -= proportionForImageI
      d3Data.push { proportion: proportionForImageI, i: i }
    return d3Data
