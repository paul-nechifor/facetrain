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
  set = facetrain.imageSets[1]
  network.classify set.path, (err) ->
    throw err if err
    results = network.imgClassifResults
    for classif, i in results
      classif.path = set.images[i].path
    results.sort (a, b) -> a.error - b.error
    console.log classif for classif in results
