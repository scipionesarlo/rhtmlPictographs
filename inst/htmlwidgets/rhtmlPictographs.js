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
    var config, err, msg;
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
      msg = "Pictograph error : Cannot parse 'settingsJsonString': " + err;
      console.error(msg);
      throw new Error(err);
    }
    instance.setConfig(config);
    return instance.draw();
  }
});
