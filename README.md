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

This should load a browser window, where a list of links to examples will be displayed. Choose an example or add another example to [R file](src/R/index.html). When changes to the [widget definition](src/scripts/CroppedImage.coffee) or any other file are saved, the browser will automatically reload.

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
4. Pie chart (radians) support
5. Multiple image substitute support
7. table of infographic support
1. Lower and Upper Text Banners
2. Customisable multi image gutters (inner padding)
3. Customisable multi image h/v alignmnent
8. Full port from bower to node_modules

# Issues

1. Vertical alignment of text overlay is slightly off (likely just a missing svg style setting).
2. How does R / R Studio handle JS Errors (this code throws specific errors on invalid input)


