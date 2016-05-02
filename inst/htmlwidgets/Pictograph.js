// Generated by CoffeeScript 1.8.0
var Pictograph;

Pictograph = (function() {
  Pictograph.pictographIndex = -1;

  function Pictograph(el, width, height, parentCss) {
    this.parentCss = parentCss != null ? parentCss : null;
    Pictograph.pictographIndex++;
    this.rootElement = _.has(el, 'length') ? el[0] : el;
    this.initialWidth = width;
    this.initialHeight = height;
  }

  Pictograph.prototype.setConfig = function(config) {
    var pictographDefaults, tableOfOneGraphic;
    this.config = config;
    if (this.config['table'] == null) {
      tableOfOneGraphic = {
        rows: [
          [
            {
              type: 'graphic',
              value: _.clone(this.config)
            }
          ]
        ]
      };
      this.config['table'] = tableOfOneGraphic;
    }
    if (this.config['resizable'] === 'true') {
      this.config['resizable'] = true;
    }
    if (this.config['resizable'] === 'false') {
      this.config['resizable'] = false;
    }
    if (this.config['resizable'] == null) {
      this.config['resizable'] = true;
    }
    if (!_.isBoolean(this.config['resizable'])) {
      throw new Error('resizable must be string [true|false]');
    }
    if (!this.config['table-id']) {
      this.config['table-id'] = "pictograph-" + Pictograph.pictographIndex;
    }
    this.cssCollector = new BaseCell(null, "" + this.config['table-id']);
    this.cssCollector._draw = function() {
      return _.noop;
    };
    pictographDefaults = {
      'font-family': 'Verdana,sans-serif',
      'font-weight': '900',
      'font-size': '24px',
      'font-color': 'black'
    };
    _.forEach(pictographDefaults, (function(_this) {
      return function(defaultValue, cssAttribute) {
        var cssValue;
        cssValue = _this.config[cssAttribute] ? _this.config[cssAttribute] : defaultValue;
        _this.cssCollector.setCss('', cssAttribute, cssValue);
        return BaseCell.setDefault(cssAttribute, cssValue);
      };
    })(this));
    if (this.config['css']) {
      return _.forEach(this.config['css'], (function(_this) {
        return function(cssBlock, cssLocationString) {
          return _.forEach(cssBlock, function(cssValue, cssAttribute) {
            return _this.cssCollector.setCss(cssLocationString, cssAttribute, cssValue);
          });
        };
      })(this));
    }
  };

  Pictograph.prototype._computeTableLayout = function() {
    var calcLineVariableDimension, numGuttersAtIndex, sumSpecified, _i, _j, _ref, _ref1, _results, _results1;
    numGuttersAtIndex = function(index) {
      return index;
    };
    this.numTableRows = this.config.table.rows.length;
    this.numTableCols = null;
    this.config.table.rows.forEach((function(_this) {
      return function(row) {
        if (_.isNull(_this.numTableCols)) {
          _this.numTableCols = row.length;
        }
        if (_this.numTableCols !== row.length) {
          throw new Error("Table is 'jagged' : contains rows with varying column length");
        }
      };
    })(this));
    this._verifyKeyIsInt(this.config.table, 'innerRowPadding', 0);
    this._verifyKeyIsInt(this.config.table, 'innerColumnPadding', 0);
    if (this.config.table.rowHeights) {
      if (!_.isArray(this.config.table.rowHeights)) {
        throw new Error("rowHeights must be array");
      }
      if (this.config.table.rowHeights.length !== this.numTableRows) {
        throw new Error("rowHeights length must match num rows specified");
      }
      sumSpecified = _.sum(this.config.table.rowHeights) + (this.numTableRows - 1) * this.config.table.innerRowPadding;
      if (!(sumSpecified <= this.initialHeight)) {
        throw new Error("Cannot specify rowHeights/innerRowPadding where sum(rows+padding) exceeds table height: " + sumSpecified + " !< " + this.initialHeight);
      }
    } else {
      this.config.table.rowHeights = (function() {
        _results = [];
        for (var _i = 1, _ref = this.numTableRows; 1 <= _ref ? _i <= _ref : _i >= _ref; 1 <= _ref ? _i++ : _i--){ _results.push(_i); }
        return _results;
      }).apply(this).map(((function(_this) {
        return function() {
          return _this.initialHeight / _this.numTableRows;
        };
      })(this)));
    }
    if (this.config.table.colWidths) {
      if (!_.isArray(this.config.table.colWidths)) {
        throw new Error("colWidths must be array");
      }
      if (this.config.table.colWidths.length !== this.numTableCols) {
        throw new Error("colWidths length must match num columns specified");
      }
      sumSpecified = _.sum(this.config.table.colWidths) + (this.numTableCols - 1) * this.config.table.innerColumnPadding;
      if (!(sumSpecified <= this.initialWidth)) {
        throw new Error("Cannot specify colWidths/innerColumnPadding where sum(cols+padding) exceeds table width: : " + sumSpecified + " !< " + this.initialWidth);
      }
    } else {
      this.config.table.colWidths = (function() {
        _results1 = [];
        for (var _j = 1, _ref1 = this.numTableCols; 1 <= _ref1 ? _j <= _ref1 : _j >= _ref1; 1 <= _ref1 ? _j++ : _j--){ _results1.push(_j); }
        return _results1;
      }).apply(this).map(((function(_this) {
        return function() {
          return _this.initialWidth / _this.numTableCols;
        };
      })(this)));
    }
    if (!this.config.table.lines) {
      this.config.table.lines = {};
    }
    this.config.table.lines.horizontal = (this.config.table.lines.horizontal || []).sort();
    this.config.table.lines.vertical = (this.config.table.lines.vertical || []).sort();
    ["padding-left", "padding-right", "padding-top", "padding-bottom"].forEach((function(_this) {
      return function(attr) {
        return _this._verifyKeyIsInt(_this.config.table.lines, attr, 0);
      };
    })(this));
    calcLineVariableDimension = function(linePosition, cellSizes, paddingSize) {
      var fractionOfCell, numCellsPast, sizeOfFraction, sizeOfGuttersPast, sizeOfNumCellsPast;
      numCellsPast = Math.floor(linePosition);
      fractionOfCell = linePosition - numCellsPast;
      sizeOfNumCellsPast = _.sum(_.slice(cellSizes, 0, numCellsPast));
      sizeOfGuttersPast = numGuttersAtIndex(numCellsPast) * paddingSize - 0.5 * paddingSize;
      sizeOfFraction = fractionOfCell * (cellSizes[numCellsPast] + paddingSize);
      return sizeOfNumCellsPast + sizeOfGuttersPast + sizeOfFraction;
    };
    this.config.table.lines.horizontal = this.config.table.lines.horizontal.map((function(_this) {
      return function(lineIndex) {
        var y;
        y = calcLineVariableDimension(lineIndex, _this.config.table.rowHeights, _this.config.table.innerRowPadding);
        return {
          position: lineIndex,
          x1: 0 + _this.config.table.lines['padding-left'],
          x2: _this.initialWidth - _this.config.table.lines['padding-right'],
          y1: y,
          y2: y,
          style: _this.config.table.lines.style || "stroke:black;stroke-width:2"
        };
      };
    })(this));
    this.config.table.lines.vertical = this.config.table.lines.vertical.map((function(_this) {
      return function(lineIndex) {
        var x;
        x = calcLineVariableDimension(lineIndex, _this.config.table.colWidths, _this.config.table.innerColumnPadding);
        return {
          position: lineIndex,
          x1: x,
          x2: x,
          y1: 0 + _this.config.table.lines['padding-top'],
          y2: _this.initialHeight - _this.config.table.lines['padding-bottom'],
          style: _this.config.table.lines.style || "stroke:black;stroke-width:2"
        };
      };
    })(this));
    console.log("@config.table.lines");
    console.log(this.config.table.lines);
    return this.config.table.rows.forEach((function(_this) {
      return function(row, rowIndex) {
        return row.forEach(function(cell, columnIndex) {
          cell.x = _.sum(_.slice(_this.config.table.colWidths, 0, columnIndex)) + numGuttersAtIndex(columnIndex) * _this.config.table.innerColumnPadding;
          cell.y = _.sum(_.slice(_this.config.table.rowHeights, 0, rowIndex)) + numGuttersAtIndex(rowIndex) * _this.config.table.innerRowPadding;
          cell.width = _this.config.table.colWidths[columnIndex];
          cell.height = _this.config.table.rowHeights[rowIndex];
          cell.row = rowIndex;
          cell.col = columnIndex;
          return console.log("setting xy for cell " + rowIndex + ":" + columnIndex + " = " + cell.x + ":" + cell.y + ". width:height= " + cell.width + ":" + cell.height);
        });
      };
    })(this));
  };

  Pictograph.prototype.draw = function() {
    var addLines, enteringCells, tableCells, tableId;
    this.cssCollector.draw();
    this._manipulateRootElementSize();
    this._addRootSvgToRootElement();
    this._computeTableLayout();
    tableCells = _.flatten(this.config.table.rows);
    addLines = (function(_this) {
      return function(lineType, data) {
        return _this.outerSvg.selectAll("." + lineType).data(data).enter().append('line').attr('x1', function(d) {
          return d.x1;
        }).attr('x2', function(d) {
          return d.x2;
        }).attr('y1', function(d) {
          return d.y1;
        }).attr('y2', function(d) {
          return d.y2;
        }).attr('style', function(d) {
          return d.style;
        }).attr('class', function(d) {
          return "line " + lineType + " line-" + d.position;
        });
      };
    })(this);
    addLines('horizontal-line', this.config.table.lines.horizontal);
    addLines('vertical-line', this.config.table.lines.vertical);
    enteringCells = this.outerSvg.selectAll('.table-cell').data(tableCells).enter().append('g').attr('class', 'table-cell').attr('transform', function(d) {
      return "translate(" + d.x + "," + d.y + ")";
    });
    tableId = this.config['table-id'];
    enteringCells.each(function(d, i) {
      var cssWrapperClass, graphic;
      cssWrapperClass = "table-cell-" + d.row + "-" + d.col;
      d3.select(this).classed(cssWrapperClass, true);
      if (d.type === 'graphic') {
        d3.select(this).classed('graphic', true);
        graphic = new GraphicCell(d3.select(this), [tableId, cssWrapperClass], d.width, d.height);
        graphic.setConfig(d.value);
        graphic.draw();
      }
      if (d.type === 'label') {
        d3.select(this).classed('label', true);
        return d3.select(this).append('svg:text').attr('x', function(d) {
          return d.width / 2;
        }).attr('y', function(d) {
          return d.height / 2;
        }).style('text-anchor', 'middle').style('alignment-baseline', 'central').style('dominant-baseline', 'central').attr('class', 'text-overlay').text(d.value);
      }
    });
    return null;
  };

  Pictograph.prototype.resize = function(width, height) {};

  Pictograph.prototype._manipulateRootElementSize = function() {
    $(this.rootElement).attr('style', '');
    if (this.config['resizable']) {
      return $(this.rootElement).width('100%').height('100%');
    } else {
      return $(this.rootElement).width(this.initialWidth).height(this.initialHeight);
    }
  };

  Pictograph.prototype._addRootSvgToRootElement = function() {
    var anonSvg;
    anonSvg = $('<svg class="pictograph-outer-svg">').addClass(this.config['table-id']).attr('id', this.config['table-id']).attr('width', '100%').attr('height', '100%');
    $(this.rootElement).append(anonSvg);
    this.outerSvg = d3.select(anonSvg[0]);
    document.getElementsByClassName("pictograph-outer-svg")[0].setAttribute('viewBox', "0 0 " + this.initialWidth + " " + this.initialHeight);
    if (this.config['preserveAspectRatio'] != null) {
      document.getElementsByClassName("pictograph-outer-svg")[0].setAttribute('preserveAspectRatio', this.config['preserveAspectRatio']);
    }
    return null;
  };

  Pictograph.prototype._verifyKeyIsInt = function(input, key, defaultValue, message) {
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
    input[key] = parseInt(input[key]);
  };

  return Pictograph;

})();
