// Generated by CoffeeScript 1.9.1
(function() {
  var Agent, BasicAnimal, Chart, Environment, Events, Interactive, Species, ToolButton, Trait, biologicaSandratSpecies, chowSpecies, env, helpers, sandratSpecies;

  helpers = require('helpers');

  Environment = require('models/environment');

  Species = require('models/species');

  Agent = require('models/agent');

  Trait = require('models/trait');

  Interactive = require('ui/interactive');

  Events = require('events');

  ToolButton = require('ui/tool-button');

  BasicAnimal = require('models/agents/basic-animal');

  Chart = require('model/chart');

  biologicaSandratSpecies = require('species/biologica/sandrats');

  sandratSpecies = require('species/sandrats');

  chowSpecies = require('species/chow');

  env = require('environments/field');

  window.model = {
    run: function() {
      this.interactive = new Interactive({
        environment: env,
        toolButtons: [
          {
            type: ToolButton.INFO_TOOL
          }, {
            type: ToolButton.CARRY_TOOL
          }
        ]
      });
      document.getElementById('environment').appendChild(this.interactive.getEnvironmentPane());
      this.env = env;
      this.locations = {
        all: {
          x: 0,
          y: 0,
          width: this.env.width,
          height: this.env.height
        },
        w: {
          x: 0,
          y: 0,
          width: Math.round(this.env.width / 3),
          height: this.env.height
        },
        ne: {
          x: Math.round(this.env.width / 3),
          y: 0,
          width: Math.round(this.env.width / 3) * 2,
          height: Math.round(this.env.height / 2)
        },
        se: {
          x: Math.round(this.env.width / 3),
          y: Math.round(this.env.height / 2),
          width: Math.round(this.env.width / 3) * 2,
          height: Math.round(this.env.height / 2)
        }
      };
      this.setupEnvironment();
      this.isSetUp = true;
      this.stopDate = 0;
      this.secondsPerSample = 2;
      this.graphInterval = Math.ceil(this.targetFPS() * this.secondsPerSample);
      Events.addEventListener(Environment.EVENTS.RESET, (function(_this) {
        return function() {
          _this.setupEnvironment();
          return $('.time-limit-dialog').fadeOut(300);
        };
      })(this));
      return Events.addEventListener(Environment.EVENTS.STEP, (function(_this) {
        return function() {
          _this.countRatsInAreas();
          if (_this.env.date % _this.graphInterval === 1) {
            drawCharts();
          }
          if (_this.stopDate > 0 && _this.env.date > _this.stopDate) {
            _this.env.stop();
            drawCharts();
            return _this._timesUp();
          }
        };
      })(this));
    },
    targetFPS: function() {
      return 1000 / (this.env != null ? this.env._runLoopDelay : Environment.DEFAULT_RUN_LOOP_DELAY);
    },
    agentsOfSpecies: function(species) {
      var a, j, len, ref, set;
      set = [];
      ref = this.env.agents;
      for (j = 0, len = ref.length; j < len; j++) {
        a = ref[j];
        if (a.species === species) {
          set.push(a);
        }
      }
      return set;
    },
    _countRats: function(rectangle) {
      var a, data, j, len, rats;
      data = {};
      rats = (function() {
        var j, len, ref, results;
        ref = this.env.agentsWithin(rectangle);
        results = [];
        for (j = 0, len = ref.length; j < len; j++) {
          a = ref[j];
          if (a.species === sandratSpecies) {
            results.push(a);
          }
        }
        return results;
      }).call(this);
      data = {
        date: Math.floor(this.env.date / this.graphInterval) * this.secondsPerSample,
        total: rats.length,
        healthy: 0,
        diabetic: 0
      };
      for (j = 0, len = rats.length; j < len; j++) {
        a = rats[j];
        if (!a.get('has diabetes')) {
          data.healthy++;
        }
        if (a.get('has diabetes')) {
          data.diabetic++;
        }
      }
      return data;
    },
    countRatsInAreas: function() {
      if (this.isFieldModel) {
        return this.current_counts.all = this._countRats(this.locations.all);
      } else {
        this.current_counts.w = this._countRats(this.locations.w);
        this.current_counts.ne = this._countRats(this.locations.ne);
        return this.current_counts.se = this._countRats(this.locations.se);
      }
    },
    setupEnvironment: function() {
      var col, i, j, k, l, ref, ref1, ref2, row;
      for (col = j = 0, ref = this.env.columns; 0 <= ref ? j <= ref : j >= ref; col = 0 <= ref ? ++j : --j) {
        for (row = k = 0, ref1 = this.env.rows; 0 <= ref1 ? k <= ref1 : k >= ref1; row = 0 <= ref1 ? ++k : --k) {
          this.env.set(col, row, "chow", false);
        }
      }
      for (i = l = 0, ref2 = window.CONFIG.startingRats || 20; 0 <= ref2 ? l < ref2 : l > ref2; i = 0 <= ref2 ? ++l : --l) {
        this.addRat();
      }
      this.current_counts = {
        all: {
          total: 0
        },
        w: {
          total: 0
        },
        se: {
          total: 0
        },
        ne: {
          total: 0
        }
      };
      return resetAndDrawCharts();
    },
    addRat: function() {
      var loc, rat;
      loc = this.isFieldModel ? this.locations.all : this.locations.w;
      rat = sandratSpecies.createAgent();
      rat.set('age', 20 + (Math.floor(Math.random() * 40)));
      rat.setLocation(env.randomLocationWithin(loc.x, loc.y, loc.width, loc.height, true));
      return this.env.addAgent(rat);
    },
    addChow: function(n, loc) {
      var chow, i, j, ref, results;
      results = [];
      for (i = j = 0, ref = n; 0 <= ref ? j < ref : j > ref; i = 0 <= ref ? ++j : --j) {
        chow = chowSpecies.createAgent();
        chow.setLocation(env.randomLocationWithin(loc.x, loc.y, loc.width, loc.height, true));
        results.push(this.env.addAgent(chow));
      }
      return results;
    },
    removeChow: function(loc) {
      var agent, agents, j, len;
      agents = env.agentsWithin(loc);
      for (j = 0, len = agents.length; j < len; j++) {
        agent = agents[j];
        if (agent.species.speciesName === "chow") {
          agent.die();
        }
      }
      return this.env.removeDeadAgents();
    },
    setChow: function(area, chow) {
      var amount, col, j, k, loc, ref, ref1, ref2, ref3, ref4, ref5, row;
      loc = this.locations[area];
      if (loc == null) {
        return;
      }
      for (col = j = ref = loc.x, ref1 = loc.x + loc.width, ref2 = this.env._columnWidth; ref2 > 0 ? j <= ref1 : j >= ref1; col = j += ref2) {
        for (row = k = ref3 = loc.y, ref4 = loc.y + loc.height, ref5 = this.env._rowHeight; ref5 > 0 ? k <= ref4 : k >= ref4; row = k += ref5) {
          this.env.setAt(col, row, "chow", chow);
        }
      }
      if (chow) {
        amount = Math.round(loc.width * loc.height / 7000);
        return this.addChow(amount, loc);
      } else {
        return this.removeChow(loc);
      }
    },
    setStopDate: function(date) {
      return this.stopDate = date;
    },
    _timesUp: function() {
      return $('.time-limit-dialog').fadeIn(300);
    }
  };

  $(function() {
    var chart1, chart1PeriodId, chart2, chart2PeriodId, config, configDefaults, container, editing, geneInfo, graph1Location, startChartPeriod, updateAlleleFrequencies, validateConfig, validationError;
    chart1 = null;
    chart2 = null;
    model.isFieldModel = !/[^\/]*html/.exec(document.location.href) || /[^\/]*html/.exec(document.location.href)[0] === "field.html";
    model.isLifespanModel = /[^\/]*html/.exec(document.location.href) && /[^\/]*html/.exec(document.location.href)[0] === "lifespan.html";
    graph1Location = model.isFieldModel ? 'all' : 'ne';
    helpers.preload([model, env, sandratSpecies], function() {
      model.run();
      if ($('#field-chart').length > 0) {
        chart1 = new Chart(model, 'field-chart', 'diabetic', graph1Location);
      }
      if ($('#field-chart-2').length > 0) {
        return chart2 = new Chart(model, 'field-chart-2', 'diabetic', 'se');
      }
    });
    $('#view-sex-check').change(function() {
      return model.showSex = $(this).is(':checked');
    });
    $('#view-prone-check').change(function() {
      return model.showPropensity = $(this).is(':checked');
    });
    $('#view-diabetic-check').change(function() {
      return model.showDiabetic = $(this).is(':checked');
    });
    chart1PeriodId = null;
    chart2PeriodId = null;
    startChartPeriod = function(adding, chart) {
      if (chart === 1) {
        if (adding) {
          chart1PeriodId = 'chow-' + Date.now();
          return chart1 != null ? chart1.startPeriod(chart1PeriodId) : void 0;
        } else {
          return chart1 != null ? chart1.endPeriod(chart1PeriodId) : void 0;
        }
      } else {
        if (adding) {
          chart2PeriodId = 'chow-' + Date.now();
          return chart2 != null ? chart2.startPeriod(chart2PeriodId) : void 0;
        } else {
          return chart2 != null ? chart2.endPeriod(chart2PeriodId) : void 0;
        }
      }
    };
    $('.chow-toggle').click(function() {
      var adding, toggle;
      toggle = $(this);
      toggle.toggleClass('on');
      adding = toggle.hasClass('on');
      if (toggle.hasClass('all')) {
        model.setChow('all', adding);
        startChartPeriod(adding, 1);
      }
      if (toggle.hasClass('north-east')) {
        model.setChow('ne', adding);
        startChartPeriod(adding, 1);
      }
      if (toggle.hasClass('south-east')) {
        model.setChow('se', adding);
        startChartPeriod(adding, 2);
      }
      if (toggle.hasClass('west')) {
        return model.setChow('w', adding);
      }
    });
    $('#time-limit').change(function() {
      model.setStopDate($(this).val() * model.targetFPS());
      if (chart1 != null) {
        chart1.recalculateLength();
      }
      return chart2 != null ? chart2.recalculateLength() : void 0;
    });
    window.resetAndDrawCharts = function() {
      if (chart1 != null) {
        chart1.reset();
      }
      if (chart2 != null) {
        chart2.reset();
      }
      return drawCharts();
    };
    window.drawCharts = function() {
      if (chart1 != null) {
        chart1.draw();
      }
      return chart2 != null ? chart2.draw() : void 0;
    };
    configDefaults = {
      "allele frequencies": {
        DR: 1,
        drb: 4,
        DY: 1,
        dyb: 4,
        DB: 1,
        dbb: 4
      },
      startingRats: 27,
      diabetes: {
        red: {
          "none": 0,
          level1: 0.167,
          level2: 0.25
        },
        yellow: {
          "none": 0,
          level1: 0.167,
          level2: 0.25
        },
        blue: {
          "none": 0,
          level1: 0.167,
          level2: 0.25
        }
      }
    };
    window.ORIGINAL_CONFIG = window.CONFIG;
    window.CONFIG = $.extend({}, configDefaults, window.CONFIG);
    container = document.getElementById("author-json");
    if (container) {
      if (config = window.localStorage.getItem('sandrats-config')) {
        window.CONFIG = $.extend(window.CONFIG, JSON.parse(config));
      }
      window.JSON_EDITOR = new JSONEditor(container);
      window.JSON_EDITOR.set(window.CONFIG);
      geneInfo = {
        'DR': {
          gene: 'red'
        },
        'drb': {
          gene: 'red'
        },
        'DY': {
          gene: 'yellow'
        },
        'dyb': {
          gene: 'yellow'
        },
        'DB': {
          gene: 'blue'
        },
        'dbb': {
          gene: 'blue'
        }
      };
      updateAlleleFrequencies = function() {
        var allele, idx, info, ref, results;
        results = [];
        for (allele in geneInfo) {
          info = geneInfo[allele];
          if (((ref = window.CONFIG['allele frequencies']) != null ? ref[allele] : void 0) != null) {
            idx = biologicaSandratSpecies.geneList[info.gene].alleles.indexOf(allele);
            results.push(biologicaSandratSpecies.geneList[info.gene].weights[idx] = window.CONFIG['allele frequencies'][allele]);
          } else {
            results.push(void 0);
          }
        }
        return results;
      };
      updateAlleleFrequencies();
      validateConfig = function(config) {
        var allele, color, j, k, len, len1, level, ref, ref1, ref2, ref3, ref4;
        ref = ['red', 'yellow', 'blue'];
        for (j = 0, len = ref.length; j < len; j++) {
          color = ref[j];
          ref1 = ['none', 'level1', 'level2'];
          for (k = 0, len1 = ref1.length; k < len1; k++) {
            level = ref1[k];
            if ((((ref2 = config.diabetes) != null ? (ref3 = ref2[color]) != null ? ref3[level] : void 0 : void 0) != null) && !$.isNumeric(config.diabetes[color][level])) {
              validationError("diabetes." + color + "." + level + " should be a number");
              return false;
            }
          }
        }
        for (allele in geneInfo) {
          if ((((ref4 = config['allele frequencies']) != null ? ref4[allele] : void 0) != null) && !$.isNumeric(config['allele frequencies'][allele])) {
            validationError("'allele frequencies'." + allele + " should be a number");
            return false;
          }
        }
        if ((config.startingRats != null) && !$.isNumeric(config.startingRats)) {
          validationError("startingRats should be a number");
          return false;
        }
        return true;
      };
      validationError = function(error) {
        return $('.validation-feedback').addClass('error').text(error);
      };
      editing = true;
      $('#author-toggle-mode').click(function() {
        if (editing) {
          $('#author-toggle-mode').text('View Tree');
          window.JSON_EDITOR.setMode('text');
          return editing = false;
        } else {
          $('#author-toggle-mode').text('View Text');
          window.JSON_EDITOR.setMode('tree');
          return editing = true;
        }
      });
      $('#author-update').click(function() {
        var newConfig;
        newConfig = window.JSON_EDITOR.get();
        if (validateConfig(newConfig)) {
          $('.validation-feedback').removeClass('error').text('OK!');
          window.CONFIG = newConfig;
          updateAlleleFrequencies();
          return model.env.reset();
        }
      });
      $('#author-remember').click(function() {
        var newConfig;
        newConfig = window.JSON_EDITOR.get();
        if (validateConfig(newConfig)) {
          $('.validation-feedback').removeClass('error').text('OK!');
          return window.localStorage.setItem('sandrats-config', JSON.stringify(newConfig));
        }
      });
      return $('#author-reset').click(function() {
        var newConfig;
        newConfig = $.extend({}, configDefaults, window.ORIGINAL_CONFIG);
        if (validateConfig(newConfig)) {
          $('.validation-feedback').removeClass('error').text('OK!');
          return window.JSON_EDITOR.set(newConfig);
        }
      });
    }
  });

}).call(this);
