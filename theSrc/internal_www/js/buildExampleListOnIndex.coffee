
exampleList = $('.example-list')

$.ajax('/content/examples').done (response) ->
  matches = response.match(new RegExp('"/content/examples/([^"]+)\.html"', 'g'))
  for match in matches
    href = match.replace(/"/g, '')

    listItem = $('<li>')

    anchor = $('<a>')
      .html(href.substring("/content/examples/".length))
      .attr('href', href)

    exampleList.append(listItem.append(anchor))

.fail (error) ->
  console.error("Failure to /content/examples directory.")
  console.error(error)
  $('body').append($('<div>').text("Failure to /content/examples directory. See dev tools console for error logging."))

