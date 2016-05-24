'use strict'

HTMLWidgets.widget
  name: 'rhtmlPictographs'
  type: 'output'

  resize: (el, width, height, instance) ->
    instance.resize width, height

  initialize: (el, width, height) ->
    return new Pictograph el, width, height

  renderValue: (el, inputConfig, instance) ->

    config = null
    try
      if _.isString inputConfig
        config = JSON.parse inputConfig
      else
        config = inputConfig

    catch err
      readableError = new Error "Pictograph error : Cannot parse 'settingsJsonString': #{err}"
      console.error readableError
      errorHandler = new DisplayError el, readableError
      errorHandler.draw()

      throw new Error err

    try
      instance.setConfig config
      instance.draw()

    catch err
      console.error err.stack
      errorHandler = new DisplayError el, err
      errorHandler.draw()
      throw new Error err
