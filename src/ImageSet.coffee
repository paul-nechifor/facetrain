tmp = require 'tmp'
fs = require 'fs'

module.exports = class ImageSet
  constructor: (@images) ->
    @path = null

  write: (cb) ->
    mapping = (image) -> "#{image.path}\n#{image.target}\n"
    data = @images.map(mapping).join('')
    tmp.file (err, path, fd) =>
      return cb err if err
      @path = path
      fs.writeFile path, data, (err) ->
        return cb err if err
        cb()
