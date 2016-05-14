module.exports = function(config) {
  config.set({
    browsers: ['PhantomJS'],
    // browsers: ['Chrome'],
    basePath: '',
    files: [
      'browser/external/d3.min.js',
      'browser/external/d3-grid.js',
      'browser/external/jquery.min.js',
      'browser/external/lodash.min.js',
      'browser/external/rHtmlStatefulWidget.js',
      'browser/external/rHtmlSvgWidget.js',

      'browser/scripts/BaseCell.js',
      'browser/scripts/DisplayError.js',
      'browser/scripts/GraphicCell.js',
      'browser/scripts/LabelCell.js',
      'browser/scripts/Pictograph.js',

      'test/*Spec.coffee',
      'test/**/*Spec.coffee',
      'testSpec.js',
      'testSpecC.coffee'
    ],

    frameworks: ['mocha', 'chai-dom', 'chai-as-promised', 'chai', 'sinon'],

    preprocessors: {
      '**/*.coffee': ['coffee']
    },

    phantomjsLauncher: {
      exitOnResourceError: true
    },

    coffeePreprocessor: {
      options: {
        bare: true,
        sourceMap: false
      },
      transformPath: function(path) {
        return path.replace(/\.coffee$/, '.js')
      }
    }
  })
};

