helpers     = require 'helpers'

Environment = require 'models/environment'
Species     = require 'models/species'
Agent       = require 'models/agent'
Trait       = require 'models/trait'
Interactive = require 'ui/interactive'
Events      = require 'events'
ToolButton  = require 'ui/tool-button'
BasicAnimal = require 'models/agents/basic-animal'

sandratSpecies  = require 'species/sandrats'
chowSpecies     = require 'species/chow'
env             = require 'environments/field'

startingRats    = 16

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
    @isSetUp = true

    Events.addEventListener Environment.EVENTS.RESET, =>
      @setupEnvironment()

    Events.addEventListener Environment.EVENTS.STEP, =>
      drawChart @countRats()

  agentsOfSpecies: (species)->
    set = []
    for a in @env.agents
      set.push a if a.species is species
    return set

  countRats: ->
    healthyRats = 0
    diabeticRats = 0
    for a in @agentsOfSpecies(sandratSpecies)
      healthyRats++ if not a.get('has diabetes')
      diabeticRats++ if a.get('has diabetes')
    console.log [healthyRats, diabeticRats]
    return [healthyRats, diabeticRats]

  setupEnvironment: ->
    for col in [0..100]
      for row in [0..70]
        @env.set col, row, "chow", false

    for i in [0...startingRats]
      @addRat()

  addRat: () ->
    top = if @isFieldModel then 0 else 350
    rat = sandratSpecies.createAgent()
    rat.setLocation env.randomLocationWithin 0, top, 1000, 700, true
    @env.addAgent rat

  addChow: (n, x, y, w, h) ->
    for i in [0...n]
      chow = chowSpecies.createAgent()
      chow.setLocation env.randomLocationWithin x, y, w, h, true
      @env.addAgent chow

  removeChow: (x, y, width, height) ->
    agents = env.agentsWithin {x, y, width, height}
    agent.die() for agent in agents when agent.species.speciesName is "chow"

  setNWChow: (chow) ->
    for col in [0..31]
      for row in [0..33]
        @env.set col, row, "chow", chow
    if (chow)
      @addChow(25, 0, 0, 330, 350)
    else
      @removeChow(0, 0, 330, 350)
  setNChow: (chow) ->
    for col in [33..64]
      for row in [0..33]
        @env.set col, row, "chow", chow
    if (chow)
      @addChow(25, 340, 0, 330, 350)
    else
      @removeChow(340, 0, 330, 350)
  setNEChow: (chow) ->
    for col in [66..100]
      for row in [0..33]
        @env.set col, row, "chow", chow
    if (chow)
      @addChow(25, 670, 0, 330, 350)
    else
      @removeChow(670, 0, 330, 350)
  setSChow: (chow) ->
    for col in [0..100]
      for row in [36..75]
        @env.set col, row, "chow", chow
    if (chow)
      @addChow(70, 0, 350, 1000, 350)
    else
      @removeChow(0, 350, 1000, 350)


$ ->
  model.isFieldModel = /[^\/]*html/.exec(document.location.href)[0] == "field.html"

  helpers.preload [model, env, sandratSpecies], ->
    model.run()

  $('#view-prone-check').change ->
    model.showPropensity = $(this).is(':checked')

  $('#chow').change ->
    model.setNWChow $(this).is(':checked')
    model.setNChow $(this).is(':checked')
    model.setNEChow $(this).is(':checked')
    model.setSChow $(this).is(':checked')
  $('#chow-nw').change ->
    model.setNWChow $(this).is(':checked')
  $('#chow-n').change ->
    model.setNChow $(this).is(':checked')
  $('#chow-ne').change ->
    model.setNEChow $(this).is(':checked')
  $('#chow-s').change ->
    model.setSChow $(this).is(':checked')

drawChart = (_data)->
    _data ?= [0,0]
    if model.isSetUp then _data = model.countRats()
    data = google.visualization.arrayToDataTable([
      ["Type", "Number of organisms", { role: "style" } ]
      ["Healthy", _data[0], "silver"]
      ["Diabetic", _data[1], "brown"]
    ])

    view = new google.visualization.DataView(data)
    view.setColumns([0, 1,
                      {
                        calc: "stringify",
                        sourceColumn: 1,
                        type: "string",
                        role: "annotation"
                      },
                      2])

    options = {
      title: "Sandrats in population",
      width: 300,
      height: 300,
      bar: {groupWidth: "95%"},
      legend: { position: "none" },
    }
    chart = new google.visualization.ColumnChart(document.getElementById("field-chart"))
    chart.draw(view, options)


google.load('visualization', '1', {packages: ['corechart', 'bar'], callback: drawChart})
