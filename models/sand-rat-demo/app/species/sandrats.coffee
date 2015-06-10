require.register "species/sandrats", (exports, require, module) ->

  helpers = require 'helpers'
  Species = require 'models/species'
  BasicAnimal = require 'models/agents/basic-animal'
  AnimatedAgent = require 'models/agents/animated-agent'
  Trait   = require 'models/trait'

  biologicaSpecies = require 'species/biologica/sandrats'

  window.orgNumber ?= 1

  class SandRat extends BasicAnimal
    moving: false
    moveCount: 0

    step: ->
      @wander()
      @_incrementAge()

      if @get('age') > @species.defs.MATURITY_AGE
        @set 'current behavior', BasicAnimal.BEHAVIOR.MATING

      overcrowded = false
      if not @_isInPensModel
        overcrowded = model.count_all > 46
      else
        if @_y > 350
          overcrowded = model.count_s > 36
        else if @_x < 330
          overcrowded = model.count_nw > 17
        else if @_x < 660
          overcrowded = model.count_n > 17
        else
          overcrowded = model.count_ne > 17

      # mate if it's not overcrowded
      if not overcrowded and @get('age') > 170 and @get('sex') is 'male' and @_timeLastMated < 0 and Math.random() < 0.3
        @mate()

      # die soon after if you've mated
      if @get('age') > 180 and @_timeLastMated > 0
        @die()

      # die when you're fairly old if it's overcrowded
      if overcrowded and @get('age') > 250 and Math.random() < 0.2
        @die()

      # die if you're very old
      if @get('age') > 400 and Math.random() < 0.2
        @die()

    makeNewborn: ->
      super()

      #so ugly
      sex = if model.env.agents.length and
        model.env.agents[model.env.agents.length-1].species.speciesName is "sandrats" and
        model.env.agents[model.env.agents.length-1].get("sex") is "female" then "male" else "female"

      @set 'sex', sex
      @set('age', Math.floor Math.random() * 80)
      @set('weight', 140 +  Math.floor Math.random() * 20)
      @set('has diabetes', false)

      @_isInPensModel = model.env.barriers.length > 0

    #copy mate so we set timeLastMated on males as well...
    mate: ->
      nearest = @_nearestMate()
      if nearest?
        @chase(nearest)
        if nearest.distanceSq < Math.pow(@get('mating distance'), 2) and (not @species.defs.CHANCE_OF_MATING? or Math.random() < @species.defs.CHANCE_OF_MATING)
          max = @get('max offspring')
          @set 'max offspring', Math.max(max, 1)
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
        "Diabetes-prone:&nbsp;&nbsp;&nbsp;": 'prone to diabetes'
        "Has diabetes:   ": 'has diabetes'
        "Weight (g):   ": 'weight'
        "Genome:  ": 'genome'
    traits: [
      new Trait {name: 'speed', default: 6 }
      new Trait {name: 'vision distance', default: 10000 }
      new Trait {name: 'mating distance', default:  10000 }
      new Trait {name: 'max offspring',   default:  3 }
      new Trait {name: 'min offspring',   default:  2 }
      new Trait {name: 'weight',   min:  140, max: 160 }
      new Trait {name: 'prone to diabetes', possibleValues: ['a:DR,b:DR','a:dp,b:DR','a:DR,b:dp','a:dp,b:dp','a:dp,b:dp','a:dp,b:dp','a:dp,b:dp','a:dp,b:dp'], isGenetic: true, isNumeric: false }
      new Trait {name: 'has diabetes', default:  false }
    ]
    imageProperties:
      initialFlipDirection: "right"
    imageRules: [
      {
        name: 'diabetic'
        contexts: ['environment']
        rules: [
          {
            image:
              path: "images/agents/diabetic-stack.png"
              scale: 0.5
              anchor:
                x: 0.5
                y: 0.7
            useIf: (agent)-> model.showDiabetic and agent.get('has diabetes')
          }
        ]
      }
      {
        name: 'prone'
        contexts: ['environment']
        rules: [
          {
            image:
              path: "images/agents/prone-stack.png"
              scale: 0.5
              anchor:
                x: 0.5
                y: 0.7
            useIf: (agent)-> model.showPropensity and agent.get('prone to diabetes') is 'prone'
          }
        ]
      }
      {
        name: 'sex'
        contexts: ['environment']
        rules: [
          {
            image:
              path: "images/agents/female-stack.png"
              scale: 0.5
              anchor:
                x: 0.5
                y: 0.7
            useIf: (agent)-> model.showSex and agent.get('sex') is 'male'
          }
          {
            image:
              path: "images/agents/male-stack.png"
              scale: 0.5
              anchor:
                x: 0.5
                y: 0.7
            useIf: (agent)-> model.showSex and agent.get('sex') is 'female'
          }
        ]
      }
      {
        name: 'rats'
        rules: [
          {
            image:
              path: "images/agents/sandrat-stack.png"
              scale: 0.7
              anchor:
                x: 0.5
                y: 0.6
            useIf: (agent)-> agent.get('weight') > 180
          }
          {
            image:
              path: "images/agents/sandrat-stack.png"
              scale: 0.5
              anchor:
                x: 0.5
                y: 0.7
          }
        ]
      }
    ]
