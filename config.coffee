exports.config =
  paths:
    watched: ['app']

  files:
    javascripts:
      joinTo:
        'js/app.js': /^(app)/
        'js/vendor2.js': /^(bower_components)/

    stylesheets:
      joinTo:
        'css/app.css' : /^(app)/
        'css/vendor.css' : /^(bower_components)/

  modules:
    wrapper: "commonjs"
