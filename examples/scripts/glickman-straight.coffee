{Facetrain} = require '../..'

facetrain = new Facetrain

facetrain.options
.filter (image) -> image.head is 'straight'
.targetFunc (image) -> if image.person is 'glickman' then 0.9 else 0.1

facetrain.train (err, network) ->
  throw err if err
  plot = __dirname + '/../plots/perf-and-error.py'
  image = __dirname + '/../images/glickman-straight-perf-and-error.svg'
  data = JSON.stringify network.performance
  network.pythonPlot plot, image, data, (err) ->
