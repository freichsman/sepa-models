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

startingRats    = 20

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
      @countRatsInAreas()
      drawCharts()

    Events.addEventListener Environment.EVENTS.AGENT_ADDED, (evt) ->
      return if evt.detail.agent.species is chowSpecies
      drawCharts()

  agentsOfSpecies: (species)->
    set = []
    for a in @env.agents
      set.push a if a.species is species
    return set

  countRatsInAreas: ->
    if @isFieldModel
      @count_all = (a for a in @env.agentsWithin({x: 0, y: 0, width: 600, height: 700})   when a.species is sandratSpecies).length
    else
      @count_s   = (a for a in @env.agentsWithin({x: 0, y: 350, width: 1000, height: 350}) when a.species is sandratSpecies).length
      @count_nw  = (a for a in @env.agentsWithin({x: 0, y: 0, width: 500, height: 350})    when a.species is sandratSpecies).length
      @count_ne  = (a for a in @env.agentsWithin({x: 500, y: 0, width: 500, height: 350})  when a.species is sandratSpecies).length

  countRats: (chartN) ->
    data = {}
    loc = {x: 0, y: 0, width: 600, height: 700}

    graphLoc = if chartN is 1 then window.graph1Location else window.graph2Location

    if graphLoc is "s"
      loc = {x: 0, y: 350, width: 1000, height: 350}
    else if graphLoc is "nw"
      loc = {x: 0, y: 0, width: 500, height: 350}
    else if graphLoc is "ne"
      loc = {x: 500, y: 0, width: 500, height: 350}

    rats = (a for a in @env.agentsWithin(loc) when a.species is sandratSpecies)

    graphType = if chartN is 1 then window.graphType else window.graph2Type

    if graphType is "diabetic"
      data = {healthy: 0, diabetic: 0}
      for a in rats
        data.healthy++ if not a.get('has diabetes')
        data.diabetic++ if a.get('has diabetes')
    else if graphType is "weight"
      data = {140: 0}
      for a in rats
        weight = Math.floor(a.get('weight') / 10) * 10
        data[weight] ?= 0
        data[weight]++

    return data

  setupEnvironment: ->
    for col in [0..60]
      for row in [0..70]
        @env.set col, row, "chow", false

    for i in [0...startingRats]
      @addRat()

    $('#chow, #chow-s, #chow-nw, #chow-n, #chow-ne').attr('checked', false)

    @count_all = 0
    @count_s   = 0
    @count_nw  = 0
    @count_ne  = 0


    drawCharts()

  addRat: () ->
    top = if @isFieldModel then 0 else 350
    rat = sandratSpecies.createAgent()
    rat.set('age', 20 + (Math.floor Math.random() * 40))
    rat.setLocation env.randomLocationWithin 0, top, 600, 700, true
    @env.addAgent rat

  addChow: (n, x, y, w, h) ->
    for i in [0...n]
      chow = chowSpecies.createAgent()
      chow.setLocation env.randomLocationWithin x, y, w, h, true
      @env.addAgent chow

  removeChow: (x, y, width, height) ->
    agents = env.agentsWithin {x, y, width, height}
    agent.die() for agent in agents when agent.species.speciesName is "chow"
    @env.removeDeadAgents()

  setNWChow: (chow) ->
    for col in [0..30]
      for row in [0..33]
        @env.set col, row, "chow", chow
    if (chow)
      @addChow(25, 0, 0, 500, 350)
    else
      @removeChow(0, 0, 500, 350)
  setNEChow: (chow) ->
    for col in [30..60]
      for row in [0..33]
        @env.set col, row, "chow", chow
    if (chow)
      @addChow(25, 500, 0, 500, 350)
    else
      @removeChow(500, 0, 500, 350)
  setSChow: (chow) ->
    for col in [0..60]
      for row in [36..75]
        @env.set col, row, "chow", chow
    if (chow)
      @addChow(70, 0, 350, 1000, 350)
    else
      @removeChow(0, 350, 1000, 350)


$ ->
  model.isFieldModel = !/[^\/]*html/.exec(document.location.href) or /[^\/]*html/.exec(document.location.href)[0] == "field.html"
  model.isLifespanModel = /[^\/]*html/.exec(document.location.href) and /[^\/]*html/.exec(document.location.href)[0] == "lifespan.html"

  if not model.isFieldModel
    window.graph1Location = "s"

  if model.isLifespanModel
    startingRats = 10

  helpers.preload [model, env, sandratSpecies], ->
    model.run()


  $('#view-sex-check').change ->
    model.showSex = $(this).is(':checked')
  $('#view-prone-check').change ->
    model.showPropensity = $(this).is(':checked')
  $('#view-diabetic-check').change ->
    model.showDiabetic = $(this).is(':checked')

  $('#chow').change ->
    model.setNWChow $(this).is(':checked')
    model.setNEChow $(this).is(':checked')
    model.setSChow $(this).is(':checked')
  $('#chow-nw').change ->
    model.setNWChow $(this).is(':checked')
  $('#chow-ne').change ->
    model.setNEChow $(this).is(':checked')
  $('#chow-s').change ->
    model.setSChow $(this).is(':checked')


  $('#graph-selection').change ->
    window.graphType = $(this).val()
    drawCharts()

  $('#graph-selection-2').change ->
    window.graph2Type = $(this).val()
    drawCharts()


  $('#graph-location-selection').change ->
    window.graph1Location = $(this).val()
    drawCharts()

  $('#graph-location-selection-2').change ->
    window.graph2Location = $(this).val()
    drawCharts()

window.graphType = "diabetic"
window.graph1Location = "all"

window.graph2Type = "diabetic"
window.graph2Location = "nw"

drawCharts = ->
  drawChart(1)
  if not model.isFieldModel
    drawChart(2)

drawChart = (chartN)->
  if not model.isSetUp then return

  _data = model.countRats(chartN)

  graphType = if chartN is 1 then window.graphType else window.graph2Type
  graphLoc = if chartN is 1 then window.graph1Location else window.graph2Location

  max = if graphLoc is "all" then 60 else if graphLoc is "s" then 40 else 20

  options = {
    title: "Sandrats in population",
    width: 300,
    height: 260,
    bar: {groupWidth: "95%"},
    legend: { position: "none" },
    vAxis: {
      viewWindowMode:'explicit',
      viewWindow:{
        max:max,
        min:0
      }
    }
  }

  if graphType is "diabetic"
    data = google.visualization.arrayToDataTable([
      ["Type", "Number of rats", { role: "style" } ]
      ["Non-diabetic", _data.healthy, "silver"]
      ["Diabetic", _data.diabetic, "brown"]
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

  else if graphType is "weight"
    transformedData = {
      "< 150":   {count: (_data[130] or 0) + (_data[140] or 0), color: "blue"}
      "150-159": {count: (_data[150]) or 0, color: "blue"}
      "160-169": {count: (_data[160]) or 0, color: "blue"}
      "170-179": {count: (_data[170]) or 0, color: "#df7c00"}
      "180-189": {count: (_data[180]) or 0, color: "#df7c00"}
      "> 190":   {count: (_data[190] or 0) + (_data[200] or 0) + (_data[210] or 0) + (_data[220] or 0) + (_data[230] or 0), color: "#df7c00"}
    }

    chartData = [
      ["Type", "Number of rats", { role: "style" } ]
    ]
    for key of transformedData
      chartData.push [key, transformedData[key].count, transformedData[key].color]

    data = google.visualization.arrayToDataTable(chartData)

    view = new google.visualization.DataView(data)
    view.setColumns([0, 1,
                      {
                        calc: "stringify",
                        sourceColumn: 1,
                        type: "string",
                        role: "annotation"
                      },
                      2])

    options.title = "Weight of sandrats (g)"


  id = if chartN is 1 then "field-chart" else "field-chart-2"
  chart = new google.visualization.ColumnChart(document.getElementById(id))
  chart.draw(view, options)


google.load('visualization', '1', {packages: ['corechart', 'bar'], callback: drawCharts})
