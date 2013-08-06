(exports ? @).Blog = do ->
  init = ->
    $.get('blog/1000GoodIntentions.html', ((result) ->
        $('#content-blog').html result
        $('#blog a').attr 'target', '_blank'
        $('#cover-blog img').attr 'src', '../blog/covers/LA DISPUTE - WILDLIFE.png'
        $('#info-blog a').text('LA DISPUTE: Wildlife').attr 'href', 'https://itunes.apple.com/nz/album/wildlife/id463651346'
      )
    )

  init: init