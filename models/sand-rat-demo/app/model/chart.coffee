helpers = require 'helpers'

require.register "model/chart", (exports, require, module) ->
  Chart = class Chart

    constructor: (@model, @parent, @location) ->
      @_guides = {}
      @_data = []
      @_timeBased = false
      @_timeProp = null
      @_time = 0

    # [ {property: "diabetic", title: "Diabetic Rats", description: "with diabetes"}, {property: "healthy", title: "Healthy Rats"} ]
    setData: (@properties) ->
      @_data = []
      if @properties.length is 1 and @properties[0].timeBased
        @_timeBased = true
        @_timeProp = @properties[0]
        for i in [1..30]
          @_data.push
            category: i
            description: @_timeProp.description
      else
        @_timeBased = false
        for prop in @properties
          @_data.push
            category: prop.title
            description: prop.description
            count: 0
            property: prop.property

    # draw initial graph or replace existing
    reset: ->
      @setData @properties
      @parent.innerHTML = ""
      @_time = 0
      @_drawChart()
      @update()

    update: ->
      if not @model.isSetUp then return

      newData = @model.current_counts[@location]

      if not @_timeBased
        for column in @_data
          column.count = newData[column.property]
      else
        @_time++
        if @_time % 2 isnt 0 then return
        timeChartTime = @_time / 2
        datum = helpers.clone @_data[0]
        datum.category = timeChartTime
        datum.count = newData[@_timeProp.property]
        datum.base  = -2
        datum.color = 'hsl(0,100%,55%)'
        if timeChartTime <= @_data.length
          @_data[timeChartTime-1] = datum
          @_data[timeChartTime-2]?.color = 'hsl(0,100%,85%)'
        else
          @_data.shift()
          @_data.push datum
          @_data[@_data.length-2]?.color = 'hsl(0,100%,85%)'

        @_extendOpenPeriods()

      @chart.validateData()

    _drawChart: ->
      opts = helpers.clone @_defaultChartProps

      if @_timeBased
        opts.valueAxes[0].title = @_timeProp.yAxis
        opts.valueAxes[0].minimum = -2

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
      graphs: [
        {
          balloonText: "<b>[[value]]</b> [[description]]"
          fillAlphas: 0.8
          lineAlpha: 0.2
          type: "column"
          valueField: "count"
          openField: "base"
          lineColorField: 'color'
          fillColorsField: 'color'
          colorField: 'color'
        }
      ]



    startPeriod: (id)->
      if not @_timeBased then return

      guide = new AmCharts.Guide
      # For whatever reason, passing these options in as a hash does *not* work!
      guide.color = '#999999'
      guide.fillColor = 'hsl(200, 100%, 92%)'
      guide.fillAlpha = 0.4
      guide.category = ''+Math.ceil @_time/2
      guide.toCategory = ''+Math.ceil @_time/2
      guide.expand = true
      guide.label = 'Sugary food added'
      guide.position = 'left'
      guide.inside = true
      guide.labelRotation = 90
      @_guides[id] = guide

      @chart?.categoryAxis.addGuide guide
      # return

    endPeriod: (id)->
      delete @_guides[id]

    _extendOpenPeriods: ()->
      if not @_timeBased then return

      for own id,guide of @_guides
        guide.toCategory = ''+Math.ceil @_time/2

      # also trim guides on the far left
      leftDate = @_data[0].category
      if leftDate > 1
        for guide in @chart?.categoryAxis?.guides
          if guide.category < leftDate && guide.toCategory >= leftDate
            guide.category = leftDate
      return


  module.exports = Chart
