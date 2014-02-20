this.quantumComputer =
  kets: {}
  gates: []

sub = '<sub> </sub>'

timeouts = []
infoBar = (selector, level, message = '') ->
  clearTimeout timeout for timeout in timeouts
  $(selector).removeClass().addClass level
  if level isnt 'default'
    ((times, count = 0) ->
      if count < times
        $(selector).toggleClass "#{level}Flash"
        callee = arguments.callee
        timeouts.push setTimeout (-> callee(times, count + 1)), 500
      else
        clearInfoBar(selector)
    )(10)
  $(selector).html message

clearInfoBar = (selector) -> infoBar selector, 'default'
info = (message) -> infoBar '#infoBar', 'info', message
warn = (message) -> infoBar '#infoBar', 'warning', message
err = (message) -> infoBar '#infoBar', 'error', message

clear = 
  input: ($el, checkVal) ->
    if checkVal? 
      if $el.val() is checkVal
        $el.val '' 
    else
      $el.val ''

  element: ($el) -> 
    $el.html ''
    
  transition: ->
    transition = [null, null]
    $('.transition').text('').removeClass 'dropped'
    $('.transition').parent().children('input').remove()
    $('.transitionAmp').remove()
  
  apply: ->
    apply.gate = null
    apply.ket = null
    $('.apply').text('').removeClass 'dropped'
    $('.apply').parent().children('input').remove()
    
  kron: ->
    kron = [null, null]
    $('.kron').text('').removeClass 'dropped'
    $('.kron').parent().children('input').remove()
    
  quantum: ->
    window.quantumComputer =
      kets: {}
      gates: []
    $('.answer').remove()
    clear.element $('.state')
    $('#kets').masonry 'reload'
    $('#gates').masonry 'reload'
    clear.transition()
    clear.apply()
    clear.kron()

checkInput =
  qubit: (value, maxVal, success, type) ->
    val = +value
    if _.isNumber(val) and not _.isNaN(val) and val > 0 and val % 1 is 0
      states = Math.pow 2, val
      if val > maxVal
        if type is 'KET'
          warn "YOU PROBABILY DON'T WANT TO INPUT #{states} PROBABILITIES. TRY AN INTEGER LESS THAN #{maxVal + 1}."
        if type is 'GATE'
          warn "YOU PROBABILY DON'T WANT TO INPUT #{Math.pow states, 2} GATE VALUES. TRY AN INTEGER LESS THAN #{maxVal + 1}."
      else
        success states
    else
      val = value
      if val isnt ''
        err "'#{val}' IS NOT A VALID INPUT. TRY AN INTEGER LESS THAN #{maxVal + 1}."

selectReset = ($select) ->
  if $select.children('option').first().text() isnt 'SELECT:'
    $select.prepend $ '<option>', text: 'SELECT:'
    $select.children('option').first().attr('selected', true)

runAlgorithm = (func, args, answerStr, algName) ->
  $('.answer').remove()
  results = func.apply this, args
  count = 1
  for own name, result of results
    if result instanceof $K
      create.ket result.col, name
    else if result instanceof $M
      create.gate result.matrix, name
    else
      $('#algorithmForm').append "<p class='answer'>#{answerStr.replace('%s', result)}.</p>"
      $('html, body').animate scrollTop: $('.answer').offset().top, 1000
  info "#{algName} ALGORITHM COMPLETED."

create = 
  label: (text, classes = '') ->
    $ '<label>'
      class: classes
      text: text
    
  input: (classes, functions, type, val) ->
    $input = $ '<input>'
      class: classes
      type: type
      val: val
    for own funcType, func of functions
      $input.bind funcType, func
    $input

  button: (funcName, func, value, classes = '') ->
    $ '<input>'
      class: "button #{classes}"
      click: func
      id: "#{funcName}Button"
      type: 'button'
      val: value

  form:
    ket: (states, elements = []) ->
      for state in [0...states]
        $label = create.label "State #{state}", 'probLabel'
        focus = ->
          clear.input $(this), '(Complex probability - a ± bi)'
          info "INPUT THE PROBABILITY THAT THIS KET IS IN STATE #{$(this).data 'state'} IN THE FORM a ± bi."    
        $input = create.input 'stateProb', focus: focus, 'text', '(Complex probability - a ± bi)'
        $input.data 'state', state
        elements.push [$label, ':', $input, '<br/>']
  
      initKet = ->
        [col, e] = (->
          [(for $inp in $('.stateProb')
            try complex = new $C($($inp).val())
            catch error
              err "BAD INPUT FOR STATE #{$($inp).data('state')}. SHOULD BE A COMPLEX PROBABILITY IN THE FORM a ± bi."
              e = error
            complex), e])()
        if not e?
          create.ket col, $('#ketName').val()
          $('#ketName').val 'φ'
          clear.element $('#ketProbs')
          clear.input $('#ketQubits')
  
      $('#ketProbs').append _.flatten([elements, create.button('createKet', initKet, 'create ket')])
      
    gate: (states) ->
      $table = $ '<table>'

      for i in [0...states]
        $tr = $ '<tr>'
        for j in [0...states]
          focus = ->
            clear.input $(this), '(a ± bi)'
            info "INPUT THE VALUE FOR THIS GATE AT INDEX [#{$(this).data 'i'}][#{$(this).data 'j'}] IN THE FORM a ± bi."
          $input = create.input 'gateVal', focus: focus, 'text', '(a ± bi)'
          $input.data 'i', i
          $input.data 'j', j
          $td = $ '<td>',
            html: $input
          $tr.append $td
        $table.append $tr

      initGate = ->
        states = Math.pow 2, $('#gateQubits').val()
        [m, e] = ((m = []) ->
          m.push [] for s in [0...states]
          [(for $inp in $('.gateVal')
            i = $($inp).data 'i'
            j = $($inp).data 'j'
            try complex = new $C($($inp).val())
            catch error
              err "BAD INPUT FOR [#{i}][#{j}]. SHOULD BE A COMPLEX NUMBER IN THE FORM a ± bi."
              e = error
            m[i][j] = complex
          m), e])()
        if not e?
          create.gate m, $('#gateName').val()
          $('#gateName').val 'M'
          clear.element $('#gateVals')
          clear.input $('#gateQubits')

      $('#gateVals').append $table, create.button('createGate', initGate, 'create gate')
      
    deutsch: ->
      $description = $('#deutschDescription')
      $description.show()
      $select = $description.find('div select')
      selectReset $select
      $select.change ->
        if $select.children('option').first().text() is 'SELECT:'
          $select.children('option').first().remove()
        $parent = $description.parent()
        $parent.children('input').remove()
        $('.answer').remove()
        clearQuantum = create.button 'clearQuantum', clear.quantum, 'clear computer'
        runFunction = ->
          info "THINKING..."
          $('.overlay').css(display: 'block').animate opacity: 0.8
          $('.overlay').promise().done ->
            $selected = $select.children('option:selected')
            oracle = $U.CreateNBitDeutschJozsaOracle 1, +$selected.val()
            answerStr = "#{$selected.text()} is %s"
            runAlgorithm Quantum.Deutsch, [oracle], answerStr, 'DEUTSCH'
            $('.overlay').animate opacity: 0, ->
              $(this).css display: 'none'
        run = create.button 'runAlgorithm', runFunction, 'run algorithm'
        $parent = $description.parent()
        $parent.children('input').remove()
        $parent.append [clearQuantum, run]
        
    deutschJozsa: ->
      $description = $('#deutschJozsaDescription')
      $description.show()
      $select = $description.find('div select')
      $('#createFunction').remove()
      selectReset $select
      $select.change ->
        if $select.children('option').first().text() is 'SELECT:'
          $select.children('option').first().remove()
        $(this).parent().siblings('div').remove()
        $div = $ '<div>', id: 'createFunction'
        elements = []
        n = +$select.children('option:selected').val()
        elements.push "<p class='title'>CREATE FUNCTION:</p>"
        for i in [0...Math.pow 2, n]
          elements.push create.label "ƒ(#{i}) = "
          valSelect = $ '<select>', class: 'valSelect'
          valSelect.append $ '<option>', value: 0, text: 0
          valSelect.append $ '<option>', value: 1, text: 1
          elements.push [valSelect]
          if i % 2 is 1
            elements.push '<br/>'
        $div.append _.flatten elements
        $description.append $div
        $('.answer').remove()
        clearQuantum = create.button 'clearAlgorithm', clear.quantum, 'clear computer'
        runFunction = ->
          info "THINKING..."
          $('.overlay').css(display: 'block').animate opacity: 0.8
          $('.overlay').promise().done ->
            $selected = $('.valSelect option:selected')
            vals = ($(el).text() for el in $selected)
            value = parseInt vals.join(''), 2
            oracle = $U.CreateNBitDeutschJozsaOracle n, value
            zero = (i for i in [0...vals.length] when vals[i] is '0')
            one = (i for i in [0...vals.length] when vals[i] is '1')
            answerStr = ''
            if zero.length > 0
              answerStr += "ƒ(#{zero}) = 0"
            if zero.length > 0 and one.length > 0
              answerStr += ', '
            if one.length > 0
              answerStr += "ƒ(#{one}) = 1"
            answerStr += ' is %s'
            runAlgorithm Quantum.DeutschJozsa, [oracle, n], answerStr, 'DEUTSCH-JOZSA'
            $('.overlay').animate opacity: 0, ->
              $(this).css display: 'none'
        run = create.button 'runAlgorithm', runFunction, 'run algorithm'
        $parent = $description.parent()
        $parent.children('input').remove()
        $parent.append [clearQuantum, run]
        
    grovers: ->
      $description = $('#groversDescription')
      $description.show()
      $select = $description.find('div select')
      $('#selectSolution').remove()
      selectReset $select
      $select.change ->
        if $select.children('option').first().text() is 'SELECT:'
          $select.children('option').first().remove()
        $(this).parent().siblings('div').remove()
        $div = $ '<div>', id: 'selectSolution'
        elements = []
        n = +$select.children('option:selected').val()
        elements.push "<p class='title'>SELECT SOLUTION:</p>"
        elements.push create.label "Solution:"
        solutionSelect = $ '<select>', class: 'solutionSelect'
        for i in [0...Math.pow 2, n]
           str = i.toString 2
           while str.length < n
             str = "0#{str}"
           solutionSelect.append $ '<option>', value: i, text: "'#{str}'"
        $div.append _.flatten [elements, solutionSelect, '<br/>']
        $description.append $div
        $('.answer').remove()
        clearQuantum = create.button 'clearAlgorithm', clear.quantum, 'clear computer'
        runFunction = ->
          info "THINKING..."
          $('.overlay').css(display: 'block').animate opacity: 0.8
          $('.overlay').promise().done ->
            sol = +$('.solutionSelect option:selected').val()
            oracle = $U.CreateNBitHaystack n, sol
            answerStr = "The solution is %s"
            runAlgorithm Quantum.Grover, [oracle], answerStr, 'GROVER\'S'
            $('.overlay').animate opacity: 0, ->
              $(this).css display: 'none'
        run = create.button 'runAlgorithm', runFunction, 'run algorithm'
        $parent = $description.parent()
        $parent.children('input').remove()
        $parent.append [clearQuantum, run]
      
    shors: ->
      $description = $('#shorsDescription')
      $description.show()
      $description.find('div select').remove()
      $description.find('label').remove()
      $div = $description.children 'div'
      for p in [1..2]
        $select = $ '<select>'
        $select.append $ '<option>', text: 'SELECT:'
        primes = (true for n in [0..600])
        primes[0] = false
        primes[1] = false
        for i in [2..Math.sqrt(600)]
          if primes[i]
            for j in [Math.pow(i, 2)..600] by i
              primes[j] = false
        for i in [0...primes.length]
          if primes[i]
            $select.append $ '<option>', val: i, text: i
        $div.append [create.label("Prime #{p}: "), $select, "<br/>"]
      $select = $description.find('div select')
      $select.change ->
        if $(this).children('option').first().text() is 'SELECT:'
          $(this).children('option').first().remove()
        p1 = $(this).parent().find('select option:selected')[0].value
        p2 = $(this).parent().find('select option:selected')[1].value
        if p1 isnt 'SELECT:' and p2 isnt 'SELECT:'
          product =  +p1 * +p2
          $(this).siblings('.subtitle').remove()
          $(this).parent().append "<p class='subtitle'><br/>#{p1} × #{p2} = #{product}<br/></p>"
          $('.answer').remove()
          runFunction = ->
            info "THINKING..."
            $('.overlay').css(display: 'block').animate opacity: 0.8
            $('.overlay').promise().done ->
              answerStr = "%s is a prime factor of #{product}"
              runAlgorithm Quantum.Shor, [product], answerStr, 'SHOR\'S'
              $('.overlay').animate opacity: 0, ->
                $(this).css display: 'none'
          run = create.button 'runAlgorithm', runFunction, 'run algorithm'
          $parent = $description.parent()
          $parent.children('input').remove()
          $parent.append run
        
  ket:  (col, name) ->
    ket = new $K(col)
    info "KET CREATED - UPDATING QUANTUM COMPUTER STATE."

    if name is '' then name = 'φ'
    
    count = 0
    copyName =  if name is 'φ' then "#{name}<sub>#{count}</sub>" else name
    if copyName.indexOf '<sub>' < 0 and copyName.indexOf '</sub>' < 0
      copyName = "#{copyName}#{sub}"
    for own key, val of quantumComputer.kets
      if key is copyName
        copyName = "#{name}<sub>#{++count}</sub>"
    name = "#{copyName}"
    
    ket.name = name
    quantumComputer.kets[name] = ket
  
    $ketDiv = $ '<div>', class: 'ket'
    display.ket ket, $ketDiv
    $('#kets').append($ketDiv).masonry('appended', $ketDiv).masonry 'reload'
    $('#kets').promise().done ->
      $(this).css overflow: ''
    
  gate: (m, name) ->  
    gate = new $M(m)
    
    type = 'GATE'
    if gate.isUnitary()
      type = 'UNITARY GATE'
    if gate.isHermitian()
      type = 'HERMITIAN GATE'
    if gate.isIdentity()
      type = 'IDENTITY GATE'
    info "#{type} CREATED - UPDATING QUANTUM COMPUTER STATE."

    if name is '' then name = 'M'

    count = 0
    copyName = if name is 'M' then "#{name}<sub>#{count}</sub>" else name
    if copyName.indexOf '<sub>' < 0 and copyName.indexOf '</sub>' < 0
      copyName = "#{copyName}#{sub}"
    for own key, val of quantumComputer.gates
      if key is copyName
        copyName = "#{name}<sub>#{++count}</sub>"
    name = "#{copyName}"

    gate.name = name
    quantumComputer.gates[name] = gate

    $gateDiv = $ '<div>', class: 'gate'
    display.gate gate, $gateDiv
    $('#gates').append($gateDiv).masonry('appended', $gateDiv).masonry 'reload'
    $('#gates').promise().done ->
      $(this).css overflow: ''
          
display =
  draggable: ($div, dragClass) ->
    $div.draggable
      revert: true
      start: ->
        $(this).addClass dragClass
      stop: ->
        $(this).removeClass dragClass

  ket: (ket, $div, elements = []) ->
    clear.element $($div)
    elements.push "<span class='name'>#{ket.name}</span><br/>"

    binLength = Math.log(ket.col.length) / Math.LN2
    for i in [0...ket.col.length]
      binary = i.toString 2
      while binary.length < binLength
        binary = 0 + binary
      elements.push "<span>#{binary}</span>: "
    
      prob = $ '<span>', 
        class: 'complexProb', 
        id: "complexProb#{i}",
        mouseenter: ->
          id = $(this).attr('id').substr 11
          name = $(this).siblings('.name').html()
          prob = quantumComputer.kets[name].probability(id).toFixed 5
          $(this).html "p(x) = #{prob}"
        mouseleave: ->
          id = $(this).attr('id').substr 11
          name = $(this).siblings('.name').html()
          compProb = quantumComputer.kets[name].col[id]
          $(this).html "#{compProb}"
        text: "#{ket.col[i]}"
    
      elements.push [prob, "<br/>"]
  
    normalise = ->
      name = $(this).siblings('.name').html()
      quantumComputer.kets[name].normalise()
      ket = quantumComputer.kets[name]
      display.ket ket, $(this).parent()
      $('#kets').masonry 'reload'
      info "KET #{name} HAS BEEN NORMALISED."
    normaliseButton = create.button "#{name}Normalise", normalise, 'normalise'
    
    del = -> 
      name = $(this).siblings('.name').html()
      ket = quantumComputer.kets[name]
      quantumComputer.kets[name] = null
      $ketDiv = $(this).parent()
      $('#kets').masonry('remove', $ketDiv).masonry 'reload'
      info "KET #{name} HAS BEEN DELETED."
    deleteButton = create.button "#{name}Delete", del, 'delete', 'red'
    
    $div.append _.flatten [elements, normaliseButton, deleteButton]
    display.draggable $div, 'draggingKet'
    
  gate: (gate, $div, elements = []) ->
    clear.element $($div)
    elements.push "<span class='name'>#{gate.name}</span>"

    matrixSpan = (type) ->
      $ '<span>',
        class: "matrixType #{type}"
        text: type[0].toUpperCase()
        mouseover: ->
          info "THIS GATE IS #{type.toUpperCase()}"

    if gate.isUnitary()
      elements.push matrixSpan 'unitary'
    if gate.isHermitian()
      elements.push matrixSpan 'hermitian'
    if gate.isIdentity()
      elements.push matrixSpan 'identity'
      
    elements.push "<br/>"

    view = ->
      display.matrix this
    viewButton = create.button "#{name}View", view, 'view matrix'
    
    del = ->
      name = $(this).siblings('.name').html()
      gate = quantumComputer.gates[name]
      quantumComputer.gates[name] = null
      $gateDiv = $(this).parent()
      $('#gates').masonry('remove', $gateDiv).masonry 'reload'
      info "GATE #{name} HAS BEEN DELETED."
    deleteButton = create.button "#{name}Delete", del, 'delete', 'red'
    
    $div.append _.flatten [elements, viewButton, deleteButton]
    display.draggable $div, 'draggingGate'
    
  matrix: (el) ->
    name = $(el).siblings('.name').html()
    gate = quantumComputer.gates[name]

    $table = $ '<table>'
    for i in [0...gate.size]
      $tr = $ '<tr>'
      for j in [0...gate.size]
        $td = $ '<td>',
          html: "<p>#{gate.matrix[i][j]}</p>"
          mouseover: ->
            name = $('.matrix').data 'name'
            gate = quantumComputer.gates[name]
            i = $(this).data 'i'
            j = $(this).data 'j'
            infoBar '#matrixInfo', 'info', "#{name} HAS VALUE #{gate.matrix[i][j]} AT [#{i}][#{j}]"
        $td.css
          width: "#{100 / gate.matrix.length}%"
          minWidth: '50px'
        $td.data 'i', i
        $td.data 'j', j
        $tr.append $td
      $table.append $tr

    $('.overlay').css(display: 'block').animate opacity: 0.8, ->
      $('.matrix').remove()
      elements = []
      width = $('#wrapper').width()
      minWidth = 400
      maxWidth = width * 0.6
      matrixWidth = gate.matrix.length * 100
      matrixWidth = if matrixWidth > maxWidth then maxWidth else matrixWidth
      matrixWidth = if matrixWidth < minWidth then minWidth else matrixWidth
      margin = (width - matrixWidth - 100) / 2
      $matrix = $ '<div>',
        class: 'matrix'
        css:
          margin: "10% #{margin}px"
          width: matrixWidth
      $('#wrapper').append $matrix
      $matrix.data 'name', name
      elements.push $ '<div>'
        class: 'default'
        id: 'matrixInfo'
      elements.push $ '<div>'
        class: 'table'
        html: $table
      elements.push  $ '<input>', 
        class: 'button red',
        click: ->
          $('.matrix').html ''
          $('.matrix').remove()
          $('.overlay').animate opacity: 0, ->
            $(this).css display: 'none'
        id: "closeViewMatrixButton", 
        type: 'button'
        val: "close"
      $matrix.append elements
      infoBar '#matrixInfo', 'info', "#{$matrix.data 'name'}"
      
select = 
  algorithm: ->
    $('.description').hide()
    $('.description').parent().children('input').remove()
    $('.answer').remove()
    name = $('#algorithms form').children('select').children(':selected').text()
    switch name
      when 'Deutsch'
        create.form.deutsch()
      when 'Deutsch-Josza'
        create.form.deutschJozsa()
      when 'Grover\'s'
        create.form.grovers()
      when 'Shor\'s'
        create.form.shors()

  gate: ->
    gateType = ->
      name = $('#gateSelect option:selected').text()
      switch name
        when 'PauliX'
          m = $U.PauliX().matrix
        when 'PauliY'
          m = $U.PauliY().matrix
        when 'PauliZ'
          m = $U.PauliZ().matrix
        when 'S'
          m = $U.S().matrix
        when 'T'
          m = $U.T().matrix
        when '√Not'
          m = $U.SqrtNot().matrix
        when 'Hadamard'
          m = $U.Hadamard().matrix
      create.gate m, name
    $form = $('#createSetGateForm')
    $form.children('input').remove()
    $form.append create.button('createSelectedGate', gateType, 'create gate')
  
  ket: ->
    ketType = ->
      name = $('#ketSelect option:selected').text()
      switch name
        when 'Zero'
          k = $K.Zero().col
        when 'One'
          k = $K.One().col
      create.ket k, name
    $form = $('#createSetKetForm')
    $form.children('input').remove()
    $form.append create.button('createSelectedKet', ketType, 'create ket')
  
transition = [null, null]
apply = gate: null, ket: null
kron = [null, null]
drop = 
  transition: ($el) ->
    name = $('.draggingKet').find('.name').html()
    ket = quantumComputer.kets[name]
    if $el.attr('id') is 'transition1Drop' then transition[0] = ket
    if $el.attr('id') is 'transition2Drop' then transition[1] = ket
    info "KET #{ket.name} HAS BEEN DROPPED ONTO TRANSITION AMPLITUDE."
    $el.addClass('dropped').html name
    if transition[0]? and transition[1]?
      $('.transitionAmp').remove()
      if transition[0].size is transition[1].size
        transitionAmplitude = transition[0].transition transition[1]
        $el.parent().append $ '<p>',
          class: 'transitionAmp'
          html: "The Transition Amplitude from #{transition[0].name} to #{transition[1].name} is #{transitionAmplitude}."
      else err "CANNOT COMPUTER TRANSITION AMPLITUDE FROM #{transition[0].name} TO #{transition[1].name}. THEY HAVE DIFFERENENT NUMBERS OF QUBITS."
    $('#clearTransitionButton').remove()
    $el.parent().append create.button 'clearTransition', clear.transition, 'clear', 'red'
  
  apply:
    buttons: ($parent) ->
      $parent.children('input').remove()
      applyNewKet = ->
        gateName = apply.gate.name.replace '<sub> </sub>', ''
        ketName = apply.ket.name.replace '<sub> </sub>', ''
        if apply.gate.size is apply.ket.col.length
          create.ket $K.ApplyGate(apply.gate, apply.ket).col, "#{gateName} → (#{ketName})"
          info "#{gateName} HAS BEEN APPLIED TO #{ketName} RESULTING IN #{gateName}->(#{ketName})."
        else err "#{gateName} CANNOT BE APPLIED TO #{ketName}. ROW/COLUMN SIZES MUST MATCH."
      applyExistingKet = ->
        if apply.gate.size is apply.ket.col.length
          name = apply.ket.name
          apply.ket = $K.ApplyGate apply.gate, apply.ket
          apply.ket.name = name
          $div = $(".ket span.name").filter(-> $(this).html() is apply.ket.name).parent()
          display.ket apply.ket.normalise(), $div
          quantumComputer.kets[apply.ket.name] = apply.ket
          info "#{apply.gate.name} HAS BEEN APPLIED TO #{apply.ket.name}."
        else err "#{apply.gate.name} CANNOT BE APPLIED TO #{apply.ket.name}. ROW/COLUMN SIZES MUST MATCH."
      $parent.append create.button 'applyNewKet', applyNewKet, 'new ket', 'half'
      $parent.append create.button 'applyExistingKet', applyExistingKet, 'existing ket', 'half'
    
    gate: ($el) ->
      name = $('.draggingGate').find('.name').html()
      gate = quantumComputer.gates[name]
      apply.gate = gate
      info "GATE #{name} HAS BEEN DROPPED ONTO APPLY GATE."
      $el.addClass('dropped').html "#{name}"
      $el.parent().children('input').remove()
      if apply.gate? and apply.ket?
        drop.apply.buttons $el.parent()
      $el.parent().append create.button 'clearApply', clear.apply, 'clear', 'red'
      
    ket: ($el) ->
      name = $('.draggingKet').find('.name').html()
      ket = quantumComputer.kets[name]
      apply.ket = ket
      info "KET #{name} HAS BEEN DROPPED ONTO APPLY GATE."
      $el.addClass('dropped').html name
      $el.parent().children('input').remove()
      if apply.gate? and apply.ket?
        drop.apply.buttons $el.parent()
      $el.parent().append create.button 'clearApply', clear.apply, 'clear', 'red'
    
  kron: ($el) ->
    button = ($parent) ->
      $parent.children('input').remove()
      kronInit = ->
        kron0Name = kron[0].name.replace '<sub> </sub>', ''
        kron1Name = kron[1].name.replace '<sub> </sub>', ''
        if kron[0].size * kron[1].size > 128
          warn "CREATING #{kron0Name}⊗#{kron1Name} WILL TAKE A LONG TIME (AND MIGHT EVEN CRASH YOUR COMPUTER). TRY SOME SMALLER GATES."
        else
          info "THINKING..."
          $('.overlay').css(display: 'block').animate opacity: 0.8
          $('.overlay').promise().done ->
            create.gate $M.Kron([kron[0], kron[1]]).matrix, "#{kron0Name}⊗#{kron1Name}"
            $('.overlay').animate opacity: 0, ->
              $(this).css display: 'none'
            info "THE KRONECKER PRODUCT OF #{kron0Name} & #{kron1Name} IS #{kron0Name}⊗#{kron1Name}."
      $parent.append create.button 'kron', kronInit, 'kron'
    
    name = $('.draggingGate').find('.name').html()
    gate = quantumComputer.gates[name]
    if $el.attr('id') is 'kron1Drop' then kron[0] = gate
    if $el.attr('id') is 'kron2Drop' then kron[1] = gate
    info "GATE #{name} HAS BEEN DROPPED ONTO KRONECKER PRODUCT."
    $el.addClass('dropped').html "#{name}"
    if kron[0]? and kron[1]?
      button $el.parent()
    $('#clearKronButton').remove()
    $el.parent().append create.button 'clearKron', clear.kron, 'clear', 'red'

$ ->
  focusClear = ($input, def) ->
    $input.focus ->
      clear.input $(this), def
      
  focusClear $('#ketName'), 'φ'
  focusClear $('#gateName'), 'M'

  focusInfo = ($input, infoMes) ->
    $input.focus ->
      info infoMes
  
  focusInfo $('#ketQubits'), 'INPUT THE NUMBER OF QUBITS FOR THIS KET E.G. \'2\'.'
  focusInfo $('#gateQubits'), 'INPUT THE NUMBER OF QUBITS FOR THIS GATE E.G. \'2\'.'
  
  keyupCheck = ($input, func, maxVal, success, type) ->
    $input.keyup ->
      clearInfoBar()
      clear.element $input.next 'div'
      val = $(this).val()
      func val, maxVal, success, type
  
  keyupCheck $('#ketQubits'), checkInput.qubit, 4, create.form.ket, 'KET'
  keyupCheck $('#gateQubits'), checkInput.qubit, 2, create.form.gate, 'GATE'
    
  changeHandle = ($select, func) ->
    $select.change ->
      $firstOption = $select.children('option').first()
      if $firstOption.text() is 'SELECT:'
        $firstOption.remove()
      func()
      
  changeHandle $('#gateSelect'), select.gate
  changeHandle $('#ketSelect'), select.ket
  changeHandle $('#algorithms form').children('select'), select.algorithm
    
  masonryDiv = ($div, itemClass) ->
    $div.masonry
      isAnimated: true
      itemSelector: itemClass
      columWidth: 1
  
  masonryDiv $('#kets'), '.ket'
  masonryDiv $('#gates'), '.gate'
  
  dropDiv = ($div, accept, func) ->
    $div.droppable
      accept: accept
      activeClass: 'drag'
      hoverClass: 'over'
      drop: ->
        func $(this)
  
  dropDiv $('.transition'), '.ket', drop.transition
  dropDiv $('#ketDrop'), '.ket', drop.apply.ket
  dropDiv $('#gateDrop'), '.gate', drop.apply.gate
  dropDiv $('.kron'), '.gate', drop.kron
          
  $('#clearQuantumComputer').click ->
    clear.quantum()

  $(window).resize ->
    $('.state').css overflow: ''