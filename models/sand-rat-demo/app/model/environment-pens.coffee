Environment   = require 'models/environment'
Rule          = require 'models/rule'

env = new Environment
  columns:  100
  rows:     70
  imgPath: "images/environments/field-pens.png"
  wrapEastWest: false
  wrapNorthSouth: false
  barriers: [
    [0, 330, 1000, 30]       # Center - horizontal
    [485, 0, 30, 340]        # Center - vertical-top
  ]

# Add weight when eating chow
env.addRule new Rule
  test: (agent)->
    return agent.species.speciesName is "sandrats" and
            agent.get('chow') and
            agent.get('weight') < 220 and
            Math.random() < 0.15
  action: (agent) ->
    agent.set 'weight', agent.get('weight') + Math.floor(Math.random() * 5)

# Remove weight when not eating chow
env.addRule new Rule
  test: (agent)->
    return agent.species.speciesName is "sandrats" and
            agent.get('chow') isnt true and
            agent.get('weight') > 155 and
            Math.random() < 0.15
  action: (agent) ->
    agent.set 'weight', agent.get('weight') - Math.floor(Math.random() * 5)

# Get diabetes if heavy (> 170) and prone
# p(get diabetes) at 170: 0
# p(get diabetes) at 200: 0.1 per step
env.addRule new Rule
  test: (agent)->
    return agent.species.speciesName is "sandrats" and
            agent.get('has diabetes') isnt true and
            agent.get('prone to diabetes') is 'prone' and
            (w = agent.get('weight')) > 170 and
            Math.random() < (((w - 170) / 30) * 0.1)
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
            Math.random() < ((-(w - 170) / 20) * 0.1)
  action: (agent) ->
    agent.set 'has diabetes', false


require.register "environments/field", (exports, require, module) ->
  module.exports = env
