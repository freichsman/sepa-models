// Generated by CoffeeScript 1.9.1
(function() {
  require.register("model/chart", function(exports, require, module) {
    var Chart;
    Chart = Chart = (function() {
      function Chart(model1, parent, type, location) {
        this.model = model1;
        this.parent = parent;
        this.type = type;
        this.location = location;
        this._data = [];
        this.recalculateLength();
        this.reset();
        this.setupChart();
        this._idx = 0;
        return;
      }

      Chart.prototype.draw = function() {
        var newData, old, ref, ref1;
        if (!this.model.isSetUp) {
          return;
        }
        if ((this._idx === this._data.length && ((ref = this._data[this._idx - 1]) != null ? ref.date : void 0) < model.env.date) || (this._idx < this._data.length && ((ref1 = this._data[this._idx]) != null ? ref1.date : void 0) < model.env.date)) {
          newData = this.model.countRats(this.model.locations[this.location]);
          newData.color = 'hsl(0,100%,55%)';
          if (this._idx > 0) {
            this._data[this._idx - 1].color = 'hsl(0,100%,92%)';
          }
          if (this._idx === this._data.length) {
            old = this._data.shift();
            this._data.push(newData);
          } else {
            this._data[this._idx] = newData;
            this._idx++;
          }
          this.chart.validateData();
        }
      };

      Chart.prototype.reset = function() {
        var i, j, ref, ref1;
        for (i = j = 0, ref = this._data.length; 0 <= ref ? j <= ref : j >= ref; i = 0 <= ref ? ++j : --j) {
          this._data[i] = {
            date: 2 * i,
            placeholder: true
          };
        }
        return (ref1 = this.chart) != null ? ref1.validateData() : void 0;
      };

      Chart.prototype.recalculateLength = function() {
        var newLength, nextDate, ref;
        if (this.model.stopDate === 0) {
          newLength = 30;
        } else {
          newLength = Math.ceil(this.model.stopDate / this.model.graphInterval) + 1;
        }
        while (this._data.length > newLength) {
          if (this._data[this._data.length - 1].placeholder) {
            this._data.pop();
          } else {
            this._data.shift();
          }
        }
        while (this._data.length < newLength) {
          nextDate = this._data.length === 0 ? 0 : this._data[this._data.length - 1].date + 2;
          this._data.push({
            date: nextDate,
            placeholder: true
          });
        }
        return (ref = this.chart) != null ? ref.validateData() : void 0;
      };

      Chart.prototype.setupChart = function() {
        return this.chart = AmCharts.makeChart(this.parent, {
          type: 'serial',
          theme: 'light',
          marginTop: 10,
          marginRight: 0,
          marginLeft: 0,
          marginBottom: 0,
          dataProvider: this._data,
          categoryField: 'date',
          categoryAxis: {
            dashLength: 1,
            minorGridEnabled: true
          },
          graphs: [
            {
              id: 'diabetic-rats-bar',
              type: 'column',
              lineColorField: 'color',
              fillColorsField: 'color',
              colorField: 'color',
              fillAlphas: 0.6,
              columnWidth: 1,
              clustered: false,
              valueField: 'diabetic',
              valueAxis: 'diabetic',
              title: 'Diabetic Rats'
            }
          ],
          valueAxes: [
            {
              id: 'diabetic',
              title: 'Diabetic Rats',
              autoGridCount: false,
              gridCount: 5,
              minimum: 0,
              maximum: 60,
              position: 'left'
            }
          ]
        });
      };

      return Chart;

    })();
    return module.exports = Chart;
  });

}).call(this);
