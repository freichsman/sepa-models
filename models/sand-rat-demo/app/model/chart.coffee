require.register "model/chart", (exports, require, module) ->
  Chart = class Chart

    constructor: (@model, @parent, @type, @location)->
      @_guides = {}
      @_data = []
      @recalculateLength()
      @reset()
      @setupChart()

      return

    draw: ->
      if not @model.isSetUp then return

      if (@_idx == @_data.length and @_data[@_idx-1]?.date < model.env.date) or
         (@_idx <  @_data.length and @_data[@_idx]?.date   < model.env.date)
        newData = @model.current_counts[@location]
        currentDate = newData.date
        newData.color = 'hsl(0,100%,55%)'
        @_data[@_idx-1].color = 'hsl(0,100%,92%)' if @_idx > 0
        if @_idx == @_data.length
          old = @_data.shift()
          @_data.push(newData)
        else
          @_data[@_idx] = newData
          @_idx++

        @_extendOpenPeriods(currentDate)
        @chart.validateData()

      return

    reset: ->
      for i in [0...(@_data.length)]
        @_data[i] = {date: 2*i, placeholder: true}

      if @chart?
        for guide in @chart.categoryAxis.guides by -1 # process in reverse order so indexes don't shift on us
          @chart.categoryAxis.removeGuide guide

      @_guides = {}

      @_idx = 0

      @chart?.validateData()
      return

    recalculateLength: ->
      if @model.stopDate is 0
        newLength = 30
      else
        newLength = Math.ceil(@model.stopDate / @model.graphInterval)+1

      while @_data.length > newLength
        if @_data[@_data.length-1].placeholder
          @_data.pop()
        else
          @_data.shift()

      while @_data.length < newLength
        nextDate = if @_data.length is 0 then 0 else @_data[@_data.length-1].date + 2
        @_data.push {date: nextDate, placeholder: true }

      @chart?.validateData()
      return

    startPeriod: (id)->
      currentDate = if @_idx is 0 then 0 else @_data[@_idx-1].date
      guide = new AmCharts.Guide
      # For whatever reason, passing these options in as a hash does *not* work!
      guide.color = '#999999'
      guide.fillColor = 'hsl(200, 100%, 92%)'
      guide.fillAlpha = 0.4
      guide.category = ''+currentDate
      guide.toCategory = ''+currentDate
      guide.expand = true
      guide.label = 'Sugary chow added'
      guide.position = 'left'
      guide.inside = true
      guide.labelRotation = 90
      @_guides[id] = guide

      @chart?.categoryAxis.addGuide guide
      return

    endPeriod: (id)->
      delete @_guides[id]
      return

    _extendOpenPeriods: (date)->
      for own id,guide of @_guides
        guide.toCategory = ''+date
      return

    setupChart: ->
      @chart = AmCharts.makeChart @parent,
        type: 'serial'
        theme: 'light'
        marginTop: 10
        marginRight: 0
        marginLeft: 0
        marginBottom: 0
        dataProvider: @_data
        categoryField: 'date'
        categoryAxis:
          dashLength: 1
          minorGridEnabled: true
        graphs: [
          {
            id: 'diabetic-rats-bar'
            type: 'column'
            lineColorField: 'color'
            fillColorsField: 'color'
            colorField: 'color'
            fillAlphas: 0.6
            columnWidth: 1
            clustered: false
            valueField: 'diabetic'
            valueAxis: 'diabetic'
            title: 'Diabetic Rats'
          }
        ]
        valueAxes: [
          {
            id: 'diabetic'
            title: 'Diabetic Rats'
            autoGridCount: false
            gridCount: 5
            minimum: 0
            maximum: if @location is 'all' then 50 else 30
            position: 'left'
          }
        ]
      return

  module.exports = Chart
