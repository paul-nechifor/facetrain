{Facetrain} = require '../lib'

facetrain = new Facetrain

facetrain.options
.filter (image) -> image.head is 'straight'

facetrain.train ->

