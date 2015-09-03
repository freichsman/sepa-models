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

    @locations =
      all: {x: 0,                        y: 0,                         width: @env.width,               height: @env.height}
      s:   {x: 0,                        y: Math.round(@env.height/2), width: @env.width,               height: Math.round(@env.height/2)}
      nw:  {x: 0,                        y: 0,                         width: Math.round(@env.width/2), height: Math.round(@env.height/2)}
      ne:  {x: Math.round(@env.width/2), y: 0,                         width: Math.round(@env.width/2), height: Math.round(@env.height/2)}

    @setupEnvironment()
    @isSetUp = true
    @stopDate = 0

    Events.addEventListener Environment.EVENTS.RESET, =>
      @setupEnvironment()
      $('.time-limit-dialog').fadeOut(300)

    Events.addEventListener Environment.EVENTS.STEP, =>
      drawCharts() if @env.date % 37 is 1
      if @stopDate > 0 and @env.date > @stopDate
        @env.stop()
        drawCharts()
        @_timesUp()

  agentsOfSpecies: (species)->
    set = []
    for a in @env.agents
      set.push a if a.species is species
    return set

  countRats: (rectangle) ->
    data = {}

    rats = (a for a in @env.agentsWithin(rectangle) when a.species is sandratSpecies)

    data = {date: @env.date, total: rats.length, healthy: 0, diabetic: 0}
    for a in rats
      data.healthy++ if not a.get('has diabetes')
      data.diabetic++ if a.get('has diabetes')
      # weight = Math.floor(a.get('weight') / 10) * 10
      # data[weight] ?= 0
      # data[weight]++

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
    loc = if @isFieldModel then @locations.all else @locations.s
    rat = sandratSpecies.createAgent()
    rat.set('age', 20 + (Math.floor Math.random() * 40))
    rat.setLocation env.randomLocationWithin loc.x, loc.y, loc.width, loc.height, true
    @env.addAgent rat

  addChow: (n, loc) ->
    for i in [0...n]
      chow = chowSpecies.createAgent()
      chow.setLocation env.randomLocationWithin loc.x, loc.y, loc.width, loc.height, true
      @env.addAgent chow

  removeChow: (loc) ->
    agents = env.agentsWithin loc
    agent.die() for agent in agents when agent.species.speciesName is "chow"
    @env.removeDeadAgents()

  setChow: (area, chow) ->
    loc = @locations[area]
    return unless loc?

    for col in [(loc.x)..(loc.x+loc.width)] by @env._columnWidth
      for row in [(loc.y)..(loc.y+loc.height)] by @env._rowHeight
        @env.setAt col, row, "chow", chow
    if chow
      amount = Math.round(loc.width * loc.height / 7000)
      @addChow(amount, loc)
    else
      @removeChow(loc)

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
    model.setChow 'all', $(this).is(':checked')
  $('#chow-nw').change ->
    model.setChow 'nw', $(this).is(':checked')
  $('#chow-ne').change ->
    model.setChow 'ne', $(this).is(':checked')
  $('#chow-s').change ->
    model.setChow 's', $(this).is(':checked')

  $('#time-limit').change ->
    model.setStopDate $(this).val()*(1000/model.env._runLoopDelay)

  window.resetAndDrawCharts = ->
    chart1?.reset()
    chart2?.reset()
    drawCharts()

  window.drawCharts = ->
    chart1?.draw()
    chart2?.draw()
