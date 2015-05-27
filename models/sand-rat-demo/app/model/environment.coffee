Environment   = require 'models/environment'
Rule          = require 'models/rule'

env = new Environment
  columns:  100
  rows:     70
  imgPath: "images/environments/field-72ppi.png"
  wrapEastWest: false
  wrapNorthSouth: false
  barriers: [
    [0, 340, 1000, 10]       # Center
    [330, 0, 10, 340]        # Left
    [660, 0, 10, 340]        # Right
  ]

env.addRule new Rule
  test: (agent)->
    return agent.get('has diabetes') isnt true and
            agent.get('prone to diabetes') is 'prone' and
            agent.get('chow')
            Math.random() < 0.03
  action: (agent) ->
    agent.set 'has diabetes', true

require.register "environments/field", (exports, require, module) ->
  module.exports = env
