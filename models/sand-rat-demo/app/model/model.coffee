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
      all: {x: 0,                        y: 0,                         width: @env.width,                 height: @env.height }
      w:   {x: 0,                        y: 0,                         width: Math.round(@env.width/3),   height: @env.height }
      ne:  {x: Math.round(@env.width/3), y: 0,                         width: Math.round(@env.width/3)*2, height: Math.round(@env.height/2)}
      se:  {x: Math.round(@env.width/3), y: Math.round(@env.height/2), width: Math.round(@env.width/3)*2, height: Math.round(@env.height/2)}

    @setupEnvironment()
    @isSetUp = true
    @stopDate = 0
    @secondsPerSample = 2
    @graphInterval = Math.ceil(@targetFPS()*@secondsPerSample) # Sample every 2 seconds

    Events.addEventListener Environment.EVENTS.RESET, =>
      @setupEnvironment()
      $('.time-limit-dialog').fadeOut(300)

    Events.addEventListener Environment.EVENTS.STEP, =>
      @countRatsInAreas()
      drawCharts() if @env.date % @graphInterval is 1
      if @stopDate > 0 and @env.date > @stopDate
        @env.stop()
        drawCharts()
        @_timesUp()

  targetFPS: ()->
    return 1000/(if @env? then @env._runLoopDelay else Environment.DEFAULT_RUN_LOOP_DELAY)

  agentsOfSpecies: (species)->
    set = []
    for a in @env.agents
      set.push a if a.species is species
    return set

  _countRats: (rectangle) ->
    data = {}

    rats = (a for a in @env.agentsWithin(rectangle) when a.species is sandratSpecies)

    data = {date: Math.floor(@env.date/@graphInterval)*@secondsPerSample, total: rats.length, healthy: 0, diabetic: 0}
    for a in rats
      data.healthy++ if not a.get('has diabetes')
      data.diabetic++ if a.get('has diabetes')
      # weight = Math.floor(a.get('weight') / 10) * 10
      # data[weight] ?= 0
      # data[weight]++

    return data

  countRatsInAreas: ->
    if @isFieldModel
      @current_counts.all = @_countRats(@locations.all)
    else
      @current_counts.w  = @_countRats(@locations.w)
      @current_counts.ne = @_countRats(@locations.ne)
      @current_counts.se = @_countRats(@locations.se)

  setupEnvironment: ->
    for col in [0..(@env.columns)]
      for row in [0..(@env.rows)]
        @env.set col, row, "chow", false

    for i in [0...startingRats]
      @addRat()

    @current_counts =
      all: {total: 0}
      w:   {total: 0}
      se:  {total: 0}
      ne:  {total: 0}

    resetAndDrawCharts()

  addRat: () ->
    loc = if @isFieldModel then @locations.all else @locations.w
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
      chart2 = new Chart(model, 'field-chart-2', 'diabetic', 'se')

  $('#view-sex-check').change ->
    model.showSex = $(this).is(':checked')
  $('#view-prone-check').change ->
    model.showPropensity = $(this).is(':checked')
  $('#view-diabetic-check').change ->
    model.showDiabetic = $(this).is(':checked')

  chart1PeriodId = null
  chart2PeriodId = null
  startChartPeriod = (adding, chart)->
    if chart is 1
      if adding
        chart1PeriodId = 'chow-'+Date.now()
        chart1?.startPeriod(chart1PeriodId)
      else
        chart1?.endPeriod(chart1PeriodId)
    else
      if adding
        chart2PeriodId = 'chow-'+Date.now()
        chart2?.startPeriod(chart2PeriodId)
      else
        chart2?.endPeriod(chart2PeriodId)

  $('.chow-toggle').click ->
    toggle = $(this)
    toggle.toggleClass('on')
    adding = toggle.hasClass('on')
    if toggle.hasClass('all')
      model.setChow 'all', adding
      startChartPeriod adding, 1
    if toggle.hasClass('north-east')
      model.setChow 'ne', adding
      startChartPeriod adding, 1
    if toggle.hasClass('south-east')
      model.setChow 'se', adding
      startChartPeriod adding, 2
    if toggle.hasClass('west')
      model.setChow 'w', adding

  $('#time-limit').change ->
    model.setStopDate $(this).val()*model.targetFPS()
    chart1?.recalculateLength()
    chart2?.recalculateLength()

  window.resetAndDrawCharts = ->
    chart1?.reset()
    chart2?.reset()
    drawCharts()

  window.drawCharts = ->
    chart1?.draw()
    chart2?.draw()
