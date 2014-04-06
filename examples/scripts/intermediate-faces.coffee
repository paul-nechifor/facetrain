{Facetrain, util} = require '../..'

facetrain = new Facetrain
facetrain.options
.filter (image) -> image.head is 'straight'
.targetFunc (image) -> if image.expression is 'happy' then [0.9] else [0.1]
.interrupt true

util.initAndSaveWeights facetrain, (err, network, weightsDir) ->
  console.log 'Saved to:', weightsDir
  network.train (err) ->
    throw err if err
