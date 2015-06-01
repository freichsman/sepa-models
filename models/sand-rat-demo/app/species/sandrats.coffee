require.register "species/sandrats", (exports, require, module) ->

  helpers = require 'helpers'
  Species = require 'models/species'
  BasicAnimal = require 'models/agents/basic-animal'
  AnimatedAgent = require 'models/agents/animated-agent'
  Trait   = require 'models/trait'

  biologicaSpecies = require 'species/biologica/sandrats'

  class SandRat extends BasicAnimal
    moving: false
    moveCount: 0

    step: ->
      @wander()
      @_incrementAge()

      if @get('age') > @species.defs.MATURITY_AGE
        @set 'current behavior', BasicAnimal.BEHAVIOR.MATING

      if @get('age') > 100 and @get('sex') is 'female' and @_timeLastMated < 0
        @mate()

      if @get('age') > 120 and @_timeLastMated > 0
        @die()

    makeNewborn: ->
      super()
      @set('age', Math.floor Math.random() * 80)
      @set('has diabetes', false)

    #copy mate so we set timeLastMated on males as well...
    mate: ->
      nearest = @_nearestMate()
      if nearest?
        @chase(nearest)
        if nearest.distanceSq < Math.pow(@get('mating distance'), 2) and (not @species.defs.CHANCE_OF_MATING? or Math.random() < @species.defs.CHANCE_OF_MATING)
          max = @get('max offspring')
          @set 'max offspring', Math.max(max/2, 1)
          @reproduce(nearest.agent)
          @set 'max offspring', max
          @_timeLastMated = @environment.date
          nearest.agent._timeLastMated = @environment.date          # ADDED THIS LINE
      else
        @wander(@get('speed') * Math.random() * 0.75)

  module.exports = new Species
    speciesName: "sandrats"
    agentClass: SandRat
    geneticSpecies: biologicaSpecies
    defs:
      CHANCE_OF_MUTATION: 0
      INFO_VIEW_SCALE: 2
      MATURITY_AGE: 20
      INFO_VIEW_PROPERTIES:
        "Prone to diabetes: ": 'prone to diabetes'
        "Has diabetes: ": 'has diabetes'
        "Genome": 'genome'
    traits: [
      new Trait {name: 'speed', default: 6 }
      new Trait {name: 'vision distance', default: 10000 }
      new Trait {name: 'eating distance', default:  50 }
      new Trait {name: 'mating distance', default:  10000 }
      new Trait {name: 'max offspring',   default:  3 }
      new Trait {name: 'min offspring',   default:  2 }
      new Trait {name: 'resource consumption rate', default:  35 }
      new Trait {name: 'metabolism', default:  0.5 }
      new Trait {name: 'chance-hop', float: true, min: 0.05, max: 0.2 }
      new Trait {name: 'prone to diabetes', possibleValues: ['a:DR,b:DR','a:dp,b:DR','a:DR,b:dp','a:dp,b:dp'], isGenetic: true, isNumeric: false }
      new Trait {name: 'has diabetes', default:  false }
    ]
    imageProperties:
      initialFlipDirection: "right"
    imageRules: [
      {
        name: 'rats'
        rules: [
          {
            image:
              render: (g) ->
                g.lineStyle(1, 0x000000)
                g.beginFill(0xd2bda9)
                g.drawCircle(0,0,10)
            useIf: (agent)-> agent.get('has diabetes') is false and agent.get('prone to diabetes') is 'prone' and model.showPropensity and agent.get('sex') is 'female'
          }
          {
            image:
              render: (g) ->
                g.lineStyle(1, 0x000000)
                g.beginFill(0xFFFFFF)
                g.drawCircle(0,0,10)
            useIf: (agent)-> agent.get('has diabetes') is false and agent.get('sex') is 'female'
          }
          {
            image:
              render: (g) ->
                g.lineStyle(1, 0x000000)
                g.beginFill(0x904f10)
                g.drawCircle(0,0,10)
            useIf: (agent)-> agent.get('has diabetes') is true and agent.get('sex') is 'female'
          }

          {
            image:
              render: (g) ->
                g.lineStyle(1, 0x000000)
                g.beginFill(0xd2bda9)
                g.drawRect(0,10,18,18)
            useIf: (agent)-> agent.get('has diabetes') is false and agent.get('prone to diabetes') is 'prone' and model.showPropensity and agent.get('sex') is 'male'
          }
          {
            image:
              render: (g) ->
                g.lineStyle(1, 0x000000)
                g.beginFill(0xFFFFFF)
                g.drawRect(0,0,18,18)
            useIf: (agent)-> agent.get('has diabetes') is false and agent.get('sex') is 'male'
          }
          {
            image:
              render: (g) ->
                g.lineStyle(1, 0x000000)
                g.beginFill(0x904f10)
                g.drawRect(0,0,18,18)
            useIf: (agent)-> agent.get('has diabetes') is true and agent.get('sex') is 'male'
          }
        ]
      }
    ]
