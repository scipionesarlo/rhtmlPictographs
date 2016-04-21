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

  Pictograph.prototype._computeTableDimensions = function() {
    var maxCols;
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
    return maxCols = 0;
  };

  Pictograph.prototype.draw = function() {
    var enteringCells, pictographContext, tableCells, tableId, tableLayout;
    this.cssCollector.draw();
    this._manipulateRootElementSize();
    this._addRootSvgToRootElement();
    this._computeTableDimensions();
    tableLayout = d3.layout.grid().bands().size([this.initialWidth, this.initialHeight]).padding([0.1, 0.1]).rows(this.numTableRows);
    tableCells = _.flatten(this.config.table.rows);
    enteringCells = this.outerSvg.selectAll('.table-cell').data(tableLayout(tableCells)).enter().append('g').attr('class', 'table-cell').attr('transform', function(d) {
      return "translate(" + d.x + "," + d.y + ")";
    });
    pictographContext = this;
    tableId = this.config['table-id'];
    enteringCells.each(function(d, i) {
      var cssWrapperClass, graphic;
      cssWrapperClass = "table-cell-" + d.row + "-" + d.col;
      d3.select(this).classed(cssWrapperClass, true);
      if (d.type === 'graphic') {
        d3.select(this).classed('graphic', true);
        graphic = new GraphicCell(d3.select(this), [tableId, cssWrapperClass], tableLayout.nodeSize()[0], tableLayout.nodeSize()[1]);
        graphic.setConfig(d.value);
        graphic.draw();
      }
      if (d.type === 'label') {
        d3.select(this).classed('label', true);
        return d3.select(this).append('svg:text').attr('x', function(d) {
          return tableLayout.nodeSize()[0] / 2;
        }).attr('y', function(d) {
          return tableLayout.nodeSize()[1] / 2;
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

  return Pictograph;

})();
