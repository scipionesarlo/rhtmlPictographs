#This file is auto generated from /content/bugs_and_improvements/vis-177-floating-labels.html
#The html examples and tutorial are the source of truth and are far more readable and beneficial. Start there (see readme for how).
#Use these r files for reference, but know that some instructional content is not transferred from the html to the r examples files
#TL;DR View the tutorial/example the way it was meant to be: in HTML format!

rhtmlPictographs::graphic('{ "table": { "rowGutterLength": 1, "columnGutterLength": 1, "rowHeights": [30, 300, 30], "colWidths": [100, 100, 100], "lines": {}, "rows": [ ["label:2", "label:7", "label:5"], [ { "type": "graphic", "value": { "debugBorder": "foot", "floatingLabels": [{ "position": "0:0", "text": "foo" }], "proportion": "=2/7", "numCols": "1", "variableImage": "circle:frombottom:red", "numImages": 7 } }, { "type": "graphic", "value": { "proportion": "=7/7", "numCols": "1", "variableImage": "circle:frombottom:blue", "numImages": 7 } }, { "type": "graphic", "value": { "proportion": "=5/7", "numCols": "1", "variableImage": "circle:frombottom:green", "numImages": 7 } } ], ["label:first", "label:second", "label:third"] ] } } ')
