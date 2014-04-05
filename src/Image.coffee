module.exports = class Image
  constructor: (@path, props) ->
    for prop, value of props
      this[prop] = value
    @target = 0.1
