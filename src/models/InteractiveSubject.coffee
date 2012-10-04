Spine = require 'spine'
Api = require 'zooniverse/lib/api'
User = require 'zooniverse/lib/models/user'

class InteractiveSubject extends Spine.Model
  @configure 'InteractiveSubject', 'redshift', 'color', 'subject', 'classification', 'type', 'counters', 'image', 'zooniverse_id'

  @fetch: ({random, limit, user}) =>
    url = @url(random, limit, user)
    fetcher = Api.get url, @fromJSON

  @url: (random, limit, user) =>
    if random
      url = '/user_groups/random-classifications'
    else if user
      url = "/user_groups/#{User.current.user_group_id}/user_recents"
    else
      url = "/user-groups/#{User.current.user_group_id}/recents"

    if limit isnt 0
      url = url + "?limit=#{limit}"

    return url

  @fromJSON: (json) =>
    @lastFetch = new Array
    for result in json
      item = @create
        counters: result.recent.subject.metadata.counters
        classification: result.recent.user.classification
        type: @findType(result.recent.subject.metadata.counters)
        image: result.recent.subject.location.standard
        zooniverse_id: result.recent.subject.zooniverse_id
      @lastFetch.push item

  @findType: (subject) =>
    if subject.smooth > subject.feature and subject.smooth > subject.artifact
      return 'smooth'
    else if subject.feature > subject.smooth and subject.feature > subject.artifact
      return 'feature'
    else
      return 'artifact'

module.exports = InteractiveSubject

