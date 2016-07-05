
cheerio = require 'cheerio'
fs = require 'fs-extra'
path = require 'path'
recursive = require 'recursive-readdir'
Promise = require 'bluebird'

demoDirectory = path.normalize __dirname + '/../content'
destinationDirectory = path.normalize __dirname + '/../../../examples'

buildRFiles = () ->
  return getListOfDemoFiles()
    .then (demoPaths) ->
      return Promise.all demoPaths.map (demoPath) ->
        return loadDemoFile(demoPath).then(processAndSaveDemo)

getListOfDemoFiles = () ->
  return new Promise (resolve, reject) ->
    recursive demoDirectory, (err, demoFiles) ->
      return reject(err) if err
      return resolve demoFiles.map (absolutePath) ->
        absolutePath.substring(demoDirectory.length)

loadDemoFile = (relativePathToDemoFile) ->
  return new Promise (resolve, reject) ->
    fs.readFile path.normalize(demoDirectory + '/' + relativePathToDemoFile), 'utf8', (err, content) ->
      return reject(err) if err
      return resolve({ demoName: relativePathToDemoFile, content: content })

processAndSaveDemo = ({demoName, content}) ->
  rFileContents = [
    "#This file is auto generated from #{demoName}",
    "#The html demo examples and tutorial are the source of truth and are far more readable and beneficial. Start there (see readme for how).",
    "#Use these r files for reference, but know that some instructional content is not transferred from the html to the r examples files",
    "#TL;DR View the tutorial/example the way it was meant to be: in HTML format!",
    ""
  ]
  $ = cheerio.load content

  sections = $('section')
  sections.each (sectionIndex, sectionElement) ->
    titles = $(this).find(('h2, h3'))
    titles.each (titleIndex, titleElement) ->
      title = $(this).text()
      rFileContents.push("##{title}")

    notes = $(this).find(('p'))
    notes.each (noteIndex, pElement) ->
      note = $(this).text()
      rFileContents.push("###{note}")

    notes = $(this).find(('li'))
    notes.each (noteIndex, liElement) ->
      listItem = $(this).text()
      rFileContents.push("## * #{listItem}")


    examples = $(this).find('.example')
    examples.each (exampleIndex, exampleElement) ->
      exampleConfig = $(this).text().replace(/\n/g, '').replace(new RegExp(' +', 'g'), ' ')
      rFileContents.push("rhtmlPictographs::graphic('#{exampleConfig}')")

    rFileContents.push('')

  destination = path.normalize destinationDirectory + '/' + demoName.replace(/.html$/, '.r')
  return saveContents { destination: destination, content: rFileContents.join('\n') }

saveContents = ({destination, content}) ->
  directory = path.dirname destination
  return ensureDirectoryExists(directory).then () ->
    return new Promise (resolve, reject) ->
      fs.writeFile destination, content, 'utf8', (err) ->
        return reject(err) if err
        return resolve(destination)

ensureDirectoryExists = (directory) ->
  return new Promise (resolve, reject) ->
    fs.mkdirp directory, (err) ->
      return reject(err) if err
      return resolve()

buildRFiles().then (results) ->
  console.log "Done generating R Examples from demo HTML. Files generated:"
  console.log results.join '\n'
  process.exit 0
.catch (error) ->
  console.log "Error generating R Examples from demo HTML: "
  console.log error
  process.exit 1
