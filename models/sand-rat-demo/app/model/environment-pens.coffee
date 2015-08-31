Environment   = require 'models/environment'
EnvRules      = require 'environments/rules'

env = new Environment
  columns:  100
  rows:     70
  imgPath: "images/environments/field-pens.png"
  wrapEastWest: false
  wrapNorthSouth: false
  barriers: [
    [0, 330, 1000, 30]       # Center - horizontal
    [485, 0, 30, 340]        # Center - vertical-top
  ]

EnvRules.init env


require.register "environments/field", (exports, require, module) ->
  module.exports = env
