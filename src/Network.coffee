tmp = require 'tmp'
{spawn} = require 'child_process'
byline = require 'byline'

module.exports = class Network
  constructor: (@facetrain) ->
    @networkFile = null
    @performance = []
    @lineInterpreters =
      performance: @onPerformance.bind this

  train: (cb) ->
    tmp.dir (err, path) =>
      return cb err if err
      @networkFile = path + '/file.net'
      @runProgram cb

  runProgram: (cb) ->
    args = []
    args.push '-n', @networkFile
    args.push '-e', @facetrain.vals.epochs + ''
    args.push '-t', @facetrain.imageSets[0].path
    args.push '-1', @facetrain.imageSets[1].path
    args.push '-2', @facetrain.imageSets[2].path

    program = spawn '../bin/facetrain', args

    lineStream = byline.createStream program.stdout
    lineStream.on 'data', @interpretLine.bind this

    program.on 'close', (code) ->
      return cb 'err-' + code unless code is 0
      cb()

  interpretLine: (line) ->
    line = line.toString()
    start = line.indexOf '>>>'
    return if start is -1
    type = line.substring 0, start
    data = line.substring start + 4, line.length
    @lineInterpreters[type]? data

  onPerformance: (data) ->
    # <epoch> <delta> <trainperf> <trainerr> <t1perf> <t1err> <t2perf> <t2err>
    numbers = data.trim().split(' ').map (n) -> Number(n)
    @performance.push numbers
