#This file is auto generated from /tutorials/labelCell.html
#The html demo examples and tutorial are the source of truth and are far more readable and beneficial. Start there (see readme for how).
#Use these r files for reference, but know that some instructional content is not transferred from the html to the r examples files
#TL;DR View the tutorial/example the way it was meant to be: in HTML format!

#Simplest Label Using shorthand "string syntax"
#Simplest Label, Multiple Label, Object as Label
## In its absolute simplest for we specify a label cell simply as a string that starts with "label:". In this for the cell does not even need to be an object with a '{type: 'label', value: ...}
## In the next simplest form, we specify the cell as an object with type=label, and use a single string for the "value" of the "value" key
## In the next simplest form, we specify an array of strings for the value
## If we need more control than that, we can set value to an object of keys, or an array of objects with keys
##The following parameters can be set for a label:
rhtmlPictographs::graphic('{ "table": { "rows": [ [ "label:A label" ] ] } }')
rhtmlPictographs::graphic('{ "table": { "rows": [ [ { "type": "label", "value": "A label" } ] ] } }')
rhtmlPictographs::graphic('{ "table": { "rows": [ [ { "type": "label", "value": [ "Line 1", "Line 2" ] } ] ] } }')
rhtmlPictographs::graphic('{ "table": { "rows": [ [ { "type": "label", "value": { "text": "A label", "font-color" : "red", "font-size": "20px", "font-family": "impact", "font-weight" : "100" } } ] ] } }')
rhtmlPictographs::graphic('{ "table": { "rows": [ [ { "type": "label", "value": [{ "text": "label 1" }, { "text": "label 2" }] } ] ] } }')

#Multi Label, With Padding, With Different Fonts on Each Line
rhtmlPictographs::graphic('{ "table": { "rows": [ [ { "type": "label", "value": { "padding-top": 20, "padding-inner": 25, "labels": [ "Line 1", { "text": "Line 2", "font-size": "14px", "font-color": "red" } ] } } ] ] } }')

#Text Alignment in labels
##The attribute to control horizontal text alignment is called horizontal-align. In order to use horizontal-align you must specify the label as an object, not as a simple string.
##There are three options: left, middle, and right. For convenience the keywords "start", "centre", "center", and "end" are also valid.
##When specifying left aligned labels, you will probably want to add "padding-left" as well, so that the label does not crowd the border
##When specifying right aligned labels, you will probably want to add "padding-right" as well, so that the label does not crowd the border
rhtmlPictographs::graphic('{ "table": { "rows": [ [ { "type": "label", "value": { "text" : "A label", "horizontal-align": "left" } } ] ] } }')
rhtmlPictographs::graphic('{ "table": { "rows": [ [ { "type": "label", "value": { "text" : "A label", "horizontal-align": "center" } } ] ] } }')
rhtmlPictographs::graphic('{ "table": { "rows": [ [ { "type": "label", "value": { "text" : "A label", "horizontal-align": "right" } } ] ] } }')

#Putting all the label alignments together
rhtmlPictographs::graphic('{ "font-color": "lightblue", "font-family": "Arvo, serif", "table": { "rows": [ [ { "type": "label", "value": { "padding-top": "5", "padding-inner": "5", "padding-left": "15", "padding-right": "15", "labels": [ { "text" : "Left Aligned", "horizontal-align": "left" }, { "text" : "Center Aligned", "horizontal-align": "center" }, { "text" : "Right Aligned", "horizontal-align": "right" } ] } } ] ] } }')

#Using small capital letters
##The font-variant small-caps can be set, which renders all lower case letters as small upper case letters.
rhtmlPictographs::graphic('{ "font-color": "lightblue", "font-family": "Arvo, serif", "table": { "rows": [ [ { "type": "label", "value": { "padding-left" : 5, "padding-inner" : 5, "labels": [ { "horizontal-align": "left", "text" : "abcdefghijklmnopqrstuvwxyz ABCDEFGHIJKLMNOPQRSTUVWXYZ", "font-variant": "small-caps" }, { "horizontal-align": "left", "text" : "abcdefghijklmnopqrstuvwxyz ABCDEFGHIJKLMNOPQRSTUVWXYZ", "font-variant": "normal" } ] } } ] ] } }')
