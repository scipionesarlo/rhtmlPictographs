
import d3 from 'd3';
import _ from 'lodash';

class GraphicCellGrid {

  static validInputDirections() {
    return [
      'right',
      'right,down',
      'right,up',
      'left',
      'left,down',
      'left,up',
      'down',
      'down,right',
      'down,left',
      'up',
      'up,right',
      'up,left',
    ];
  }

  static get validHorizontalDirections() {
    return ['right', 'left'];
  }
  static get validVerticalDirections() {
    return ['up', 'down'];
  }

  static _isValidInternalDirection(value) {
    const validHorizontalDirection = GraphicCellGrid.validHorizontalDirections.includes(value);
    const validVerticalDirection = GraphicCellGrid.validVerticalDirections.includes(value);
    return validHorizontalDirection || validVerticalDirection;
  }

  static get _defaultHorizontalDirection() {
    return 'right';
  }
  static get _defaultVerticalDirection() {
    return 'down';
  }

  constructor() {
    this.primaryDirection(GraphicCellGrid._defaultHorizontalDirection);
    this.secondaryDirection(GraphicCellGrid._defaultVerticalDirection);

    this.numRows = 0;
    this.numCols = 0;
    this.rowsSpecified = false;
    this.colsSpecified = false;
    this.containerSize([1, 1]);
    this._nodeSize = [1, 1];

    this.padding([0, 0]);
  }

  compute(newNodes) {
    this.nodes = newNodes;
    this._calcGridDimensions();
    this._calcNodeSize();
    return this._distribute();
  }

  _calcGridDimensions() {
    if (this.rowsSpecified && this.colsSpecified) {
      if ((this.numRows * this.numCols) !== this.nodes.length) {
        const errorMath = `${this.numRows} * ${this.numCols} !== ${this.nodes.length}`;
        throw new Error(`rows * cols must equal node length if both rows and cols are specified: ${errorMath}`);
      }
      return;
    }

    if (this.rowsSpecified && !this.colsSpecified) {
      this.numCols = Math.ceil(this.nodes.length / this.numRows);
    } else {
      if (!this.colsSpecified) {
        this.numCols = Math.ceil(Math.sqrt(this.nodes.length));
      }
      if (!this.rowsSpecified) {
        this.numRows = Math.ceil(this.nodes.length / this.numCols);
      }
    }
  }

  _calcNodeSize() {
    this.scale = {
      x: this._computeScale(this._containerWidth(), this.numCols, this._padding[0]),
      y: this._computeScale(this._containerHeight(), this.numRows, this._padding[1])
    };
  }

  // NB div by zero on gutterAllocation === 1 is avoided by validation rules in this.padding()
  _computeScale(totalSize, numElements, gutterAllocation) {
    const numGutters = numElements - 1;
    const gutterToColRatio = gutterAllocation / (1 - gutterAllocation);
    const nodeSize = totalSize / (numElements + (numGutters * gutterToColRatio));
    const gutterSize = nodeSize * gutterToColRatio;
    return { nodeSize, gutterSize };
  }

  getTopLeftCoordOfImageSlot(rowNumber, colNumber) {

    // adjust to get top left coord of slot not right (due to mirroring in _getRangeFromDomain)
    const adjustedColumnNumber = (columnNumber) => {
      if ([this.primaryDirection(), this.secondaryDirection()].includes('left')) {
        return columnNumber + 0.99999999;
      }
      return columnNumber;
    }

    // adjust to get top coord of slot not bottom (due to mirroring in _getRangeFromDomain)
    const adjustedRowNumber = (rowNumber) => {
      if ([this.primaryDirection(), this.secondaryDirection()].includes('up')) {
        return rowNumber + 0.99999999;
      }
      return rowNumber;
    }

    return {
      x: this.getX(adjustedColumnNumber(colNumber)),
      y: this.getY(adjustedRowNumber(rowNumber))
    }
  }

  getX(position) {
    if ([this.primaryDirection(), this.secondaryDirection()].includes('left')) {
      let x = this._getRangeFromDomain(position, this.scale.x.nodeSize, this.scale.x.gutterSize);
      return this._containerWidth() - x;
    }
    return this._getRangeFromDomain(position, this.scale.x.nodeSize, this.scale.x.gutterSize);
  }

  getGutterX(position) {
    if ([this.primaryDirection(), this.secondaryDirection()].includes('left')) {
      let x = this._getGutterRangeFromDomain(position, this.scale.x.nodeSize, this.scale.x.gutterSize);
      return this._containerWidth() - x;
    }
    return this._getGutterRangeFromDomain(position, this.scale.x.nodeSize, this.scale.x.gutterSize);
  }

  getY(position) {
    if ([this.primaryDirection(), this.secondaryDirection()].includes('up')) {
      let y = this._getRangeFromDomain(position, this.scale.y.nodeSize, this.scale.y.gutterSize);
      return this._containerHeight() - y;
    }
    return this._getRangeFromDomain(position, this.scale.y.nodeSize, this.scale.y.gutterSize);;
  }

  getGutterY(position) {
    if ([this.primaryDirection(), this.secondaryDirection()].includes('up')) {
      let y = this._getGutterRangeFromDomain(position, this.scale.y.nodeSize, this.scale.y.gutterSize);
      return this._containerWidth() - y;
    }
    return this._getGutterRangeFromDomain(position, this.scale.y.nodeSize, this.scale.y.gutterSize);
  }

  _getRangeFromDomain(position, nodeSize, gutterSize) {
    const seperate = function(position) {
      const whole = (position > 0) ? Math.floor(position) : Math.ceil(position);
      const fraction = parseFloat(position) - whole;
      return { whole, fraction };
    }

    const { whole, fraction } = seperate(position);
    const x = whole * nodeSize + whole * gutterSize + fraction * nodeSize;
    return x;
  }

  _getGutterRangeFromDomain(position, nodeSize, gutterSize) {
    const seperate = function(position) {
      const whole = (position > 0) ? Math.floor(position) : Math.ceil(position);
      const fraction = parseFloat(position) - whole;
      return { whole, fraction };
    }

    if (position < 1) {
      throw new Error(`Invalid gutter position '${position}: must be >= 1`);
    }

    // TODO test for greater than number gutter ?

    const { whole, fraction } = seperate(position);
    const x = whole * nodeSize + (whole - 1) * gutterSize + fraction * gutterSize;
    return x;
  }

  _distribute() {
    const lastColumn = this.numCols - 1;
    const lastRow = this.numRows - 1;

    const initializeNextVacantSpot = function (primaryDirection, secondaryDirection) {
      const nextVacantSpot = {
        row: null,
        col: null,
        rowOrder: 0,
        colOrder: 0,
      };

      [primaryDirection, secondaryDirection].forEach((direction) => {
        switch (direction) {
          case 'right':
            nextVacantSpot.col = 0;
            break;
          case 'left':
            nextVacantSpot.col = 0;
            break;
          case 'down':
            nextVacantSpot.row = 0;
            break;
          case 'up':
            nextVacantSpot.row = 0;
            break;
          default:
            throw new Error(`Unexpected direction: '${direction}'`);
        }
      });

      return nextVacantSpot;
    };

    const nextVacantSpot = initializeNextVacantSpot(this.primaryDirection(), this.secondaryDirection());

    const advanceRow = function (increment) {
      nextVacantSpot.rowOrder += 1;
      nextVacantSpot.row += increment;
    };
    const resetRow = function (resetValue) {
      nextVacantSpot.rowOrder = 0;
      nextVacantSpot.row = resetValue;
    };
    const advanceCol = function (increment) {
      nextVacantSpot.colOrder += 1;
      nextVacantSpot.col += increment;
    };
    const resetCol = function (resetValue) {
      nextVacantSpot.colOrder = 0;
      nextVacantSpot.col = resetValue;
    };

    let i = -1;
    while (++i < this.nodes.length) {
      const topLeftCoords = this.getTopLeftCoordOfImageSlot(nextVacantSpot.row, nextVacantSpot.col)
      _.merge(this.nodes[i], topLeftCoords);
      // this.nodes[i].x = this.getX(nextVacantSpot.col);
      // this.nodes[i].y = this.getY(nextVacantSpot.row);

      // this.nodes[i].col = nextVacantSpot.col;
      // this.nodes[i].row = nextVacantSpot.row;
      this.nodes[i].rowOrder = nextVacantSpot.rowOrder;
      this.nodes[i].colOrder = nextVacantSpot.colOrder;
      switch (this.primaryDirection()) {
        case 'right':
          if (nextVacantSpot.col < lastColumn) {
            advanceCol(1);
          } else {
            resetCol(0);
            advanceRow(1);
          }
          break;
        case 'left':
          if (nextVacantSpot.col < lastColumn) {
            advanceCol(1);
          } else {
            resetCol(0);
            advanceRow(1);
          }
          break;
        case 'down':
          if (nextVacantSpot.row < lastRow) {
            advanceRow(1);
          } else {
            resetRow(0);
            advanceCol(1);
          }
          break;
        case 'up':
          if (nextVacantSpot.row < lastRow) {
            advanceRow(1);
          } else {
            resetRow(0);
            advanceCol(1);
          }
          break;
        default:
          throw new Error(`Unexpected direction: '${this.primaryDirection()}'`);
      }
    }
    return this.nodes;
  }

  rows(value) {
    this.rowsSpecified = true;
    this.numRows = value;
    return this;
  }

  cols(value) {
    this.colsSpecified = true;
    this.numCols = value;
    return this;
  }

  containerSize(newSize) {
    this._containerSize = newSize;
    return this;
  }

  _containerWidth() {
    return this._containerSize[0];
  }

  _containerHeight() {
    return this._containerSize[1];
  }

  padding(value) {
    if (!_.isArray(value)) {
      throw new Error("Padding must be array");
    }
    if (value[0] >= 1 || value[1] >= 1) {
      throw new Error("Padding values must be less than 1");
    }
    if (value[0] < 0 || value[1] < 0) {
      throw new Error("Padding values must be greater than or equal to 0");
    }
    this._padding = value;
    return this;
  }

  nodeSize() {
    return [this.scale.x.nodeSize, this.scale.y.nodeSize];
  }

  direction(value) {
    if (arguments.length === 0) {
      return `${this.primaryDirection()},${this.secondaryDirection()}`;
    }

    const directions = value.split(',');
    const singleDirectionProvided = directions.length === 1;

    this.primaryDirection(directions[0]);

    if (singleDirectionProvided) {
      if (GraphicCellGrid.validHorizontalDirections.includes(this.primaryDirection())) {
        this.secondaryDirection(GraphicCellGrid._defaultVerticalDirection);
      } else {
        this.secondaryDirection(GraphicCellGrid._defaultHorizontalDirection);
      }
    } else {
      this.secondaryDirection(directions[1]);
    }

    return this;
  }

  primaryDirection(value) {
    if (!value) {
      return this._primaryDirection;
    }
    if (!GraphicCellGrid._isValidInternalDirection(value)) {
      throw new Error(`Invalid primary direction ${value}`);
    }
    this._primaryDirection = value;
    return this;
  }

  secondaryDirection(value) {
    if (!value) {
      return this._secondaryDirection;
    }
    if (!GraphicCellGrid._isValidInternalDirection(value)) {
      throw new Error(`Invalid secondary direction ${value}`);
    }
    this._secondaryDirection = value;
    return this;
  }
}

module.exports = GraphicCellGrid;
