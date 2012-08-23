BaseController = require("./BaseController")

class Table extends BaseController
  events: 
    'click .subject' : 'selection'

  constructor: ->
    super

  name: "Table"

  render: =>
    console.log @data
    @html require('views/table')(@data)

  selection: (e) =>
    @selected.removeClass('selected') if @selected
    @selected = $(e.currentTarget)
    @selected.addClass('selected')
    @publish([ { message: "selected", item_id: @selected.attr('data-id') } ])

module.exports = Table