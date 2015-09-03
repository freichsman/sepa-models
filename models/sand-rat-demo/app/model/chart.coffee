require.register "model/chart", (exports, require, module) ->
  Chart = class Chart

    constructor: (@model, @parent, @type, @location)->
      @_data = []
      @recalculateLength()
      @reset()
      @setupChart()
      @_idx = 0

      return

    draw: ->
      if not @model.isSetUp then return

      if (@_idx == @_data.length and @_data[@_idx-1]?.date < model.env.date) or
         (@_idx <  @_data.length and @_data[@_idx]?.date   < model.env.date)
        newData = @model.countRats(@model.locations[@location])
        newData.color = 'hsl(0,100%,55%)'
        @_data[@_idx-1].color = 'hsl(0,100%,92%)' if @_idx > 0
        if @_idx == @_data.length
          old = @_data.shift()
          @_data.push(newData)
        else
          @_data[@_idx] = newData
          @_idx++
        @chart.validateData()

      return

    reset: ->
      for i in [0..(@_data.length)]
        @_data[i] = {date: 2*i, placeholder: true}
      @chart?.validateData()

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
            maximum: 60
            position: 'left'
          }
        ]

  module.exports = Chart
