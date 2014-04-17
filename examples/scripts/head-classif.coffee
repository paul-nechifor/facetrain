{Facetrain, util} = require '../..'

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

facetrain.train (err, network) ->
  throw err if err
  set = facetrain.imageSets[1]
  network.classify set.path, (err) ->
    throw err if err
    results = network.imgClassifResults
    for classif, i in results
      classif.path = set.images[i].path
    results.sort (a, b) -> a.error - b.error
    console.log classif for classif in results

    util.plotClassifs results, (err, dir) ->
      throw err if err

      interval = (a, b) ->
        list =
          for i in [a..b]
            "out#{i}.png"
        return list.join ' '

      len = results.length
      images = __dirname + '/../images'

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
      """, (err) -> throw err if err
