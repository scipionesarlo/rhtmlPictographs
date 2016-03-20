An R HTMLWidget that displays a single cropped image infographic
# Installation

Prerequisites:

1. Must have node.js version >= 5.0 installed
2. tested on OSX only, should work in Windows/Linux

Steps:

1. `npm install`
2. `bower install`
3. `gulp build`

# To develop and test in test browser context:

Prerequisites: Chrome installed (tested on OSX only, should work in Windows/Linux)

`gulp serve`

Now make changes to the javascript/css. On file save, the browser will automatically reload with your changes

# To test locally in r context

Prerequisite: `gulp build`

Run this sequence in R:

```
library('devtools')
install('dist/package')
source('dist/package/R/CroppedImage.r')
CroppedImage(0.33, 400, 400, '{"baseImageUrl": "https://s3-ap-southeast-2.amazonaws.com/kyle-public-numbers-assets/htmlwidgets/CroppedImage/black_square_512.png", "variableImageUrl": "https://s3-ap-southeast-2.amazonaws.com/kyle-public-numbers-assets/htmlwidgets/CroppedImage/blue_square_512.png"}')
```

# R Usage

The actual R package - the project deliverable - is automatically generated in the `dist/package` directory when you run `gulp build`.

The signature definition is documented in the main [R file](src/R/CroppedImage.R)

# Todo

1. local image support
2. Go full JS class
3. Resize support

# Issues

1. Horizontal alignment of text overlay is not working correctly
2. Use of to be deprecated CSS property 'clip'
3. How does R / R Studio handle JS Errors (this code throws specific errors on invalid input)


