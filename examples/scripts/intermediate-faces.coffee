{Facetrain, util} = require '../..'
tmp = require 'tmp'

init = (facetrain, cb) ->
  facetrain.init (err) ->
    return cb err if err
    network = facetrain.getNewNetwork()
    tmp.dir (err, weightsDir) ->
      return cb err if err
      cb null, network, weightsDir

facetrain = new Facetrain
facetrain.options
.filter (image) -> image.head is 'straight'
.targetFunc (image) -> if image.expression is 'happy' then 0.9 else 0.1
.interrupt true

init facetrain, (err, network, weightsDir) ->
  console.log 'Saved to:', weightsDir
  network.interruptListener = (epoch, next) ->
    network.saveAllHiddenWeights weightsDir, epoch, (err) ->
      throw err if err
      next()
  network.train (err) ->
    throw err if err
