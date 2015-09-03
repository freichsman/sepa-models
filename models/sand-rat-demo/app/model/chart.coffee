require.register "model/chart", (exports, require, module) ->
  Chart = class Chart

    constructor: (@model, @parent, @type, @location)->
      @_rectangles =
        all: {x: 0, y: 0, width: 600, height: 700}
        s:   {x: 0, y: 350, width: 1000, height: 350}
        nw:  {x: 0, y: 0, width: 500, height: 350}
        ne:  {x: 500, y: 0, width: 500, height: 350}

      @_data =
        all: []
        s:   []
        nw:  []
        ne:  []
      @setupChart()
      @reset()

      return

    draw: ->
      if not @model.isSetUp then return

      if @_data.length is 0 or @_data[@location][@_data[@location].length-1].date < model.env.date
        for loc in ['all','s','nw','ne']
          newData = @model.countRats(@_rectangles[loc])
          @_data[loc].push(newData)
        @chart.validateData()
        @chart.zoomToIndexes(@_data[@location].length - 11, @_data[@location].length - 1)

      return

    reset: ->
      for loc in ['all','s','nw','ne']
        @_data[loc].length = 0
        @_data[loc].push({date: i}) for i in [-10..0] by 1
      @chart.validateData()
      @chart.zoomToIndexes(0, 9)

    setType: (@type)->
      # TODO redo labels, etc

    setLocation: (@location)->
      @chart.dataProvider = @_data[@location]
      @chart.validateData()
      @chart.zoomToIndexes(@_data[@location].length - 11, @_data[@location].length - 1)

    setupChart: ->
      @chart = AmCharts.makeChart @parent,
        type: 'serial'
        theme: 'light'
        marginTop: 10
        marginRight: 0
        marginLeft: 0
        marginBottom: 0
        dataProvider: @_data[@location]
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

    # The old chart code. Currently unused, but maintained for reference
    drawChart = (chartN)->
      max = if graphLoc is "all" then 60 else if graphLoc is "s" then 40 else 30

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


  module.exports = Chart
