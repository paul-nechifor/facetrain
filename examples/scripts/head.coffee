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
.interrupt true

util.initAndSaveWeights facetrain, (err, network, weightsDir) ->
  console.log 'Saved to:', weightsDir
  network.train (err) ->
    throw err if err
    plot = __dirname + '/../plots/perf-and-error.py'
    data = JSON.stringify network.performance
    util.pythonPlot plot, util.putImage(__filename, 'svg'), data, (err) ->
      throw err if err
