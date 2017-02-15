#This file is auto generated from /content/tutorials/2_graphicCell_external_images.html
#The html examples and tutorial are the source of truth and are far more readable and beneficial. Start there (see readme for how).
#Use these r files for reference, but know that some instructional content is not transferred from the html to the r examples files
#TL;DR View the tutorial/example the way it was meant to be: in HTML format!

#Option 1: use the "slice" feature of SVG aspect ratios
#Option 2: use the "none" feature of SVG aspect ratios
#Option 3: use the "min vs mid vs max" settings of SVG aspect ratios
##Consider this external image of a 600x900 green rectange:
##Consider placing that external image inside several different graphic cell dimensions:
##There are two ways to address this if you want the external image to completely fill the provided image slot:
##You can also "shift" the image up down left and right so all extra space will appear on one side of the image:
## * Option 1: use the "slice" feature of SVG aspect ratios: This tells the SVG engine to fill the slot with the image and try to get the aspect ratio as close as possible, and its ok to crop the image a bit.
## * Option 2: use the "none" feature of SVG aspect ratios: This tells the SVG engine to fill the slot with the image by distorting it, completely ignoring the aspect ratio of the image.
## * Option 3: use the "min/mid/max" setting of SVG aspect ratios: This tells the SVG engine to move the image in specific directions so all extra space occurs one or more sides of the image.
rhtmlPictographs::graphic('url:/images/green_rectangle_600_900.jpg')
rhtmlPictographs::graphic('url:/images/green_rectangle_600_900.jpg')
rhtmlPictographs::graphic('url:/images/green_rectangle_600_900.jpg')
rhtmlPictographs::graphic('{ "variableImage": { "type": "url", "url": "/images/green_rectangle_600_900.jpg", "preserveAspectRatio" : "xMidYMid slice" } }')
rhtmlPictographs::graphic('{ "variableImage": { "type": "url", "url": "/images/green_rectangle_600_900.jpg", "preserveAspectRatio" : "xMidYMid slice" } }')
rhtmlPictographs::graphic('{ "variableImage": { "type": "url", "url": "/images/green_rectangle_600_900.jpg", "preserveAspectRatio" : "none" } }')
rhtmlPictographs::graphic('{ "variableImage": { "type": "url", "url": "/images/green_rectangle_600_900.jpg", "preserveAspectRatio" : "none" } }')
rhtmlPictographs::graphic('{ "variableImage": { "type": "url", "url": "/images/green_rectangle_600_900.jpg", "preserveAspectRatio" : "xMinYMid meet" } }')
rhtmlPictographs::graphic('{ "variableImage": { "type": "url", "url": "/images/green_rectangle_600_900.jpg", "preserveAspectRatio" : "xMaxYMid meet" } }')
rhtmlPictographs::graphic('{ "variableImage": { "type": "url", "url": "/images/green_rectangle_600_900.jpg", "preserveAspectRatio" : "xMidYMin meet" } }')
rhtmlPictographs::graphic('{ "variableImage": { "type": "url", "url": "/images/green_rectangle_600_900.jpg", "preserveAspectRatio" : "xMidYMax meet" } }')
