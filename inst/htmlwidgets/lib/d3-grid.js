(function() {
  var DEBUG = false;

  d3.layout.grid = function() {
    var mode = "equal",
        layout = _distributeEqually,
        x = d3.scale.ordinal(),
        y = d3.scale.ordinal(),
        size = [1, 1],
        actualSize = [0, 0],
        nodeSize = false,
        bands = false,
        padding = [0, 0],
        desiredCols, desiredRows;

    function grid(nodes) {
      return layout(nodes);
    }

    function _distributeEqually(nodes) {
      var numCols = desiredCols ? desiredCols : 0;
      var numRows = desiredRows ? desiredRows : 0;
      var col;
      var row;

      function calcGridDimensions() {
        if (numRows && !numCols) {
          numCols = Math.ceil(nodes.length / numRows)
        } else {
          numCols || (numCols = Math.ceil(Math.sqrt(nodes.length)));
          numRows || (numRows = Math.ceil(nodes.length / numCols));
        }
      }

      function calcActualSize() {
        if (nodeSize) {
          x.domain(d3.range(numCols)).range(d3.range(0, (size[0] + padding[0]) * numCols, size[0] + padding[0]));
          y.domain(d3.range(numRows)).range(d3.range(0, (size[1] + padding[1]) * numRows, size[1] + padding[1]));
          actualSize[0] = bands ? x(numCols - 1) + size[0] : x(numCols - 1);
          actualSize[1] = bands ? y(numRows - 1) + size[1] : y(numRows - 1);
        } else if (bands) {
          x.domain(d3.range(numCols)).rangeBands([0, size[0]], padding[0], 0);
          y.domain(d3.range(numRows)).rangeBands([0, size[1]], padding[1], 0);
          actualSize[0] = x.rangeBand();
          actualSize[1] = y.rangeBand();
        } else {
          x.domain(d3.range(numCols)).rangePoints([0, size[0]]);
          y.domain(d3.range(numRows)).rangePoints([0, size[1]]);
          actualSize[0] = x(1);
          actualSize[1] = y(1);
        }
      }

      // layout left to right (vary cols), then top to bottom (vary rows)
      // detect when we are assigning to a "gap" and skip gaps

      function layoutNodes() {

        var nextVacantSpot = { col: 0, row: 0 };
        var numGaps = numRows * numCols - nodes.length;
        var modulo = nodes.length % numRows;

        var pickNextSpot = function() {

          var advance = function() {
            if (nextVacantSpot.col < numCols - 1) {
              nextVacantSpot.col++;
            }
            else {
              nextVacantSpot.row++;
              nextVacantSpot.col = 0;
            }
          };

          var isGap = function() {

            if (numGaps == 0) {
              return false;
            }

            if (!desiredRows && !desiredCols) {
              return false;
            }

            //NB the layout is left-to-right then top-to-bottom, so gaps are not an issue if numCols specified
            if (desiredRows) {
              if (nextVacantSpot.col == numCols - 1) {
                if (nextVacantSpot.row + 1 > modulo) {
                  return true;
                }
              }
            }

            return false;
          }

          var runAwayBreaker = 0; //NB shouldn't happen but guard anyway
          while (true) {
            runAwayBreaker++;
            advance();

            if (!isGap()) {
              break;
            }

            if (runAwayBreaker > nodes.length) {
              break;
            }
          }
        }

        var i = -1;
        while (++i < nodes.length) {

          nodes[i].x = x(nextVacantSpot.col);
          nodes[i].y = y(nextVacantSpot.row);
          nodes[i].col = nextVacantSpot.col;
          nodes[i].row = nextVacantSpot.row;

          pickNextSpot();

        }
      }

      calcGridDimensions();
      calcActualSize();

      if (DEBUG) console.log('specified cols/rows', desiredCols, desiredRows);
      if (DEBUG) console.log('computed cols/rows', numCols, numRows);

      layoutNodes();

      return nodes;
    }

    grid.size = function(value) {
      if (!arguments.length) return nodeSize ? actualSize : size;
      actualSize = [0, 0];
      nodeSize = (size = value) == null;
      return grid;
    }

    grid.nodeSize = function(value) {
      if (!arguments.length) return nodeSize ? size : actualSize;
      actualSize = [0, 0];
      nodeSize = (size = value) != null;
      return grid;
    }

    grid.rows = function(value) {
      if (!arguments.length) return desiredRows;
      if (desiredCols) throw new Error("Cannot specify both rows and cols");
      desiredRows = value;
      return grid;
    }

    grid.cols = function(value) {
      if (!arguments.length) return desiredCols;
      if (desiredRows) throw new Error("Cannot specify both rows and cols");
      desiredCols = value;
      return grid;
    }

    grid.bands = function() {
      bands = true;
      return grid;
    }

    grid.points = function() {
      bands = false;
      return grid;
    }

    grid.padding = function(value) {
      if (!arguments.length) return padding;
      padding = value;
      return grid;
    }

    return grid;
  };
})();
