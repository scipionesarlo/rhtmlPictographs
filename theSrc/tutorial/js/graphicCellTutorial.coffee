
addExampleTo = () ->
  element = $(this)
  exampleConfig = $(this).data()

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
    .css('width', "#{exampleConfig.exampleWidth}")
    .css('height', "#{exampleConfig.exampleHeight}")

  innerInnerExampleDiv = $('<div>')

  element.append configDiv.append(configPre)
  element.append innerExampleDiv.append(innerInnerExampleDiv)

  instance = new Pictograph innerInnerExampleDiv, exampleConfig.exampleWidth, exampleConfig.exampleHeight
  instance.setConfig graphicCellConfig
  instance.draw()

  instanceId = instance.config['table-id']
  innerInnerExampleDiv.attr('class', "inner-inner-example #{instanceId}")

defaultConfig = {
  exampleWidth: 100
  exampleHeight: 100
}

processRow = () ->
  row = $(this)

  rowConfig = _.defaults row.data(), defaultConfig

  $(this).find('.example').data(rowConfig)
  $(this).find('.example').each addExampleTo

$(document).ready ->
  $('.row').each processRow
