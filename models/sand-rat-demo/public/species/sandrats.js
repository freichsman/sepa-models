// Generated by CoffeeScript 1.9.1
(function() {
  var extend = function(child, parent) { for (var key in parent) { if (hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
    hasProp = {}.hasOwnProperty;

  require.register("species/sandrats", function(exports, require, module) {
    var AnimatedAgent, BasicAnimal, SandRat, Species, Trait, biologicaSpecies, helpers;
    helpers = require('helpers');
    Species = require('models/species');
    BasicAnimal = require('models/agents/basic-animal');
    AnimatedAgent = require('models/agents/animated-agent');
    Trait = require('models/trait');
    biologicaSpecies = require('species/biologica/sandrats');
    SandRat = (function(superClass) {
      extend(SandRat, superClass);

      function SandRat() {
        return SandRat.__super__.constructor.apply(this, arguments);
      }

      SandRat.prototype.moving = false;

      SandRat.prototype.moveCount = 0;

      SandRat.prototype.step = function() {
        this.wander();
        this._incrementAge();
        if (this.get('age') > this.species.defs.MATURITY_AGE) {
          this.set('current behavior', BasicAnimal.BEHAVIOR.MATING);
        }
        if (this.get('age') > 100 && this.get('sex') === 'female' && this._timeLastMated < 0) {
          this.mate();
        }
        if (this.get('age') === 120 && this._timeLastMated > 0) {
          return this.die();
        }
      };

      SandRat.prototype.makeNewborn = function() {
        SandRat.__super__.makeNewborn.call(this);
        return this.set('age', Math.floor(Math.random() * 80));
      };

      SandRat.prototype.mate = function() {
        var max, nearest;
        nearest = this._nearestMate();
        if (nearest != null) {
          this.chase(nearest);
          if (nearest.distanceSq < Math.pow(this.get('mating distance'), 2) && ((this.species.defs.CHANCE_OF_MATING == null) || Math.random() < this.species.defs.CHANCE_OF_MATING)) {
            max = this.get('max offspring');
            this.set('max offspring', Math.max(max / 2, 1));
            this.reproduce(nearest);
            this.set('max offspring', max);
            this._timeLastMated = this.environment.date;
            return nearest.agent._timeLastMated = this.environment.date;
          }
        } else {
          return this.wander(this.get('speed') * Math.random() * 0.75);
        }
      };

      return SandRat;

    })(BasicAnimal);
    return module.exports = new Species({
      speciesName: "sandrats",
      agentClass: SandRat,
      geneticSpecies: biologicaSpecies,
      defs: {
        CHANCE_OF_MUTATION: 0,
        INFO_VIEW_SCALE: 2,
        MATURITY_AGE: 20,
        INFO_VIEW_PROPERTIES: {
          "Prone to diabetes: ": 'prone to diabetes',
          "Has diabetes: ": 'has diabetes'
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
          name: 'eating distance',
          "default": 50
        }), new Trait({
          name: 'mating distance',
          "default": 10000
        }), new Trait({
          name: 'max offspring',
          "default": 2
        }), new Trait({
          name: 'min offspring',
          "default": 2
        }), new Trait({
          name: 'resource consumption rate',
          "default": 35
        }), new Trait({
          name: 'metabolism',
          "default": 0.5
        }), new Trait({
          name: 'chance-hop',
          float: true,
          min: 0.05,
          max: 0.2
        }), new Trait({
          name: 'prone to diabetes',
          possibleValues: ['a:DR,b:DR', 'a:dp,b:DR', 'a:DR,b:dp', 'a:dp,b:dp'],
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
          name: 'rats',
          rules: [
            {
              image: {
                render: function(g) {
                  g.lineStyle(1, 0x000000);
                  g.beginFill(0xd2bda9);
                  return g.drawCircle(0, 0, 10);
                }
              },
              useIf: function(agent) {
                return agent.get('has diabetes') === false && agent.get('prone to diabetes') === 'prone' && model.showPropensity;
              }
            }, {
              image: {
                render: function(g) {
                  g.lineStyle(1, 0x000000);
                  g.beginFill(0xd2bda9);
                  return g.drawCircle(0, 0, 10);
                }
              },
              useIf: function(agent) {
                return agent.get('has diabetes') === false && agent.get('prone to diabetes') === 'prone' && model.showPropensity;
              }
            }, {
              image: {
                render: function(g) {
                  g.lineStyle(1, 0x000000);
                  g.beginFill(0xFFFFFF);
                  return g.drawCircle(0, 0, 10);
                }
              },
              useIf: function(agent) {
                return agent.get('has diabetes') === false;
              }
            }, {
              image: {
                render: function(g) {
                  g.lineStyle(1, 0x000000);
                  g.beginFill(0x904f10);
                  return g.drawCircle(0, 0, 10);
                }
              },
              useIf: function(agent) {
                return agent.get('has diabetes') === true;
              }
            }
          ]
        }, {
          name: 'sex',
          rules: [
            {
              image: {
                render: function(g) {
                  g.lineStyle(1, 0xFF0000);
                  return g.drawCircle(0, 0, 10);
                }
              },
              useIf: function(agent) {
                return agent.get('sex') === 'female';
              }
            }
          ]
        }
      ]
    });
  });

}).call(this);
