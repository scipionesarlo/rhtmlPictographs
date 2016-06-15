
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
    @_verifyKeyIsInt @config, 'padding-right', 0
    @_verifyKeyIsInt @config, 'padding-left', 0

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

  computeLabelOffsetsUsingAlign: (config) ->
    alignment = config['horizontal-align']
    labelCoord = switch
      when alignment is 'start' then { x : 0 + @config['padding-left'], y: 0 }
      when alignment is 'middle' then { x: @width / 2, y: 0 }
      when alignment is 'end' then { x: @width - @config['padding-right'], y: 0 }
    labelCoord

  _draw: () ->
    currentY = @config['padding-top']
    _.forEach @labels, (labelConfig) =>
      fontSize = parseInt labelConfig['font-size'].replace(/(px|em)/, '')

      labelOffsets = this.computeLabelOffsetsUsingAlign labelConfig

      @_addTextTo @parentSvg, labelConfig['text'], labelConfig['class'], labelConfig['horizontal-align'], labelOffsets.x, labelOffsets.y + currentY + fontSize / 2

      currentY += fontSize + @config['padding-inner']

  _addTextTo: (parent, text, myClass, textAnchor, x, y) ->
    parent.append('svg:text')
      .attr 'class', myClass
      .attr 'x', x # note this is the midpoint not the top/bottom (thats why we divide by 2)
      .attr 'y', y # same midpoint consideration
      .attr 'text-anchor', textAnchor
      #alignment-baseline and dominant-baseline should do same thing but are both may be necessary for browser compatability
      .style 'alignment-baseline', 'central'
      .style 'dominant-baseline', 'central'
      .text text
