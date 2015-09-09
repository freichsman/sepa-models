require.register "species/biologica/sandrats", (exports, require, module) ->
  # TODO This should probably get ported back to BioLogica.js
  BioLogica.Genetics.prototype.getRandomAllele = (exampleOfGene) ->
    for own gene of @species.geneList
      _allelesOfGene = @species.geneList[gene].alleles
      _weightsOfGene = @species.geneList[gene].weights || []
      if exampleOfGene in _allelesOfGene
        allelesOfGene = _allelesOfGene
        break

    if _weightsOfGene.length
      _weightsOfGene[_weightsOfGene.length] = 0 while _weightsOfGene.length < allelesOfGene.length # Fill missing allele weights with 0
    else
      _weightsOfGene[_weightsOfGene.length] = 1 while _weightsOfGene.length < allelesOfGene.length # Equally weighted for all alleles

    totWeights = _weightsOfGene.reduce ((prev, cur)-> prev + cur), 0
    rand = Math.random() * totWeights
    curMax = 0
    for weight,i in _weightsOfGene
      curMax += weight
      if rand <= curMax
        return allelesOfGene[i]

    console.error('somehow did not pick one: ' + allelesOfGene[0]) if console.error?
    return allelesOfGene[0]

  genes = [
    {dominant: 'DR', recessive: 'drb' },
    {dominant: 'DR', recessive: 'drb' },
    {dominant: 'DY', recessive: 'dyb' },
    {dominant: 'DY', recessive: 'dyb' },
    {dominant: 'DB', recessive: 'dbb' },
    {dominant: 'DB', recessive: 'dbb' }
  ]

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
        weights: [0.2, 0.8]
        start: 10000000
        length: 10584
      'yellow':
        alleles: ['DY', 'dyb']
        weights: [0.2, 0.8]
        start: 10000000
        length: 8882
      'blue':
        alleles: ['DB', 'dbb']
        weights: [0.2, 0.8]
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
      'red diabetes':
        'none': [['drb','drb']]
        'level1': [['DR','drb']]
        'level2': [['DR','DR']]
      'yellow diabetes':
        'none': [['dyb','dyb']]
        'level1': [['DY','dyb']]
        'level2': [['DY','DY']]
      'blue diabetes':
        'none': [['dbb','dbb']]
        'level1': [['DB','dbb']]
        'level2': [['DB','DB']]

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
