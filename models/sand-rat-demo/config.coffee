exports.config =
  paths:
    watched: ['app']

  files:
    javascripts:
      joinTo:
        'js/vendor2.js': /^(bower_components)/

    stylesheets:
      joinTo:
        'css/vendor.css' : /^(bower_components)/

  conventions:
    assets: /app(\/|\\)/

  plugins:
    afterBrunch: [
      'echo -n "Cleaning coffee files..." && find public/ -type f -name "*.coffee" -delete'
      'echo -n "Building app..." && coffee --compile --output public app/'
    ]

  overrides:
    production:
      plugins:
        afterBrunch: [
          'echo -n "Cleaning coffee files..." && find public/ -type f -name "*.coffee" -delete'
          'echo -n "Building app and digesting..." && coffee --compile --output public app/ && ./bin/digest'
        ]
