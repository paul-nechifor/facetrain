tmp = require 'tmp'
fs = require 'fs'

module.exports = class ImageSet
  constructor: (@images) ->
    @path = null

  write: (cb) ->
    data = @images.map((image) -> image.path + '\n').join('')
    tmp.file (err, path, fd) =>
      return cb err if err
      @path = path
      fs.writeFile path, data, (err) ->
        return cb err if err
        cb()
