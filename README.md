An R HTMLWidget that displays a single cropped image infographic
# installation

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

1. library('devtools')
2. install('dist/package')
3. source('dist/package/R/CroppedImage.r')
4. CroppedImage('ff')

# R Usage

The actual R package - the project deliverable - is automatically generated in the `dist/package` directory when you run `gulp build`.

Currently all params are hardcoded in the JS layer. Obviously this will be addressed.


