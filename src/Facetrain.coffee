findit = require 'findit'
Image = require './Image'
ImageSet = require './ImageSet'
OptionSet = require './OptionSet'
Network = require './Network'

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
        network = new Network this
        network.train (err) ->
          return cb err if err
          cb null, network

  getImages: (cb) ->
    @getImageFiles (err, files) =>
      return cb err if err
      images =
        for file in files
          new Image file, @vals.dataFunc file
      filtered = @filterImages images
      for image in filtered
        image.target = @vals.targetFunc image
      cb null, filtered

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
