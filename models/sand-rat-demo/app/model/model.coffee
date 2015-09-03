helpers     = require 'helpers'

Environment = require 'models/environment'
Species     = require 'models/species'
Agent       = require 'models/agent'
Trait       = require 'models/trait'
Interactive = require 'ui/interactive'
Events      = require 'events'
ToolButton  = require 'ui/tool-button'
BasicAnimal = require 'models/agents/basic-animal'

Chart       = require 'model/chart'

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
    @stopDate = 0

    Events.addEventListener Environment.EVENTS.RESET, =>
      @setupEnvironment()
      $('.time-limit-dialog').fadeOut(300)

    Events.addEventListener Environment.EVENTS.STEP, =>
      @countRatsInAreas()
      drawCharts() if @env.date % 37 is 1
      if @stopDate > 0 and @env.date > @stopDate
        @env.stop()
        drawCharts()
        @_timesUp()

    # Events.addEventListener Environment.EVENTS.AGENT_ADDED, (evt) ->
    #   return if evt.detail.agent.species is chowSpecies
    #   drawCharts()

  agentsOfSpecies: (species)->
    set = []
    for a in @env.agents
      set.push a if a.species is species
    return set

  countRatsInAreas: ->
    if @isFieldModel
      @count_all = (a for a in @env.agentsWithin({x: 0, y: 0, width: @env.width, height: @env.height})   when a.species is sandratSpecies).length
    else
      @count_s   = (a for a in @env.agentsWithin({x: 0, y: Math.round(@env.height/2), width: @env.width, height: Math.round(@env.height/2)}) when a.species is sandratSpecies).length
      @count_nw  = (a for a in @env.agentsWithin({x: 0, y: 0, width: Math.round(@env.width/2), height: Math.round(@env.height/2)})    when a.species is sandratSpecies).length
      @count_ne  = (a for a in @env.agentsWithin({x: Math.round(@env.width/2), y: 0, width: Math.round(@env.width/2), height: Math.round(@env.height/2)})  when a.species is sandratSpecies).length

  countRats: (rectangle) ->
    data = {}

    rats = (a for a in @env.agentsWithin(rectangle) when a.species is sandratSpecies)

    data = {date: @env.date, total: rats.length, healthy: 0, diabetic: 0, 140: 0}
    for a in rats
      data.healthy++ if not a.get('has diabetes')
      data.diabetic++ if a.get('has diabetes')
      weight = Math.floor(a.get('weight') / 10) * 10
      data[weight] ?= 0
      data[weight]++

    return data

  setupEnvironment: ->
    for col in [0..(@env.columns)]
      for row in [0..(@env.rows)]
        @env.set col, row, "chow", false

    for i in [0...startingRats]
      @addRat()

    $('#chow, #chow-s, #chow-nw, #chow-ne').attr('checked', false)

    @count_all = 0
    @count_s   = 0
    @count_nw  = 0
    @count_ne  = 0


    resetAndDrawCharts()

  addRat: () ->
    top = if @isFieldModel then 0 else 350
    rat = sandratSpecies.createAgent()
    rat.set('age', 20 + (Math.floor Math.random() * 40))
    rat.setLocation env.randomLocationWithin 0, top, @env.width, @env.height-top, true
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
    for col in [0..(Math.ceil(@env.columns/2))] by 1
      for row in [0..33]
        @env.set col, row, "chow", chow
    if (chow)
      @addChow(25, 0, 0, 500, 350)
    else
      @removeChow(0, 0, 500, 350)
  setNEChow: (chow) ->
    for col in [(Math.ceil(@env.columns/2))..(@env.columns)] by 1
      for row in [0..33]
        @env.set col, row, "chow", chow
    if (chow)
      @addChow(25, 500, 0, 500, 350)
    else
      @removeChow(500, 0, 500, 350)
  setSChow: (chow) ->
    for col in [0..(@env.columns)] by 1
      for row in [36..75]
        @env.set col, row, "chow", chow
    if (chow)
      @addChow(70, 0, 350, 1000, 350)
    else
      @removeChow(0, 350, 1000, 350)

  setStopDate: (date)->
    @stopDate = date

  _timesUp: ->
    $('.time-limit-dialog').fadeIn(300)


$ ->
  chart1 = null
  chart2 = null

  model.isFieldModel = !/[^\/]*html/.exec(document.location.href) or /[^\/]*html/.exec(document.location.href)[0] == "field.html"
  model.isLifespanModel = /[^\/]*html/.exec(document.location.href) and /[^\/]*html/.exec(document.location.href)[0] == "lifespan.html"

  graph1Location = if model.isFieldModel then 'all' else 'ne'

  if model.isLifespanModel
    startingRats = 10

  helpers.preload [model, env, sandratSpecies], ->
    model.run()
    if $('#field-chart').length > 0
      chart1 = new Chart(model, 'field-chart',   'diabetic', graph1Location)
    if $('#field-chart-2').length > 0
      chart2 = new Chart(model, 'field-chart-2', 'diabetic', 'nw')


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

  $('#time-limit').change ->
    model.setStopDate $(this).val()*(1000/model.env._runLoopDelay)

  window.resetAndDrawCharts = ->
    chart1?.reset()
    chart2?.reset()
    drawCharts()

  window.drawCharts = ->
    chart1?.draw()
    chart2?.draw()
