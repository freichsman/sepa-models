Rule          = require 'models/rule'

require.register "environments/rules", (exports, require, module) ->
  worstChance = 0.2
  diabetesChance = (agent) ->
    odds = 0
    for color in ['red', 'yellow', 'blue']
      colorLevel = agent.get(color+' diabetes')
      if colorLevel is 'level1'
        odds += if window.CONFIG?.diabetes?[color]?.level1? then window.CONFIG.diabetes[color].level1 else (1/6)
      else if colorLevel is 'level2'
        odds += if window.CONFIG?.diabetes?[color]?.level2? then window.CONFIG.diabetes[color].level2 else (2/6)
      else if colorLevel is 'none'
        if window.CONFIG?.diabetes?[color]?['none']?
          odds += window.CONFIG.diabetes[color]['none']

    return worstChance * odds

  module.exports =
    init: (env)->
      # Add weight when eating chow
      env.addRule new Rule
        test: (agent)->
          return agent.species.speciesName is "sandrats" and
                  agent.get('chow') and
                  agent.get('weight') < 220 and
                  Math.random() < 0.15 # 0.16?
        action: (agent) ->
          agent.set 'weight', agent.get('weight') + Math.floor(Math.random() * 5)

      # Remove weight when not eating chow
      env.addRule new Rule
        test: (agent)->
          return agent.species.speciesName is "sandrats" and
                  agent.get('chow') isnt true and
                  agent.get('weight') > 155 and
                  Math.random() < 0.15 # 0.16?
        action: (agent) ->
          agent.set 'weight', agent.get('weight') - Math.floor(Math.random() * 5)

      # Get diabetes if heavy (> 170) and prone
      # p(get diabetes) at 170: 0
      # p(get diabetes) at 200: 0.1 per step
      env.addRule new Rule
        test: (agent)->
          return agent.species.speciesName is "sandrats" and
                  agent.get('has diabetes') isnt true and
                  agent.get('prone to diabetes') and
                  (w = agent.get('weight')) > 170 and
                  Math.random() < (((w - 170) / 30) * diabetesChance(agent))
        action: (agent) ->
          agent.set 'has diabetes', true

      # Lose diabetes if not heavy (< 170) and prone
      # p(lose diabetes) at 170: 0
      # p(lose diabetes) at 150: 0.1 per step
      env.addRule new Rule
        test: (agent)->
          return agent.species.speciesName is "sandrats" and
                  agent.get('has diabetes') is true and
                  (w = agent.get('weight')) < 170 and
                  Math.random() < ((-(w - 170) / 20) * (worstChance - diabetesChance(agent)))
        action: (agent) ->
          agent.set 'has diabetes', false
