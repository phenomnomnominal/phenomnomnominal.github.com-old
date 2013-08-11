(exports ? @).Twitter = do ->
  MONTHS = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec']
  TWEET_PATH = 'http://phenomnomnominal.herokuapp.com/getTweets.json?callback=?'

  _$twitter = $('#twitter span')
  _tweets = _count = null

  _formatDate = (date) ->
    date = new Date(date)

    month = date.getMonth()
    day = date.getDate()
    year = date.getFullYear()
    hour = date.getHours()
    mins = date.getMinutes()

    meridian = if hour > 11 then 'PM' else 'AM'
    hour = hour % 12
    hour = if hour is 0 then 12 else hour
    mins = if mins < 10 then ('0' + mins) else mins
    dateStr = "#{MONTHS[month]} #{day}, #{year} at #{hour}:#{mins} #{meridian}"

  _handleTweets = (response) ->
    _tweets = response.data
    _displayNextTweet()

  _displayNextTweet = ->
    clearInterval scroll
    _count = if _count is (_tweets.length - 1) or _count is null then 0 else _count + 1
    
    _wrapHTML = ->
      "<a target='_blank' href='https://twitter.com/phenomnominal/status/#{_tweets[_count].id_str}'>#{_tweetHTML}</a>"

    _tweetHTML = "<em>></em>#{_tweets[_count].text} - (#{_formatDate _tweets[_count].created_at})"
    _$twitter.html _wrapHTML(_tweetHTML)
    setTimeout (->
      scroll = setInterval (->
        _tweetHTML = "<em>></em>#{_$twitter.text()[3...]}"
        _$twitter.html _wrapHTML(_tweetHTML)
        if _$twitter.text().length < 3
          clearInterval scroll
          _displayNextTweet()
      ), 300
    ), 1000
  init: ->
    $.getJSON(TWEET_PATH, _handleTweets) if _tweets is null