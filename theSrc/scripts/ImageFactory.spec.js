import _ from 'lodash'
import ImageFactory from './ImageFactory'

describe('ImageFactory class:', function () {
  describe('parseConfig():', function () {
    beforeEach(function () {
      this.run = function (configString, expectConfig) {
        const actualConfig = ImageFactory.parseConfig(configString)
        const errorString = `
Actual: ${JSON.stringify(actualConfig, {}, 2)}
Expected: ${JSON.stringify(expectConfig, {}, 2)}
`
        expect(actualConfig, errorString).to.deep.equal(expectConfig)
      }
    })

    describe('shapes:', function () {
      // NB config parsing of shapes is currently identical, so the detailed testing is done in circle,
      // and this block just tests existence
      it('parses correctly', function () { this.run('circle', { type: 'circle' }) })
      it('parses correctly', function () { this.run('ellipse', { type: 'ellipse' }) })
      it('parses correctly', function () { this.run('square', { type: 'square' }) })
      it('parses correctly', function () { this.run('rect', { type: 'rect' }) })
    })

    describe('keyword handlers:', function () {
      describe('scaling techniques:', function () {
        it('parses correctly', function () { this.run('circle:scale', { type: 'circle', scale: true }) })
        it('parses correctly', function () { this.run('circle:vertical', { type: 'circle', clip: 'frombottom' }) })
        it('parses correctly', function () { this.run('circle:horizontal', { type: 'circle', clip: 'fromleft' }) })
        it('parses correctly', function () { this.run('circle:radial', { type: 'circle', clip: 'radial' }) })
        it('parses correctly', function () { this.run('circle:pie', { type: 'circle', clip: 'radial' }) })
        it('parses correctly', function () { this.run('circle:fromleft', { type: 'circle', clip: 'fromleft' }) })
        it('parses correctly', function () { this.run('circle:fromright', { type: 'circle', clip: 'fromright' }) })
        it('parses correctly', function () { this.run('circle:frombottom', { type: 'circle', clip: 'frombottom' }) })
        it('parses correctly', function () { this.run('circle:fromtop', { type: 'circle', clip: 'fromtop' }) })
      })
    })

    describe('specify colors:', function () {
      it('parses correctly', function () { this.run('circle', { type: 'circle' }) })
      it('parses correctly', function () { this.run('circle:redcoat', { type: 'circle', color: 'redcoat' }) })
      it('parses correctly', function () { this.run('circle:scale:redcoat', { type: 'circle', scale: true, color: 'redcoat' }) })
      it('parses correctly', function () { this.run('circle:redcoat:scale', { type: 'circle', scale: true, color: 'redcoat' }) })
      it('parses correctly', function () { this.run('circle:#123456:scale', { type: 'circle', scale: true, color: '#123456' }) })
    })

    describe('url:', function () {
      it('parses correctly', function () { this.run('http://example.com/foo', { type: 'url', url: 'http://example.com/foo' }) })
      it('parses correctly', function () { this.run('https://example.com/foo', { type: 'url', url: 'https://example.com/foo' }) })
      it('parses correctly', function () { this.run('url:http://example.com/foo', { type: 'url', url: 'http://example.com/foo' }) })
      it('parses correctly', function () { this.run('url:scale:http://example.com/foo', { type: 'url', url: 'http://example.com/foo', scale: true }) })
      it('parses correctly', function () { this.run('url:scale:foo.jpg', { type: 'url', url: 'foo.jpg', scale: true }) })
      it('parses correctly', function () { this.run('url:/local/image.jpg', { type: 'url', url: '/local/image.jpg' }) })
    })

    describe('data urls:', function () {
      it('parses correctly', function () { this.run('data:image/png;base64,iVBOBblahblahX+=', { type: 'data', url: 'data:image/png;base64,iVBOBblahblahX+=' }) })
      it('parses correctly', function () { this.run('data:scale:image/png;base64,iVBOBblahblahX+=', { type: 'data', url: 'data:image/png;base64,iVBOBblahblahX+=', scale: true }) })
    })

    describe('recolored svg urls:', function () {
      it('parses correctly', function () { this.run('url:red:/local/image.svg', { type: 'recoloredExternalSvg', url: '/local/image.svg', color: 'red' }) })

      it('rejects other types of url recolor requests', function () {
        const thrower = function () {
          ImageFactory.parseConfig('url:red:/local/image.jpg')
        }
        expect(thrower).to.throw('unsupported image type')
      })
    })

    describe('preserveAspectRatio validation:', function () {
      const tests = [
        'none : valid',
        'xMinYMin : valid',
        'xMidYMin : valid',
        'xMaxYMin : valid',
        'xMinYMid : valid',
        'xMidYMid : valid',
        'xMaxYMid : valid',
        'xMinYMax : valid',
        'xMidYMax : valid',
        'xMaxYMax : valid',

        'xMinYMin slice : valid',
        'xMidYMin slice : valid',
        'xMaxYMin slice : valid',
        'xMinYMid slice : valid',
        'xMidYMid slice : valid',
        'xMaxYMid slice : valid',
        'xMinYMax slice : valid',
        'xMidYMax slice : valid',
        'xMaxYMax slice : valid',

        'xMinYMin meet : valid',
        'xMidYMin meet : valid',
        'xMaxYMin meet : valid',
        'xMinYMid meet : valid',
        'xMidYMid meet : valid',
        'xMaxYMid meet : valid',
        'xMinYMax meet : valid',
        'xMidYMax meet : valid',
        'xMaxYMax meet : valid',

        ' : invalid',
        'dogs : invalid',
        'xMinYMin dogs : invalid'
      ]

      _(tests).each((testDefinitionString) => {
        const [testString, valid] = testDefinitionString.split(' : ')
        it(`${testString} is ${valid}`, function () {
          const expectation = expect(() => {
            ImageFactory.parseConfig({
              type: 'url',
              url: '/foo.svg',
              preserveAspectRatio: testString
            })
          })

          if (valid === 'valid') {
            expectation.not.to.throw()
          } else {
            expectation.to.throw(/Invalid preserveAspectRatio string/i)
          }
        })
      })
    })

    describe('invalid config:', function () {
      it('empty string', function () { expect(() => this.run('')).to.throw(/invalid.*empty string/i) })
      it('invalid type', function () { expect(() => this.run('foo:red')).to.throw(/invalid.*unknown.*type/i) })
      it('too many unknowns', function () { expect(() => this.run('circle:red:blue')).to.throw(/too.*many.*unknown/i) })
      it('invalid url config', function () { expect(() => this.run('url')).to.throw(/url string must end with a url/i) })
      it('invalid url config 2', function () { expect(() => this.run('url:scale:/foo.jpg:blue')).to.throw(/url string must end with a url/i) })
    })
  })
})
