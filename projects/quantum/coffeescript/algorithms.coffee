# ### [Quantum Computer Simulator](../quantum.html)
# *algorithms.coffee* contains the implementations of the [**`Deutsch`**](#d), [**`Deutsch-Jozsa`**](#dj), [**`Grover`**](#g) and [**`Shor`**](#s) algorithms.
# ___

# ## <section id='q'>Quantum:</section>
#
# The **`Quantum`** object holds references to the functions for each algorithm.
# ___
Quantum =
  
  # ### <section id='d'>**Deutsch**:</section>
  #
  # > The Deutsch Algorithm solves a problem that isn't particularly difficult or particularly important, but it can be solved faster on a quantum computer than on a classical computer.  
  # >
  # > Suppose there is a function ƒ(x) that maps the set {0, 1} onto the set {0, 1}. We want to know whether the function is BALANCED (one-to-one) or CONSTANT (same output for either input). This can be solved on a quantum computer by using the Deutsch Algorithm.
  Deutsch: (oracle) ->
    x = $K.Zero()
    y = $K.One()
    ϕ0 = $K.Combine(x, y)
    HkH = $M.Kron([$U.Hadamard(), $U.Hadamard()])
    ϕ1 = $K.ApplyGate(HkH, ϕ0)
    ϕ2 = $K.ApplyGate(oracle, ϕ1)
    HkI = $M.Kron([$U.Hadamard(), $U.Identity()])
    ϕ3 = $K.ApplyGate(HkI, ϕ2)
    ϕ4 = new $K(ϕ3.col)
    ϕ4.ignore 1
    
    answer = (ket) -> 
      if ket.probability(0) is 1 then 'Constant'
      else if ket.probability(0) is 0 then 'Balanced'
    
    results = 
      'ϕ<sub>0</sub>': ϕ0
      'H⊗H': HkH
      'ϕ<sub>1</sub> = H⊗H → ϕ<sub>0</sub>': ϕ1
      'U<sub>ƒ</sub>': oracle
      'ϕ<sub>2</sub> = Oracle → ϕ<sub>1</sub>': ϕ2
      'H⊗I': HkI
      'ϕ<sub>3</sub> = H⊗I → ϕ<sub>2</sub>': ϕ3
      'answer': answer ϕ4
    
  # ### <section id='dj'>**DeutschJozsa**:</section>
  #
  # >The [Deutsch-Jozsa Algorithm](http://en.wikipedia.org/wiki/Deutsch%E2%80%93Jozsa_algorithm) is an extension to the Deutsch Algorithm.
	#
	# > Instead of a function which maps {0, 1} onto {0, 1}, we have a function that map the set {0, 1}<sup>n</sup> onto the set {0, 1}. We want to determine whether this function is <strong>BALANCED</strong> (one-to-one) or <strong>NOT BALANCED</strong> (not one-to-one).
	#
	# > Again, this is not a particularly useful problem to solve, but the Deutsch-Jozsa Algorithm is one of the first algorithms that is exponentially faster on a quantum computer than on a classical computer.
  DeutschJozsa: (oracle, n) ->
    xn = ($K.Zero() for i in [1...n])
    x = _.reduce(xn,
      (p, n) => $K.Combine p, n,
      $K.Zero())
    y = $K.One()
    HkN = $M.Kron($U.Hadamard() for i in [0...n])
    HkNkH = $M.Kron([HkN, $U.Hadamard()])
    HkNkI = $M.Kron([HkN, $U.Identity()])
    ϕ0 = $K.Combine(x, y).normalise()
    ϕ1 = $K.ApplyGate(HkNkH, ϕ0).normalise()
    ϕ2 = $K.ApplyGate oracle, ϕ1
    ϕ3 = $K.ApplyGate(HkNkI, ϕ2).normalise()
    ϕ4 = new $K(ϕ3.col)
    ϕ4.ignore 1
    
    answer = (ket) ->
      if ket.probability(0) is 1 then 'Constant'
      else if ket.probability(0) is 0 then 'Balanced'
      else 'Not Constant or Balanced'
    
    results = 
      'ϕ<sub>0</sub>': ϕ0
      'H<sup>⊗N+1</sup>': HkNkH
      'ϕ<sub>1</sub> = H<sup>⊗N+1</sup> → ϕ<sub>0</sub>': ϕ1
      'U<sub>ƒ</sub>': oracle
      'ϕ<sub>2</sub> = Oracle → ϕ<sub>1</sub>': ϕ2
      'H<sup>⊗N</sup>⊗I': HkNkI
      'ϕ<sub>3</sub> = H<sup>⊗N</sup>⊗I → ϕ<sub>2</sub>': ϕ3
      'answer': answer ϕ4

  # ### <section id='g'>**Grover**:</section>
  #
  # >[Grover's Algorithm](http://en.wikipedia.org/wiki/Grover%27s_algorithm) is a quantum algorithm for searching an unsorted database with N entries in O(N<sup>1/2</sup>) time. This is better than an equivalent classical algorithm, which would take at least linear time.
  #
  # > As an example, if we has a list of all N bit strings, e.g. for 4 bits, '0000', '0001', '0010', ... , of which one string is the correct result, Grover's Algorithm can select the correct answer from all the possibilities.
  #
  # > Grover's Algorithm is probabilistic, in that it gives the correct answer with high, but not certain, probability. This chance of getting the correct answer can be increased by repeating the algorithm.
  Grover: (oracle) ->
    n = Math.log(oracle.size / 2) / Math.LN2
    xn = ($K.Zero() for i in [1...n])
    x = _.reduce(xn,
      (p, n) => $K.Combine p, n,
      $K.Zero())
    y = new $K([new $C(0), new $C(1)])
    HkN = $M.Kron($U.Hadamard() for i in [0...n])
    HkNkH = $M.Kron([HkN, $U.Hadamard()])
    HkNkI = $M.Kron([HkN, $U.Identity()])
    negI = $M.Identity(n).negate()
    μ = $M.Ones(n).scale(2 / Math.pow(2, n))
    invMean = $M.Add(negI, μ)
    invMeankI = $M.Kron([invMean, $U.Identity()])
    ϕ0 = $K.Combine(x, y)
    ϕ1 = $K.ApplyGate(HkNkH, ϕ0)
    origϕ1 = new $K(ϕ1.col)
    ϕ2 = []
    for i in [0...Math.max(Math.floor((Math.PI / 4) * Math.sqrt Math.pow(2, n)), 2)]
      ϕ2a = $K.ApplyGate(oracle, ϕ1)
      ϕ2b = $K.ApplyGate(invMeankI, ϕ2a)
      ϕ2[i] = 'ϕ2a': ϕ2a, 'ϕ2b': ϕ2b
      ϕ1 = ϕ2b
    ϕ3 = ϕ1
    ϕ4 = new $K(ϕ3.col)
    ϕ4.ignore 1
    
    answer = (ket) ->
      samples = []
      for i in [0...ket.size]
        for j in [0...ket.probability(i) * 1000]
          samples.push i
      str = samples[Math.floor Math.random() * samples.length].toString 2
      while str.length < n
        str = "0#{str}"
      "'#{str}'"
      
    results = 
      'ϕ<sub>0</sub>': ϕ0
      'H<sup>⊗N+1</sup>': HkNkH
      'ϕ<sub>1</sub><sup>1</sup> = H<sup>⊗N+1</sup> → ϕ<sub>0</sub>': origϕ1
      'U<sub>ƒ</sub>': oracle
      '(µ<sup>-1</sup>)<sup>⊗I</sup>': invMeankI
      'answer': answer ϕ4
    for i in [0...ϕ2.length - 1]
      for own key, val of ϕ2[i]
        if key is 'ϕ2a'
          results["ϕ<sub>2a</sub><sup>#{i + 1}</sup> = Oracle → ϕ<sub>1</sub><sup>#{i + 1}</sup>"] = val
        if key is 'ϕ2b'
          results["ϕ<sub>2b</sub><sup>#{i + 1}</sup> = (µ<sup>-1</sup>)<sup>⊗I</sup> → ϕ<sub>2a</sub><sup>#{i + 1}</sup>"] = val
          if i < ϕ2.length - 2
            results["ϕ<sub>1</sub><sup>#{i + 2}</sup> = ϕ<sub>2b</sub><sup>#{i + 1}</sup>"] = val
          else
            results["ϕ<sub>3</sub> = ϕ<sub>2b</sub><sup>#{i + 1}</sup>"] = val
    results
  # ### <section id='s'>**Shor**:</section>
  #
  # > [Shor's Algorithm](http://en.wikipedia.org/wiki/Shor%27s_algorithm') is a quantum algorithm for performing integer factorisation in polynomial time. This is much better than an equivalent classical algorithm, which the most efficient of which runs in sub-exponential time.
  #
  # > Given a number which is a product of two unknown primes, a quantum computer using Shor's Algorithm can determine the prime factors in a reasonable time (compared to a classical computer).
  #
  # > With a large enough quantum computer, this algorithm could be used to break public-key encryption, as these encryption methods rely on the fact that is is difficult to find the factors of large numbers.
  Shor: (N) ->
    result = null
    
    isPrime = (N) ->
      primes = (true for n in [0..N])
      primes[0] = false
      primes[1] = false
      for i in [2..Math.sqrt(N)]
        if primes[i]
          for j in [Math.pow(i, 2)..N] by i
            primes[j] = false
      primes[N]
      
    if isPrime N
      return [1, N]
    a = Math.floor(Math.random() * N) + 2
    
    gcd = (a, b) -> if b is 0 then a else gcd(b, a % b)
    
    c = gcd(a, N)
    if c isnt 1
      result = [N / c, N / (N / c)]
      
    mod = (a, b) -> ((a % b) + b) % b
    
    if not result?
      aRmodNVals = [1]
      r = 1
      while aRmodN isnt 1
        aRmodN = mod Math.pow(a, r), N
        r++
        aRmodNVals = [aRmodN].concat aRmodNVals
        if _.isNaN aRmodN
          break
      period = r - 1
      if mod(period, 2) is 1 or Math.pow(a, (period / 2)) is mod(-1, N) or _.isNaN(aRmodNVals[0])
        return Quantum.Shor(N)
      result = [gcd(Math.pow(a, (period / 2)) + 1, N), gcd(Math.pow(a, (period / 2)) - 1, N)]
      if result[0] is result[1]
        return Quantum.Shor(N)
      else 
        return result
    [f1, f2] = result
    [f1, f2]

# ___
# ## Exports:

# The [**`Quantum`**](#q) object is added to the global `root` object. 
root = exports ? this
root.Quantum = Quantum