# ### [Quantum Computer Simulator](../quantum.html)
# *bra-ket.coffee* contains the **`Bra`** and **`Ket`** classes.
# ___

# ## Error Types:
# Some specific **`Error`** types for these classes:

# <section id='bce'></section>
#
# * **`BraConstructorError`**:
#
# >> These errors are thrown when something is wrong in the [**`Bra`**](#bra) constructor
class BraConstructorError extends Error
  
# <section id='kce'></section>
#
# * **`KetConstructorError`**:
#
# >> These errors are thrown when something is wrong in the [**`Ket`**](#ket) constructor
class KetConstructorError extends Error
  
# ___

# ## <section id='bra'>Bra:</section>
# ___
# The **`Bra`** class provides representation of a quantum state as a row matrix. Used internally for computing state probabilities.
class Bra
  # ### *constructor:*
  # > The **`Bra`** constructor requires one parameters:
  #
  # > * A `Array` as a representation of the quantum state matrix, containing only [**`Complex`**](complex.html#complex) numbers: `row`
  #
  # >The constructor function also takes a single optional parameter.
  #
  # > * A `Number` which multiplies the whole matrix by a scaling value: `constant` - defaults to `1`
  #
  # > If the arguments are of the incorrect type, the constructor will throw a [**`BraConstructorError`**](#bce).
  constructor: (@row, constant = 1) ->
    unless @row?
      throw BraConstructorError '`row` must be defined.'
    unless _.isArray @row
      throw BraConstructorError '`row` must be an Array.'
    unless _.isNumber constant
      throw BraConstructorError '`constant` must be a Number'
    for v in [0...@row.length]
      @row[v] = new $C(@row[v]).multiply constant
    @size = @row.length

# ___

# ## <section id='ket'>Ket:</section>
# ___
# The **`Ket`** class provides representation of a quantum state as a column matrix.
class Ket
  # ### *constructor:*
  # > The **`Ket`** constructor requires one parameters:
  #
  # > * A `Array` as a representation of the quantum state matrix, containing only [**`Complex`**](complex.html#complex) numbers: `col`
  #
  # >The constructor function also takes a single optional parameter.
  #
  # > * A `Number` which multiplies the whole matrix by a scaling value: `constant` - defaults to `1`
  #
  # > If the arguments are of the incorrect type, the constructor will throw a [**`KetConstructorError`**](#kce).
  constructor: (@col, constant = 1) ->
    unless @col?
      throw KetConstructorError '`col` must be defined.'
    unless _.isArray @col
      throw KetConstructorError '`col` must be an Array.'
    unless _.isNumber constant
      throw KetConstructorError '`constant` must be a Number'
    @size = @col.length
    for v in [0...@size]
      @col[v] = new $C(@col[v]).multiply constant
    @sumAbsSqrd = _.reduce col, ((p, n) => p + Math.pow(n.mag(), 2)), 0

  # ___
  # ### Utility Constructor Functions:

  # These functions are attached to the **`Ket`** class and provide easy access to some commonly generated Kets:

  # ### *Ket.Zero:*
  # > **`Ket.Zero`** creates a new **`Ket`** where the state is set to `0`.
  @Zero: ->
    new $K([new $C(1), new $C(0)])

  # ### *Ket.One:*
  # > **`Ket.One`** creates a new **`Ket`** where the state is set to `1`.
  @One: ->
    new $K([new $C(0), new $C(1)])

  # ___
  # ### Utility Functions:

  # ### *print:*
  # > **`print`** outputs a representation of a **Ket** to the console, e.g:
  #
  # >> **COFFEESCRIPT:**
  #
  # >>     zero = $K.Zero()
  # >>     zero.print 'Zero'
  #
  # >> **CONSOLE OUTPUT:**
  #
  # >>     Zero KET:
  # >>     1 + 0i
  # >>     0 + 0i
    
  print: (id) ->
    console.log "#{id} KET:"
    for c in @col
      console.log "#{c}"
    this
    
  # ### *toBra:*
  # > **`toBra`** is used internally to convert a **Ket** in column matrix form into a **Bra** in row matrix form.
  toBra = (ket) ->
    row = (new $C(val).conjugate() for val in ket.col)
    new Bra(row)
    
  # ___
  # ### Prototypical Instance Functions:

  # These functions are attached to each instance of the **`Ket`** class - changing the function of one **`Ket`** changes the function on all other **`Kets`** as well. These functions act on a **`Ket`** instance in place - the original object is modified.
    
  # ### *probability:*
  # > **`probability`** returns that a probability is in a given state. A **`Ket`** represents *N* bits, and can therefore be in *2<sup>N</sup>* states. The `n` parameter indicates which state to find the probability of the **`Ket`** being in. 
  #
  # > Answers are rounded to prevent probabilities such as `0.24999999999999999` which can occur due to floating-point rounding.
  probability: (n) ->
    if @sumAbsSqrd isnt 0
      precision = +(Math.pow(@col[n].mag(), 2) / @sumAbsSqrd).toPrecision 10
      rounded = Math.round precision
      if Math.abs(precision - rounded) < 1e-10 then rounded else precision
    else 0

  # ### *normalise:*
  # > **`normalise`** divides each value in a **`Ket`** by a constant factor - the sum of the absolute values, squared - to make the length of the vector `1`, thereby *normalising* the probabilities.
  normalise: ->
    if @sumAbsSqrd isnt 0
      @col = (@col[v].divide(Math.sqrt @sumAbsSqrd) for v in [0...@size])
      @sumAbsSqrd = 1
    this

  # ### *transition:*
  # > **`transition`** finds the transition amplitude between this **`Ket`** and another given **`Ket`**, by converting the second **`Ket`** into a [**`Bra`**](#bra) and multiplying the two together.
  transition: (ket) ->
    bra = toBra ket
    dotProduct = _.reduce [0...@size],
      (p, n) => p.add bra.row[n].multiply @col[n],
      new $C(0)

  # ### *ignore:*
  # > **`ignore`** disregards `n` Qubits in a given **`Ket`**, by combining the probabilities that that state occurs with *n* bits lower than it. 
  #
  # > For example, if `1` Qubit is to be ignored, the new probability that the state is `|0>` is the probability that the old state was `|00>` plus the probability that the old state was `|01>`.
  ignore: (n) ->
    @normalise()
    val = []
    for i in [0...(@col.length / Math.pow(2, n))]
      startN = Math.pow(2, n) * i
      endN = startN + Math.pow(2, n)
      val[i] = new $C(0)
      for p in [startN...endN]
        val[i].add new $C(@probability p)
    @col = val
    @size = val.length
    @sumAbsSqrd = _.reduce @col, ((p, n) => p + Math.pow(n.mag(), 2)), 0
    this

  # ___
  # ### Static Functions:

  # These functions belong to the **`Ket`** class - any object arguments are not modified and a new object is always returned.

  # ### *Ket.Combine:*
  # > **`Ket.Combine`** merges two **`Kets`** together by calling the [**`Matrix.Kron`**](matrix.html#kron) function on the two column matrices. 
  #
  # > The resulting **`Ket`** is in the state that is the combination of the two **`Kets`**, e.g.
  #
  # >>     kZ = $K.Zero() #|0> 
  # >>     KO = $K.One()  #|1> 
  # >>     ket = $K.Combine kZ, kO 
  # >>     ket.print 'ket' 
  # >>     ket KET: 
  # >>     0 + 0i 
  # >>     1 + 0i 
  # >>     0 + 0i 
  # >>     0 + 0i 
  @Combine: (ket1, ket2) ->
    ket1Col = ([v] for v in ket1.col)
    ket1Mat = new $M(ket1Col)
    ket2Col = ([v] for v in ket2.col)
    ket2Mat = new $M(ket2Col)
    new $K(_.flatten $M.Kron([ket1Mat, ket2Mat]).matrix)

  # ### *Ket.ApplyGate:*
  # > **`Ket.ApplyGate`** transforms the state of a **`Ket`** by performing a gate operation on it, e.g.
  #
  # >>     kZ = $K.Zero() #|0> 
  # >>     hadamard = $U.Haramard() 
  # >>     ket = $K.ApplyGate hadamard, kZ
  # >>     ket.print 'ket' 
  # >>     ket KET: 
  # >>     0.707 + 0.00i 
  # >>     0.707 + 0.00i 
  @ApplyGate: (gate, ket) ->
    col = ([v] for v in ket.col)
    ketMat = new Matrix(col)
    result = Matrix.Multiply gate, ketMat
    col = _.flatten result.matrix
    new Ket(col)

# ___
# ## Exports:

# The [**`Ket`**](#ket) class is added to the global `root` object, with the alias [**`$K`**](#ket).
root = exports ? this
root.$K = root.Ket = Ket