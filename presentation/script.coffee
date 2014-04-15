initReveal = ->
  Reveal.initialize
    controls: true
    progress: true
    history: true
    center: true
    hideAddressBar: true

    transition: 'linear'
    transitionSpeed: 'fast'
    backgroundTransition: 'slide'

    width: 1024
    height: 768
    margin: 0.0
    minScale: 0.2
    maxScale: 4.0

main = ->
  initReveal()

main()
