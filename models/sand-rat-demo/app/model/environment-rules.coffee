Rule          = require 'models/rule'

require.register "environments/rules", (exports, require, module) ->
  worstChance = 0.2
  diabetesChance = (agent) ->
    if agent.get('prone to diabetes') is 'not prone'
      return 0
    else if agent.get('prone to diabetes') is 'level1'
      return worstChance * (1/6)
    else if agent.get('prone to diabetes') is 'level1'
      return worstChance * (2/6)
    else if agent.get('prone to diabetes') is 'level1'
      return worstChance * (3/6)
    else if agent.get('prone to diabetes') is 'level1'
      return worstChance * (4/6)
    else if agent.get('prone to diabetes') is 'level1'
      return worstChance * (5/6)
    else if agent.get('prone to diabetes') is 'level1'
      return worstChance

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
                  agent.get('prone to diabetes') isnt 'not prone' and
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
