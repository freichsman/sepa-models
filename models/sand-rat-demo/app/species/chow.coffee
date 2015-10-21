require.register "species/chow", (exports, require, module) ->

  Species = require 'models/species'
  Inanimate = require 'models/inanimate'

  class Chow extends Inanimate
    canShowInfo: ->
      false

  module.exports = new Species
    speciesName: "chow"
    agentClass: Chow
    defs: {}
    traits: []
    imageRules: [
      {
        name: 'plus one'
        contexts: ['environment']
        rules: [
          {
            image:
              path: "images/agents/chow.png"
              scale: 0.5
              anchor:
                x: 0.5
                y: 1
          }
        ]
      }
    ]
