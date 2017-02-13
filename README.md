An R HTMLWidget that can generate single image graphics, mutli image graphics, or a table of single/multi image graphics.

# Installation in R

1. `library(devtools)`
1. `install_github('Displayr/rhtmlPictographs', auth_token='????????????????????')`

Simplest Example to verify installation:

```
rhtmlPictographs::graphic(0.33, 400, 400, '{"baseImageUrl": "https://s3-ap-southeast-2.amazonaws.com/kyle-public-numbers-assets/htmlwidgets/CroppedImage/black_square_512.png", "variableImageUrl": "https://s3-ap-southeast-2.amazonaws.com/kyle-public-numbers-assets/htmlwidgets/CroppedImage/blue_square_512.png"}')
```

# Local Installation to Develop/Contribute

Prerequisites:

1. Must have node.js version >= 6.1 installed
1. Must have Google Chrome installed
1. tested on OSX only, should work in Windows/Linux

Steps:

1. `git clone git@github.com:Displayr/rhtmlPictographs.git`
1. `cd rhtmlPictographs`
1. `npm install`
1. `gulp serve`

You should now see a page listing tutorial sections and several examples. Each of these pages has one or more pictographs defined.

Choose an example or add another example/tutorial to the [internal www content](theSrc/internal_www/content). When changes to the [widget source code](theSrc/scripts) or any other file in `./theSrc` are saved, the browser will automatically reload.

# Docs

The repo contains an internal web server that can be started via `gulp serve`. Once the server is running, on [the index page](http://127.0.0.1:9000) of the web content there is a link to a tutorial. This is the best way to understand how to use the widget.

This repo was build from the [rhtmlTemplate](https://github.com/Displayr/rhtmlTemplate) repo. The rhtmlTemplate repo has several docs pages linked from its main readme which are all relevant to the structure and inner working of the rhtmlPictograph repo.

## Detailed list of CSS class names - useful when targeting these DOM via the custom CSS feature

A bit out of date [here](docs/pictograph-dom-class-names.md)

## R Examples

The R examples are auto generated from the [internal www contents](theSrc/internal_www). You are strongly encouraged to view the contents in it's intended glorious format (using a browser), and only use the [R examples file](examples/) for reference.
