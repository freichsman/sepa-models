require.register "species/biologica/sandrats", (exports, require, module) ->
  genes = [
    {dominant: 'DR', recessive: 'drb' },
    {dominant: 'DR', recessive: 'drb' },
    {dominant: 'DY', recessive: 'dyb' },
    {dominant: 'DY', recessive: 'dyb' },
    {dominant: 'DB', recessive: 'dbb' },
    {dominant: 'DB', recessive: 'dbb' }
  ]

  combos = (num, idx=0, current=[], results=[], dominantCount=0) ->
    if dominantCount is num and current.length is genes.length
      results.push current
    for i in [idx...(genes.length)]
      combos(num, i+1, current.concat(genes[i].dominant),  results, dominantCount+1) if dominantCount < num
      combos(num, i+1, current.concat(genes[i].recessive), results, dominantCount)

    if idx is 0 then return results else return

  module.exports =

    name: 'Sandrats'

    chromosomeNames: ['1', '2', 'XY']

    chromosomeGeneMap:
      '1': ['DR']
      '2': ['DY','DB']
      'XY': []

    chromosomesLength:
      '1': 100000000
      '2': 100000000
      'XY': 70000000

    geneList:
      'red':
        alleles: ['DR', 'drb']
        start: 10000000
        length: 10584
      'yellow':
        alleles: ['DY', 'dyb']
        start: 10000000
        length: 8882
      'blue':
        alleles: ['DB', 'dbb']
        start: 600000000
        length: 5563

    alleleLabelMap:
      'DR': 'Red'
      'DY': 'Yellow'
      'DB': 'Blue'
      'drb': 'Black'
      'dyb': 'Black'
      'dbb': 'Black'
      'Y' : 'Y'
      ''  : ''

    traitRules:
      'prone to diabetes':
        'not prone': combos(0)
        'level1': combos(1)
        'level2': combos(2)
        'level3': combos(3)
        'level4': combos(4)
        'level5': combos(5)
        'level6': combos(6)

    ###
      Images are handled via the populations.js species
    ###
    getImageName: (org) ->
      undefined

    ###
      no lethal characteristics
    ###
    makeAlive: (org) ->
      undefined
