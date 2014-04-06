{spawn} = require 'child_process'
path = require 'path'
tmp = require 'tmp'

###
  Get the name of the image to create based on the script name and place it in
  the examples dir.
###
exports.putImage = (filename, extension) ->
  name = path.basename filename, path.extname filename
  return "#{__dirname}/../examples/images/#{name}.#{extension}"

exports.pythonPlot = (script, image, data, cb) ->
  prg = spawn 'python2', [script, image]
  prg.stdin.end data
  prg.on 'close', (code) ->
    return cb 'err-' + code unless code is 0
    cb()

exports.trainNetworks = (facetrain, nTimes, cb) ->
  i = 0
  networks = []
  next = ->
    return cb null, networks if i >= nTimes
    facetrain.train (err, network) ->
      return cb err if err
      networks.push network
      i++
      next()
  next()

exports.initAndSaveWeights = (facetrain, cb) ->
  facetrain.init (err) ->
    return cb err if err
    network = facetrain.getNewNetwork()
    tmp.dir (err, weightsDir) ->
      return cb err if err
      network.interruptListener = (epoch, next) ->
        network.saveAllHiddenWeights weightsDir, epoch, (err) ->
          return cb err if err
          next()
      cb null, network, weightsDir
