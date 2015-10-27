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

biologicaSandratSpecies = require 'species/biologica/sandrats'
sandratSpecies  = require 'species/sandrats'
chowSpecies     = require 'species/chow'
env             = require 'environments/field'

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
    @secondsPerSample = 1
    @graphInterval = Math.ceil(@targetFPS()*@secondsPerSample)

    Events.addEventListener Environment.EVENTS.RESET, =>
      @setupEnvironment()
      $('.time-limit-dialog').fadeOut(300)
      resetAndDrawCharts()

    Events.addEventListener Environment.EVENTS.START, =>
      $('.time-limit-dialog').fadeOut(300)

    Events.addEventListener Environment.EVENTS.STEP, =>
      @countRatsInAreas()
      updateCharts() if @env.date % @graphInterval is 1
      if @stopDate > 0 and @env.date is @stopDate
        @env.stop()
        updateCharts()
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

    data = {date: Math.floor(@env.date/@graphInterval)*@secondsPerSample, total: rats.length, healthy: 0, diabetic: 0, prone: 0, notProne: 0, thin: 0, medium: 0, obese: 0}
    for a in rats
      if a.get('has diabetes')
        data.diabetic++
      else
        data.healthy++

      if a.get('prone to diabetes')
        data.prone++
      else
        data.notProne++

      weight = Math.floor(a.get('weight') / 10) * 10
      if weight < 160
        data.thin++
      else if weight < 180
        data.medium++
      else
        data.obese++

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

    for i in [0...(if window.CONFIG?.startingRats? then window.CONFIG.startingRats else 20)]
      @addRat()

    @current_counts =
      all: {total: 0}
      w:   {total: 0}
      se:  {total: 0}
      ne:  {total: 0}

    if window.CONFIG?.timeLimit?
      @stopDate = Math.ceil window.CONFIG.timeLimit * model.targetFPS()
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

  _timesUp: ->
    $('.time-limit-dialog').fadeIn(300)

chart1 = null
chart2 = null

resetAndDrawCharts = ->
  chart1?.reset()
  chart2?.reset()

updateCharts = ->
  chart1?.update()
  chart2?.update()

chartTypes =
    diabetes: [
        {property: "diabetic", title: "Diabetic Rats", description: "rats with diabetes"},
        {property: "healthy", title: "Healthy Rats", description: "healthy rats"}
      ]
    risk: [
        {property: "prone", title: "Risk of diabetes", description: "at risk of diabetes"},
        {property: "notProne", title: "No risk of diabetes", description: "with no risk of diabetes"}
      ]
    weight: [
        {property: "thin", title: "Thin", description: "thin rats"},
        {property: "medium", title: "Heavy", description: "heavy rats"},
        {property: "obese", title: "Obese", description: "obese rats"}
      ]
    diabetesTime: [
        {property: "diabetic", timeBased: true, description: "rats with diabetes", yAxis: "Rats with diabetes"},
      ]

defaultChartTypes = ["diabetes", "weight", "risk", "diabetesTime"]

updatePulldowns = () ->
  $('#chart-1-selector').html ""
  $('#chart-2-selector').html ""
  #<option selected="selected" value="diabetes">Sand Rats with Diabetes</option>
  options =
    diabetes: "Sand Rats with Diabetes"
    weight: "Weight of Sand Rats"
    risk: "Risk of Diabetes"
    diabetesTime: "Diabetes over time"
  if window.CONFIG?.chart?.options?
    authoredOptions = window.CONFIG.chart.options
  else
    authoredOptions = defaultChartTypes

  createSelectOption = (opt) ->
    $("<option value='#{opt}'>#{options[opt]}</option>")

  for option in authoredOptions
    $('#chart-1-selector').append createSelectOption(option)
    $('#chart-2-selector').append createSelectOption(option)

  chart1?.setData chartTypes[authoredOptions[0]]
  chart2?.setData chartTypes[authoredOptions[0]]
  resetAndDrawCharts()

  if authoredOptions.length < 2
    $('#chart-1-selector').hide()
    $('#chart-2-selector').hide()

geneInfo =
  'DR':
    gene: 'red'
  'drb':
    gene: 'red'
  'DY':
    gene: 'yellow'
  'dyb':
    gene: 'yellow'
  'DB':
    gene: 'blue'
  'dbb':
    gene: 'blue'

updateAlleleFrequencies = ->
  for allele,info of geneInfo
    if window.CONFIG['allele frequencies']?[allele]?
      idx = biologicaSandratSpecies.geneList[info.gene].alleles.indexOf(allele)
      biologicaSandratSpecies.geneList[info.gene].weights[idx] = window.CONFIG['allele frequencies'][allele]

updateTimeLimitPopup = ->
  console.log "will do"
  if window.CONFIG?.timeLimitTitle?
    console.log "setting title to #{window.CONFIG.timeLimitTitle}"
    $(".time-limit-dialog>.title").html(window.CONFIG.timeLimitTitle)
  if window.CONFIG?.timeLimitMessage? && window.CONFIG.timeLimitMessage.length
    $(".time-limit-dialog>.content").html("")
    for message in window.CONFIG.timeLimitMessage
      $(".time-limit-dialog>.content").append $("<div>#{message}</div>")

processConfig = ->
  updateAlleleFrequencies()
  updatePulldowns()
  updateTimeLimitPopup()

$ ->

  model.isFieldModel = !/[^\/]*html/.exec(document.location.href) or /[^\/]*html/.exec(document.location.href)[0] == "field.html"
  model.isLifespanModel = /[^\/]*html/.exec(document.location.href) and /[^\/]*html/.exec(document.location.href)[0] == "lifespan.html"

  graph1Location = if model.isFieldModel then 'all' else 'ne'

  helpers.preload [model, env, sandratSpecies], ->
    model.run()
    if $('#field-chart').length > 0
      chart1 = new Chart(model, 'field-chart', graph1Location)
      type = if window.CONFIG?.chart?.options? then window.CONFIG.chart.options[0] else defaultChartTypes[0]
      chart1.setData chartTypes[type]
      chart1.reset()
    if $('#field-chart-2').length > 0
      chart2 = new Chart(model, 'field-chart-2', 'se')
      type = if window.CONFIG?.chart?.options? then window.CONFIG.chart.options[0] else defaultChartTypes[0]
      chart2.setData chartTypes[type]
      chart2.reset()

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
    chart1?.recalculateLength()
    chart2?.recalculateLength()

  $('#chart-1-selector').change ->
    chart1.setData chartTypes[this.value]
    chart1.reset()

  $('#chart-2-selector').change ->
    chart2.setData chartTypes[this.value]
    chart2.reset()

  configDefaults =
    "allele frequencies":
      DR: 1
      drb: 4
      DY: 1
      dyb: 4
      DB: 1
      dbb: 4
    startingRats: 27
    diabetes:
      red:
        "none": 0
        level1: 0.167
        level2: 0.25
      yellow:
        "none": 0
        level1: 0.167
        level2: 0.25
      blue:
        "none": 0
        level1: 0.167
        level2: 0.25
    chart:
      options: ["diabetes", "weight", "risk", "diabetesTime"]
    timeLimit: 30
    timeLimitTitle: "Times up!"
    timeLimitMessage: ["What happened to the rats in the pens?",
      "Hit reset to run the model again."]

  window.ORIGINAL_CONFIG = window.CONFIG
  window.CONFIG = $.extend({}, configDefaults, window.CONFIG)
  processConfig()

  container = document.getElementById("author-json")
  if container
    if config = window.localStorage.getItem('sandrats-config')
      window.CONFIG = $.extend(window.CONFIG, JSON.parse(config))
    window.JSON_EDITOR = new JSONEditor(container)
    window.JSON_EDITOR.set(window.CONFIG)

    validateConfig = (config)->
      # validate the odds of getting diabetes
      for color in ['red','yellow','blue']
        for level in ['none','level1','level2']
          if config.diabetes?[color]?[level]? and not $.isNumeric(config.diabetes[color][level])
            validationError("diabetes."+color+"."+level+" should be a number")
            return false

      for allele of geneInfo
        if config['allele frequencies']?[allele]? and not $.isNumeric(config['allele frequencies'][allele])
          validationError("'allele frequencies'."+allele+" should be a number")
          return false

      if config.startingRats? and not $.isNumeric(config.startingRats)
        validationError("startingRats should be a number")
        return false

      if config.chart?
        if config.chart.bars? and not $.isNumeric(config.chart.bars)
          validationError("chart.bars should be a number")
          return false
        if config.chart.barWidth? and not $.isNumeric(config.chart.barWidth)
          validationError("chart.barWidth should be a number")
          return false
        if config.chart.connectingLine? and $.type(config.chart.connectingLine) isnt 'boolean'
          validationError("chart.connectingLine should be true or false")
          return false

      return true

    validationError = (error)->
      $('.validation-feedback').addClass('error').text(error)

    editing = true
    $('#author-toggle-mode').click ->
      if editing
        $('#author-toggle-mode').text('View Tree')
        window.JSON_EDITOR.setMode('text')
        editing = false
      else
        $('#author-toggle-mode').text('View Text')
        window.JSON_EDITOR.setMode('tree')
        editing = true

    $('#author-update').click ->
      newConfig = window.JSON_EDITOR.get()
      if validateConfig(newConfig)
        $('.validation-feedback').removeClass('error').text('OK!')
        window.CONFIG = newConfig
        processConfig()
        model.env.reset()

    $('#author-remember').click ->
      newConfig = window.JSON_EDITOR.get()
      if validateConfig(newConfig)
        $('.validation-feedback').removeClass('error').text('OK!')
        window.localStorage.setItem('sandrats-config', JSON.stringify(newConfig))

    $('#author-reset').click ->
      newConfig = $.extend({}, configDefaults, window.ORIGINAL_CONFIG)
      if validateConfig(newConfig)
        $('.validation-feedback').removeClass('error').text('OK!')
        window.JSON_EDITOR.set(newConfig)

