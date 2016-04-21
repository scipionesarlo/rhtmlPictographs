
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

    #@TODO: resizble handling needs work
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

  _computeTableDimensions: () ->
    @numTableRows = @config.table.rows.length
    @numTableCols = null
    @config.table.rows.forEach (row) =>
      if _.isNull @numTableCols
        @numTableCols = row.length

      if @numTableCols != row.length
        throw new Error "Table is 'jagged' : contains rows with varying column length"

    maxCols = 0

  draw: () ->
    @cssCollector.draw()

    @_manipulateRootElementSize()
    @_addRootSvgToRootElement()
    @_computeTableDimensions()

    #d3.layout.grid must be provided by github.com/NumbersInternational/d3-grid
    tableLayout = d3.layout.grid()
      .bands()
      .size [@initialWidth, @initialHeight]
      .padding([0.1, 0.1]) #@TODO control padding
      .rows(@numTableRows)

    tableCells = _.flatten(@config.table.rows)

    enteringCells = @outerSvg.selectAll('.table-cell')
      .data tableLayout tableCells
      .enter()
      .append 'g'
        .attr 'class', 'table-cell'
        .attr 'transform', (d) ->
          return "translate(" + d.x + "," + d.y + ")"

    pictographContext = @
    tableId = @config['table-id']
    enteringCells.each (d, i) ->

      cssWrapperClass = "table-cell-#{d.row}-#{d.col}"
      d3.select(this).classed cssWrapperClass, true

      if d.type is 'graphic'
        d3.select(this).classed 'graphic', true
        graphic = new GraphicCell d3.select(this), [tableId, cssWrapperClass], tableLayout.nodeSize()[0], tableLayout.nodeSize()[1]
        graphic.setConfig d.value
        graphic.draw()

      if d.type is 'label'
        d3.select(this).classed 'label', true
        d3.select(this).append('svg:text')
          .attr 'x', (d) -> tableLayout.nodeSize()[0] / 2
          .attr 'y', (d) -> tableLayout.nodeSize()[1] / 2
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
