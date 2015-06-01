require.register "species/chow", (exports, require, module) ->

  Species = require 'models/species'
  Inanimate = require 'models/inanimate'

  module.exports = new Species
    speciesName: "chow"
    agentClass: Inanimate
    defs: {}
    traits: []
    imageRules: [
      {
        name: 'plus one'
        contexts: ['environment']
        rules: [
          {
            image:
              render: (g) ->
                g.beginFill(0xea1ab7)
                g.drawCircle(0,0,5)
          }
        ]
      }
    ]
