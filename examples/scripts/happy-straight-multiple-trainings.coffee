{Facetrain, util} = require '../..'

facetrain = new Facetrain
facetrain.options
.filter (image) -> image.head is 'straight'
.targetFunc (image) -> if image.expression is 'happy' then [0.9] else [0.1]

util.trainNetworks facetrain, 100, (err, networks) ->
  throw err if err
  plot = __dirname + '/../plots/multiple-trainings.py'
  data = util.getMultipleErrorData networks
  util.pythonPlot plot, util.putImage(__filename, 'svg'), data, (err) ->
    throw err if err
