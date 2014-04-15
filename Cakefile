require('coffee-script').register()
Build = require('web-build-tools').Build
{sh, cmd} = Build
jade = require 'jade'
fs = require 'fs'


config =
  debug: false

b = new Build task, config, (->),
  clean: (cb) ->
    sh 'cd presentation; rm -fr build; mkdir build', cb

  bower: (cb) ->
    sh 'cd presentation; bower install', cb

  copyReq: (cb) ->
    sh """
      mkdir presentation/build/reveal
      cd presentation/bower_components/reveal.js
      cp js/reveal.min.js css/reveal.min.css lib/js/* ../../build/reveal
    """, cb

  copyImages: (cb) ->
    sh 'cp -r examples/images presentation/build/images', cb

  stylus: (cb) ->
    Build.stylus 'presentation/build/style.css', 'presentation/style.styl',
      config, cb

  jade: (cb) ->
    jade.renderFile 'presentation/index.jade', {}, (err, html) ->
      fs.writeFileSync 'presentation/build/index.html', html
      cb?()

  script: (cb) ->
    Build.browserify 'presentation/build/script.js',
      './presentation/script.coffee', config, cb

  presentation: (cb) ->
    b.run ['clean', 'bower', 'copyReq', 'copyImages', 'stylus', 'jade',
      'script']
    cb?()


b.makePublic
  presentation: 'Build the presentation.'
