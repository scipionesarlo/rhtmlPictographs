var BaseCell;

BaseCell = (function() {
  function BaseCell() {}

  BaseCell.prototype.draw = function() {
    throw new Error("BaseCell.draw must be overridden by child");
  };

  return BaseCell;

})();
