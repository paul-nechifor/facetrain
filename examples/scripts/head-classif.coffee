{Facetrain, util} = require '../..'

images = __dirname + '/../images'

facetrain = new Facetrain
facetrain.options
.hidden 3
.output 4
.targetFunc (image) -> [
  if image.head is 'up' then 0.9 else 0.1
  if image.head is 'right' then 0.9 else 0.1
  if image.head is 'straight' then 0.9 else 0.1
  if image.head is 'left' then 0.9 else 0.1
]

getOwn = (cb) ->
  own = new Facetrain
  own.options
  .imagesDir __dirname + '/../faces'
  .split [1, 0, 0]
  .hidden 3
  .output 4
  .targetFunc (image) -> [0, 0, 0, 0]
  own.init (err) ->
    return cb err if err
    cb null, own.imageSets[0]

classifyTestExamples = (network, set, cb) ->
  network.classify set.path, (err) ->
    return cb err if err
    results = util.getJoinedResults network, set, true
    console.log results

    util.plotClassifs results, (err, dir) ->
      return cb err if err

      interval = (a, b) ->
        list =
          for i in [a..b]
            "out#{i}.png"
        return list.join ' '

      len = results.length

      copyBad = ->
        ret = ''
        for i in [0..7]
          ret += "cp out#{len-i-1}.png #{images}/head-classif-bad-#{i}.png\n"
        return ret

      copyGood = ->
        ret = ''
        for i in [0..15]
          ret += "cp out#{i}.png #{images}/head-classif-good-#{i}.png\n"
        return ret

      util.sh """
        cd #{dir}
        convert -delay 300 -loop 0 #{interval  0,  9} head-classif-0.gif
        convert -delay 300 -loop 0 #{interval 10, 19} head-classif-1.gif
        convert -delay 300 -loop 0 #{interval 20, 29} head-classif-2.gif
        convert -delay 300 -loop 0 #{interval len-11, len-1} head-classif-3.gif
        cp head-classif-* #{images}
        #{copyBad()}
        #{copyGood()}
      """, (err) ->
        return cb err if err
        cb()

classifyOwn = (network, set, cb) ->
  network.classify set.path, (err) ->
    return cb err if err
    results = util.getJoinedResults network, set, true
    console.log results
    util.plotClassifs results, (err, dir) ->
      return cb err if err
      commands = "cd #{dir}\nsleep 1\n"
      for i in [0..3]
        commands += "cp out#{i}.png #{images}/own-face-classif-#{i}.png\n"
      util.sh commands, (err) ->
        return cb err if err
        cb()

facetrain.train (err, network) ->
  throw err if err
  classifyTestExamples network, facetrain.imageSets[1], (err) ->
    throw err if err
    getOwn (err, ownSet) ->
      throw err if err
      classifyOwn network, ownSet, (err) ->
        throw err if err
