{Facetrain} = require '../lib'

facetrain = new Facetrain

facetrain.options
.filter (image) -> image.head is 'straight'
.targetFunc (image) -> if image.person is 'glickman' then 0.9 else 0.1

facetrain.train (err, network) ->
  throw err if err
  console.log network.performance
