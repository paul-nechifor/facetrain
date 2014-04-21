{Facetrain, util} = require '../..'

getFirstTraining = (cb) ->
  facetrain = new Facetrain
  facetrain.options
  .filter (image) -> image.head is 'straight'
  .targetFunc (image) -> if image.eyes is 'sunglasses' then [0.9] else [0.1]

  facetrain.train (err, network) ->
    return cb err if err
    cb null, facetrain, network

trainAgain = (networks, facetrain, nTimes, cb) ->
  i = 0
  next = ->
    return cb() if i >= nTimes
    trainSet = facetrain.imageSets[0]
    trainSet.images.pop()
    trainSet.write (err) ->
      return cb err if err
      network = facetrain.getNewNetwork()
      network.train (err) ->
        return cb err if err
        networks.push network
        i++
        next()
  next()

getFirstTraining (err, facetrain, network) ->
  throw err if err
  networks = [network]

  trainAgain networks, facetrain, 60, (err) ->
    throw err if err
    plot = __dirname + '/../plots/multiple-trainings-ordered.py'
    data = util.getMultipleErrorData networks
    data.title = 'images used: red = 70 to blue = 10'
    util.pythonPlot plot, util.putImage(__filename, 'svg'), data, (err) ->
      throw err if err

