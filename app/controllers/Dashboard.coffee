Spine = require('spine')
_ = require('underscore/underscore')

class Dashboard extends Spine.Controller
  constructor: ->
    super
    @render()

  events: 
    submit: 'onSubmit'

  tools: []

  channels: []

  sources: ["GalaxyZooSubject"]

  bindSelect: require('views/bind_select')

  count: 0

  render: =>
    @html require('views/dashboard')() if @el.html

  addTool: (tool) ->
    @currentTool = tool.channel
    @tools.push tool
    @channels.push tool.channel

  createTool: (className) ->
    @count += 1
    @append "<div class=\"tool\" id=\"#{@count}\"></div>"
    tool = new className({el: "##{@count}"})
    @addTool tool
    tool.append @bindSelect(@)

  onSubmit: (e) =>
    e.preventDefault()
    tool = $('button[type="submit"]').val()
    source = $('select.channel').find('option:selected').attr('value') || $('select.source').find('option:selected').attr('value')
    params = $('input[name="params"]').val()
    @bindTool tool, source, params

  bindTool: (tool, source, params='') ->
    receiverTool = _.find @tools, (tool) ->
      tool.channel = tool
    if params
      receiverTool.getDataSource source, params
    else
      receiverTool.subscribe source, tool.process
      sourceTool = _.find @tools, (tool) ->
        tool.channel == source
      receiverTool.receiveData tool.data

module.exports = Dashboard