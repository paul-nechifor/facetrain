{Facetrain, util} = require '../..'

facetrain = new Facetrain
facetrain.options
.filter (image) -> image.head is 'straight'
.targetFunc (image) -> if image.eyes is 'sunglasses' then 0.9 else 0.1

util.trainNetworks facetrain, 100, (err, networks) ->
  throw err if err
  plot = __dirname + '/../plots/multiple-trainings.py'
  data =
    perf: []
    error: []
  for network in networks
    data.perf.push network.performance.t2perf
    data.error.push network.performance.t2err
  data = JSON.stringify data
  util.pythonPlot plot, util.putImage(__filename, 'svg'), data, (err) ->
    throw err if err
