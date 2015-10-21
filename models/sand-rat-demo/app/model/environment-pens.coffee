Environment   = require 'models/environment'
EnvRules      = require 'environments/rules'

env = new Environment
  columns:  60
  rows:     45
  imgPath: "images/environments/pens-mockup.png"
  wrapEastWest: false
  wrapNorthSouth: false
  barriers: [
    [140, 0, 30, 450]       # Vertical - left-center
    [170, 220, 430, 30]     # Horizontal - divides top and bottom right-side pens
  ]

EnvRules.init env

# env.getView().showingBarriers = true

require.register "environments/field", (exports, require, module) ->
  module.exports = env
