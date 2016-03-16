HTMLWidgets.widget({

  name: 'CroppedImage',

  type: 'output',

  factory: function(el, width, height) {

    var input = {
      direction: 'horizontal',
      percentage: 0.4233333,
      height: 150,
      width: 150,

      baseImageUrl: 'https://s3-ap-southeast-2.amazonaws.com/kyle-public-numbers-assets/htmlwidgets/CroppedImage/black_square.png',
      variableImageUrl: 'https://s3-ap-southeast-2.amazonaws.com/kyle-public-numbers-assets/htmlwidgets/CroppedImage/blue_square.png',

      height: 150, //@TODO right now this must be a numeric with no px, em, %, etc.
      width: 150, //@TODO right now this must be a numeric with no px, em, %, etc.
      'text-overlay': true,
      'font-family': 'Verdana,sans-serif',
      'font-weight': '900',
      'font-size': '20px',
      'font-color': 'white'
    };

    return {

      renderValue: function(x) {

        var generateClip = function() {
          var x;
          if (input.direction === 'horizontal') {
            x = input.percentage * input.width;
            return "rect(auto, " + x + "px, auto, auto)";
          } else if (input.direction === 'vertical') {
            x = input.height - input.percentage * input.height;
            return "rect(" + x + "px, auto, auto, auto)";
          } else {
            throw new Error("Boom !");
          }
        };

        var baseImage = $('<img>')
          .addClass('base-image')
          .attr('src', input.baseImageUrl)
          .css('width', input.width)
          .css('height', input.height);

        var variableImage = $('<img>')
          .addClass('variable-image')
          .attr('src', input.variableImageUrl)
          .css('width', input.width)
          .css('height', input.height)
          .css('clip', generateClip());

        var text = $('<span>')
          .addClass('text-overlay')
          .html('Text')

        var divContainer = $('<div>')
          .addClass('cropped-image-container')
          .css('width', input.width)
          .css('height', input.height);

        divContainer.append(baseImage).append(variableImage)

        if (input['text-overlay']) {
          var text = $('<span>').addClass('text-overlay');

          _.forEach(['font-family', 'font-size', 'font-weight'], function(cssAttribute) {
            if (_.has(input, cssAttribute)) {
              text.css(cssAttribute, input[cssAttribute]);
            }
          });

          if (_.has(input, 'font-color')) {
            text.css('color', input['font-color']);
          }

          formattedPercentage = (100 * input.percentage).toFixed(0);
          text.html(formattedPercentage + "%");

          //@TODO: this is a workaround, need to set horizontal align "better"
          text.css('margin-left', parseFloat(input.width) / 3.0 );
          text.css('margin-right', parseFloat(input.width) / 3.0 );

          divContainer.append(text);
        }

        $(el).append(divContainer);

        return null;
      },

      resize: function(width, height) {

        // TODO: code to re-render the widget with a new size

      }

    };
  }
});
