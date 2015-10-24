require.register "species/sandrats", (exports, require, module) ->

  helpers = require 'helpers'
  Species = require 'models/species'
  BasicAnimal = require 'models/agents/basic-animal'
  AnimatedAgent = require 'models/agents/animated-agent'
  Trait   = require 'models/trait'

  biologicaSpecies = require 'species/biologica/sandrats'

  window.orgNumber ?= 1

  class SandRat extends BasicAnimal
    label: 'Sand Rat'
    moving: false
    moveCount: 0

    step: ->
      @wander()
      @_incrementAge()

      if @get('age') > @species.defs.MATURITY_AGE
        @set 'current behavior', BasicAnimal.BEHAVIOR.MATING

      overcrowded = false
      if not @_isInPensModel
        overcrowded = model.current_counts.all.total > 46
      else
        if @_x < model.env.width/3
          overcrowded = model.current_counts.w.total > 30
        else if @_y < model.env.height/2
          overcrowded = model.current_counts.ne.total > 30
        else
          overcrowded = model.current_counts.se.total > 30

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

    resetGeneticTraits: ()->
      super()
      @set 'genome', @_genomeButtonsString()
      @set 'prone to diabetes', @get('red diabetes') isnt 'none' or @get('yellow diabetes') isnt 'none' or @get('blue diabetes') isnt 'none'

    _genomeButtonsString: ()->
      alleles = @organism.getAlleleString().replace(/a:/g,'').replace(/b:/g,'').replace(/,/g, '')
      alleles = alleles.replace(/d[ryb]b/g, '<span class="allele black"></span>')
      alleles = alleles.replace(/DR/g, '<span class="allele red"></span>')
      alleles = alleles.replace(/DY/g, '<span class="allele yellow"></span>')
      alleles = alleles.replace(/DB/g, '<span class="allele blue"></span>')
      return alleles

  module.exports = new Species
    speciesName: "sandrats"
    agentClass: SandRat
    geneticSpecies: biologicaSpecies
    defs:
      CHANCE_OF_MUTATION: 0
      INFO_VIEW_SCALE: 2
      MATURITY_AGE: 20
      INFO_VIEW_PROPERTIES:
        "Weight (g):": 'weight'
        "": 'genome'
    traits: [
      new Trait {name: 'speed', default: 6 }
      new Trait {name: 'vision distance', default: 10000 }
      new Trait {name: 'mating distance', default: 10000 }
      new Trait {name: 'max offspring',   default:  3 }
      new Trait {name: 'min offspring',   default:  2 }
      new Trait {name: 'weight',   min:  140, max: 160 }
      new Trait {name: 'prone to diabetes', default: false }
      new Trait {name: 'red diabetes', possibleValues: [''], isGenetic: true, isNumeric: false }
      new Trait {name: 'yellow diabetes', possibleValues: [''], isGenetic: true, isNumeric: false }
      new Trait {name: 'blue diabetes', possibleValues: [''], isGenetic: true, isNumeric: false }
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
              scale: 0.4
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
              scale: 0.4
              anchor:
                x: 0.5
                y: 0.7
            useIf: (agent)-> model.showPropensity and agent.get('prone to diabetes')
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
              scale: 0.4
              anchor:
                x: 0.5
                y: 0.7
            useIf: (agent)-> model.showSex and agent.get('sex') is 'male'
          }
          {
            image:
              path: "images/agents/male-stack.png"
              scale: 0.4
              anchor:
                x: 0.5
                y: 0.7
            useIf: (agent)-> model.showSex and agent.get('sex') is 'female'
          }
        ]
      }
      {
        name: 'rats'
        contexts: ['environment','carry-tool']
        rules: [
          {
            image:
              path: "images/agents/sandrat-obese.png"
              scale: 0.9
              anchor:
                x: 0.6
                y: 0.9
            useIf: (agent)-> agent.get('weight') > 180
          }
          {
            image:
              path: "images/agents/sandrat-skinny.png"
              scale: 0.8
              anchor:
                x: 0.6
                y: 0.9
          }
        ]
      }
      {
        name: 'rats info tool'
        contexts: ['info-tool']
        rules: [
          {
            image:
              path: "images/agents/sandrat-obese.png"
              scale: 0.9
              anchor:
                x: 0.6
                y: 0.9
            useIf: (agent)-> agent.get('weight') > 180
          }
          {
            image:
              path: "images/agents/sandrat-skinny.png"
              scale: 0.8
              anchor:
                x: 0.6
                y: 0.9
          }
        ]
      }
    ]
