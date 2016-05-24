describe 'ImageFactory class:', ->

  describe 'parseConfigString():', ->

    beforeEach ->
      @run = (configString, expectConfig) ->
        ImageFactory.parseConfigString configString
        expect(ImageFactory.parseConfigString configString).to.deep.equal expectConfig

    describe 'url:', ->
      it 'is good', -> @run 'http://example.com/foo', { type: 'url', url: 'http://example.com/foo' }
      it 'is good', -> @run 'https://example.com/foo', { type: 'url', url: 'https://example.com/foo' }
      it 'is good', -> @run 'url:http://example.com/foo', { type: 'url', url: 'http://example.com/foo' }
      it 'is good', -> @run 'url:scale:http://example.com/foo', { type: 'url', url: 'http://example.com/foo', scale: true }
      it 'is good', -> @run 'url:scale:foo.jpg', { type: 'url', url: 'foo.jpg', scale: true }
      it 'is good', -> @run 'url:vertical:http://example.com/foo', { type: 'url', url: 'http://example.com/foo', verticalclip: true }
      it 'is good', -> @run 'url:verticalclip:http://example.com/foo', { type: 'url', url: 'http://example.com/foo', verticalclip: true }
      it 'is good', -> @run 'url:horizontal:http://example.com/foo', { type: 'url', url: 'http://example.com/foo', horizontalclip: true }
      it 'is good', -> @run 'url:horizontalclip:http://example.com/foo', { type: 'url', url: 'http://example.com/foo', horizontalclip: true }
      it 'is good', -> @run 'url:/local/image.jpg', { type: 'url', url: '/local/image.jpg' }

    describe 'shapes brief:', ->
      # config parsing of shapes is currently identical, so detailed testing is in circle, this block just tests existence
      it 'is good', -> @run 'circle', { type: 'circle' }
      it 'is good', -> @run 'ellipse', { type: 'ellipse' }
      it 'is good', -> @run 'square', { type: 'square' }
      it 'is good', -> @run 'rect', { type: 'rect' }

    describe 'circles detailed:', ->
      it 'is good', -> @run 'circle', { type: 'circle' }
      it 'is good', -> @run 'circle:scale', { type: 'circle', scale: true }
      it 'is good', -> @run 'circle:scale:redcoat', { type: 'circle', scale: true, color: 'redcoat' }
      it 'is good', -> @run 'circle:redcoat:scale', { type: 'circle', scale: true, color: 'redcoat' }
      it 'is good', -> @run 'circle:verticalclip:redcoat', { type: 'circle', verticalclip: true, color: 'redcoat' }
      it 'is good', -> @run 'circle:horizontalclip:redcoat', { type: 'circle', horizontalclip: true, color: 'redcoat' }

     describe 'invalid strings:', ->

       it 'empty string', -> expect( => @run '').to.throw(/invalid.*empty string/i)
       it 'invalid type', -> expect( => @run 'foo:red').to.throw(/invalid.*unknown.*type/i)
       it 'too many unknowns', -> expect( => @run 'circle:red:blue').to.throw(/too.*many.*unknown/i)
       it 'invalid url config', -> expect( => @run 'url').to.throw(/url string must end with a url/i)
       it 'invalid url config 2', -> expect( => @run 'url:scale:/foo.jpg:blue').to.throw(/url string must end with a url/i)
