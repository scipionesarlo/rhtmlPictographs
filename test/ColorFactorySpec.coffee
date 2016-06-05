
ranOnce = false

describe 'ColorFactory class', ->

  beforeEach ->
    #NB this doesn't follow test isolation but works for testing ColorFactory
    unless ranOnce
      ranOnce = true
      ColorFactory.processNewConfig {
        palettes:
          test: ['red', 'blue', 'green' ]
        aliases:
          primary: 'brown'
          secondary: 'yellow'
      }

  it 'round robins through a color palette', ->

    expect(ColorFactory.getColor('test')).to.equal 'red'
    expect(ColorFactory.getColor('test')).to.equal 'blue'
    expect(ColorFactory.getColor('test')).to.equal 'green'
    expect(ColorFactory.getColor('test')).to.equal 'red'

  it 'returns aliases', ->

    expect(ColorFactory.getColor('primary')).to.equal 'brown'
    expect(ColorFactory.getColor('secondary')).to.equal 'yellow'

  it 'passes everything else through', ->

    expect(ColorFactory.getColor('pink')).to.equal 'pink'
