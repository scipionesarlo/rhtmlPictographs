
class Pictograph

  #NB Coffeescript class syntax note:
  # @ in front of method / variable def: static class method
  # @ within method body : short hand for this / self / instance context
  # e.g @pictograph is a static variable, @rootElement is an instance variable

  @pictographIndex = -1

  constructor: (el, width, height, @parentCss=null) ->
    Pictograph.pictographIndex++

    @rootElement = if _.has(el, 'length') then el[0] else el
    @initialWidth = width
    @initialHeight = height

  setConfig: (@config) ->

    unless @config['table']?
      tableOfOneGraphic =
        rows: [[{type: 'graphic', value: _.clone(@config) }]]
      @config['table'] = tableOfOneGraphic

    #@TODO: resizable string vs boolean handling needs work
    @config['resizable'] = true if @config['resizable'] is 'true'
    @config['resizable'] = false if @config['resizable'] is 'false'
    @config['resizable'] = true unless @config['resizable']?
    throw new Error 'resizable must be string [true|false]' unless _.isBoolean(@config['resizable'])

    @config['table-id'] = "pictograph-#{Pictograph.pictographIndex}" unless @config['table-id']
    @cssCollector = new BaseCell(null, "#{@config['table-id']}") #hacky, @TODO extract CssCollector from BaseCell
    @cssCollector._draw = () -> _.noop

    pictographDefaults = {
      'font-family': 'Verdana,sans-serif'
      'font-weight': '900'
      'font-size': '24px'
      'font-color': 'black'
    }

    _.forEach pictographDefaults, (defaultValue, cssAttribute) =>
      cssValue = if @config[cssAttribute] then @config[cssAttribute] else defaultValue
      @cssCollector.setCss '', cssAttribute, cssValue
      BaseCell.setDefault cssAttribute, cssValue # currently this is only necessary for 'font-size'

    if @config['css']
      _.forEach @config['css'], (cssBlock, cssLocationString) =>
        _.forEach cssBlock, (cssValue, cssAttribute) =>
          @cssCollector.setCss cssLocationString, cssAttribute, cssValue

  #@TODO I am a beast of a 100 line function. Could create a custom layout function, could combine with d3-grid
  _computeTableLayout: () ->

    numGuttersAtIndex = (index) -> index

    @numTableRows = @config.table.rows.length
    @numTableCols = null
    @config.table.rows.forEach (row) =>
      if _.isNull @numTableCols
        @numTableCols = row.length

      if @numTableCols != row.length
        throw new Error "Table is 'jagged' : contains rows with varying column length"

    @_verifyKeyIsInt @config.table, 'innerRowPadding', 0
    @_verifyKeyIsInt @config.table, 'innerColumnPadding', 0

    if @config.table.rowHeights
      #@TODO: verify and cast Array values to Ints
      unless _.isArray @config.table.rowHeights
        throw new Error "rowHeights must be array"

      unless @config.table.rowHeights.length == @numTableRows
        throw new Error "rowHeights length must match num rows specified"

      sumSpecified = _.sum(@config.table.rowHeights) + (@numTableRows-1) * @config.table.innerRowPadding
      unless sumSpecified <= @initialHeight
        throw new Error "Cannot specify rowHeights/innerRowPadding where sum(rows+padding) exceeds table height: #{sumSpecified} !< #{@initialHeight}"

    else
      @config.table.rowHeights = [1..@numTableRows].map ( => @initialHeight / @numTableRows )

    if @config.table.colWidths
      #@TODO: verify and cast Array values to Ints
      unless _.isArray @config.table.colWidths
        throw new Error "colWidths must be array"

      unless @config.table.colWidths.length == @numTableCols
        throw new Error "colWidths length must match num columns specified"

      sumSpecified = _.sum(@config.table.colWidths) + (@numTableCols-1) * @config.table.innerColumnPadding
      unless sumSpecified <= @initialWidth
        throw new Error "Cannot specify colWidths/innerColumnPadding where sum(cols+padding) exceeds table width: : #{sumSpecified} !< #{@initialWidth}"

    else
      @config.table.colWidths = [1..@numTableCols].map ( => @initialWidth / @numTableCols )

    #TODO: verify input
    @config.table.lines = {} unless @config.table.lines
    @config.table.lines.horizontal = (@config.table.lines.horizontal || []).sort()
    @config.table.lines.vertical = (@config.table.lines.vertical || []).sort()

    ["padding-left", "padding-right", "padding-top", "padding-bottom"].forEach (attr) =>
      @_verifyKeyIsInt @config.table.lines, attr, 0

    calcLineVariableDimension = (linePosition, cellSizes, paddingSize) ->
      numCellsPast = Math.floor(linePosition)
      fractionOfCell = linePosition - numCellsPast

      sizeOfNumCellsPast = _.sum(_.slice(cellSizes, 0, numCellsPast))
      sizeOfGuttersPast = numGuttersAtIndex(numCellsPast) * paddingSize - 0.5 * paddingSize
      sizeOfFraction = fractionOfCell * (cellSizes[numCellsPast] + paddingSize)

      return sizeOfNumCellsPast + sizeOfGuttersPast + sizeOfFraction

    @config.table.lines.horizontal = @config.table.lines.horizontal.map (lineIndex) =>
      y = calcLineVariableDimension lineIndex, @config.table.rowHeights, @config.table.innerRowPadding
      return {
        position: lineIndex
        x1: 0 + @config.table.lines['padding-left']
        x2: @initialWidth - @config.table.lines['padding-right']
        y1: y
        y2: y
        style: @config.table.lines.style || "stroke:black;stroke-width:2"
      }

    @config.table.lines.vertical = @config.table.lines.vertical.map (lineIndex) =>
      x = calcLineVariableDimension lineIndex, @config.table.colWidths, @config.table.innerColumnPadding
      return {
        position: lineIndex
        x1: x
        x2: x
        y1: 0 + @config.table.lines['padding-top']
        y2: @initialHeight - @config.table.lines['padding-bottom']
        style: @config.table.lines.style || "stroke:black;stroke-width:2"
      }

    console.log "@config.table.lines"
    console.log @config.table.lines

    @config.table.rows.forEach (row, rowIndex) =>
      row.forEach (cell, columnIndex) =>
        cell.x = _.sum( _.slice(@config.table.colWidths, 0, columnIndex)) + numGuttersAtIndex(columnIndex) * @config.table.innerColumnPadding
        cell.y = _.sum( _.slice(@config.table.rowHeights, 0, rowIndex)) + numGuttersAtIndex(rowIndex) * @config.table.innerRowPadding
        cell.width = @config.table.colWidths[columnIndex]
        cell.height = @config.table.rowHeights[rowIndex]
        cell.row = rowIndex
        cell.col = columnIndex
        console.log("setting xy for cell #{rowIndex}:#{columnIndex} = #{cell.x}:#{cell.y}. width:height= #{cell.width}:#{cell.height}")

  draw: () ->
    @cssCollector.draw()

    @_manipulateRootElementSize()
    @_addRootSvgToRootElement()
    @_computeTableLayout()

    tableCells = _.flatten(@config.table.rows)

    addLines = (lineType, data) =>
      @outerSvg.selectAll(".#{lineType}")
        .data data
        .enter()
        .append 'line'
          .attr 'x1', (d) -> d.x1
          .attr 'x2', (d) -> d.x2
          .attr 'y1', (d) -> d.y1
          .attr 'y2', (d) -> d.y2
          .attr 'style', (d) -> d.style
          .attr 'class', (d) -> "line #{lineType} line-#{d.position}"

    addLines 'horizontal-line', @config.table.lines.horizontal
    addLines 'vertical-line', @config.table.lines.vertical

    enteringCells = @outerSvg.selectAll('.table-cell')
      .data tableCells
      .enter()
      .append 'g'
        .attr 'class', 'table-cell'
        .attr 'transform', (d) ->
          return "translate(" + d.x + "," + d.y + ")"

    tableId = @config['table-id']
    enteringCells.each (d, i) ->

      cssWrapperClass = "table-cell-#{d.row}-#{d.col}"
      d3.select(this).classed cssWrapperClass, true

      if d.type is 'graphic'
        d3.select(this).classed 'graphic', true
        graphic = new GraphicCell d3.select(this), [tableId, cssWrapperClass], d.width, d.height
        graphic.setConfig d.value
        graphic.draw()

      if d.type is 'label'
        d3.select(this).classed 'label', true
        d3.select(this).append('svg:text')
          .attr 'x', (d) -> d.width / 2
          .attr 'y', (d) -> d.height / 2
          .style 'text-anchor', 'middle'
          #alignment-baseline and dominant-baseline should do similar thing
          # but both may be necessary for browser compatability ...
          .style 'alignment-baseline', 'central'
          .style 'dominant-baseline', 'central'
          .attr 'class', 'text-overlay'
          .text d.value

    return null

  resize: (width, height) ->
    #NB delberately not implemented - not needed

  _manipulateRootElementSize: () ->

    #root element has width and height in a style tag. Clear that
    $(@rootElement).attr('style', '')

    if @config['resizable']
      $(@rootElement).width('100%').height('100%')
    else
      $(@rootElement).width(@initialWidth).height(@initialHeight)

  _addRootSvgToRootElement: () ->

    anonSvg = $('<svg class="pictograph-outer-svg">')
      .addClass @config['table-id']
      .attr 'id', @config['table-id']
      .attr 'width', '100%'
      .attr 'height', '100%'

    $(@rootElement).append(anonSvg)

    @outerSvg = d3.select(anonSvg[0])

    #NB JQuery insists on lowercasing attributes, so we must use JS directly
    # when setting viewBox and preserveAspectRatio ?!
    document.getElementsByClassName("pictograph-outer-svg")[0]
      .setAttribute 'viewBox', "0 0 #{@initialWidth} #{@initialHeight}"
    if @config['preserveAspectRatio']?
      document.getElementsByClassName("pictograph-outer-svg")[0]
        .setAttribute 'preserveAspectRatio', @config['preserveAspectRatio']

    return null

  _verifyKeyIsInt: (input, key, defaultValue, message='Must be integer') ->
    if !_.isUndefined defaultValue
      unless _.has input, key
        input[key] = defaultValue
        return

    if _.isNaN parseInt input[key]
      throw new Error "invalid '#{key}': #{input[key]}. #{message}."

    input[key] = parseInt input[key]
    return
