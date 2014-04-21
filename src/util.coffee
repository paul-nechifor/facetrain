{spawn, exec} = require 'child_process'
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
  prg.stdin.end JSON.stringify data
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

exports.getMultipleErrorData = (networks) ->
  data =
    perf: []
    error: []
  for network in networks
    data.perf.push network.performance.t2perf
    data.error.push network.performance.t2err
  return data

exports.sh = sh = (script, cb) ->
  exec script, (err, stdout, stderr) ->
    return cb? err if err
    process.stdout.write stdout + stderr
    cb?()

exports.joinHidden = (dir, nHidden, nEpochs, geom, cb) ->
  script = "cd #{dir}\n"
  h = nHidden
  for e in [1..nEpochs]
    script += "montage hidden-#{e}-[1-#{h}].pgm -tile #{h}x1 " +
      "-geometry #{geom} -filter point  hidden-#{e}.png\n"
  sh script, cb

exports.animateHidden = (dir, delay, cb) ->
  c = """
    cd #{dir}
    convert -delay #{delay} -loop 0 hidden-*.png hidden.gif
  """
  sh c, cb

exports.joinAndAnimate = (dir, nHidden, nEpochs, geom, delay, cb) ->
  exports.joinHidden dir, nHidden, nEpochs, geom, (err) ->
    return cb? err if err
    exports.animateHidden dir, delay, (err) ->
      return cb? err if err
      cb?()

exports.plotClassifs = (classifs, cb) ->
  tmp.dir (err, dir) ->
    return cb err if err
    i = 0
    next = ->
      return cb null, dir if i >= classifs.length
      exports.plotClassif dir, i, classifs[i], (err) ->
        return cb err if err
        i++
        next()
    next()

exports.plotClassif = (dir, i, classif, cb) ->
  plot = __dirname + '/../examples/plots/output.py'
  data =
    output: classif.output
  image = "#{dir}/plot#{i}.png"
  exports.pythonPlot plot, image, data, (err) ->
    return cb err if err
    cb()

    sh """
      cd #{dir}
      convert -scale 256x240 #{classif.path} face#{i}.png
      convert -scale 256 plot#{i}.png plot-small-#{i}.png
      convert -append face#{i}.png plot-small-#{i}.png out#{i}.png
    """
