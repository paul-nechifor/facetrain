tmp = require 'tmp'
{spawn} = require 'child_process'

module.exports = class Network
  constructor: (@facetrain) ->
    @networkFile = null

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

    program.stdout.on 'data', (data) ->
      console.log data + ''

    program.on 'close', (code) ->
      return cb 'err-' + code unless code is 0
      cb()
