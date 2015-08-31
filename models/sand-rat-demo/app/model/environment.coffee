Environment   = require 'models/environment'
EnvRules      = require 'environments/rules'

env = new Environment
  columns:  60
  rows:     70
  imgPath: "images/environments/field.png"
  wrapEastWest: false
  wrapNorthSouth: false

EnvRules.init env

require.register "environments/field", (exports, require, module) ->
  module.exports = env
