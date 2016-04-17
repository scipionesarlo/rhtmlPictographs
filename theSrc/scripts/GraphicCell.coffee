
class GraphicCell extends BaseCell

  setConfig: (@config) ->
    throw new Error "Must specify 'variableImageUrl'" unless @config.variableImageUrl?

    @_verifyKeyIsFloat @config, 'percentage', 1, 'Must be number between 0 and 1'
    @_verifyKeyIsRatio @config, 'percentage'

    @_verifyKeyIsInt @config, 'numImages', 1
    @_verifyKeyIsInt(@config, 'numRows', 1) if @config['numRows']?
    @_verifyKeyIsInt(@config, 'numCols', 1) if @config['numCols']?
    if @config['numRows']? and @config['numCols']?
      throw new Error "Cannot specify both numRows and numCols. Choose one, and use numImages to control exact dimensions."

    @config['direction'] = 'horizontal' unless @config['direction']?
    unless @config['direction'] in ['horizontal', 'vertical']
      throw new Error "direction must be either (horizontal|vertical)"

    @_verifyKeyIsFloat @config, 'interColumnPadding', 0.05, 'Must be number between 0 and 1'
    @_verifyKeyIsRatio @config, 'interColumnPadding'
    @_verifyKeyIsFloat @config, 'interRowPadding', 0.05, 'Must be number between 0 and 1'
    @_verifyKeyIsRatio @config, 'interRowPadding'

    @_processTextConfig 'text-header'
    @_processTextConfig 'text-overlay'
    @_processTextConfig 'text-footer'

    if @config['text-overlay']? and @config['text-overlay']['text'].match(/^percentage$/)
      @config['text-overlay']['text'] = "#{(100 * @config.percentage).toFixed(0)}%"

  _processTextConfig: (key) ->
    if @config[key]?
      textConfig = if _.isString(@config[key]) then { text : @config[key] } else @config[key]

      #font-size must be present to compute dimensions
      textConfig['font-size'] = BaseCell.getDefault('font-size') unless textConfig['font-size']?

      for cssAttribute in ['font-family', 'font-size', 'font-weight', 'font-color']
        @setCss(key, cssAttribute, textConfig[cssAttribute]) if textConfig[cssAttribute]?

      @config[key] = textConfig

  _draw: () ->
    @_computeDimensions()

    #@TODO remove duplicated text-header and text-footer handling
    if @config['text-header']?
      x = @width / 2
      y = @dimensions.headerHeight / 2
      @_addTextTo @parentSvg, @config['text-header']['text'], 'text-header', x, y

    graphicContainer = @parentSvg.append('g')
      .attr('class', 'graphic-container')
      .attr 'transform', "translate(0,#{@dimensions.graphicOffSet})"

    if @config['text-footer']?
      x = @width / 2
      y = @dimensions.footerOffset + @dimensions.footerHeight / 2
      @_addTextTo @parentSvg, @config['text-footer']['text'], 'text-footer', x, y

    d3Data = @_generateDataArray @config.percentage, @config.numImages

    #d3.grid is added to d3 via github.com/NumbersInternational/d3-grid
    gridLayout = d3.layout.grid()
      .bands()
      .size [@width, @dimensions.graphicHeight]
      .padding([0.05, 0.05])
      .padding([@config['interColumnPadding'], @config['interRowPadding']])

    gridLayout.rows(@config['numRows']) if @config['numRows']?
    gridLayout.cols(@config['numCols']) if @config['numCols']?

    enteringLeafNodes = graphicContainer.selectAll(".node")
      .data gridLayout(d3Data)
      .enter()
      .append "g"
        .attr "class", "node"
        .attr "transform", (d) -> return "translate(#{d.x},#{d.y})"

    backgroundRect = enteringLeafNodes.append("svg:rect")
      .attr 'width', gridLayout.nodeSize()[0]
      .attr 'height', gridLayout.nodeSize()[1]
      .attr 'class', 'background-rect'
      .attr 'fill', @config['background-color'] || 'none'

    if @config['debugBorder']?
      backgroundRect
        .attr 'stroke', 'black'
        .attr 'stroke-width', '1'

    if @config.baseImageUrl?
      enteringLeafNodes.append("svg:image")
        .attr 'width', gridLayout.nodeSize()[0]
        .attr 'height', gridLayout.nodeSize()[1]
        .attr 'xlink:href', @config.baseImageUrl
        .attr 'class', 'base-image'

    enteringLeafNodes.append('clipPath')
      .attr 'id', 'my-clip'
      .append 'rect'
        .attr 'x', 0

        .attr 'y', (d) =>
          return 0 if @config.direction == 'horizontal'
          return gridLayout.nodeSize()[1] * (1 -d.percentage)

        .attr 'width', (d) =>
          return gridLayout.nodeSize()[0] * d.percentage if @config.direction == 'horizontal'
          return gridLayout.nodeSize()[0]

        .attr 'height', (d) =>
          return gridLayout.nodeSize()[1] * d.percentage if @config.direction == 'vertical'
          return gridLayout.nodeSize()[1]

    enteringLeafNodes.append("svg:image")
      .attr 'width', gridLayout.nodeSize()[0]
      .attr 'height', gridLayout.nodeSize()[1]
      .attr 'clip-path', 'url(#my-clip)'
      .attr 'xlink:href', @config.variableImageUrl
      .attr 'class', 'variable-image'

    if @config['tooltip']
      enteringLeafNodes.append("svg:title")
        .text @config['tooltip']

    if @config['text-overlay']?
      x = gridLayout.nodeSize()[0] / 2
      y = gridLayout.nodeSize()[1] / 2
      @_addTextTo enteringLeafNodes, @config['text-overlay']['text'], 'text-overlay', x, y

  _computeDimensions: () ->

    @dimensions = {}

    @dimensions.headerHeight = 0 + (if @config['text-header']? then parseInt(@config['text-header']['font-size'].replace(/(px|em)/, '')) else 0)
    @dimensions.footerHeight = 0 + (if @config['text-footer']? then parseInt(@config['text-footer']['font-size'].replace(/(px|em)/, '')) else 0)

    @dimensions.graphicHeight = @height - @dimensions.headerHeight - @dimensions.footerHeight
    @dimensions.graphicOffSet = 0 + @dimensions.headerHeight

    @dimensions.footerOffset = 0 + @dimensions.headerHeight + @dimensions.graphicHeight
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

  _generateDataArray: (percentage, numImages) ->
    d3Data = []
    totalArea = percentage * numImages
    for num in [1..numImages]
      percentage = Math.min(1, Math.max(0, 1 + totalArea - num))
      d3Data.push { percentage: percentage }
    return d3Data
