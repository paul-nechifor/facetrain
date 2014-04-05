{spawn} = require 'child_process'
path = require 'path'

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
