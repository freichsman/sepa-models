require.register "model/chart", (exports, require, module) ->
  Chart = class Chart

    constructor: (@model, @parent, @type, @location)->
      @_data = []
      @setupChart()
      @reset()

      return

    draw: ->
      if not @model.isSetUp then return

      if @_data.length is 0 or @_data[@_data.length-1].date < model.env.date
        newData = @model.countRats(@model.locations[@location])
        @_data.push(newData)
        @chart.validateData()
        @chart.zoomToIndexes(@_data.length - 11, @_data.length - 1)

      return

    reset: ->
      @_data.length = 0
      @_data.push({date: i}) for i in [-10..0] by 1
      @chart.validateData()
      @chart.zoomToIndexes(0, 9)

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
        legend:
          useGraphSettings: true
          autoMargins: false
          marginLeft: 40
          marginRight: 0
          fontSize: 10
          markerSize: 12
          # equalWidths: false
          # labelWidth: 70
          position: 'bottom'
          verticalGap: 5
          markerLabelGap: 5
          maxColumns: 3
          switchType: 'v'
        graphs: [
          {
            id: 'diabetic-rats-line'
            lineColor: '#ff0000'
            lineThickness: 2
            type: 'smoothedLine'
            valueField: 'diabetic'
            valueAxis: 'diabetic'
            title: 'Line'
          }
          {
            id: 'diabetic-rats-dots'
            bullet: 'round'
            bulletSize: 4
            lineColor: '#ff0000'
            lineThickness: 0
            type: 'smoothedLine'
            valueField: 'diabetic'
            valueAxis: 'diabetic'
            title: 'Points'
          }
          {
            id: 'all-rats-bar'
            type: 'column'
            lineColor: '#6666ff'
            lineAlpha: 0.6
            fillColors: '#6666ff'
            fillAlphas: 0.6
            columnWidth: 1
            clustered: false
            valueField: 'total'
            valueAxis: 'diabetic'
            title: 'Total Rats'
          }
          {
            id: 'diabetic-rats-bar'
            type: 'column'
            lineColor: '#990000'
            fillColors: '#990000'
            fillAlphas: 0.6
            columnWidth: 0.6
            clustered: false
            valueField: 'diabetic'
            valueAxis: 'diabetic'
            title: 'Diabetic Rats'
          }
        ]
        chartScrollbar:
          graph: 'diabetic-rats-bar'
          backgroundColor: '#444444'
          color: '#000000'
          # selectedBackgroundColor: '#FFFFFF'
          resizeEnabled: false
          scrollbarHeight: 15
        zoomOutButton:
          display: 'none'
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
