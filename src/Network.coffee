tmp = require 'tmp'
{spawn} = require 'child_process'
byline = require 'byline'

module.exports = class Network
  constructor: (@facetrain) ->
    @networkFile = null
    @performance =
      epoch: []
      delta: []
      trainperf: []
      trainerr: []
      t1perf: []
      t1err: []
      t2perf: []
      t2err: []
    @performanceList = [
      @performance.epoch
      @performance.delta
      @performance.trainperf
      @performance.trainerr
      @performance.t1perf
      @performance.t1err
      @performance.t2perf
      @performance.t2err
    ]
    @lineInterpreters =
      performance: @onPerformance.bind this
      interrupt: @onInterrupt.bind this
      imgclassif: @onImgClassif.bind this
    @interruptListener = (epoch, next) ->
      next()
    @program = null
    @imgClassifResults = null

  train: (cb) ->
    tmp.dir (err, path) =>
      return cb err if err
      @networkFile = path + '/file.net'
      args = [
        '-n', @networkFile
        '-e', @facetrain.vals.epochs + ''
        '-H', @facetrain.vals.hidden + ''
        '-o', @facetrain.vals.output + ''
        '-t', @facetrain.imageSets[0].path
        '-1', @facetrain.imageSets[1].path
        '-2', @facetrain.imageSets[2].path
      ]
      args.push '-i' if @facetrain.vals.interrupt
      args.push '-v' if @facetrain.vals.validate
      @runProgram args, cb

  classify: (setPath, cb) ->
    @imgClassifResults = []
    args = [
      '-n', @networkFile
      '-e', '0'
      '-H', @facetrain.vals.hidden + ''
      '-o', @facetrain.vals.output + ''
      '-t', setPath
      '-c'
    ]
    @runProgram args, cb

  runProgram: (args, cb) ->
    @program = spawn __dirname + '/../bin/facetrain', args

    lineStream = byline.createStream @program.stdout
    lineStream.on 'data', @interpretLine.bind this

    @program.on 'close', (code) ->
      return cb 'err-' + code unless code is 0
      cb()

  saveHiddenWeights: (path, size, n, cb) ->
    args = [@networkFile, path, size[0], size[1], n]
    hid = spawn __dirname + '/../bin/hidtopgm', args
    hid.on 'close', (code) ->
      return cb 'err-' + code unless code is 0
      cb()

  saveAllHiddenWeights: (path, epoch, cb) ->
    n = @facetrain.vals.hidden
    size = @facetrain.vals.size

    i = 1
    next = =>
      return cb null if i > n
      imagePath = "#{path}/hidden-#{epoch}-#{i}.pgm"
      @saveHiddenWeights imagePath, size, i, (err) ->
        return cb err if err
        i++
        next()
    next()

  interpretLine: (line) ->
    line = line.toString()
    start = line.indexOf '>>>'
    return if start is -1
    type = line.substring 0, start
    data = line.substring start + 3, line.length
    @lineInterpreters[type]? data

  onPerformance: (data) ->
    numbers = data.trim().split(' ').map (n) -> Number(n)
    for number, i in numbers
      @performanceList[i].push number
    return

  onInterrupt: (data) ->
    epoch = data
    next = => @program.stdin.write 'y'
    @interruptListener epoch, next

  onImgClassif: (data) ->
    numbers = data.trim().split(' ').map (n) -> Number(n)
    classif =
      correct: !!numbers[1]
      error: numbers[2]
      output: numbers.slice 3
    @imgClassifResults.push classif
