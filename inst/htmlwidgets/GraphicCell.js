var GraphicCell,
  __hasProp = {}.hasOwnProperty,
  __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

GraphicCell = (function(_super) {
  __extends(GraphicCell, _super);

  function GraphicCell(parentSvg, config, width, height) {
    this.parentSvg = parentSvg;
    this.config = config;
    this.width = width;
    this.height = height;
  }

  GraphicCell.prototype.draw = function() {
    var backgroundRect, cssAttribute, d3Data, dimensions, displayText, enteringLeafNodes, graphicContainer, gridLayout, textFooter, textHeader, textOverlay, _i, _j, _k, _len, _len1, _len2, _ref, _ref1, _ref2, _results;
    dimensions = {};
    dimensions.headerHeight = 0 + (this.config['text-header'] != null ? this.config.text['font-size'] : 0);
    dimensions.footerHeight = 0 + (this.config['text-footer'] != null ? this.config.text['font-size'] : 0);
    dimensions.graphicHeight = this.height - dimensions.headerHeight - dimensions.footerHeight;
    dimensions.graphicOffSet = 0 + dimensions.headerHeight;
    dimensions.footerOffset = 0 + dimensions.headerHeight + dimensions.graphicHeight;
    if (this.config['text-header'] != null) {
      textHeader = this.parentSvg.append('svg:text').attr('x', this.width / 2).attr('y', dimensions.headerHeight / 2).style('text-anchor', 'middle').style('alignment-baseline', 'central').style('dominant-baseline', 'central').attr('class', 'text-header').text((function(_this) {
        return function(d) {
          return _this.config['text-header'];
        };
      })(this));
      if (this.config.text['font-color'] != null) {
        textHeader.attr('fill', this.config.text['font-color']);
      }
      _ref = ['font-family', 'font-size', 'font-weight'];
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        cssAttribute = _ref[_i];
        if (this.config.text[cssAttribute] != null) {
          textHeader.attr(cssAttribute, this.config.text[cssAttribute]);
        }
      }
    }
    graphicContainer = this.parentSvg.append('g').attr('class', 'graphic-container').attr('transform', "translate(0," + dimensions.graphicOffSet + ")");
    if (this.config['text-footer'] != null) {
      textFooter = this.parentSvg.append('svg:text').attr('x', this.width / 2).attr('y', dimensions.footerOffset + dimensions.footerHeight / 2).style('text-anchor', 'middle').style('alignment-baseline', 'central').style('dominant-baseline', 'central').attr('class', 'text-footer').text((function(_this) {
        return function(d) {
          return _this.config['text-footer'];
        };
      })(this));
      if (this.config.text['font-color'] != null) {
        textFooter.attr('fill', this.config.text['font-color']);
      }
      _ref1 = ['font-family', 'font-size', 'font-weight'];
      for (_j = 0, _len1 = _ref1.length; _j < _len1; _j++) {
        cssAttribute = _ref1[_j];
        if (this.config.text[cssAttribute] != null) {
          textFooter.attr(cssAttribute, this.config.text[cssAttribute]);
        }
      }
    }
    d3Data = this._generateDataArray(this.config.percentage, this.config.numImages);
    gridLayout = d3.layout.grid().bands().size([this.width, dimensions.graphicHeight]).padding([0.05, 0.05]).padding([this.config['interColumnPadding'], this.config['interRowPadding']]);
    if (this.config['numRows'] != null) {
      gridLayout.rows(this.config['numRows']);
    }
    if (this.config['numCols'] != null) {
      gridLayout.cols(this.config['numCols']);
    }
    enteringLeafNodes = graphicContainer.selectAll(".node").data(gridLayout(d3Data)).enter().append("g").attr("class", "node").attr("transform", function(d) {
      return "translate(" + d.x + "," + d.y + ")";
    });
    backgroundRect = enteringLeafNodes.append("svg:rect").attr('width', gridLayout.nodeSize()[0]).attr('height', gridLayout.nodeSize()[1]).attr('class', 'background-rect').attr('fill', this.config['background-color'] || 'none');
    if (this.config['debugBorder'] != null) {
      backgroundRect.attr('stroke', 'black').attr('stroke-width', '1');
    }
    if (this.config.baseImageUrl != null) {
      enteringLeafNodes.append("svg:image").attr('width', gridLayout.nodeSize()[0]).attr('height', gridLayout.nodeSize()[1]).attr('xlink:href', this.config.baseImageUrl).attr('class', 'base-image');
    }
    enteringLeafNodes.append('clipPath').attr('id', 'my-clip').append('rect').attr('x', 0).attr('y', (function(_this) {
      return function(d) {
        if (_this.config.direction === 'horizontal') {
          return 0;
        }
        return gridLayout.nodeSize()[1] * (1 - d.percentage);
      };
    })(this)).attr('width', (function(_this) {
      return function(d) {
        if (_this.config.direction === 'horizontal') {
          return gridLayout.nodeSize()[0] * d.percentage;
        }
        return gridLayout.nodeSize()[0];
      };
    })(this)).attr('height', (function(_this) {
      return function(d) {
        if (_this.config.direction === 'vertical') {
          return gridLayout.nodeSize()[1] * d.percentage;
        }
        return gridLayout.nodeSize()[1];
      };
    })(this));
    enteringLeafNodes.append("svg:image").attr('width', gridLayout.nodeSize()[0]).attr('height', gridLayout.nodeSize()[1]).attr('clip-path', 'url(#my-clip)').attr('xlink:href', this.config.variableImageUrl).attr('class', 'variable-image');
    if (this.config['tooltip']) {
      enteringLeafNodes.append("svg:title").text(this.config['tooltip']);
    }
    if (this.config['text-overlay']) {
      displayText = this.config['text-overlay'].match(/^percentage$/) ? "" + ((100 * this.config.percentage).toFixed(0)) + "%" : this.config['text-overlay'];
      textOverlay = enteringLeafNodes.append("svg:text").attr('x', function(d) {
        return gridLayout.nodeSize()[0] / 2;
      }).attr('y', function(d) {
        return gridLayout.nodeSize()[1] / 2;
      }).style('text-anchor', 'middle').style('alignment-baseline', 'central').style('dominant-baseline', 'central').attr('class', 'text-overlay').text(displayText);
      if (this.config.text['font-color'] != null) {
        textOverlay.attr('fill', this.config.text['font-color']);
      }
      _ref2 = ['font-family', 'font-size', 'font-weight'];
      _results = [];
      for (_k = 0, _len2 = _ref2.length; _k < _len2; _k++) {
        cssAttribute = _ref2[_k];
        if (this.config.text[cssAttribute] != null) {
          _results.push(textOverlay.attr(cssAttribute, this.config.text[cssAttribute]));
        } else {
          _results.push(void 0);
        }
      }
      return _results;
    }
  };

  GraphicCell.prototype._generateDataArray = function(percentage, numImages) {
    var d3Data, num, totalArea, _i;
    d3Data = [];
    totalArea = percentage * numImages;
    for (num = _i = 1; 1 <= numImages ? _i <= numImages : _i >= numImages; num = 1 <= numImages ? ++_i : --_i) {
      percentage = Math.min(1, Math.max(0, 1 + totalArea - num));
      d3Data.push({
        percentage: percentage
      });
    }
    return d3Data;
  };

  return GraphicCell;

})(BaseCell);
