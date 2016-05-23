// Generated by CoffeeScript 1.8.0
var Pictograph,
  __hasProp = {}.hasOwnProperty,
  __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

Pictograph = (function(_super) {
  __extends(Pictograph, _super);

  function Pictograph(el, width, height) {
    Pictograph.__super__.constructor.call(this, el, width, height);
  }

  Pictograph.prototype._processConfig = function() {
    var pictographDefaults, tableOfOneGraphic;
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
      _.forEach(this.config['css'], (function(_this) {
        return function(cssBlock, cssLocationString) {
          return _.forEach(cssBlock, function(cssValue, cssAttribute) {
            return _this.cssCollector.setCss(cssLocationString, cssAttribute, cssValue);
          });
        };
      })(this));
    }
    if (this.config.table.colors) {
      return ColorFactory.processNewConfig(this.config.table.colors);
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
      return function(row, rowIndex) {
        if (!_.isArray(row)) {
          throw new Error("Invalid rows spec: row " + rowIndex + " must be array of cell definitions");
        }
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
      this.config.table.rowHeights = this.config.table.rowHeights.map(function(candidate) {
        var rowHeight;
        rowHeight = parseInt(candidate);
        if (_.isNaN(rowHeight)) {
          throw new Error("Invalid rowHeight '" + candidate + "': must be integer");
        }
        return rowHeight;
      });
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
          return parseInt(_this.initialHeight / _this.numTableRows);
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
      this.config.table.colWidths = this.config.table.colWidths.map(function(candidate) {
        var colWidth;
        colWidth = parseInt(candidate);
        if (_.isNaN(colWidth)) {
          throw new Error("Invalid colWidth '" + candidate + "': must be integer");
        }
        return colWidth;
      });
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
          return parseInt(_this.initialWidth / _this.numTableCols);
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
      sizeOfGuttersPast = 0;
      if (numCellsPast > 0 && numCellsPast < cellSizes.length) {
        sizeOfGuttersPast = numGuttersAtIndex(numCellsPast) * paddingSize - 0.5 * paddingSize;
      } else if (numCellsPast > 0 && numCellsPast === cellSizes.length) {
        sizeOfGuttersPast = numGuttersAtIndex(numCellsPast - 1) * paddingSize;
      }
      sizeOfFraction = 0;
      if (numCellsPast === 0) {
        sizeOfFraction = fractionOfCell * cellSizes[numCellsPast];
      } else if (numCellsPast < cellSizes.length) {
        sizeOfFraction = fractionOfCell * (cellSizes[numCellsPast] + paddingSize);
      }
      return sizeOfNumCellsPast + sizeOfGuttersPast + sizeOfFraction;
    };
    this.config.table.lines.horizontal = this.config.table.lines.horizontal.map((function(_this) {
      return function(lineIndexCandidate) {
        var lineIndex, y;
        lineIndex = parseFloat(lineIndexCandidate);
        if (_.isNaN(lineIndex)) {
          throw new Error("Invalid vertical line position '" + lineIndexCandidate + "': must be numeric");
        }
        if (lineIndex > _this.numTableRows || lineIndex < 0) {
          throw new Error("Cannot create line at '" + lineIndex + "': past end of table");
        }
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
      return function(lineIndexCandidate) {
        var lineIndex, x;
        lineIndex = parseFloat(lineIndexCandidate);
        if (_.isNaN(lineIndex)) {
          throw new Error("Invalid vertical line position '" + lineIndexCandidate + "': must be numeric");
        }
        if (lineIndex > _this.numTableCols || lineIndex < 0) {
          throw new Error("Cannot create line at '" + lineIndex + "': past end of table");
        }
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
    return this.config.table.rows.forEach((function(_this) {
      return function(row, rowIndex) {
        return row.forEach(function(cell, columnIndex) {
          cell.x = _.sum(_.slice(_this.config.table.colWidths, 0, columnIndex)) + numGuttersAtIndex(columnIndex) * _this.config.table.innerColumnPadding;
          cell.y = _.sum(_.slice(_this.config.table.rowHeights, 0, rowIndex)) + numGuttersAtIndex(rowIndex) * _this.config.table.innerRowPadding;
          cell.width = _this.config.table.colWidths[columnIndex];
          cell.height = _this.config.table.rowHeights[rowIndex];
          cell.row = rowIndex;
          return cell.col = columnIndex;
        });
      };
    })(this));
  };

  Pictograph.prototype._redraw = function() {
    var addLines, enteringCells, tableCells, tableId;
    this.cssCollector.draw();
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
      var cssWrapperClass, graphic, label;
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
        label = new LabelCell(d3.select(this), [tableId, cssWrapperClass], d.width, d.height);
        label.setConfig(d.value);
        return label.draw();
      }
    });
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

})(RhtmlSvgWidget);
