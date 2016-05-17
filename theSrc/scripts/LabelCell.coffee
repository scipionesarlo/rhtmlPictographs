
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

    _.forEach @labels, (labelConfig, index) =>
      labelConfig['class'] ?= "label-#{index}"

      #font-size must be present to compute dimensions
      labelConfig['font-size'] = BaseCell.getDefault('font-size') unless labelConfig['font-size']?

      _.forEach labelConfig, (labelValue, labelKey) =>
        return if labelKey in ['class', 'text']
        @setCss(labelConfig['class'], labelKey, labelValue)

  _draw: () ->
    currentY = @config['padding-top']
    _.forEach @labels, (labelConfig) =>
      fontSize = parseInt labelConfig['font-size'].replace(/(px|em)/, '')
      labelCenter =
        x: @width / 2
        y: currentY + fontSize / 2

      @_addTextTo @parentSvg, labelConfig['text'], labelConfig['class'], labelCenter.x, labelCenter.y

      currentY += fontSize + @config['padding-inner']

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
