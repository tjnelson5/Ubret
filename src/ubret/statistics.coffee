BaseTool = window.Ubret.BaseTool or require('./base_tool')

class Statistics extends BaseTool

  constructor: (opts) ->
    super opts
    @displayFormat = if opts.format then d3.format(opts.format) else d3.format(',.03f')
    @createList()
    @start()

  start: =>
    return is @selectedKey is 'id'
    @createStats()
    @displayStats()

  createList: =>
    @ul = d3.select(@selector)
      .append('ul')
      .attr('class', 'statistics')

  createStats: =>
    @statistics = new Array
    @statistics.push [stat, @[stat]()] for stat in ['mean', 'median', 'mode', 'min', 'max', 'variance', 'standardDeviation', 'skew', 'kurtosis']

  displayStats: => 
    @ul.selectAll('li').remove()

    li = @ul.selectAll('li')
      .data(@statistics)
      .enter().append('li')
      .attr('data-stat', (d) -> d[0])
      .text( (d) => "#{@formatKey(d[0])}: #{@displayFormat(d[1])}" )

  # Statistics
  mean: =>
    count = @dimensions.id.groupAll().reduceCount().value()
    sum = @dimensions.id.groupAll().reduce(((p, v) => p + v[@selectedKey]),
                                          ((p, v) => p - v[@selectedKey]), 
                                          ((p, v) -> 0))
                                            .value()
    sum / count

  median: =>
    count = @dimensions.id.groupAll().reduceCount().value()

    # Check for odd length
    midPoint = count / 2
    if midPoint % 1
      median = ((@dimensions[@selectedKey].top(Math.floor midPoint) + @dimensions[@selectedKey].top(Math.ceil midPoint)) / 2)
    else
      median = @dimensions[@selectedKey].top(midPoint)
    _.last(median)[@selectedKey]

  mode: =>
    mode = @dimensions[@selectedKey].group().reduceCount().top(1)
    mode[0].key

  min: =>
    @dimensions[@selectedKey].bottom(1)[0][@selectedKey]

  max: =>
    @dimensions[@selectedKey].top(1)[0][@selectedKey]

  variance: =>
    count = @dimensions.id.groupAll().reduceCount().value()
    mean = @mean()

    varianceFormulaAdd = (p, v) =>
      p + Math.pow(Math.abs(v[@selectedKey] - mean), 2)
    varianceFormulaRemove = (p, v) =>
      p - Math.pow(Math.abs(v[@selectedKey] - mean), 2)
    variance = @dimensions.id.groupAll().reduce(varianceFormulaAdd, varianceFormulaRemove, (p, v) -> 0).value()

    variance / count

  standardDeviation: () =>
    Math.sqrt @variance()

  skew: =>
    mean = @mean()
    standardDeviation = @standardDeviation()
    count = @dimensions.id.groupAll().reduceCount().value()

    reduceAdd = (p, v) =>
      p + Math.pow(v[@selectedKey] - mean, 3)
    reduceRemove = (p, v) =>
      p - Math.pow(v[@selectedKey] - mean, 3)
    sum = @dimensions.id.groupAll().reduce(reduceAdd, reduceRemove, (p, v) -> 0).value()

    denom = count * Math.pow(standardDeviation, 3)
    sum / denom

  kurtosis: =>
    mean = @mean()
    standardDeviation = @standardDeviation()
    count = @dimensions.id.groupAll().reduceCount().value()

    reduceAdd = (p, v) =>
      p + Math.pow(v[@selectedKey] - mean, 4)
    reduceRemove = (p, v) =>
      p - Math.pow(v[@selectedKey] - mean, 4)
    sum = @dimensions.id.groupAll().reduce(reduceAdd, reduceRemove, (p, v) -> 0).value()

    denom = count * Math.pow(standardDeviation, 4)

    kurtosis = sum / denom

if typeof require is 'function' and typeof module is 'object' and typeof exports is 'object'
  module.exports = Statistics
else
  window.Ubret['Statistics'] = Statistics