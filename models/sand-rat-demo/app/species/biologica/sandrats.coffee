require.register "species/biologica/sandrats", (exports, require, module) ->

  module.exports =

    name: 'Sandrats'

    chromosomeNames: ['1', '2', 'XY']

    chromosomeGeneMap:
      '1': ['DR']
      '2': []
      'XY': []

    chromosomesLength:
      '1': 100000000
      '2': 100000000
      'XY': 70000000

    geneList:
      'diabetes':
        alleles: ['DR', 'dp']
        start: 10000000
        length: 10584

    alleleLabelMap:
      'dp': 'Prone'
      'DR': 'Not prone'
      'Y' : 'Y'
      ''  : ''

    traitRules:
      'prone to diabetes':
        'prone':  [['dp','dp']]
        'not prone':  [['DR','DR'],['DR','dp']]

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
