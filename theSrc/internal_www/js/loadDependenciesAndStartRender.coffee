# TEMPLATE! - this list of dependencies and widget files needs to be kept up to date
dependencies = [
  '/external/d3.min.js'
  '/external/jquery.min.js'
  '/external/lodash.min.js'
  { src: '/external/d3-grid.js', waitFor: () -> waitForTheseGlobals(['d3']) }
  '/external/rHtmlStatefulWidget.js'
  { src: '/external/rHtmlSvgWidget.js', waitFor: () -> waitForTheseGlobals(['d3']) }

  '/widget/RecolorSvg.js'
  { src: '/widget/ColorFactory.js', waitFor: () -> waitForTheseGlobals(['d3']) }
  '/widget/ImageFactory.js'
  '/widget/DisplayError.js'
  '/widget/BaseCell.js'
  { src: '/widget/GraphicCell.js', waitFor: () -> waitForTheseGlobals(['d3', 'ImageFactory']) }
  '/widget/LabelCell.js'
  { src: '/widget/Pictograph.js', waitFor: () -> waitForTheseGlobals(['GraphicCell', 'LabelCell']) }
  { src: '/js/renderContentPage.js', waitFor: () -> waitForTheseGlobals(['Pictograph']) }
]

waitForTheseGlobals = (globals) ->
  for dependency in globals
    return false unless window.hasOwnProperty(dependency)
  return true

createScriptOnceWaitForIsTrue = (src,waitFor) ->
  myInterval = setInterval () ->
    if waitFor()
      console.log "done waiting for script #{src}"
      clearInterval myInterval
      script = document.createElement('script')
      script.setAttribute('src', src)
      body = document.getElementsByTagName("body")[0]
      body.appendChild(script)
  , 20


addDependenciesToDocument = () ->
  for dependency in dependencies
    src = if (dependency.hasOwnProperty('src')) then dependency.src else dependency
    waitCondition = if (dependency.hasOwnProperty('waitFor')) then dependency.waitFor else () -> true
    createScriptOnceWaitForIsTrue src, waitCondition

addDependenciesToDocument()
