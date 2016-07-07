class LabelCell extends BaseCell

  setConfig: (@config) ->

    @labels = []
    if _.isString @config
      @labels = [{ text: @config }]
      @config = {}

    else if _.isArray @config
      @labels = @config.map (labelConfig) ->
        if _.isString labelConfig
          return { text: labelConfig }
        else
          return labelConfig
      @config = {}

    else if _.has @config, 'labels'
      @labels = @config.labels.map (labelConfig) ->
        if _.isString labelConfig
          return { text: labelConfig }
        else
          return labelConfig

    else
      @labels = [@config]

    @_verifyKeyIsInt @config, 'padding-top', 0
    @_verifyKeyIsInt @config, 'padding-inner', 0
    @_verifyKeyIsInt @config, 'padding-bottom', 0
    @_verifyKeyIsInt @config, 'padding-right', 0
    @_verifyKeyIsInt @config, 'padding-left', 0

    @config['vertical-align'] ?= 'center'
    @config['vertical-align'] = 'center' if @config['vertical-align'] in ['middle', 'centre']

    unless @config['vertical-align'] in ['top', 'center', 'bottom']
      throw new Error "Invalid vertical align #{@config['vertical-align']} : must be one of ['top', 'center', 'bottom']"

    _.forEach @labels, (labelConfig, index) =>
      labelConfig['class'] ?= "label-#{index}"

      labelConfig['horizontal-align'] ?= 'middle'
      labelConfig['horizontal-align'] = 'middle' if labelConfig['horizontal-align'] in ['center', 'centre']
      labelConfig['horizontal-align'] = 'start' if labelConfig['horizontal-align'] in ['left']
      labelConfig['horizontal-align'] = 'end' if labelConfig['horizontal-align'] in ['right']

      unless labelConfig['horizontal-align'] in ['start', 'middle', 'end']
        throw new Error "Invalid horizontal align #{labelConfig['horizontal-align']} : must be one of ['left', 'center', 'right']"

      #font-size must be present to compute dimensions
      labelConfig['font-size'] = BaseCell.getDefault('font-size') unless labelConfig['font-size']?

      _.forEach labelConfig, (labelValue, labelKey) =>
        return if labelKey in ['class', 'text', 'horizontal-align']
        @setCss(labelConfig['class'], labelKey, labelValue)

  computeAllocatedVerticalSpace: () ->
    allocatedVerticalSpace = @config['padding-inner'] * @labels.length - 1
    _.forEach @labels, (labelConfig, index) =>
      labelFontSize = @getAdjustedTextSize labelConfig['font-size']
      allocatedVerticalSpace += labelFontSize

    @allocatedVerticalSpace = allocatedVerticalSpace

  computeHorizontalOffset: (horizontalAlign) ->
    return switch
      when horizontalAlign is 'start' then @config['padding-left']
      when horizontalAlign is 'middle' then @width / 2
      when horizontalAlign is 'end' then @width - @config['padding-right']

  computeInitialVerticalOffset: (verticalAlign) ->
    freeVertSpace = @height - @config['padding-top'] - @config['padding-bottom'] - @allocatedVerticalSpace
    if freeVertSpace < 0
      console.error "Label is using too much vertical space"
      freeVertSpace = 0

    return switch
      when verticalAlign is 'top' then @config['padding-top']
      when verticalAlign is 'center' then @config['padding-top'] + freeVertSpace / 2
      when verticalAlign is 'bottom' then @config['padding-top'] + freeVertSpace

  _draw: () ->
    if @config['background-color']
      @parentSvg.append 'svg:rect'
        .attr 'class', 'background'
        .attr 'width', @width
        .attr 'height', @height
        .attr 'fill', @config['background-color']

    @computeAllocatedVerticalSpace()
    currentY = @computeInitialVerticalOffset @config['vertical-align']

    _.forEach @labels, (labelConfig) =>

      fontSize = @getAdjustedTextSize labelConfig['font-size']
      xOffset = @computeHorizontalOffset labelConfig['horizontal-align']

      @_addTextTo @parentSvg, labelConfig['text'], labelConfig['class'], labelConfig['horizontal-align'], xOffset, currentY + fontSize / 2, fontSize

      currentY += fontSize + @config['padding-inner']

  _addTextTo: (parent, text, myClass, textAnchor, x, y, fontSize) ->
    parent.append('svg:text')
      .attr 'class', myClass
      .attr 'x', x # note this is the midpoint not the top/bottom (thats why we divide by 2)
      .attr 'y', y # same midpoint consideration
      .attr 'text-anchor', textAnchor
      #alignment-baseline and dominant-baseline should do same thing but are both may be necessary for browser compatability
      .style 'font-size', fontSize
      .style 'alignment-baseline', 'central'
      .style 'dominant-baseline', 'central'
      .text text

  _resize: () ->
    @parentSvg.selectAll('*').remove()
    @_draw()
