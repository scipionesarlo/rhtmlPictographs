
class Pictograph

  constructor: (el, width, height) ->
    @rootElement = if _.has(el, 'length') then el[0] else el
    @initialWidth = width
    @initialHeight = height
    @config = {}

  setConfig: (params) ->

    @input = params

    unless @input['table']?

      tableOfOneGraphic =
        rows: [
          [
            {
              type: 'graphic'
              value: _.clone(@input)
            }
          ]
        ]
      @input['table'] = tableOfOneGraphic

    #@TODO address duplication
    #default text params
    @config['text'] = {}

    textParamsFromInput = {}
    textParamsFromInput['font-family'] = @input['font-family'] if @input['font-family']?
    textParamsFromInput['font-weight'] = parseInt(@input['font-weight']) if @input['font-weight']?
    textParamsFromInput['font-size'] = parseInt(@input['font-size'].replace(/(px|em)/, '')) if @input['font-size']?
    textParamsFromInput['font-color'] = @input['font-color'] if @input['font-color']?

    pictograpghTextDefaults = {
      'font-family': 'Verdana,sans-serif'
      'font-weight': '900'
      'font-size': '24'
      'font-color': 'black'
    }

    _.defaults @config['text'], textParamsFromInput, pictograpghTextDefaults

  validateGraphicCellConfig: (cellConfig, defaults) ->

    #@TODO: apply defaults

    throw new Error "Must specify 'variableImageUrl'" unless cellConfig.variableImageUrl?

    @verifyKeyIsFloat cellConfig, 'percentage', 1, 'Must be number between 0 and 1'
    @verifyKeyIsRatio cellConfig, 'percentage'

    @verifyKeyIsInt cellConfig, 'numImages', 1
    @verifyKeyIsInt(cellConfig, 'numRows', 1) if cellConfig['numRows']?
    @verifyKeyIsInt(cellConfig, 'numCols', 1) if cellConfig['numCols']?
    if cellConfig['numRows']? and cellConfig['numCols']?
      throw new Error "Cannot specify both numRows and numCols. Choose one, and use numImages to control exact dimensions."

    cellConfig['direction'] = 'horizontal' unless cellConfig['direction']?
    unless cellConfig['direction'] in ['horizontal', 'vertical']
      throw new Error "direction must be either (horizontal|vertical)"

    @verifyKeyIsFloat cellConfig, 'interColumnPadding', 0.05, 'Must be number between 0 and 1'
    @verifyKeyIsRatio cellConfig, 'interColumnPadding'
    @verifyKeyIsFloat cellConfig, 'interRowPadding', 0.05, 'Must be number between 0 and 1'
    @verifyKeyIsRatio cellConfig, 'interRowPadding'

    #default text params
    cellConfig['text'] = {}

    textParamsFromCellDefinition = {}
    textParamsFromCellDefinition['font-family'] = cellConfig['font-family'] if cellConfig['font-family']?
    textParamsFromCellDefinition['font-weight'] = parseInt(cellConfig['font-weight']) if cellConfig['font-weight']?
    textParamsFromCellDefinition['font-size'] = parseInt(cellConfig['font-size'].replace(/(px|em)/, '')) if cellConfig['font-size']?
    textParamsFromCellDefinition['font-color'] = cellConfig['font-color'] if cellConfig['font-color']?

    _.defaults cellConfig['text'], textParamsFromCellDefinition, @config['text']

    return cellConfig

  verifyKeyIsFloat: (input, key, defaultValue, message='Must be float') ->
    if !_.isUndefined defaultValue
      unless _.has input, key
        input[key] = defaultValue
        return

    if _.isNaN parseFloat input[key]
      throw new Error "invalid '#{key}': #{input[key]}. #{message}."

    input[key] = parseFloat input[key]
    return

  verifyKeyIsInt: (input, key, defaultValue, message='Must be integer') ->
    if !_.isUndefined defaultValue
      unless _.has input, key
        input[key] = defaultValue
        return

    if _.isNaN parseInt input[key]
      throw new Error "invalid '#{key}': #{input[key]}. #{message}."

    input[key] = parseFloat input[key]
    return

  verifyKeyIsRatio: (input, key) ->
    throw new Error "#{key} must be >= 0" unless input[key] >= 0
    throw new Error "#{key} must be <= 1" unless input[key] <= 1

  _computeTableDimensions: () ->
    @numTableRows = @input.table.rows.length
    @numTableCols = null
    @input.table.rows.forEach (row) =>
      if _.isNull @numTableCols
        @numTableCols = row.length
      else
        throw new Error "Table is 'jagged' : contains rows with varying column length" unless @numTableCols == row.length

    maxCols = 0

  draw: () ->
    @_addRootSvg()

    @_computeTableDimensions()

    #d3.layout.grid must be provided by github.com/NumbersInternational/d3-grid
    tableLayout = d3.layout.grid()
      .bands()
      .size [@initialWidth, @initialHeight]
      .padding([0.1, 0.1]); #@TODO control padding ?

    tableLayout.rows(@numTableRows)

    #@TODO apply default input params
    tableCells = _.flatten(@input.table.rows).map (cellConfig) =>
      if cellConfig.type is 'graphic'
        @validateGraphicCellConfig cellConfig.value, @input
      cellConfig

    console.log "tableCells"
    console.log tableCells

    enteringCells = @outerSvg.selectAll('.node')
      .data tableLayout(tableCells)
      .enter()
      .append 'g'
        .attr 'class', 'node'
        .attr 'transform', (d) ->
          return "translate(" + d.x + "," + d.y + ")"

    pictographContext = @
    enteringCells.each (d, i) ->
      if d.type is 'graphic'
        graphic = new GraphicCell d3.select(this), d.value, tableLayout.nodeSize()[0], tableLayout.nodeSize()[1]
        graphic.draw()

      if d.type is 'label'
        d3.select(this).append("svg:text")
          .attr 'x', (d) -> tableLayout.nodeSize()[0] / 2
          .attr 'y', (d) -> tableLayout.nodeSize()[1] / 2
          .style 'text-anchor', 'middle'
          #alignment-baseline and dominant-baseline should do same thing but are both may be necessary for browser compatability
          .style 'alignment-baseline', 'central'
          .style 'dominant-baseline', 'central'
          .attr 'class', 'text-overlay'
          .text d.value

    return null

  _addRootSvg: (instance, input) ->
    #NB the following sequence is a little rough because I am switching between native JS, jQuery, and D3
    #@TODO : clean this up

    anonSvg = $("<svg class=\"rhtml-pictograph-outer-svg\">")
      .attr 'width', '100%'
      .attr 'height', '100%'

    $(@rootElement)
      .attr('style', '') #NB clear the existing style because it sets the container height and width, which I am (contentiously) overiding
      .width("100%")
      .height("100%")
      .append(anonSvg)

    @outerSvg = d3.select('.rhtml-pictograph-outer-svg')

    #NB JQuery insists on lowercasing attributes, so we must use JS directly
    # when setting viewBox and preserveAspectRatio ?!
    document.getElementsByClassName("rhtml-pictograph-outer-svg")[0]
      .setAttribute 'viewBox', "0 0 #{@initialWidth} #{@initialHeight}"
    if @input['preserveAspectRatio']?
      document.getElementsByClassName("rhtml-pictograph-outer-svg")[0]
        .setAttribute 'preserveAspectRatio', @input['preserveAspectRatio']

    return null
