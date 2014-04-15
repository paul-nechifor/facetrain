{Facetrain, util} = require '../..'

facetrain = new Facetrain
facetrain.options
.filter (image) -> image.head is 'straight'
.targetFunc (image) -> if image.expression is 'happy' then [0.9] else [0.1]
.interrupt true

util.initAndSaveWeights facetrain, (err, network, weightsDir) ->
  network.train (err) ->
    throw err if err
    last = 40
    util.joinAndAnimate weightsDir, 4, last, '128x120+4+4', 15, (err) ->
      throw err if err
      images = __dirname + '/../images/intermediate-faces'
      util.sh """
        cd #{weightsDir}
        cp hidden-1.png #{images}-hidden-first.png
        cp hidden-#{last}.png #{images}-hidden-last.png
        cp hidden.gif #{images}-hidden-animation.gif
        rm -fr `pwd`
      """, (err) -> throw err if err
