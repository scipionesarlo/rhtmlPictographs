class GraphicCell extends BaseCell

  constructor: (@parentSvg, @config, @width, @height) ->

  draw: () ->

    #@TODO into function
    dimensions = {}

    dimensions.headerHeight = 0 + (if @config['text-header']? then @config.text['font-size'] else 0)
    dimensions.footerHeight = 0 + (if @config['text-footer']? then @config.text['font-size'] else 0)

    dimensions.graphicHeight = @height - dimensions.headerHeight - dimensions.footerHeight
    dimensions.graphicOffSet = 0 + dimensions.headerHeight

    dimensions.footerOffset = 0 + dimensions.headerHeight + dimensions.graphicHeight


    #@TODO remove duplicated text-header and text-footer handling
    if @config['text-header']?
      textHeader = @parentSvg.append('svg:text')
        .attr 'x', @width / 2 #NB /2 because its midpoint
        .attr 'y', dimensions.headerHeight / 2 #NB /2 because its midpoint
        .style 'text-anchor', 'middle'
        #alignment-baseline and dominant-baseline should do same thing but are both may be necessary for browser compatability
        .style 'alignment-baseline', 'central'
        .style 'dominant-baseline', 'central'
        .attr 'class', 'text-header'
        .text (d) => @config['text-header']

      textHeader.attr('fill', @config.text['font-color']) if @config.text['font-color']?
      for cssAttribute in ['font-family', 'font-size', 'font-weight']
        textHeader.attr(cssAttribute, @config.text[cssAttribute]) if @config.text[cssAttribute]?

    graphicContainer = @parentSvg.append('g')
      .attr('class', 'graphic-container')
      .attr 'transform', "translate(0,#{dimensions.graphicOffSet})"

    if @config['text-footer']?
      textFooter = @parentSvg.append('svg:text')
        .attr 'x', @width / 2 #NB /2 because its midpoint
        .attr 'y', dimensions.footerOffset + dimensions.footerHeight / 2 #NB /2 because its midpoint
        .style 'text-anchor', 'middle'
        #alignment-baseline and dominant-baseline should do same thing but are both may be necessary for browser compatabilitu
        .style 'alignment-baseline', 'central'
        .style 'dominant-baseline', 'central'
        .attr 'class', 'text-footer'
        .text (d) => @config['text-footer']

      textFooter.attr('fill', @config.text['font-color']) if @config.text['font-color']?
      for cssAttribute in ['font-family', 'font-size', 'font-weight']
        textFooter.attr(cssAttribute, @config.text[cssAttribute]) if @config.text[cssAttribute]?

    d3Data = @_generateDataArray @config.percentage, @config.numImages

    #d3.grid is added to d3 via github.com/NumbersInternational/d3-grid
    gridLayout = d3.layout.grid()
      .bands()
      .size [@width, dimensions.graphicHeight]
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

    if @config['text-overlay']
      displayText = if @config['text-overlay'].match(/^percentage$/) then "#{(100 * @config.percentage).toFixed(0)}%" else @config['text-overlay']

      textOverlay = enteringLeafNodes.append("svg:text")
        .attr 'x', (d) -> gridLayout.nodeSize()[0] / 2
        .attr 'y', (d) -> gridLayout.nodeSize()[1] / 2
        .style 'text-anchor', 'middle'
        #alignment-baseline and dominant-baseline should do same thing but are both may be necessary for browser compatabilitu
        .style 'alignment-baseline', 'central'
        .style 'dominant-baseline', 'central'
        .attr 'class', 'text-overlay'
        .text displayText

      textOverlay.attr('fill', @config.text['font-color']) if @config.text['font-color']?
      for cssAttribute in ['font-family', 'font-size', 'font-weight']
        textOverlay.attr(cssAttribute, @config.text[cssAttribute]) if @config.text[cssAttribute]?

  _generateDataArray: (percentage, numImages) ->
    d3Data = []
    totalArea = percentage * numImages
    for num in [1..numImages]
      percentage = Math.min(1, Math.max(0, 1 + totalArea - num))
      d3Data.push { percentage: percentage }
    return d3Data
