class BaseCell
  constructor: () ->

  draw: () ->
    throw new Error "BaseCell.draw must be overridden by child"
