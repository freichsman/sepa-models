(function() {
  'use strict';

  var globals = typeof window === 'undefined' ? global : window;
  if (typeof globals.require === 'function') return;

  var modules = {};
  var cache = {};
  var aliases = {};
  var has = ({}).hasOwnProperty;

  var endsWith = function(str, suffix) {
    return str.indexOf(suffix, str.length - suffix.length) !== -1;
  };

  var _cmp = 'components/';
  var unalias = function(alias, loaderPath) {
    var start = 0;
    if (loaderPath) {
      if (loaderPath.indexOf(_cmp) === 0) {
        start = _cmp.length;
      }
      if (loaderPath.indexOf('/', start) > 0) {
        loaderPath = loaderPath.substring(start, loaderPath.indexOf('/', start));
      }
    }
    var result = aliases[alias + '/index.js'] || aliases[loaderPath + '/deps/' + alias + '/index.js'];
    if (result) {
      return _cmp + result.substring(0, result.length - '.js'.length);
    }
    return alias;
  };

  var _reg = /^\.\.?(\/|$)/;
  var expand = function(root, name) {
    var results = [], part;
    var parts = (_reg.test(name) ? root + '/' + name : name).split('/');
    for (var i = 0, length = parts.length; i < length; i++) {
      part = parts[i];
      if (part === '..') {
        results.pop();
      } else if (part !== '.' && part !== '') {
        results.push(part);
      }
    }
    return results.join('/');
  };

  var dirname = function(path) {
    return path.split('/').slice(0, -1).join('/');
  };

  var localRequire = function(path) {
    return function expanded(name) {
      var absolute = expand(dirname(path), name);
      return globals.require(absolute, path);
    };
  };

  var initModule = function(name, definition) {
    var module = {id: name, exports: {}};
    cache[name] = module;
    definition(module.exports, localRequire(name), module);
    return module.exports;
  };

  var require = function(name, loaderPath) {
    var path = expand(name, '.');
    if (loaderPath == null) loaderPath = '/';
    path = unalias(name, loaderPath);

    if (has.call(cache, path)) return cache[path].exports;
    if (has.call(modules, path)) return initModule(path, modules[path]);

    var dirIndex = expand(path, './index');
    if (has.call(cache, dirIndex)) return cache[dirIndex].exports;
    if (has.call(modules, dirIndex)) return initModule(dirIndex, modules[dirIndex]);

    throw new Error('Cannot find module "' + name + '" from '+ '"' + loaderPath + '"');
  };

  require.alias = function(from, to) {
    aliases[to] = from;
  };

  require.register = require.define = function(bundle, fn) {
    if (typeof bundle === 'object') {
      for (var key in bundle) {
        if (has.call(bundle, key)) {
          modules[key] = bundle[key];
        }
      }
    } else {
      modules[bundle] = fn;
    }
  };

  require.list = function() {
    var result = [];
    for (var item in modules) {
      if (has.call(modules, item)) {
        result.push(item);
      }
    }
    return result;
  };

  require.brunch = true;
  require._cache = cache;
  globals.require = require;
})();
require.register("model/chart", function(exports, require, module) {
var Chart, helpers,
  __hasProp = {}.hasOwnProperty;

helpers = require('helpers');

module.exports = Chart = Chart = (function() {
  function Chart(model, parent, location) {
    this.model = model;
    this.parent = parent;
    this.location = location;
    this._guides = {};
    this._data = [];
    this._timeBased = false;
    this._timeProp = null;
    this._time = 0;
  }

  Chart.prototype.setData = function(properties) {
    var i, prop, _i, _j, _len, _ref, _results, _results1;
    this.properties = properties;
    this._data = [];
    if (this.properties.length === 1 && this.properties[0].timeBased) {
      this._timeBased = true;
      this._timeProp = this.properties[0];
      _results = [];
      for (i = _i = 1; _i <= 30; i = ++_i) {
        _results.push(this._data.push({
          category: i,
          description: this._timeProp.description
        }));
      }
      return _results;
    } else {
      this._timeBased = false;
      _ref = this.properties;
      _results1 = [];
      for (_j = 0, _len = _ref.length; _j < _len; _j++) {
        prop = _ref[_j];
        _results1.push(this._data.push({
          category: prop.title,
          description: prop.description,
          count: 0,
          property: prop.property
        }));
      }
      return _results1;
    }
  };

  Chart.prototype.reset = function() {
    this.setData(this.properties);
    this.parent.innerHTML = "";
    this._time = 0;
    this._drawChart();
    return this.update();
  };

  Chart.prototype.update = function() {
    var column, datum, newData, timeChartTime, _i, _len, _ref, _ref1, _ref2;
    if (!this.model.isSetUp) {
      return;
    }
    newData = this.model.current_counts[this.location];
    if (!this._timeBased) {
      _ref = this._data;
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        column = _ref[_i];
        column.count = newData[column.property];
      }
    } else {
      this._time++;
      if (this._time % 2 !== 0) {
        return;
      }
      timeChartTime = this._time / 2;
      datum = helpers.clone(this._data[0]);
      datum.category = timeChartTime;
      datum.count = newData[this._timeProp.property];
      datum.base = -2;
      datum.color = 'hsl(0,100%,55%)';
      if (timeChartTime <= this._data.length) {
        this._data[timeChartTime - 1] = datum;
        if ((_ref1 = this._data[timeChartTime - 2]) != null) {
          _ref1.color = 'hsl(0,100%,85%)';
        }
      } else {
        this._data.shift();
        this._data.push(datum);
        if ((_ref2 = this._data[this._data.length - 2]) != null) {
          _ref2.color = 'hsl(0,100%,85%)';
        }
      }
      this._extendOpenPeriods();
    }
    return this.chart.validateData();
  };

  Chart.prototype._drawChart = function() {
    var opts;
    opts = helpers.clone(this._defaultChartProps);
    if (this._timeBased) {
      opts.valueAxes[0].title = this._timeProp.yAxis;
      opts.valueAxes[0].minimum = -2;
    }
    opts.dataProvider = this._data;
    return this.chart = AmCharts.makeChart(this.parent, opts);
  };

  Chart.prototype._defaultChartProps = {
    type: 'serial',
    theme: 'light',
    marginTop: 10,
    marginRight: 0,
    marginLeft: 0,
    marginBottom: 0,
    categoryAxis: {
      dashLength: 1,
      minorGridEnabled: true
    },
    valueAxes: [
      {
        title: 'Number of Rats',
        autoGridCount: false,
        gridCount: 6,
        showFirstLabel: false,
        strictMinMax: true,
        minimum: 0,
        maximum: Chart.location === 'all' ? 50 : 30,
        position: 'left'
      }
    ],
    categoryField: 'category',
    graphs: [
      {
        balloonText: "<b>[[value]]</b> [[description]]",
        fillAlphas: 0.8,
        lineAlpha: 0.2,
        type: "column",
        valueField: "count",
        openField: "base",
        lineColorField: 'color',
        fillColorsField: 'color',
        colorField: 'color'
      }
    ]
  };

  Chart.prototype.startPeriod = function(id) {
    var guide, _ref;
    if (!this._timeBased) {
      return;
    }
    guide = new AmCharts.Guide;
    guide.color = '#999999';
    guide.fillColor = 'hsl(200, 100%, 92%)';
    guide.fillAlpha = 0.4;
    guide.category = '' + Math.ceil(this._time / 2);
    guide.toCategory = '' + Math.ceil(this._time / 2);
    guide.expand = true;
    guide.label = 'Sugary food added';
    guide.position = 'left';
    guide.inside = true;
    guide.labelRotation = 90;
    this._guides[id] = guide;
    return (_ref = this.chart) != null ? _ref.categoryAxis.addGuide(guide) : void 0;
  };

  Chart.prototype.endPeriod = function(id) {
    return delete this._guides[id];
  };

  Chart.prototype._extendOpenPeriods = function() {
    var guide, id, leftDate, _i, _len, _ref, _ref1, _ref2, _ref3;
    if (!this._timeBased) {
      return;
    }
    _ref = this._guides;
    for (id in _ref) {
      if (!__hasProp.call(_ref, id)) continue;
      guide = _ref[id];
      guide.toCategory = '' + Math.ceil(this._time / 2);
    }
    leftDate = this._data[0].category;
    if (leftDate > 1) {
      _ref3 = (_ref1 = this.chart) != null ? (_ref2 = _ref1.categoryAxis) != null ? _ref2.guides : void 0 : void 0;
      for (_i = 0, _len = _ref3.length; _i < _len; _i++) {
        guide = _ref3[_i];
        if (guide.category < leftDate && guide.toCategory >= leftDate) {
          guide.category = leftDate;
        }
      }
    }
  };

  return Chart;

})();

module.exports = Chart;
});

;require.register("model/environment-pens", function(exports, require, module) {
var EnvRules, Environment, env;

Environment = require('models/environment');

EnvRules = require('./environment-rules');

env = new Environment({
  columns: 60,
  rows: 45,
  imgPath: "images/environments/pens.png",
  wrapEastWest: false,
  wrapNorthSouth: false,
  barriers: [[170, 0, 55, 450], [220, 200, 380, 50]]
});

EnvRules.init(env);

module.exports = env;
});

;require.register("model/environment-rules", function(exports, require, module) {
var Rule, diabetesChance, worstChance;

Rule = require('models/rule');

worstChance = 0.2;

diabetesChance = function(agent) {
  var color, colorLevel, odds, _i, _len, _ref, _ref1, _ref2, _ref3, _ref4, _ref5, _ref6, _ref7, _ref8, _ref9;
  odds = 0;
  _ref = ['red', 'yellow', 'blue'];
  for (_i = 0, _len = _ref.length; _i < _len; _i++) {
    color = _ref[_i];
    colorLevel = agent.get(color + ' diabetes');
    if (colorLevel === 'level1') {
      odds += ((_ref1 = window.CONFIG) != null ? (_ref2 = _ref1.diabetes) != null ? (_ref3 = _ref2[color]) != null ? _ref3.level1 : void 0 : void 0 : void 0) != null ? window.CONFIG.diabetes[color].level1 : 1 / 6;
    } else if (colorLevel === 'level2') {
      odds += ((_ref4 = window.CONFIG) != null ? (_ref5 = _ref4.diabetes) != null ? (_ref6 = _ref5[color]) != null ? _ref6.level2 : void 0 : void 0 : void 0) != null ? window.CONFIG.diabetes[color].level2 : 2 / 6;
    } else if (colorLevel === 'none') {
      if (((_ref7 = window.CONFIG) != null ? (_ref8 = _ref7.diabetes) != null ? (_ref9 = _ref8[color]) != null ? _ref9['none'] : void 0 : void 0 : void 0) != null) {
        odds += window.CONFIG.diabetes[color]['none'];
      }
    }
  }
  return worstChance * odds;
};

module.exports = {
  init: function(env) {
    env.addRule(new Rule({
      test: function(agent) {
        return agent.species.speciesName === "sandrats" && agent.get('chow') && agent.get('weight') < 220 && Math.random() < 0.15;
      },
      action: function(agent) {
        return agent.set('weight', agent.get('weight') + Math.floor(Math.random() * 5));
      }
    }));
    env.addRule(new Rule({
      test: function(agent) {
        return agent.species.speciesName === "sandrats" && agent.get('chow') !== true && agent.get('weight') > 155 && Math.random() < 0.15;
      },
      action: function(agent) {
        return agent.set('weight', agent.get('weight') - Math.floor(Math.random() * 5));
      }
    }));
    env.addRule(new Rule({
      test: function(agent) {
        var w;
        return agent.species.speciesName === "sandrats" && agent.get('has diabetes') !== true && agent.get('prone to diabetes') && (w = agent.get('weight')) > 170 && Math.random() < (((w - 170) / 30) * diabetesChance(agent));
      },
      action: function(agent) {
        return agent.set('has diabetes', true);
      }
    }));
    return env.addRule(new Rule({
      test: function(agent) {
        var w;
        return agent.species.speciesName === "sandrats" && agent.get('has diabetes') === true && (w = agent.get('weight')) < 170 && Math.random() < ((-(w - 170) / 20) * (worstChance - diabetesChance(agent)));
      },
      action: function(agent) {
        return agent.set('has diabetes', false);
      }
    }));
  }
};
});

;require.register("model/environment", function(exports, require, module) {
var EnvRules, Environment, env;

Environment = require('models/environment');

EnvRules = require('./environment-rules');

env = new Environment({
  columns: 60,
  rows: 45,
  imgPath: "images/environments/field.png",
  wrapEastWest: false,
  wrapNorthSouth: false
});

EnvRules.init(env);

module.exports = env;
});

;require.register("model/model", function(exports, require, module) {
var Agent, BasicAnimal, Chart, Environment, Events, Interactive, Species, ToolButton, Trait, biologicaSandratSpecies, chart1, chart2, chartTypes, chowSpecies, defaultChartTypes, env, environmentType, fastRats, fieldEnvironment, geneInfo, helpers, pensEnvironment, processConfig, resetAndDrawCharts, slowRats, updateAlleleFrequencies, updateCharts, updatePulldowns, updateTimeLimitPopup, _ref;

helpers = require('helpers');

Environment = require('models/environment');

Environment = require('models/environment');

Species = require('models/species');

Agent = require('models/agent');

Trait = require('models/trait');

Interactive = require('ui/interactive');

Events = require('events');

ToolButton = require('ui/tool-button');

BasicAnimal = require('models/agents/basic-animal');

Chart = require('./chart');

biologicaSandratSpecies = require('../species/biologica/sandrats');

fastRats = require('../species/sandrats');

slowRats = require('../species/sandrats-long-life');

chowSpecies = require('../species/chow');

pensEnvironment = require('./environment-pens');

fieldEnvironment = require('./environment');

environmentType = ((_ref = window.CONFIG) != null ? _ref.environment : void 0) != null ? window.CONFIG.environment : "pens";

env = (function() {
  switch (environmentType) {
    case "pens":
      return pensEnvironment;
    case "field":
      return fieldEnvironment;
  }
})();

window.model = {
  run: function() {
    var agent, _i, _ref1, _ref2,
      _this = this;
    environmentType = ((_ref1 = window.CONFIG) != null ? _ref1.environment : void 0) != null ? window.CONFIG.environment : "pens";
    env = (function() {
      switch (environmentType) {
        case "pens":
          return pensEnvironment;
        case "field":
          return fieldEnvironment;
      }
    })();
    _ref2 = env.agents;
    for (_i = _ref2.length - 1; _i >= 0; _i += -1) {
      agent = _ref2[_i];
      env.removeAgent(agent);
    }
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
    this.secondsPerSample = 1;
    this.graphInterval = Math.ceil(this.targetFPS() * this.secondsPerSample);
    Events.addEventListener(Environment.EVENTS.RESET, function() {
      _this.setupEnvironment();
      $('.time-limit-dialog').fadeOut(300);
      $('.chow-toggle').removeClass('on');
      return resetAndDrawCharts();
    });
    Events.addEventListener(Environment.EVENTS.START, function() {
      return $('.time-limit-dialog').fadeOut(300);
    });
    return Events.addEventListener(Environment.EVENTS.STEP, function() {
      _this.countRatsInAreas();
      if (_this.env.date % _this.graphInterval === 1) {
        updateCharts();
      }
      if (_this.stopDate > 0 && _this.env.date === _this.stopDate) {
        _this.env.stop();
        updateCharts();
        return _this._timesUp();
      }
    });
  },
  targetFPS: function() {
    return 1000 / (this.env != null ? this.env._runLoopDelay : Environment.DEFAULT_RUN_LOOP_DELAY);
  },
  agentsOfSpecies: function(species) {
    var a, set, _i, _len, _ref1;
    set = [];
    _ref1 = this.env.agents;
    for (_i = 0, _len = _ref1.length; _i < _len; _i++) {
      a = _ref1[_i];
      if (a.species === species) {
        set.push(a);
      }
    }
    return set;
  },
  _countRats: function(rectangle) {
    var a, data, rats, weight, _i, _len;
    data = {};
    rats = (function() {
      var _i, _len, _ref1, _results;
      _ref1 = this.env.agentsWithin(rectangle);
      _results = [];
      for (_i = 0, _len = _ref1.length; _i < _len; _i++) {
        a = _ref1[_i];
        if (a.species === this.sandratSpecies) {
          _results.push(a);
        }
      }
      return _results;
    }).call(this);
    data = {
      date: Math.floor(this.env.date / this.graphInterval) * this.secondsPerSample,
      total: rats.length,
      healthy: 0,
      diabetic: 0,
      prone: 0,
      notProne: 0,
      thin: 0,
      medium: 0,
      obese: 0
    };
    for (_i = 0, _len = rats.length; _i < _len; _i++) {
      a = rats[_i];
      if (a.get('has diabetes')) {
        data.diabetic++;
      } else {
        data.healthy++;
      }
      if (a.get('prone to diabetes')) {
        data.prone++;
      } else {
        data.notProne++;
      }
      weight = Math.floor(a.get('weight') / 10) * 10;
      if (weight < 160) {
        data.thin++;
      } else if (weight < 180) {
        data.medium++;
      } else {
        data.obese++;
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
    var col, row, speciesType, _i, _j, _ref1, _ref2, _ref3, _ref4;
    for (col = _i = 0, _ref1 = this.env.columns; 0 <= _ref1 ? _i <= _ref1 : _i >= _ref1; col = 0 <= _ref1 ? ++_i : --_i) {
      for (row = _j = 0, _ref2 = this.env.rows; 0 <= _ref2 ? _j <= _ref2 : _j >= _ref2; row = 0 <= _ref2 ? ++_j : --_j) {
        this.env.set(col, row, "chow", false);
      }
    }
    speciesType = ((_ref3 = window.CONFIG) != null ? _ref3.species : void 0) != null ? window.CONFIG.species : "fast";
    this.sandratSpecies = speciesType === "fast" ? fastRats : slowRats;
    this.addRats();
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
    if (((_ref4 = window.CONFIG) != null ? _ref4.timeLimit : void 0) != null) {
      this.stopDate = Math.ceil(window.CONFIG.timeLimit * model.targetFPS());
    }
    return resetAndDrawCharts();
  },
  addRats: function() {
    var alleles, quantity, specifiedTraits, traits, _i, _j, _len, _ref1, _ref2, _ref3, _results;
    specifiedTraits = [];
    if (((_ref1 = window.CONFIG) != null ? _ref1.populationGenetics : void 0) != null) {
      _ref2 = window.CONFIG.populationGenetics;
      for (alleles in _ref2) {
        quantity = _ref2[alleles];
        traits = this.createTraits(alleles);
        for (_i = 0; 0 <= quantity ? _i < quantity : _i > quantity; 0 <= quantity ? _i++ : _i--) {
          specifiedTraits.push(traits);
        }
      }
    }
    if (((_ref3 = window.CONFIG) != null ? _ref3.startingRats : void 0) != null) {
      while (specifiedTraits.length < window.CONFIG.startingRats) {
        specifiedTraits.push([]);
      }
    }
    _results = [];
    for (_j = 0, _len = specifiedTraits.length; _j < _len; _j++) {
      traits = specifiedTraits[_j];
      _results.push(this.addRat(traits));
    }
    return _results;
  },
  createTraits: function(alleles) {
    var blueAlleles, m, re, redAlleles, traits, yellowAlleles;
    console.log("creating traits from " + alleles);
    traits = [];
    redAlleles = [];
    yellowAlleles = [];
    blueAlleles = [];
    re = /[ab]:[^,]*/g;
    while ((m = re.exec(alleles)) !== null) {
      if (~m[0].search(/dr/i)) {
        redAlleles.push(m[0]);
      }
      if (~m[0].search(/dy/i)) {
        yellowAlleles.push(m[0]);
      }
      if (~m[0].search(/db/i)) {
        blueAlleles.push(m[0]);
      }
    }
    if (redAlleles.length) {
      traits.push(new Trait({
        name: "red diabetes",
        "default": redAlleles.join(","),
        isGenetic: true
      }));
    }
    if (yellowAlleles.length) {
      traits.push(new Trait({
        name: "yellow diabetes",
        "default": yellowAlleles.join(","),
        isGenetic: true
      }));
    }
    if (blueAlleles.length) {
      traits.push(new Trait({
        name: "blue diabetes",
        "default": blueAlleles.join(","),
        isGenetic: true
      }));
    }
    return traits;
  },
  addRat: function(traits) {
    var loc, rat;
    loc = this.isFieldModel ? this.locations.all : this.locations.w;
    rat = this.sandratSpecies.createAgent(traits);
    rat.set('age', 20 + (Math.floor(Math.random() * 40)));
    rat.setLocation(env.randomLocationWithin(loc.x, loc.y, loc.width, loc.height, true));
    return this.env.addAgent(rat);
  },
  addChow: function(n, loc) {
    var chow, i, _i, _results;
    _results = [];
    for (i = _i = 0; 0 <= n ? _i < n : _i > n; i = 0 <= n ? ++_i : --_i) {
      chow = chowSpecies.createAgent();
      chow.setLocation(env.randomLocationWithin(loc.x, loc.y, loc.width, loc.height, true));
      _results.push(this.env.addAgent(chow));
    }
    return _results;
  },
  removeChow: function(loc) {
    var agent, agents, _i, _len;
    agents = env.agentsWithin(loc);
    for (_i = 0, _len = agents.length; _i < _len; _i++) {
      agent = agents[_i];
      if (agent.species.speciesName === "chow") {
        agent.die();
      }
    }
    return this.env.removeDeadAgents();
  },
  setChow: function(area, chow) {
    var amount, col, loc, row, _i, _j, _ref1, _ref2, _ref3, _ref4, _ref5, _ref6;
    loc = this.locations[area];
    if (loc == null) {
      return;
    }
    for (col = _i = _ref1 = loc.x, _ref2 = loc.x + loc.width, _ref3 = this.env._columnWidth; _ref3 > 0 ? _i <= _ref2 : _i >= _ref2; col = _i += _ref3) {
      for (row = _j = _ref4 = loc.y, _ref5 = loc.y + loc.height, _ref6 = this.env._rowHeight; _ref6 > 0 ? _j <= _ref5 : _j >= _ref5; row = _j += _ref6) {
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
  _timesUp: function() {
    return $('.time-limit-dialog').fadeIn(300);
  }
};

chart1 = null;

chart2 = null;

resetAndDrawCharts = function() {
  if (chart1 != null) {
    chart1.reset();
  }
  return chart2 != null ? chart2.reset() : void 0;
};

updateCharts = function() {
  if (chart1 != null) {
    chart1.update();
  }
  return chart2 != null ? chart2.update() : void 0;
};

chartTypes = {
  diabetes: [
    {
      property: "diabetic",
      title: "Diabetic Rats",
      description: "rats with diabetes"
    }, {
      property: "healthy",
      title: "Healthy Rats",
      description: "healthy rats"
    }
  ],
  risk: [
    {
      property: "prone",
      title: "Risk of diabetes",
      description: "at risk of diabetes"
    }, {
      property: "notProne",
      title: "No risk of diabetes",
      description: "with no risk of diabetes"
    }
  ],
  weight: [
    {
      property: "thin",
      title: "Thin",
      description: "thin rats"
    }, {
      property: "medium",
      title: "Heavy",
      description: "heavy rats"
    }, {
      property: "obese",
      title: "Obese",
      description: "obese rats"
    }
  ],
  diabetesTime: [
    {
      property: "diabetic",
      timeBased: true,
      description: "rats with diabetes",
      yAxis: "Rats with diabetes"
    }
  ]
};

defaultChartTypes = ["diabetes", "weight", "risk", "diabetesTime"];

updatePulldowns = function() {
  var authoredOptions, createSelectOption, option, options, _i, _len, _ref1, _ref2;
  $('#chart-1-selector').html("");
  $('#chart-2-selector').html("");
  options = {
    diabetes: "Sand Rats with Diabetes",
    weight: "Weight of Sand Rats",
    risk: "Risk of Diabetes",
    diabetesTime: "Diabetes over time"
  };
  if (((_ref1 = window.CONFIG) != null ? (_ref2 = _ref1.chart) != null ? _ref2.options : void 0 : void 0) != null) {
    authoredOptions = window.CONFIG.chart.options;
  } else {
    authoredOptions = defaultChartTypes;
  }
  createSelectOption = function(opt) {
    return $("<option value='" + opt + "'>" + options[opt] + "</option>");
  };
  for (_i = 0, _len = authoredOptions.length; _i < _len; _i++) {
    option = authoredOptions[_i];
    $('#chart-1-selector').append(createSelectOption(option));
    $('#chart-2-selector').append(createSelectOption(option));
  }
  if (chart1 != null) {
    chart1.setData(chartTypes[authoredOptions[0]]);
  }
  if (chart2 != null) {
    chart2.setData(chartTypes[authoredOptions[0]]);
  }
  resetAndDrawCharts();
  if (authoredOptions.length < 2) {
    $('#chart-1-selector').hide();
    return $('#chart-2-selector').hide();
  }
};

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
  var allele, idx, info, _ref1, _results;
  _results = [];
  for (allele in geneInfo) {
    info = geneInfo[allele];
    if (((_ref1 = window.CONFIG['allele frequencies']) != null ? _ref1[allele] : void 0) != null) {
      idx = biologicaSandratSpecies.geneList[info.gene].alleles.indexOf(allele);
      _results.push(biologicaSandratSpecies.geneList[info.gene].weights[idx] = window.CONFIG['allele frequencies'][allele]);
    } else {
      _results.push(void 0);
    }
  }
  return _results;
};

updateTimeLimitPopup = function() {
  var message, _i, _len, _ref1, _ref2, _ref3, _results;
  console.log("will do");
  if (((_ref1 = window.CONFIG) != null ? _ref1.timeLimitTitle : void 0) != null) {
    console.log("setting title to " + window.CONFIG.timeLimitTitle);
    $(".time-limit-dialog>.title").html(window.CONFIG.timeLimitTitle);
  }
  if ((((_ref2 = window.CONFIG) != null ? _ref2.timeLimitMessage : void 0) != null) && window.CONFIG.timeLimitMessage.length) {
    $(".time-limit-dialog>.content").html("");
    _ref3 = window.CONFIG.timeLimitMessage;
    _results = [];
    for (_i = 0, _len = _ref3.length; _i < _len; _i++) {
      message = _ref3[_i];
      _results.push($(".time-limit-dialog>.content").append($("<div>" + message + "</div>")));
    }
    return _results;
  }
};

processConfig = function() {
  updateAlleleFrequencies();
  updatePulldowns();
  return updateTimeLimitPopup();
};

$(function() {
  var chart1PeriodId, chart2PeriodId, config, configDefaults, container, editing, graph1Location, startChartPeriod, validateConfig, validationError;
  model.isFieldModel = !/[^\/]*html/.exec(document.location.href) || /[^\/]*html/.exec(document.location.href)[0] === "field.html";
  graph1Location = model.isFieldModel ? 'all' : 'ne';
  helpers.preload([model, env, fastRats, slowRats], function() {
    var type, _ref1, _ref2, _ref3, _ref4;
    model.run();
    if ($('#field-chart').length > 0) {
      chart1 = new Chart(model, 'field-chart', graph1Location);
      type = ((_ref1 = window.CONFIG) != null ? (_ref2 = _ref1.chart) != null ? _ref2.options : void 0 : void 0) != null ? window.CONFIG.chart.options[0] : defaultChartTypes[0];
      chart1.setData(chartTypes[type]);
      chart1.reset();
    }
    if ($('#field-chart-2').length > 0) {
      chart2 = new Chart(model, 'field-chart-2', 'se');
      type = ((_ref3 = window.CONFIG) != null ? (_ref4 = _ref3.chart) != null ? _ref4.options : void 0 : void 0) != null ? window.CONFIG.chart.options[0] : defaultChartTypes[0];
      chart2.setData(chartTypes[type]);
      return chart2.reset();
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
    if (chart1 != null) {
      chart1.recalculateLength();
    }
    return chart2 != null ? chart2.recalculateLength() : void 0;
  });
  $('#chart-1-selector').change(function() {
    chart1.setData(chartTypes[this.value]);
    return chart1.reset();
  });
  $('#chart-2-selector').change(function() {
    chart2.setData(chartTypes[this.value]);
    return chart2.reset();
  });
  configDefaults = {
    populationGenetics: {
      "a:DR,b:DR": 2,
      "a:DR,a:DY,a:dbb,b:dbb": 2
    },
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
    },
    chart: {
      options: ["diabetes", "weight", "risk", "diabetesTime"]
    },
    timeLimit: 30,
    timeLimitTitle: "Times up!",
    timeLimitMessage: ["What happened to the rats in the pens?", "Hit reset to run the model again."]
  };
  window.ORIGINAL_CONFIG = window.CONFIG;
  window.CONFIG = $.extend({}, configDefaults, window.CONFIG);
  processConfig();
  container = document.getElementById("author-json");
  if (container) {
    if (config = window.localStorage.getItem('sandrats-config')) {
      window.CONFIG = $.extend(window.CONFIG, JSON.parse(config));
    }
    window.JSON_EDITOR = new JSONEditor(container);
    window.JSON_EDITOR.set(window.CONFIG);
    validateConfig = function(config) {
      var allele, color, level, _i, _j, _len, _len1, _ref1, _ref2, _ref3, _ref4, _ref5;
      _ref1 = ['red', 'yellow', 'blue'];
      for (_i = 0, _len = _ref1.length; _i < _len; _i++) {
        color = _ref1[_i];
        _ref2 = ['none', 'level1', 'level2'];
        for (_j = 0, _len1 = _ref2.length; _j < _len1; _j++) {
          level = _ref2[_j];
          if ((((_ref3 = config.diabetes) != null ? (_ref4 = _ref3[color]) != null ? _ref4[level] : void 0 : void 0) != null) && !$.isNumeric(config.diabetes[color][level])) {
            validationError("diabetes." + color + "." + level + " should be a number");
            return false;
          }
        }
      }
      for (allele in geneInfo) {
        if ((((_ref5 = config['allele frequencies']) != null ? _ref5[allele] : void 0) != null) && !$.isNumeric(config['allele frequencies'][allele])) {
          validationError("'allele frequencies'." + allele + " should be a number");
          return false;
        }
      }
      if ((config.startingRats != null) && !$.isNumeric(config.startingRats)) {
        validationError("startingRats should be a number");
        return false;
      }
      if (config.chart != null) {
        if ((config.chart.bars != null) && !$.isNumeric(config.chart.bars)) {
          validationError("chart.bars should be a number");
          return false;
        }
        if ((config.chart.barWidth != null) && !$.isNumeric(config.chart.barWidth)) {
          validationError("chart.barWidth should be a number");
          return false;
        }
        if ((config.chart.connectingLine != null) && $.type(config.chart.connectingLine) !== 'boolean') {
          validationError("chart.connectingLine should be true or false");
          return false;
        }
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
        processConfig();
        document.getElementById('environment').innerHTML = "";
        return model.run();
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
});

;require.register("species/biologica/sandrats", function(exports, require, module) {
var genes,
  __hasProp = {}.hasOwnProperty,
  __indexOf = [].indexOf || function(item) { for (var i = 0, l = this.length; i < l; i++) { if (i in this && this[i] === item) return i; } return -1; };

console.log("hi?");

BioLogica.Genetics.prototype.getRandomAllele = function(exampleOfGene) {
  var allelesOfGene, curMax, gene, i, rand, totWeights, weight, _allelesOfGene, _i, _len, _ref, _weightsOfGene;
  _ref = this.species.geneList;
  for (gene in _ref) {
    if (!__hasProp.call(_ref, gene)) continue;
    _allelesOfGene = this.species.geneList[gene].alleles;
    _weightsOfGene = this.species.geneList[gene].weights || [];
    if (__indexOf.call(_allelesOfGene, exampleOfGene) >= 0) {
      allelesOfGene = _allelesOfGene;
      break;
    }
  }
  if (_weightsOfGene.length) {
    while (_weightsOfGene.length < allelesOfGene.length) {
      _weightsOfGene[_weightsOfGene.length] = 0;
    }
  } else {
    while (_weightsOfGene.length < allelesOfGene.length) {
      _weightsOfGene[_weightsOfGene.length] = 1;
    }
  }
  totWeights = _weightsOfGene.reduce((function(prev, cur) {
    return prev + cur;
  }), 0);
  rand = Math.random() * totWeights;
  curMax = 0;
  for (i = _i = 0, _len = _weightsOfGene.length; _i < _len; i = ++_i) {
    weight = _weightsOfGene[i];
    curMax += weight;
    if (rand <= curMax) {
      return allelesOfGene[i];
    }
  }
  if (console.error != null) {
    console.error('somehow did not pick one: ' + allelesOfGene[0]);
  }
  return allelesOfGene[0];
};

genes = [
  {
    dominant: 'DR',
    recessive: 'drb'
  }, {
    dominant: 'DR',
    recessive: 'drb'
  }, {
    dominant: 'DY',
    recessive: 'dyb'
  }, {
    dominant: 'DY',
    recessive: 'dyb'
  }, {
    dominant: 'DB',
    recessive: 'dbb'
  }, {
    dominant: 'DB',
    recessive: 'dbb'
  }
];

module.exports = {
  name: 'Sandrats',
  woo: 'hi!',
  chromosomeNames: ['1', '2', 'XY'],
  chromosomeGeneMap: {
    '1': ['DR'],
    '2': ['DY', 'DB'],
    'XY': []
  },
  chromosomesLength: {
    '1': 100000000,
    '2': 100000000,
    'XY': 70000000
  },
  geneList: {
    'red': {
      alleles: ['DR', 'drb'],
      weights: [0.2, 0.8],
      start: 10000000,
      length: 10584
    },
    'yellow': {
      alleles: ['DY', 'dyb'],
      weights: [0.2, 0.8],
      start: 10000000,
      length: 8882
    },
    'blue': {
      alleles: ['DB', 'dbb'],
      weights: [0.2, 0.8],
      start: 600000000,
      length: 5563
    }
  },
  alleleLabelMap: {
    'DR': 'Red',
    'DY': 'Yellow',
    'DB': 'Blue',
    'drb': 'Black',
    'dyb': 'Black',
    'dbb': 'Black',
    'Y': 'Y',
    '': ''
  },
  traitRules: {
    'red diabetes': {
      'none': [['drb', 'drb']],
      'level1': [['DR', 'drb']],
      'level2': [['DR', 'DR']]
    },
    'yellow diabetes': {
      'none': [['dyb', 'dyb']],
      'level1': [['DY', 'dyb']],
      'level2': [['DY', 'DY']]
    },
    'blue diabetes': {
      'none': [['dbb', 'dbb']],
      'level1': [['DB', 'dbb']],
      'level2': [['DB', 'DB']]
    }
  },
  /*
    Images are handled via the populations.js species
  */

  getImageName: function(org) {
    return void 0;
  },
  /*
    no lethal characteristics
  */

  makeAlive: function(org) {
    return void 0;
  }
};
});

;require.register("species/chow", function(exports, require, module) {
var Chow, Inanimate, Species, _ref,
  __hasProp = {}.hasOwnProperty,
  __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

Species = require('models/species');

Inanimate = require('models/inanimate');

Chow = (function(_super) {
  __extends(Chow, _super);

  function Chow() {
    _ref = Chow.__super__.constructor.apply(this, arguments);
    return _ref;
  }

  Chow.prototype.canShowInfo = function() {
    return false;
  };

  return Chow;

})(Inanimate);

module.exports = new Species({
  speciesName: "chow",
  agentClass: Chow,
  defs: {},
  traits: [],
  imageRules: [
    {
      name: 'plus one',
      contexts: ['environment'],
      rules: [
        {
          image: {
            path: "images/agents/chow.png",
            scale: 0.5,
            anchor: {
              x: 0.5,
              y: 1
            }
          }
        }
      ]
    }
  ]
});
});

;require.register("species/sandrats-long-life", function(exports, require, module) {
var AnimatedAgent, BasicAnimal, SandRat, Species, Trait, biologicaSpecies, helpers, _ref,
  __hasProp = {}.hasOwnProperty,
  __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

helpers = require('helpers');

Species = require('models/species');

BasicAnimal = require('models/agents/basic-animal');

AnimatedAgent = require('models/agents/animated-agent');

Trait = require('models/trait');

biologicaSpecies = require('./biologica/sandrats');

if (window.orgNumber == null) {
  window.orgNumber = 1;
}

SandRat = (function(_super) {
  __extends(SandRat, _super);

  function SandRat() {
    _ref = SandRat.__super__.constructor.apply(this, arguments);
    return _ref;
  }

  SandRat.prototype.label = 'Sand Rat';

  SandRat.prototype.moving = false;

  SandRat.prototype.moveCount = 0;

  SandRat.prototype.step = function() {
    var overcrowded;
    this.wander();
    this._incrementAge();
    if (this.get('age') > this.species.defs.MATURITY_AGE) {
      this.set('current behavior', BasicAnimal.BEHAVIOR.MATING);
    }
    overcrowded = false;
    if (!this._isInPensModel) {
      overcrowded = model.current_counts.all.total > 46;
    } else {
      if (this._x < model.env.width / 3) {
        overcrowded = model.current_counts.w.total > 30;
      } else if (this._y < model.env.height / 2) {
        overcrowded = model.current_counts.ne.total > 30;
      } else {
        overcrowded = model.current_counts.se.total > 30;
      }
    }
    if (!overcrowded && this.get('age') > 650 && this.get('sex') === 'male' && this._timeLastMated < 0 && Math.random() < 0.3) {
      this.mate();
    }
    if (this.get('age') > 700 && this._timeLastMated > 0) {
      this.die();
    }
    if (overcrowded && this.get('age') > 750 && Math.random() < 0.2) {
      this.die();
    }
    if (this.get('age') > 1000 && Math.random() < 0.2) {
      return this.die();
    }
  };

  SandRat.prototype.makeNewborn = function() {
    var sex;
    SandRat.__super__.makeNewborn.call(this);
    sex = model.env.agents.length && model.env.agents[model.env.agents.length - 1].species.speciesName === "sandrats" && model.env.agents[model.env.agents.length - 1].get("sex") === "female" ? "male" : "female";
    this.set('sex', sex);
    this.set('age', 15);
    this.set('weight', 140 + Math.floor(Math.random() * 10));
    this.set('has diabetes', false);
    return this._isInPensModel = model.env.barriers.length > 0;
  };

  SandRat.prototype.mate = function() {
    var max, nearest;
    nearest = this._nearestMate();
    if (nearest != null) {
      this.chase(nearest);
      if (nearest.distanceSq < Math.pow(this.get('mating distance'), 2) && ((this.species.defs.CHANCE_OF_MATING == null) || Math.random() < this.species.defs.CHANCE_OF_MATING)) {
        max = this.get('max offspring');
        this.set('max offspring', Math.max(max, 1));
        this.reproduce(nearest.agent);
        this.set('max offspring', max);
        this._timeLastMated = this.environment.date;
        return nearest.agent._timeLastMated = this.environment.date;
      }
    } else {
      return this.wander(this.get('speed') * Math.random() * 0.75);
    }
  };

  SandRat.prototype.resetGeneticTraits = function() {
    SandRat.__super__.resetGeneticTraits.call(this);
    this.set('genome', this._genomeButtonsString());
    return this.set('prone to diabetes', this.get('red diabetes') !== 'none' || this.get('yellow diabetes') !== 'none' || this.get('blue diabetes') !== 'none');
  };

  SandRat.prototype._genomeButtonsString = function() {
    var alleles;
    alleles = this.organism.getAlleleString().replace(/a:/g, '').replace(/b:/g, '').replace(/,/g, '');
    alleles = alleles.replace(/d[ryb]b/g, '<span class="allele black"></span>');
    alleles = alleles.replace(/DR/g, '<span class="allele red"></span>');
    alleles = alleles.replace(/DY/g, '<span class="allele yellow"></span>');
    alleles = alleles.replace(/DB/g, '<span class="allele blue"></span>');
    return alleles;
  };

  return SandRat;

})(BasicAnimal);

module.exports = new Species({
  speciesName: "sandrats",
  agentClass: SandRat,
  geneticSpecies: biologicaSpecies,
  defs: {
    CHANCE_OF_MUTATION: 0,
    INFO_VIEW_SCALE: 2,
    MATURITY_AGE: 80,
    INFO_VIEW_PROPERTIES: {
      "Weight (g):": 'weight',
      "": 'genome'
    }
  },
  traits: [
    new Trait({
      name: 'speed',
      "default": 6
    }), new Trait({
      name: 'vision distance',
      "default": 10000
    }), new Trait({
      name: 'mating distance',
      "default": 10000
    }), new Trait({
      name: 'max offspring',
      "default": 3
    }), new Trait({
      name: 'min offspring',
      "default": 2
    }), new Trait({
      name: 'weight',
      min: 140,
      max: 160
    }), new Trait({
      name: 'prone to diabetes',
      "default": false
    }), new Trait({
      name: 'red diabetes',
      possibleValues: [''],
      isGenetic: true,
      isNumeric: false
    }), new Trait({
      name: 'yellow diabetes',
      possibleValues: [''],
      isGenetic: true,
      isNumeric: false
    }), new Trait({
      name: 'blue diabetes',
      possibleValues: [''],
      isGenetic: true,
      isNumeric: false
    }), new Trait({
      name: 'has diabetes',
      "default": false
    })
  ],
  imageProperties: {
    initialFlipDirection: "right"
  },
  imageRules: [
    {
      name: 'diabetic',
      contexts: ['environment'],
      rules: [
        {
          image: {
            path: "images/agents/diabetic-stack.png",
            scale: 0.4,
            anchor: {
              x: 0.5,
              y: 0.7
            }
          },
          useIf: function(agent) {
            return model.showDiabetic && agent.get('has diabetes');
          }
        }
      ]
    }, {
      name: 'prone',
      contexts: ['environment'],
      rules: [
        {
          image: {
            path: "images/agents/prone-stack.png",
            scale: 0.4,
            anchor: {
              x: 0.5,
              y: 0.7
            }
          },
          useIf: function(agent) {
            return model.showPropensity && agent.get('prone to diabetes');
          }
        }
      ]
    }, {
      name: 'sex',
      contexts: ['environment'],
      rules: [
        {
          image: {
            path: "images/agents/female-stack.png",
            scale: 0.4,
            anchor: {
              x: 0.5,
              y: 0.7
            }
          },
          useIf: function(agent) {
            return model.showSex && agent.get('sex') === 'male';
          }
        }, {
          image: {
            path: "images/agents/male-stack.png",
            scale: 0.4,
            anchor: {
              x: 0.5,
              y: 0.7
            }
          },
          useIf: function(agent) {
            return model.showSex && agent.get('sex') === 'female';
          }
        }
      ]
    }, {
      name: 'rats',
      contexts: ['environment', 'carry-tool'],
      rules: [
        {
          image: {
            path: "images/agents/sandrat-obese.png",
            scale: 0.9,
            anchor: {
              x: 0.6,
              y: 0.9
            }
          },
          useIf: function(agent) {
            return agent.get('weight') > 180;
          }
        }, {
          image: {
            path: "images/agents/sandrat-skinny.png",
            scale: 0.8,
            anchor: {
              x: 0.6,
              y: 0.9
            }
          }
        }
      ]
    }, {
      name: 'rats info tool',
      contexts: ['info-tool'],
      rules: [
        {
          image: {
            path: "images/agents/sandrat-obese.png",
            scale: 0.9,
            anchor: {
              x: 0.6,
              y: 0.9
            }
          },
          useIf: function(agent) {
            return agent.get('weight') > 180;
          }
        }, {
          image: {
            path: "images/agents/sandrat-skinny.png",
            scale: 0.8,
            anchor: {
              x: 0.6,
              y: 0.9
            }
          }
        }
      ]
    }
  ]
});
});

;require.register("species/sandrats", function(exports, require, module) {
var AnimatedAgent, BasicAnimal, SandRat, Species, Trait, biologicaSpecies, helpers, _ref,
  __hasProp = {}.hasOwnProperty,
  __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

helpers = require('helpers');

Species = require('models/species');

BasicAnimal = require('models/agents/basic-animal');

AnimatedAgent = require('models/agents/animated-agent');

Trait = require('models/trait');

biologicaSpecies = require('./biologica/sandrats');

if (window.orgNumber == null) {
  window.orgNumber = 1;
}

SandRat = (function(_super) {
  __extends(SandRat, _super);

  function SandRat() {
    _ref = SandRat.__super__.constructor.apply(this, arguments);
    return _ref;
  }

  SandRat.prototype.label = 'Sand Rat';

  SandRat.prototype.moving = false;

  SandRat.prototype.moveCount = 0;

  SandRat.prototype.step = function() {
    var overcrowded;
    this.wander();
    this._incrementAge();
    if (this.get('age') > this.species.defs.MATURITY_AGE) {
      this.set('current behavior', BasicAnimal.BEHAVIOR.MATING);
    }
    overcrowded = false;
    if (!this._isInPensModel) {
      overcrowded = model.current_counts.all.total > 46;
    } else {
      if (this._x < model.env.width / 3) {
        overcrowded = model.current_counts.w.total > 30;
      } else if (this._y < model.env.height / 2) {
        overcrowded = model.current_counts.ne.total > 30;
      } else {
        overcrowded = model.current_counts.se.total > 30;
      }
    }
    if (!overcrowded && this.get('age') > 170 && this.get('sex') === 'male' && this._timeLastMated < 0 && Math.random() < 0.3) {
      this.mate();
    }
    if (this.get('age') > 180 && this._timeLastMated > 0) {
      this.die();
    }
    if (overcrowded && this.get('age') > 250 && Math.random() < 0.2) {
      this.die();
    }
    if (this.get('age') > 400 && Math.random() < 0.2) {
      return this.die();
    }
  };

  SandRat.prototype.makeNewborn = function() {
    var sex;
    SandRat.__super__.makeNewborn.call(this);
    sex = model.env.agents.length && model.env.agents[model.env.agents.length - 1].species.speciesName === "sandrats" && model.env.agents[model.env.agents.length - 1].get("sex") === "female" ? "male" : "female";
    this.set('sex', sex);
    this.set('age', Math.floor(Math.random() * 80));
    this.set('weight', 140 + Math.floor(Math.random() * 20));
    this.set('has diabetes', false);
    return this._isInPensModel = model.env.barriers.length > 0;
  };

  SandRat.prototype.mate = function() {
    var max, nearest;
    nearest = this._nearestMate();
    if (nearest != null) {
      this.chase(nearest);
      if (nearest.distanceSq < Math.pow(this.get('mating distance'), 2) && ((this.species.defs.CHANCE_OF_MATING == null) || Math.random() < this.species.defs.CHANCE_OF_MATING)) {
        max = this.get('max offspring');
        this.set('max offspring', Math.max(max, 1));
        this.reproduce(nearest.agent);
        this.set('max offspring', max);
        this._timeLastMated = this.environment.date;
        return nearest.agent._timeLastMated = this.environment.date;
      }
    } else {
      return this.wander(this.get('speed') * Math.random() * 0.75);
    }
  };

  SandRat.prototype.resetGeneticTraits = function() {
    SandRat.__super__.resetGeneticTraits.call(this);
    this.set('genome', this._genomeButtonsString());
    return this.set('prone to diabetes', this.get('red diabetes') !== 'none' || this.get('yellow diabetes') !== 'none' || this.get('blue diabetes') !== 'none');
  };

  SandRat.prototype._genomeButtonsString = function() {
    var alleles;
    alleles = this.organism.getAlleleString().replace(/a:/g, '').replace(/b:/g, '').replace(/,/g, '');
    alleles = alleles.replace(/d[ryb]b/g, '<span class="allele black"></span>');
    alleles = alleles.replace(/DR/g, '<span class="allele red"></span>');
    alleles = alleles.replace(/DY/g, '<span class="allele yellow"></span>');
    alleles = alleles.replace(/DB/g, '<span class="allele blue"></span>');
    return alleles;
  };

  return SandRat;

})(BasicAnimal);

module.exports = new Species({
  speciesName: "sandrats",
  agentClass: SandRat,
  geneticSpecies: biologicaSpecies,
  defs: {
    CHANCE_OF_MUTATION: 0,
    INFO_VIEW_SCALE: 2,
    MATURITY_AGE: 20,
    INFO_VIEW_PROPERTIES: {
      "Weight (g):": 'weight',
      "": 'genome'
    }
  },
  traits: [
    new Trait({
      name: 'speed',
      "default": 6
    }), new Trait({
      name: 'vision distance',
      "default": 10000
    }), new Trait({
      name: 'mating distance',
      "default": 10000
    }), new Trait({
      name: 'max offspring',
      "default": 3
    }), new Trait({
      name: 'min offspring',
      "default": 2
    }), new Trait({
      name: 'weight',
      min: 140,
      max: 160
    }), new Trait({
      name: 'prone to diabetes',
      "default": false
    }), new Trait({
      name: 'red diabetes',
      possibleValues: [''],
      isGenetic: true,
      isNumeric: false
    }), new Trait({
      name: 'yellow diabetes',
      possibleValues: [''],
      isGenetic: true,
      isNumeric: false
    }), new Trait({
      name: 'blue diabetes',
      possibleValues: [''],
      isGenetic: true,
      isNumeric: false
    }), new Trait({
      name: 'has diabetes',
      "default": false
    })
  ],
  imageProperties: {
    initialFlipDirection: "right"
  },
  imageRules: [
    {
      name: 'diabetic',
      contexts: ['environment'],
      rules: [
        {
          image: {
            path: "images/agents/diabetic-stack.png",
            scale: 0.4,
            anchor: {
              x: 0.5,
              y: 0.7
            }
          },
          useIf: function(agent) {
            return model.showDiabetic && agent.get('has diabetes');
          }
        }
      ]
    }, {
      name: 'prone',
      contexts: ['environment'],
      rules: [
        {
          image: {
            path: "images/agents/prone-stack.png",
            scale: 0.4,
            anchor: {
              x: 0.5,
              y: 0.7
            }
          },
          useIf: function(agent) {
            return model.showPropensity && agent.get('prone to diabetes');
          }
        }
      ]
    }, {
      name: 'sex',
      contexts: ['environment'],
      rules: [
        {
          image: {
            path: "images/agents/female-stack.png",
            scale: 0.4,
            anchor: {
              x: 0.5,
              y: 0.7
            }
          },
          useIf: function(agent) {
            return model.showSex && agent.get('sex') === 'male';
          }
        }, {
          image: {
            path: "images/agents/male-stack.png",
            scale: 0.4,
            anchor: {
              x: 0.5,
              y: 0.7
            }
          },
          useIf: function(agent) {
            return model.showSex && agent.get('sex') === 'female';
          }
        }
      ]
    }, {
      name: 'rats',
      contexts: ['environment', 'carry-tool'],
      rules: [
        {
          image: {
            path: "images/agents/sandrat-obese.png",
            scale: 0.9,
            anchor: {
              x: 0.6,
              y: 0.9
            }
          },
          useIf: function(agent) {
            return agent.get('weight') > 180;
          }
        }, {
          image: {
            path: "images/agents/sandrat-skinny.png",
            scale: 0.8,
            anchor: {
              x: 0.6,
              y: 0.9
            }
          }
        }
      ]
    }, {
      name: 'rats info tool',
      contexts: ['info-tool'],
      rules: [
        {
          image: {
            path: "images/agents/sandrat-obese.png",
            scale: 0.9,
            anchor: {
              x: 0.6,
              y: 0.9
            }
          },
          useIf: function(agent) {
            return agent.get('weight') > 180;
          }
        }, {
          image: {
            path: "images/agents/sandrat-skinny.png",
            scale: 0.8,
            anchor: {
              x: 0.6,
              y: 0.9
            }
          }
        }
      ]
    }
  ]
});
});

;
//# sourceMappingURL=app.js.map