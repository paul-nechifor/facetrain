findit = require 'findit'
tmp = require 'tmp'
{spawn} = require 'child_process'
Image = require './Image'
ImageSet = require './ImageSet'
OptionSet = require './OptionSet'

shuffle = (array) ->
  counter = array.length
  while counter > 0
    index = Math.floor Math.random() * counter
    counter--
    temp = array[counter]
    array[counter] = array[index]
    array[index] = temp

module.exports = class Facetrain
  constructor: ->
    @options = new OptionSet
    @vals = @options.values
    @imageSets = null
    @networkFile  = null

  train: (cb) ->
    if @vals.scale
      @options.filter (image) => image.scale is @vals.scale
    @getImages (err, images) =>
      return cb err if err
      sets = @splitSets images
      @createImageSets sets, (err, imageSets) =>
        @imageSets = imageSets
        tmp.dir (err, path) =>
          return cb err if err
          @networkFile = path + '/file.net'
          @runProgram cb

  runProgram: (cb) ->
    args = []
    args.push '-n', @networkFile
    args.push '-e', @vals.epochs + ''
    args.push '-t', @imageSets[0].path
    args.push '-1', @imageSets[1].path
    args.push '-2', @imageSets[2].path

    program = spawn '../bin/facetrain', args

    program.stdout.on 'data', (data) ->
      console.log data + ''

    program.on 'close', (code) ->
      return cb 'err-' + code unless code is 0
      cb()

  getImages: (cb) ->
    @getImageFiles (err, files) =>
      return cb err if err
      images =
        for file in files
          new Image file, @vals.dataFunc file
      cb null, @filterImages images

  getImageFiles: (cb) ->
    files = []
    findit @vals.imagesDir
    .on 'file', (file, stat) =>
      files.push file if @vals.fileFilter file
    .on 'end', ->
      cb null, files

  filterImages: (images) ->
    return images.filter (image) =>
      for filter in @vals.filters
        return false unless filter image
      return true

  splitSets: (images) ->
    shuffle images
    split1 = Math.ceil images.length * @vals.split[0]
    split2 = split1 + Math.ceil images.length * @vals.split[1]
    return [
      images.slice 0, split1
      images.slice split1, split2
      images.slice split2, images.length - 1
    ]

  createImageSets: (sets, cb) ->
    i = 0
    imageSets = []
    next = ->
      return cb null, imageSets if i >= sets.length
      set = new ImageSet sets[i]
      imageSets.push set
      set.write (err) ->
        return cb err if err
        i++
        next()
    next()
