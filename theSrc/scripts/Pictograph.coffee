
class Pictograph extends RhtmlSvgWidget

  constructor: (el, width, height) ->
    super el, width, height

  _processConfig: () ->

    unless @config['table']?
      tableOfOneGraphic =
        rows: [[{type: 'graphic', value: _.clone(@config) }]]
      @config['table'] = tableOfOneGraphic

    #@TODO: resizable string vs boolean handling needs work
    @config['resizable'] = true if @config['resizable'] is 'true'
    @config['resizable'] = false if @config['resizable'] is 'false'
    @config['resizable'] = true unless @config['resizable']?
    throw new Error 'resizable must be string [true|false]' unless _.isBoolean(@config['resizable'])

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
    @config.table.rows.forEach (row, rowIndex) =>

      unless _.isArray row
        throw new Error "Invalid rows spec: row #{rowIndex} must be array of cell definitions"

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

      @config.table.rowHeights = @config.table.rowHeights.map (candidate) ->
        rowHeight = parseInt candidate
        if _.isNaN rowHeight
          throw new Error "Invalid rowHeight '#{candidate}': must be integer"
        rowHeight

      sumSpecified = _.sum(@config.table.rowHeights) + (@numTableRows-1) * @config.table.innerRowPadding
      unless sumSpecified <= @initialHeight
        throw new Error "Cannot specify rowHeights/innerRowPadding where sum(rows+padding) exceeds table height: #{sumSpecified} !< #{@initialHeight}"

    else
      @config.table.rowHeights = [1..@numTableRows].map ( => parseInt(@initialHeight / @numTableRows) )

    if @config.table.colWidths
      #@TODO: verify and cast Array values to Ints
      unless _.isArray @config.table.colWidths
        throw new Error "colWidths must be array"

      unless @config.table.colWidths.length == @numTableCols
        throw new Error "colWidths length must match num columns specified"

      @config.table.colWidths = @config.table.colWidths.map (candidate) ->
        colWidth = parseInt candidate
        if _.isNaN colWidth
          throw new Error "Invalid colWidth '#{candidate}': must be integer"
        colWidth

      sumSpecified = _.sum(@config.table.colWidths) + (@numTableCols-1) * @config.table.innerColumnPadding
      unless sumSpecified <= @initialWidth
        throw new Error "Cannot specify colWidths/innerColumnPadding where sum(cols+padding) exceeds table width: : #{sumSpecified} !< #{@initialWidth}"


    else
      @config.table.colWidths = [1..@numTableCols].map ( => parseInt(@initialWidth / @numTableCols) )

    @config.table.lines = {} unless @config.table.lines
    @config.table.lines.horizontal = (@config.table.lines.horizontal || []).sort()
    @config.table.lines.vertical = (@config.table.lines.vertical || []).sort()

    ["padding-left", "padding-right", "padding-top", "padding-bottom"].forEach (attr) =>
      @_verifyKeyIsInt @config.table.lines, attr, 0

    calcLineVariableDimension = (linePosition, cellSizes, paddingSize) ->
      numCellsPast = Math.floor(linePosition)
      fractionOfCell = linePosition - numCellsPast

      sizeOfNumCellsPast = _.sum(_.slice(cellSizes, 0, numCellsPast))

      sizeOfGuttersPast = 0
      if numCellsPast > 0 and numCellsPast < cellSizes.length
        sizeOfGuttersPast = numGuttersAtIndex(numCellsPast) * paddingSize - 0.5 * paddingSize
      else if numCellsPast > 0 and numCellsPast == cellSizes.length
        sizeOfGuttersPast = numGuttersAtIndex(numCellsPast - 1) * paddingSize

      sizeOfFraction = 0
      if numCellsPast == 0
        sizeOfFraction = fractionOfCell * cellSizes[numCellsPast]
      else if numCellsPast < cellSizes.length
        sizeOfFraction = fractionOfCell * (cellSizes[numCellsPast] + paddingSize)

      return sizeOfNumCellsPast + sizeOfGuttersPast + sizeOfFraction

    @config.table.lines.horizontal = @config.table.lines.horizontal.map (lineIndexCandidate) =>

      lineIndex = parseFloat lineIndexCandidate
      if _.isNaN lineIndex
        throw new Error "Invalid vertical line position '#{lineIndexCandidate}': must be numeric"

      if lineIndex > @numTableRows or lineIndex < 0
        throw new Error "Cannot create line at '#{lineIndex}': past end of table"

      y = calcLineVariableDimension lineIndex, @config.table.rowHeights, @config.table.innerRowPadding
      return {
        position: lineIndex
        x1: 0 + @config.table.lines['padding-left']
        x2: @initialWidth - @config.table.lines['padding-right']
        y1: y
        y2: y
        style: @config.table.lines.style || "stroke:black;stroke-width:2"
      }

    @config.table.lines.vertical = @config.table.lines.vertical.map (lineIndexCandidate) =>

      lineIndex = parseFloat lineIndexCandidate
      if _.isNaN lineIndex
        throw new Error "Invalid vertical line position '#{lineIndexCandidate}': must be numeric"

      if lineIndex > @numTableCols  or lineIndex < 0
        throw new Error "Cannot create line at '#{lineIndex}': past end of table"

      x = calcLineVariableDimension lineIndex, @config.table.colWidths, @config.table.innerColumnPadding
      return {
        position: lineIndex
        x1: x
        x2: x
        y1: 0 + @config.table.lines['padding-top']
        y2: @initialHeight - @config.table.lines['padding-bottom']
        style: @config.table.lines.style || "stroke:black;stroke-width:2"
      }

    @config.table.rows.forEach (row, rowIndex) =>
      row.forEach (cell, columnIndex) =>
        cell.x = _.sum( _.slice(@config.table.colWidths, 0, columnIndex)) + numGuttersAtIndex(columnIndex) * @config.table.innerColumnPadding
        cell.y = _.sum( _.slice(@config.table.rowHeights, 0, rowIndex)) + numGuttersAtIndex(rowIndex) * @config.table.innerRowPadding
        cell.width = @config.table.colWidths[columnIndex]
        cell.height = @config.table.rowHeights[rowIndex]
        cell.row = rowIndex
        cell.col = columnIndex

  _redraw: () ->
    @cssCollector.draw()
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
        label = new LabelCell d3.select(this), [tableId, cssWrapperClass], d.width, d.height
        label.setConfig d.value
        label.draw()

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
