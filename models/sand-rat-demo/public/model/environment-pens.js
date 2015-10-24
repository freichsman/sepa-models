// Generated by CoffeeScript 1.9.1
(function() {
  var EnvRules, Environment, env;

  Environment = require('models/environment');

  EnvRules = require('environments/rules');

  env = new Environment({
    columns: 60,
    rows: 45,
    imgPath: "images/environments/pens.png",
    wrapEastWest: false,
    wrapNorthSouth: false,
    barriers: [[170, 0, 55, 450], [220, 200, 380, 50]]
  });

  EnvRules.init(env);

  require.register("environments/field", function(exports, require, module) {
    return module.exports = env;
  });

}).call(this);
