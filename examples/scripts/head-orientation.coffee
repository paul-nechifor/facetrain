{Facetrain, util} = require '../..'

repeat = (hidden, cb) ->
  facetrain = new Facetrain
  facetrain.options
  .hidden hidden
  .output 4
  .targetFunc (image) -> [
    if image.head is 'up' then 0.9 else 0.1
    if image.head is 'right' then 0.9 else 0.1
    if image.head is 'straight' then 0.9 else 0.1
    if image.head is 'left' then 0.9 else 0.1
  ]
  .interrupt true

  util.initAndSaveWeights facetrain, (err, network, weightsDir) ->
    network.train (err) ->
      throw err if err
      last = 50
      util.joinAndAnimate weightsDir, hidden, last, '128x120+4+4', 15, (err) ->
        throw err if err
        images = __dirname + '/../images/head-orientation-' + hidden
        util.sh """
          cd #{weightsDir}
          cp hidden-#{last}.png #{images}-hidden-last.png
          rm -fr `pwd`
        """, (err) ->
          throw err if err
          cb?()

repeat 3, ->
  repeat 4, ->
    repeat 5, ->
