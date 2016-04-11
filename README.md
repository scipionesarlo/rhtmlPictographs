An R HTMLWidget that can generate single image graphics, mutli image graphics, or a table of single/multi image graphics.

# Installation

Prerequisites:

1. Must have node.js version >= 5.0 installed
2. tested on OSX only, should work in Windows/Linux

Steps:

1. `npm install`
3. `gulp build`

# To develop and test in test browser context:

Prerequisites: Chrome installed (tested on OSX only, should work in Windows/Linux)

`gulp serve`

This should load a browser window, where a list of links to examples will be displayed. Choose an example or add another example to [R file](src/R/index.html). When changes to the [widget definition](src/scripts/rhtmlPictographs.coffee) or any other file are saved, the browser will automatically reload.

# To install in R

Prerequisite: `gulp build`

Run this sequence in R:

```
library('devtools')
install_github('NumbersInternational/rhtmlPictographs')
```

# R Usage

Try building a single image graphic:

```
rhtmlPictographs::graphic(0.33, 400, 400, '{"baseImageUrl": "https://s3-ap-southeast-2.amazonaws.com/kyle-public-numbers-assets/htmlwidgets/CroppedImage/black_square_512.png", "variableImageUrl": "https://s3-ap-southeast-2.amazonaws.com/kyle-public-numbers-assets/htmlwidgets/CroppedImage/blue_square_512.png"}')
```

The method signatures and their definitions are detailed in the main [R file](src/R/rhtmlPictographs.R)

# Todo

1. local image support
1. Go full JS class
1. Pie chart (radians) support
1. Multiple image substitute support
1. table of infographic support
1. Customisable multi image h/v alignmnent

# Issues

1. How does R / R Studio handle JS Errors (this code throws specific errors on invalid input)


