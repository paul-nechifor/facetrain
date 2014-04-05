{Facetrain, util} = require '../..'

facetrain = new Facetrain
facetrain.options
.filter (image) -> image.head is 'straight'
.targetFunc (image) -> if image.eyes is 'sunglasses' then 0.9 else 0.1

facetrain.train (err, network) ->
  throw err if err
  plot = __dirname + '/../plots/perf-and-error.py'
  data = JSON.stringify network.performance
  util.pythonPlot plot, util.putImage(__filename, 'svg'), data, (err) ->
    throw err if err
