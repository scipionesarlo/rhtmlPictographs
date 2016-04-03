#' rhtmlPictographs HTML Widget
#'
#' A HTMLWidget that can generate single image graphics, mutli image graphics, or a table of single/multi image graphics
#'
#' @description Scenario 1: Single graphic containing one or more image
#' Generate a single graphic containing one or more images, with one of the images cropped to represent a percentage.
#' One or more images are provided, a base and a variable image.
#' The variable image is cropped vertically or horizontally to create a partially displayed image.
#' If the base image is provided it will be fully rendered "underneath" the variable image.
#' A text overlay contianing the "percentage fill" or any other supplied text can be displayed as well.
#'
#' @param percentage: numeric between 0 and 1
#' @param width: positive numeric representing desired width of graphic
#' @param height: positive numeric representing desired height of graphic
#' @param settingsJsonString: valid JSON string containing the following params
#'   - direction: ("horizontal"|"vertical") - default horizontal. Indicates direction of cropping
#'   - numImages: integer - default 1. The number of images to display
#'   - numRows: integer - default unset. The number of rows in the grid. Must be <= numImages
#'   - numCols: integer - default unset. The number of cols in the grid. Must be <= numImages
#'   - baseImageUrl: URL - required. The URL (including http://) of baseImage
#'   - variableImageUrl: URL - required. The URL (including http://) of variableImageUrl
#'   - background-color: string - default unset. Set a background color under both images
#'   - text-overlay: - string - default unset. A string to display overlaid over the center of the graphic. If string set to 'percentage' then the numeric percentage will be displayed
#'   - text-header: string - default unset. Text to display above graphic
#'   - text-override: string - optional. Text to display below graphic
#'   - font-family: css - optional. Controls font. See : https://developer.mozilla.org/en/docs/Web/CSS/font-family
#'   - font-weight: css - optional. Controls font thickness. See : https://developer.mozilla.org/en/docs/Web/CSS/font-weight
#'   - font-size: css - optional. Controls font size. See : https://developer.mozilla.org/en/docs/Web/CSS/font-size
#'   - font-color: css - optional. Controls font color. Note this maps to the css 'color' property. See : https://developer.mozilla.org/en/docs/Web/CSS/color
#'   - tooltip: string - optional. A string to display on mouse hover over the graphic
#'
#' @examples
#'
#' single horizontally cropped image - minimal settings
#' rhtmlPictographs::graphic(0.66, 400, 400, '{"direction": "horizontal", "baseImageUrl": "https://s3-ap-southeast-2.amazonaws.com/kyle-public-numbers-assets/htmlwidgets/CroppedImage/black_square_512.png", "variableImageUrl": "https://s3-ap-southeast-2.amazonaws.com/kyle-public-numbers-assets/htmlwidgets/CroppedImage/blue_square_512.png"}')
#'
#' single horizontally cropped image - fully customized
#' rhtmlPictographs::graphic(0.66, 400, 400, '{"direction": "vertical", "baseImageUrl": "https://s3-ap-southeast-2.amazonaws.com/kyle-public-numbers-assets/htmlwidgets/CroppedImage/black_square_512.png", "variableImageUrl": "https://s3-ap-southeast-2.amazonaws.com/kyle-public-numbers-assets/htmlwidgets/CroppedImage/blue_square_512.png", "text-overlay": "Heaps customizable!", "background-color": "green", "text-header": "Big header", "text-footer": "Big footer", "font-family": "verdana", "font-weight": "900", "font-size": "32px", "font-color": "magenta", "tooltip": "hover text!"}')
#'
#' single horizontally cropped image - minimal settings
#' rhtmlPictographs::graphic(0.66, 400, 400, '{"numImages": 3, "text-overlay": false, "baseImageUrl": "https://s3-ap-southeast-2.amazonaws.com/kyle-public-numbers-assets/htmlwidgets/CroppedImage/black_square_512.png", "variableImageUrl": "https://s3-ap-southeast-2.amazonaws.com/kyle-public-numbers-assets/htmlwidgets/CroppedImage/blue_square_512.png"}')
#'
#' multiple cropped image graphic
#' rhtmlPictographs::graphic(0.8, 400, 400, '{"numImages": 3, "baseImageUrl": "https://s3-ap-southeast-2.amazonaws.com/kyle-public-numbers-assets/htmlwidgets/CroppedImage/black_square_512.png", "variableImageUrl": "https://s3-ap-southeast-2.amazonaws.com/kyle-public-numbers-assets/htmlwidgets/CroppedImage/blue_square_512.png", "text-header": "Big header", "text-footer": "Big footer", "font-family": "verdana", "font-weight": "900", "font-size": "24px", "font-color": "blue"}')
#' @author Kyle Zeeuwen <kyle.zeeuwen@gmail.com>
#'
#' @source https://github.com/NumbersInternational/htmlwidgets-croppedimage
#'
#' @import htmlwidgets
#'
#' @export
#'

graphic <- function(percentage, width = NULL, height = NULL, settingsJsonString = '{}') {

  input = list(
    percentage = percentage,
    settingsJsonString = settingsJsonString
  )

  # create widget
  htmlwidgets::createWidget(
    name = 'rhtmlPictographs',
    input,
    width = width,
    height = height,
    package = 'rhtmlPictographs'
  )
}
