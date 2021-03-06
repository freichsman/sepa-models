// Generated by CoffeeScript 1.9.1
(function() {
  var Rule;

  Rule = require('models/rule');

  require.register("environments/rules", function(exports, require, module) {
    var diabetesChance, worstChance;
    worstChance = 0.2;
    diabetesChance = function(agent) {
      var color, colorLevel, i, len, odds, ref, ref1, ref2, ref3, ref4, ref5, ref6, ref7, ref8, ref9;
      odds = 0;
      ref = ['red', 'yellow', 'blue'];
      for (i = 0, len = ref.length; i < len; i++) {
        color = ref[i];
        colorLevel = agent.get(color + ' diabetes');
        if (colorLevel === 'level1') {
          odds += ((ref1 = window.CONFIG) != null ? (ref2 = ref1.diabetes) != null ? (ref3 = ref2[color]) != null ? ref3.level1 : void 0 : void 0 : void 0) != null ? window.CONFIG.diabetes[color].level1 : 1 / 6;
        } else if (colorLevel === 'level2') {
          odds += ((ref4 = window.CONFIG) != null ? (ref5 = ref4.diabetes) != null ? (ref6 = ref5[color]) != null ? ref6.level2 : void 0 : void 0 : void 0) != null ? window.CONFIG.diabetes[color].level2 : 2 / 6;
        } else if (colorLevel === 'none') {
          if (((ref7 = window.CONFIG) != null ? (ref8 = ref7.diabetes) != null ? (ref9 = ref8[color]) != null ? ref9['none'] : void 0 : void 0 : void 0) != null) {
            odds += window.CONFIG.diabetes[color]['none'];
          }
        }
      }
      return worstChance * odds;
    };
    return module.exports = {
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

}).call(this);
