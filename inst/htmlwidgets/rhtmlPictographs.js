'use strict';
HTMLWidgets.widget({
  name: 'rhtmlPictographs',
  type: 'output',
  resize: function(el, width, height, instance) {
    return instance.resize(width, height);
  },
  initialize: function(el, width, height) {
    return new Pictograph(el, width, height);
  },
  renderValue: function(el, params, instance) {
    var config, err, errorHandler, readableError;
    config = null;
    try {
      if (_.isString(params.settingsJsonString)) {
        config = JSON.parse(params.settingsJsonString);
      } else {
        config = params.settingsJsonString;
      }
      if (params.percentage != null) {
        config.percentage = params.percentage;
      }
    } catch (_error) {
      err = _error;
      readableError = new Error("Pictograph error : Cannot parse 'settingsJsonString': " + err);
      console.error(readableError);
      errorHandler = new DisplayError(el, readableError);
      errorHandler.draw();
      throw new Error(err);
    }
    try {
      instance.setConfig(config);
      return instance.draw();
    } catch (_error) {
      err = _error;
      console.error(err.stack);
      errorHandler = new DisplayError(el, err);
      return errorHandler.draw();
    }
  }
});
