helpers = require 'helpers'

require.register "model/chart", (exports, require, module) ->
  Chart = class Chart

    constructor: (@model, @parent, @location) ->
      @_guides = {}
      @_data = []

    # [ {property: "diabetic", title: "Diabetic Rats", description: "with diabetes"}, {property: "healthy", title: "Healthy Rats"} ]
    setData: (@properties) ->
      @_data = []
      for prop in @properties
        @_data.push
          category: prop.title
          description: prop.description
          count: 0
          prop: prop.property

    # draw initial graph or replace existing
    reset: ->
      @parent.innerHTML = ""
      @_drawChart()
      @update()

    update: ->
      if not @model.isSetUp then return

      newData = @model.current_counts[@location]
      for column in @_data
        column.count = newData[column.prop]
      @chart.validateData()

    _drawChart: ->
      opts = helpers.clone @_defaultChartProps

      opts.graphs.push
        balloonText: "<b>[[value]]</b> [[description]]",
        fillAlphas: 0.8,
        lineAlpha: 0.2,
        type: "column",
        valueField: "count"

      opts.dataProvider = @_data


      @chart = AmCharts.makeChart @parent, opts



    _defaultChartProps:
      type: 'serial'
      theme: 'light'
      marginTop: 10
      marginRight: 0
      marginLeft: 0
      marginBottom: 0
      categoryAxis:
        dashLength: 1
        minorGridEnabled: true
      valueAxes: [
        {
          title: 'Number of Rats'
          autoGridCount: false
          gridCount: 6
          showFirstLabel: false
          strictMinMax: true
          minimum: 0
          maximum: if @location is 'all' then 50 else 30
          position: 'left'
        }
      ]
      categoryField: 'category'
      graphs: []



    startPeriod: (id)->
      # currentDate = if @_idx is 0 then 0 else @_data[@_idx-1].date
      # guide = new AmCharts.Guide
      # # For whatever reason, passing these options in as a hash does *not* work!
      # guide.color = '#999999'
      # guide.fillColor = 'hsl(200, 100%, 92%)'
      # guide.fillAlpha = 0.4
      # guide.category = ''+currentDate
      # guide.toCategory = ''+currentDate
      # guide.expand = true
      # guide.label = 'Sugary food added'
      # guide.position = 'left'
      # guide.inside = true
      # guide.labelRotation = 90
      # @_guides[id] = guide

      # @chart?.categoryAxis.addGuide guide
      # return

    endPeriod: (id)->
      # delete @_guides[id]
      # return

    _extendOpenPeriods: (date)->
      # for own id,guide of @_guides
      #   guide.toCategory = ''+date
      # return


  module.exports = Chart
