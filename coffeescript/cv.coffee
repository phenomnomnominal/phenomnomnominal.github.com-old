(exports ? @).CV = do ->
  init = ->
    $.get('cv/cv.html', ((result) -> 
        $('#content-cv').html result
        $('#cv a').attr 'target', '_blank'
      )
    )

  init: init