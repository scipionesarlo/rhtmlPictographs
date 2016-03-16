HTMLWidgets.widget({

  name: 'CroppedImage',

  type: 'output',

  factory: function(el, width, height) {

    var input = {
      direction: 'horizontal',
      percentage: 0.2,
      height: 350, //@TODO right now this must be a numeric with no px, em, %, etc.
      width: 350, //@TODO right now this must be a numeric with no px, em, %, etc.

      baseImageUrl: 'https://s3-ap-southeast-2.amazonaws.com/kyle-public-numbers-assets/htmlwidgets/CroppedImage/black_square.png',
      variableImageUrl: 'https://s3-ap-southeast-2.amazonaws.com/kyle-public-numbers-assets/htmlwidgets/CroppedImage/blue_square.png',

      'text-overlay': true,
      'font-family': 'Verdana,sans-serif',
      'font-weight': '900',
      'font-size': '20px',
      'font-color': 'orange'
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

        var divContainer = $('<div>')
          .addClass('cropped-image-container')
          .css('width', input.width)
          .css('height', input.height);

        divContainer.append(baseImage).append(variableImage)

        if (input['text-overlay']) {

          var textContainer = $('<div>').addClass('text-container')
            .css('width', input.width)
            .css('height', input.height)
            .css('line-height', input.height + 'px') //@TODO must have px ...

          var textTranslateValue = 'translate(' + (input.height / 2) + 'px)';
          console.log(textTranslateValue);
          var text = $('<span>').addClass('text-overlay')
            .css('transform', textTranslateValue) //@TODO not a good solution
            .css('margin-left', '-16px') //@TODO even worse

          textContainer.append(text)

          _.forEach(['font-family', 'font-size', 'font-weight'], function(cssAttribute) {
            if (_.has(input, cssAttribute)) {
              text.css(cssAttribute, input[cssAttribute]);
            }
          });

          if (_.has(input, 'font-color')) {
            text.css('color', input['font-color']);
          }

          formattedPercentage = (100 * input.percentage).toFixed(0);
          text.html(formattedPercentage + '%');

          divContainer.append(textContainer);
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
