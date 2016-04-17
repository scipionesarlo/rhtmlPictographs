var BaseCell;

BaseCell = (function() {
  BaseCell.defaults = {};

  BaseCell.setDefault = function(k, v) {
    return this.defaults[k] = v;
  };

  BaseCell.getDefault = function(k) {
    return this.defaults[k];
  };

  function BaseCell(parentSvg, myCssSelector, width, height) {
    this.parentSvg = parentSvg;
    this.width = parseInt(width);
    this.height = parseInt(height);
    this.cssBucket = {};
    if (_.isString(myCssSelector)) {
      this.myCssSelector = [myCssSelector];
    } else if (_.isArray(myCssSelector)) {
      this.myCssSelector = myCssSelector;
    } else {
      throw new Error("Invalid myCssSelector: " + myCssSelector);
    }
  }

  BaseCell.prototype.setConfig = function(config) {
    this.config = config;
  };

  BaseCell.prototype.draw = function() {
    this._draw();
    return this._generateDynamicCss();
  };

  BaseCell.prototype.setCss = function(cssLocation, cssAttr, cssValue) {
    var cssLocationKey, ensurePartsAreSupportedCss, transformedInstructions, validCssLocationKey;
    ensurePartsAreSupportedCss = function(cssSelectorParts) {
      return cssSelectorParts.map(function(part) {
        if (_.startsWith(part, '.')) {
          return part;
        }
        if (_.startsWith(part, '#')) {
          return part;
        }
        return '.' + part;
      });
    };
    cssLocationKey = null;
    if (cssLocation === '') {
      cssLocationKey = this.myCssSelector;
    } else if (_.isString(cssLocation)) {
      cssLocationKey = this.myCssSelector.concat(cssLocation);
    } else if (_.isArray(cssLocation)) {
      cssLocationKey = this.myCssSelector.concat(cssLocation);
    } else {
      throw new Error("Invalid cssLocation: " + JSON.stringify(cssLocation));
    }
    validCssLocationKey = ensurePartsAreSupportedCss(cssLocationKey);
    transformedInstructions = this._transformCssInstructions(validCssLocationKey, cssAttr, cssValue);
    return _.forEach(transformedInstructions, (function(_this) {
      return function(i) {
        var cssSelector;
        cssSelector = i.location.join(' ');
        if (!_.has(_this.cssBucket, cssSelector)) {
          _this.cssBucket[cssSelector] = {};
        }
        return _this.cssBucket[cssSelector][i.attribute] = i.value;
      };
    })(this));
  };

  BaseCell.prototype._transformCssInstructions = function(inLocation, inAttr, inValue) {
    var finalCssComponent, instructions, setFillOnAllChildElements, setFillOnThisElement, thisLocation;
    instructions = [];
    if (inAttr === 'font-color') {
      setFillOnThisElement = {
        attribute: 'fill',
        value: inValue
      };
      thisLocation = _.clone(inLocation);
      finalCssComponent = thisLocation[thisLocation.length - 1];
      thisLocation[thisLocation.length - 1] = "text" + finalCssComponent;
      setFillOnThisElement.location = thisLocation;
      setFillOnAllChildElements = {
        attribute: 'fill',
        value: inValue,
        location: inLocation.concat('text')
      };
      instructions.push(setFillOnThisElement);
      instructions.push(setFillOnAllChildElements);
    } else {
      instructions.push({
        location: inLocation,
        attribute: inAttr,
        value: inValue
      });
    }
    return instructions;
  };

  BaseCell.prototype._draw = function() {
    throw new Error("BaseCell._draw must be overridden by child");
  };

  BaseCell.prototype._generateDynamicCss = function() {
    var cssBlocks, style;
    cssBlocks = _.map(this.cssBucket, function(cssDefinition, cssSelector) {
      var cssDefinitionString;
      cssDefinitionString = _.map(cssDefinition, function(cssValue, cssAttr) {
        return "" + cssAttr + ": " + cssValue + ";";
      }).join('\n');
      return "" + cssSelector + " { " + cssDefinitionString + " }";
    });
    style = $('<style>').attr('type', 'text/css').html(cssBlocks.join('\n'));
    return $('head').append(style);
  };

  BaseCell.prototype._verifyKeyIsFloat = function(input, key, defaultValue, message) {
    if (message == null) {
      message = 'Must be float';
    }
    if (!_.isUndefined(defaultValue)) {
      if (!_.has(input, key)) {
        input[key] = defaultValue;
        return;
      }
    }
    if (_.isNaN(parseFloat(input[key]))) {
      throw new Error("invalid '" + key + "': " + input[key] + ". " + message + ".");
    }
    input[key] = parseFloat(input[key]);
  };

  BaseCell.prototype._verifyKeyIsInt = function(input, key, defaultValue, message) {
    if (message == null) {
      message = 'Must be integer';
    }
    if (!_.isUndefined(defaultValue)) {
      if (!_.has(input, key)) {
        input[key] = defaultValue;
        return;
      }
    }
    if (_.isNaN(parseInt(input[key]))) {
      throw new Error("invalid '" + key + "': " + input[key] + ". " + message + ".");
    }
    input[key] = parseFloat(input[key]);
  };

  BaseCell.prototype._verifyKeyIsRatio = function(input, key) {
    if (!(input[key] >= 0)) {
      throw new Error("" + key + " must be >= 0");
    }
    if (!(input[key] <= 1)) {
      throw new Error("" + key + " must be <= 1");
    }
  };

  return BaseCell;

})();
