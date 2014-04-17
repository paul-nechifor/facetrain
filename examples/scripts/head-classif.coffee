{Facetrain, util} = require '../..'

facetrain = new Facetrain
facetrain.options
.hidden 3
.output 4
.targetFunc (image) -> [
  if image.head is 'up' then 0.9 else 0.1
  if image.head is 'right' then 0.9 else 0.1
  if image.head is 'straight' then 0.9 else 0.1
  if image.head is 'left' then 0.9 else 0.1
]

facetrain.train (err, network) ->
  throw err if err
  network.classify facetrain.imageSets[0].path, (err) ->
    throw err if err
    for image, i in facetrain.imageSets[0].images
      console.log image.path, network.imgClassifResults[i]
