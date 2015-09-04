Environment   = require 'models/environment'
EnvRules      = require 'environments/rules'

env = new Environment
  columns:  100
  rows:     70
  imgPath: "images/environments/field-pens.png"
  wrapEastWest: false
  wrapNorthSouth: false
  barriers: [
    [285, 0, 85, 700]       # Vertical - left-center
    [333, 312, 667, 76]     # Horizontal - divides top and bottom right-side pens
  ]

EnvRules.init env

# env.getView().showingBarriers = true

require.register "environments/field", (exports, require, module) ->
  module.exports = env
