Environment   = require 'models/environment'
EnvRules      = require './environment-rules'

env = new Environment
  columns:  60
  rows:     45
  imgPath: "images/environments/pens.png"
  wrapEastWest: false
  wrapNorthSouth: false
  barriers: [
    [170, 0, 55, 450]       # Vertical - left-center
    [220, 200, 380, 50]     # Horizontal - divides top and bottom right-side pens
  ]

EnvRules.init env

# env.getView().showingBarriers = true

module.exports = env
