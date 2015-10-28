Environment   = require 'models/environment'
EnvRules      = require './environment-rules'

env = new Environment
  columns:  60
  rows:     45
  imgPath: "images/environments/field.png"
  wrapEastWest: false
  wrapNorthSouth: false

EnvRules.init env

module.exports = env
