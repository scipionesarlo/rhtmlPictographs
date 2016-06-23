
exampleList = $('.example-list')

$.ajax('/demo/content/examples').done (response) ->
  matches = response.match(new RegExp('"/demo/content/examples/([^"]+)\.html"', 'g'))
  for match in matches
    href = match.replace(/"/g, '')

    listItem = $('<li>')

    anchor = $('<a>')
      .html(href.substring("/demo/content/examples/".length))
      .attr('href', href)

    exampleList.append(listItem.append(anchor))

.fail (error) ->
  console.error("Failure to /demo/content/examples directory.")
  console.error(error)
  $('body').append($('<div>').text("Failure to /demo/content/examples directory. See dev tools console for error logging."))

