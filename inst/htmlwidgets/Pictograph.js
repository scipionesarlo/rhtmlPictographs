var Pictograph;

Pictograph = (function() {
  function Pictograph(el, width, height) {
    this.rootElement = _.has(el, 'length') ? el[0] : el;
    this.initialWidth = width;
    this.initialHeight = height;
    this.config = {};
  }

  Pictograph.prototype.setConfig = function(params) {
    var pictograpghTextDefaults, tableOfOneGraphic, textParamsFromInput;
    this.input = params;
    if (this.input['table'] == null) {
      tableOfOneGraphic = {
        rows: [
          [
            {
              type: 'graphic',
              value: _.clone(this.input)
            }
          ]
        ]
      };
      this.input['table'] = tableOfOneGraphic;
    }
    this.config['text'] = {};
    textParamsFromInput = {};
    if (this.input['font-family'] != null) {
      textParamsFromInput['font-family'] = this.input['font-family'];
    }
    if (this.input['font-weight'] != null) {
      textParamsFromInput['font-weight'] = parseInt(this.input['font-weight']);
    }
    if (this.input['font-size'] != null) {
      textParamsFromInput['font-size'] = parseInt(this.input['font-size'].replace(/(px|em)/, ''));
    }
    if (this.input['font-color'] != null) {
      textParamsFromInput['font-color'] = this.input['font-color'];
    }
    pictograpghTextDefaults = {
      'font-family': 'Verdana,sans-serif',
      'font-weight': '900',
      'font-size': '24',
      'font-color': 'black'
    };
    return _.defaults(this.config['text'], textParamsFromInput, pictograpghTextDefaults);
  };

  Pictograph.prototype.validateGraphicCellConfig = function(cellConfig, defaults) {
    var textParamsFromCellDefinition, _ref;
    if (cellConfig.variableImageUrl == null) {
      throw new Error("Must specify 'variableImageUrl'");
    }
    this.verifyKeyIsFloat(cellConfig, 'percentage', 1, 'Must be number between 0 and 1');
    this.verifyKeyIsRatio(cellConfig, 'percentage');
    this.verifyKeyIsInt(cellConfig, 'numImages', 1);
    if (cellConfig['numRows'] != null) {
      this.verifyKeyIsInt(cellConfig, 'numRows', 1);
    }
    if (cellConfig['numCols'] != null) {
      this.verifyKeyIsInt(cellConfig, 'numCols', 1);
    }
    if ((cellConfig['numRows'] != null) && (cellConfig['numCols'] != null)) {
      throw new Error("Cannot specify both numRows and numCols. Choose one, and use numImages to control exact dimensions.");
    }
    if (cellConfig['direction'] == null) {
      cellConfig['direction'] = 'horizontal';
    }
    if ((_ref = cellConfig['direction']) !== 'horizontal' && _ref !== 'vertical') {
      throw new Error("direction must be either (horizontal|vertical)");
    }
    this.verifyKeyIsFloat(cellConfig, 'interColumnPadding', 0.05, 'Must be number between 0 and 1');
    this.verifyKeyIsRatio(cellConfig, 'interColumnPadding');
    this.verifyKeyIsFloat(cellConfig, 'interRowPadding', 0.05, 'Must be number between 0 and 1');
    this.verifyKeyIsRatio(cellConfig, 'interRowPadding');
    cellConfig['text'] = {};
    textParamsFromCellDefinition = {};
    if (cellConfig['font-family'] != null) {
      textParamsFromCellDefinition['font-family'] = cellConfig['font-family'];
    }
    if (cellConfig['font-weight'] != null) {
      textParamsFromCellDefinition['font-weight'] = parseInt(cellConfig['font-weight']);
    }
    if (cellConfig['font-size'] != null) {
      textParamsFromCellDefinition['font-size'] = parseInt(cellConfig['font-size'].replace(/(px|em)/, ''));
    }
    if (cellConfig['font-color'] != null) {
      textParamsFromCellDefinition['font-color'] = cellConfig['font-color'];
    }
    _.defaults(cellConfig['text'], textParamsFromCellDefinition, this.config['text']);
    return cellConfig;
  };

  Pictograph.prototype.verifyKeyIsFloat = function(input, key, defaultValue, message) {
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

  Pictograph.prototype.verifyKeyIsInt = function(input, key, defaultValue, message) {
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

  Pictograph.prototype.verifyKeyIsRatio = function(input, key) {
    if (!(input[key] >= 0)) {
      throw new Error("" + key + " must be >= 0");
    }
    if (!(input[key] <= 1)) {
      throw new Error("" + key + " must be <= 1");
    }
  };

  Pictograph.prototype._computeTableDimensions = function() {
    var maxCols;
    this.numTableRows = this.input.table.rows.length;
    this.numTableCols = null;
    this.input.table.rows.forEach((function(_this) {
      return function(row) {
        if (_.isNull(_this.numTableCols)) {
          return _this.numTableCols = row.length;
        } else {
          if (_this.numTableCols !== row.length) {
            throw new Error("Table is 'jagged' : contains rows with varying column length");
          }
        }
      };
    })(this));
    return maxCols = 0;
  };

  Pictograph.prototype.draw = function() {
    var enteringCells, pictographContext, tableCells, tableLayout;
    this._addRootSvg();
    this._computeTableDimensions();
    tableLayout = d3.layout.grid().bands().size([this.initialWidth, this.initialHeight]).padding([0.1, 0.1]);
    tableLayout.rows(this.numTableRows);
    tableCells = _.flatten(this.input.table.rows).map((function(_this) {
      return function(cellConfig) {
        if (cellConfig.type === 'graphic') {
          _this.validateGraphicCellConfig(cellConfig.value, _this.input);
        }
        return cellConfig;
      };
    })(this));
    console.log("tableCells");
    console.log(tableCells);
    enteringCells = this.outerSvg.selectAll('.node').data(tableLayout(tableCells)).enter().append('g').attr('class', 'node').attr('transform', function(d) {
      return "translate(" + d.x + "," + d.y + ")";
    });
    pictographContext = this;
    enteringCells.each(function(d, i) {
      var graphic;
      if (d.type === 'graphic') {
        graphic = new GraphicCell(d3.select(this), d.value, tableLayout.nodeSize()[0], tableLayout.nodeSize()[1]);
        graphic.draw();
      }
      if (d.type === 'label') {
        return d3.select(this).append("svg:text").attr('x', function(d) {
          return tableLayout.nodeSize()[0] / 2;
        }).attr('y', function(d) {
          return tableLayout.nodeSize()[1] / 2;
        }).style('text-anchor', 'middle').style('alignment-baseline', 'central').style('dominant-baseline', 'central').attr('class', 'text-overlay').text(d.value);
      }
    });
    return null;
  };

  Pictograph.prototype._addRootSvg = function(instance, input) {
    var anonSvg;
    anonSvg = $("<svg class=\"rhtml-pictograph-outer-svg\">").attr('width', '100%').attr('height', '100%');
    $(this.rootElement).attr('style', '').width("100%").height("100%").append(anonSvg);
    this.outerSvg = d3.select('.rhtml-pictograph-outer-svg');
    document.getElementsByClassName("rhtml-pictograph-outer-svg")[0].setAttribute('viewBox', "0 0 " + this.initialWidth + " " + this.initialHeight);
    if (this.input['preserveAspectRatio'] != null) {
      document.getElementsByClassName("rhtml-pictograph-outer-svg")[0].setAttribute('preserveAspectRatio', this.input['preserveAspectRatio']);
    }
    return null;
  };

  return Pictograph;

})();
