helpers     = require 'helpers'

Environment = require 'models/environment'
Species     = require 'models/species'
Agent       = require 'models/agent'
Trait       = require 'models/trait'
Interactive = require 'ui/interactive'
Events      = require 'events'
ToolButton  = require 'ui/tool-button'
BasicAnimal = require 'models/agents/basic-animal'

sandratSpecies   = require 'species/sandrats'
env                = require 'environments/field'

startingRats     = 20

window.model =
  run: ->
    @interactive = new Interactive
      environment: env
      toolButtons: [
        {
          type: ToolButton.INFO_TOOL
        }
        {
          type: ToolButton.CARRY_TOOL
        }
      ]

    document.getElementById('environment').appendChild @interactive.getEnvironmentPane()

    @env = env

    @setupEnvironment()
    Events.addEventListener Environment.EVENTS.RESET, =>
      @setupEnvironment()

  setupEnvironment: ->
    for col in [0..100]
      for row in [0..70]
        @env.set col, row, "chow", false

    for i in [0...startingRats]
      @addRat()

  addRat: () ->
    rat = sandratSpecies.createAgent()
    rat.setLocation env.randomLocationWithin 0, 350, 1000, 350, true
    @env.addAgent rat

  setNWChow: (chow) ->
    for col in [0..31]
      for row in [0..33]
        @env.set col, row, "chow", chow
  setNChow: (chow) ->
    for col in [33..64]
      for row in [0..33]
        @env.set col, row, "chow", chow
  setNEChow: (chow) ->
    for col in [66..100]
      for row in [0..33]
        @env.set col, row, "chow", chow
  setSChow: (chow) ->
    for col in [0..100]
      for row in [36..75]
        @env.set col, row, "chow", chow


$ ->
  helpers.preload [model, env, sandratSpecies], ->
    model.run()

  $('#view-prone-check').change ->
    model.showPropensity = $(this).is(':checked')

  $('#chow-nw').change ->
    model.setNWChow $(this).is(':checked')
  $('#chow-n').change ->
    model.setNChow $(this).is(':checked')
  $('#chow-ne').change ->
    model.setNEChow $(this).is(':checked')
  $('#chow-s').change ->
    model.setSChow $(this).is(':checked')
