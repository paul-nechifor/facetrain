String::endsWith = (suffix) ->
  return @indexOf(suffix, @length - suffix.length) isnt -1

module.exports = class OptionSet
  constructor: ->
    @values =
      imagesDir: __dirname + '/../faces'
      fileFilter: (path) -> path.endsWith '.pgm'
      scale: 4
      # The size of the input images.
      size: [32, 30]
      # Number of hidden units.
      hidden: 4
      # Number of output units.
      output: 1
      filters: []
      split: [0.444, 0.333, 0.223]
      epochs: 80
      interrupt: false
      targetFunc: null
      dataFunc: (path) ->
        names = path.split '/'
        p = names[names.length - 1].split('.')[0].split '_'
        props =
          person: p[0]
          head: p[1]
          expression: p[2]
          eyes: p[3]
          scale: if p.length > 4 then Number(p[4]) else 1
        return props

  filter: (filter) ->
    @values.filters.push filter
    return this

# Add this-returning setters for OptionSet values.
for name of (new OptionSet).values
  do (name) ->
    OptionSet.prototype[name] = (value) ->
      @values[name] = value
      return this
