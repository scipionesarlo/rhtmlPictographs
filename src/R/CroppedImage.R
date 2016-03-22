#' Cropped Image HTML Widget
#'
#' A HTML Widget that displays an image cropped based on a provided percentage
#'
#' @description Generate a single cropped image infographic with optional text overlay.
#' Two images are provided, a base and a variable image.
#' The variable image is cropped vertically or horizontally to create a partially filled base image.
#' A text overlay contianing the "percentage fill" can be optionally displayed as well.
#'
#' @param percentage: numeric between 0 and 1
#' @param width: positive numeric representing desired width of widget
#' @param height: positive numeric representing desired height of widget
#' @param settingsJsonString: valid JSON string containing the following params
#'   - direction: ("horizontal"|"vertical") - default horizontal. Indicates direction of cropping
#'   - numImages: integer - default 1. The number of images to display
#'   - (todo) numRows: integer - default 1. The number of rows in the grid. Must be <= numImages
#'   - baseImageUrl: URL - required. The URL (including http://) of baseImage
#'   - variableImageUrl: URL - required. The URL (including http://) of variableImageUrl
#'   - text-overlay: (true|false) - default true. true to show text, false to hide text. By default text is <percentage>%
#'   - text-override: string - optional. override the <percentage>% default text
#'   - font-family: css - optional. Controls font. See : https://developer.mozilla.org/en/docs/Web/CSS/font-family
#'   - font-weight: css - optional. Controls font thickness. See : https://developer.mozilla.org/en/docs/Web/CSS/font-weight
#'   - font-size: css - optional. Controls font size. See : https://developer.mozilla.org/en/docs/Web/CSS/font-size
#'   - font-color: css - optional. Controls font color. Note this maps to the css 'color' property. See : https://developer.mozilla.org/en/docs/Web/CSS/color
#'
#' @examples
#'
#' single horizontally cropped image
#' CroppedImage(0.66, 400, 400, '{"direction": "horizontal", "baseImageUrl": "https://s3-ap-southeast-2.amazonaws.com/kyle-public-numbers-assets/htmlwidgets/CroppedImage/black_square_512.png", "variableImageUrl": "https://s3-ap-southeast-2.amazonaws.com/kyle-public-numbers-assets/htmlwidgets/CroppedImage/blue_square_512.png", "text-overlay": true, "font-family": "Verdana,sans-serif", "font-weight": "900", "font-size": "20px", "font-color": "white"}')
#'
#' @author Kyle Zeeuwen <kyle.zeeuwen@gmail.com>
#'
#' @source https://github.com/NumbersInternational/htmlwidgets-croppedimage
#'
#' @import htmlwidgets
#'
#' @export
#'

CroppedImage <- function(percentage, width = NULL, height = NULL, settingsJsonString = '{}') {

  input = list(
    percentage = percentage,
    settingsJsonString = settingsJsonString
  )

  # create widget
  htmlwidgets::createWidget(
    name = 'CroppedImage',
    input,
    width = width,
    height = height,
    package = 'CroppedImage'
  )
}
