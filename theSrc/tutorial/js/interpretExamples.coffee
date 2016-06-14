
addExampleTo = (rowConfig) ->
  element = $(this)
  exampleConfig = _.defaults $(this).data(), rowConfig

  graphicCellConfig = null
  configString = element.text()
  if configString.match(/^{/)
    graphicCellConfig = JSON.parse configString
    configString = JSON.stringify graphicCellConfig, {}, 2
  else
    graphicCellConfig = configString

  element.empty()

  configDiv = $('<div>')
  configPre = $('<pre>')
    .attr('class', 'config')
    .css('height', "auto")
    .html(configString)

  innerExampleDiv = $('<div>')
    .attr('class', 'inner-example')
    .css('width', "#{exampleConfig.exW}")
    .css('height', "#{exampleConfig.exH}")

  innerInnerExampleDiv = $('<div>')

  element.append configDiv.append(configPre)
  element.append innerExampleDiv.append(innerInnerExampleDiv)

  instance = new Pictograph innerInnerExampleDiv, exampleConfig.exW, exampleConfig.exH
  instance.setConfig graphicCellConfig
  instance.draw()

  instanceId = instance.config['table-id']
  innerInnerExampleDiv.attr('class', "inner-inner-example #{instanceId}")

defaultConfig = {
  exW: 100
  exH: 100
}

processRow = () ->
  row = $(this)

  rowConfig = _.defaults row.data(), defaultConfig

  $(this).find('.example').each _.partial addExampleTo, rowConfig

$(document).ready ->
  $('.row').each processRow
