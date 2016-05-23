describe 'ColorFactory class', ->

  describe 'getColorFromPalette()', ->

    it 'round robins through a color palette', ->

      ColorFactory.processNewConfig {
        palettes:
          test: ['red', 'blue', 'green' ]
      }

      expect(ColorFactory.getColorFromPalette('test')).to.equal 'red'
      expect(ColorFactory.getColorFromPalette('test')).to.equal 'blue'
      expect(ColorFactory.getColorFromPalette('test')).to.equal 'green'
      expect(ColorFactory.getColorFromPalette('test')).to.equal 'red'

