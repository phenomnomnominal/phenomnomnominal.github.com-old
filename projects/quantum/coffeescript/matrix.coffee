# ### [Quantum Computer Simulator](../quantum.html)
# *matrix.coffee* contains the **`Matrix`**, **`Hermitian`** and **`Unitary`** classes.
# ___

# ## Error Types:
# Some specific **`Error`** types for these classes:

# <section id='mce'></section>
#
# * **`MatrixConstructorError`**:
#
# >> These errors are thrown when something is wrong in the [**`Matrix`**](#matrix) constructor
class MatrixConstructorError extends Error

# <section id='mme'></section>
#
# * **`MatrixMathError`**:
#
# >> These errors are thrown when something is mathematically wrong a **`Matrix`** function
class MatrixMathError extends Error

# <section id='hce'></section>
#
# * **`HermitianConstructorError`**:
#
# >> These errors are thrown when something is wrong in the [**`Hermitian`**](#hermitian) constructor
class HermitianConstructorError extends Error

# <section id='uce'></section>
#
# * **`UnitaryConstructorError`**:
#
# >> These errors are thrown when something is wrong in the [**`Unitary`**](#unitary) constructor
class UnitaryConstructorError extends Error

# ___

# ## <section id='matrix'>Matrix:</section>
# ___
# The **`Matrix`** class provides a low-level representation of Matrices.
class Matrix
  # ### *constructor:*
  # > The **`Matrix`** constructor requires one parameters:
  #
  # > * A `2D Array` as a representation of the matrix, containing only [**`Complex`**](complex.html#complex) numbers: `m`
  #
  # >The constructor function also takes a single optional parameter.
  #
  # > * A `Number` which multiplies the whole matrix by a scaling value: `constant` - defaults to `1`
  #
  # > If the arguments are of the incorrect type, the constructor will throw a [**`MatrixConstructorError`**](#mce).
  constructor: (m, constant = 1) ->
    unless m?
      throw MatrixConstructorError '`m` must be defined.'
    unless _.isArray m
      throw MatrixConstructorError '`m` must be an Array.'
    for obj in m
      unless _.isArray obj
        throw MatrixConstructorError '`m` must be a 2D Array.'
    unless m.length > 0
      throw MatrixConstructorError '`m` must have more than 0 rows.'
    length = -1
    for n in m
      if length < 0
        length = n.length
      unless n.length is length
        throw MatrixConstructorError '`m` must contain rows of one length.'
    unless length > 0
      throw MatrixConstructorError '`m` must have more than 0 columns.'
    for n in m
      for obj in n
        unless obj instanceof $C
          throw MatrixConstructorError '`m` must only contain Complex numbers.'

    complexM = []
    for x in [0...m.length]
      for y in [0...m[x].length]
        complexM[x] ?= []
        complexM[x][y] = new $C(m[x][y]).multiply constant
    @matrix = complexM
    @rows = @matrix.length
    @columns = @matrix[0].length

  # ___
  # ### Utility Constructor Functions:

  # These functions are attached to the **`Matrix`** class and provide easy access to some commonly generated Matrices:

  # ### *Matrix.Identity:*
  # > **`Matrix.Identity`** creates a new **`Matrix`** where the values *M<sub>ij</sub>* where *i = j* are set to `1`. The size of the **`Matrix`** is determined by `n`, where the resulting **`Matrix`** will be *2<sup>n</sup> x 2<sup>n</sup>*
  @Identity: (n = 1) ->
    n = Math.pow 2, n
    matrix = []
    for r in [0...n]
      matrix[r] = []
      for c in [0...n]
        matrix[r][c] = if r is c then new $C(1) else new $C(0)
    new Matrix(matrix)

  # ### *Matrix.Ones:*
  # > **`Matrix.Ones`** creates a new **`Matrix`** where all values are set to `1`. The size of the **`Matrix`** is determined by `n`, where the resulting **`Matrix`** will be *2<sup>n</sup> x 2<sup>n</sup>*
  @Ones: (n = 1) ->
    n = Math.pow 2, n
    matrix = []
    for r in [0...n]
      matrix[r] = []
      for c in [0...n]
        matrix[r][c] = new $C(1)
    new Matrix(matrix)
    
  # ### *Matrix.Zeroes:*
  # > **`Matrix.Zeroes`** creates a new **`Matrix`** where all values are set to `0`. The size of the **`Matrix`** is determined by `n`, where the resulting **`Matrix`** will be *2<sup>n</sup> x 2<sup>n</sup>*
  @Zeroes: (n = 1) ->
    n = Math.pow 2, n
    matrix = []
    for r in [0...n]
      matrix[r] = []
      for c in [0...n]
        matrix[r][c] = new $C(0)
    new Matrix(matrix)

  # ___
  # ### Utility Functions:

  # ### *print:*
  # > **`print`** outputs a representation of a **Matrix** to the console, e.g:
  #
  # >> **COFFEESCRIPT:**
  #
  # >>     hadamard = $U.Hadamard()
  # >>     hadamard.print 'Hadamard'
  #
  # >> **CONSOLE OUTPUT:**
  #
  # >>     Hadamard MATRIX:
  # >>     [0.7071067811865475 + 0i, 0.7071067811865475 + 0i]
  # >>     [0.7071067811865475 + 0i, -0.7071067811865475 + 0i]
  print: (id) ->
    console.log "#{id} MATRIX:"
    for r in [0...@rows]
      str = '['
      for c in [0...@columns]
        str += "#{@matrix[r][c]}, "
      str = "#{str[0...str.length - 2]}]"
      console.log str
    this

  # ___
  # ### Prototypical Instance Functions:

  # These functions are attached to each instance of the **`Matrix`** class - changing the function of one **`Matrix`** changes the function on all other **`Matrixs`** as well. These functions act on a **`Matrix`** instance in place - the original object is modified.

  # ### *scale:*
  # > **`scale`** scales each value in a **Matrix** by a given scaling factor, `s`.
  scale: (s) ->
    for r in [0...@rows]
      for c in [0...@columns]
        @matrix[r][c].multiply s
    this

  # ### *negate:*
  # > **`negate`** scales each value in a **Matrix** by `-1`.
  negate: ->
    this.scale -1

  # ### *transpose:*
  # > **`transpose`** transposes a **Matrix** by flipping the **Matrix** across the trace.
  transpose: ->
    trans = clone(this)
    for r in [0...@rows]
      for c in [0...@columns]
        trans.matrix[c][r] = @matrix[r][c]
    trans

  # ### *conj:*
  # > **`conj`** conjugates a **Matrix** by conjugating each of the values in the **Matrix**.
  conj: ->
    conj = clone(this)
    for r in [0...@rows]
      for c in [0...@columns]
        conj.matrix[r][c] = @matrix[r][c].conjugate()
    conj

  # ### *isUnitary:*
  # > **`isUnitary`** tests if a **Matrix** is [unitary](http://en.wikipedia.org/wiki/Unitary_matrix) by checking that *UU<sub>ct</sub> = I*, where *U<sub>ct</sub>* is the *conjugate transpose* of *U*, and *I* is an *Identity* matirx.
  #
  # > In quantum systems, all matrices representing [gate](http://en.wikipedia.org/wiki/Quantum_gate) operations must be unitary. This function is therefore called whenever a **`Unitary`** is initialised.
  isUnitary: ->
    if @rows isnt @columns
      no
    else
      @size = @rows
      conjTrans = clone(this).conj().transpose()
      if Matrix.Multiply(this, conjTrans).isIdentity() then yes else no

  # ### *isHermitian:*
  # > **`isHermitian`** tests if a **Matrix** is [Hermitian](http://en.wikipedia.org/wiki/Hermitian_matrix) by checking that *U<sub>ct</sub> = U*, where *U<sub>ct</sub>* is the *conjugate transpose* of *U*.
  #
  # > In quantum systems, all matrices representing [measurement](http://en.wikipedia.org/wiki/Quantum_measurement) operations must be Hermitian. This function is therefore called whenever a **`Hermitian`** is initialised.
  isHermitian: ->
    if @rows isnt @columns
      no
    else
      @size = @rows
      for r in [0...@size]
        for c in [0...@size]
          val = @matrix[r][c]
          conj = $C.Conjugate @matrix[c][r]
          if not $C.Equals val, conj then return no
      yes

  # ### *isIdentity:*
  # > **`isIdentity`** tests if a **Matrix** is an [Identity](http://en.wikipedia.org/wiki/Identity_matrix) matrix by checking that *U<sub>ij</sub>* is `1` where *i = j*, and `0` everywhere else.
  isIdentity: ->
    if @rows isnt @columns
      no
    else
      for r in [0...@rows]
        for c in [0...@columns]
          if r is c
            if not @matrix[r][c].equals new $C(1) then return no
          else
            if not @matrix[r][c].equals new $C(0) then return no
      yes

  # ### *clone:*
  # > **`clone`** creates an exact copy of the existing **Matrix**.
  clone = (m) ->
    new Matrix(m.matrix)

  # ___
  # ### Static Functions:

  # These functions belong to the **`Matrix`** class - any object arguments are not modified and a new object is always returned.

  # ### *Matrix.Add:*
  # > **`Matrix.Add`** adds any number of **`Matrix`** together.
  @Add = (m1, m2, mn...) ->
    if m1.columns isnt m2.columns and m1.rows isnt m2.rows
      throw MatrixMathError 'Matrix dimensions incorrect for addition.'
    result = []
    for i in [0...m1.rows]
      result[i] = []
      for j in [0...m1.columns]
        result[i][j] = $C.Add(m1.matrix[i][j], m2.matrix[i][j])
    add = new Matrix(result)
    for m in mn
      add = Matrix.Multiply add, m
    add  

  # ### *Matrix.Multiply:*
  # > **`Matrix.Multiply`** multiplies any number of **`Matrixs`** together.
  @Multiply = (m1, m2, mn...) ->
    if m1.columns isnt m2.rows
      throw MatrixMathError 'Matrix dimensions incorrect for multiplication.'
    result = []
    for i in [0...m1.rows]
      result.push []
    for r in [0...m1.rows]
      for c in [0...m2.columns]
        val = new $C(0)
        for k in [0...m1.columns]
          val.add $C.Multiply(m1.matrix[r][k], m2.matrix[k][c])
        result[r][c] = val
    mul = new Matrix(result)
    for m in mn
      mul = Matrix.Multiply mul, m
    mul
  
  # ### <section id='kron'>*Matrix.Kron:*</section>
  # > **`Matrix.Kron`** evaluates the [Kronecker Product](http://en.wikipedia.org/wiki/Kronecker_product) of any number of **`Matrix`**.
  @Kron = (matrices) ->
    if matrices.length is 1
      return matrices[0]
    else
      m1 = matrices[0]
      m2 = matrices[1]
      kronProd = []
      height1 = m1.rows
      width1 = m1.columns
      height2 = m2.rows
      width2 = m2.columns
      for m in [0...height1 * height2]
        kronProd.push []
      for m in [0...height1]
        for n in [0...width1]
          for p in [0...height2]
            for q in [0...width2]
              newM = m * height2 + p
              newN = n * width2 + q
              val = $C.Multiply m1.matrix[m][n], m2.matrix[p][q]
              kronProd[newM][newN] = val
      return Matrix.Kron [new Matrix(kronProd)].concat matrices[2..]

# ___

# ## <section id='hermitian'>Hermitian:</section>
# ___
# The **`Hermitian`** class provides a representation of [Hermitian](http://en.wikipedia.org/wiki/Hermitian_matrix) matrices, which are a special type of **Matrix** which has the property that *U<sub>ct</sub> = U*, where *U<sub>ct</sub>* is the *conjugate transpose* of *U*.
#
# In quantum systems, all matrices representing [measurement](http://en.wikipedia.org/wiki/Quantum_measurement) operations must be Hermitian. 
class Hermitian extends Matrix
  # ### *constructor:*
  # > The **`Hermitian`** constructor requires one parameters:
  #
  # > * A `2D Array` as a representation of the matrix, containing only [**`Complex`**](complex.html#complex) numbers: `m`
  #
  # >The constructor function also takes a single optional parameter.
  #
  # > * A `Number` which multiplies the whole matrix by a scaling value: `constant` - defaults to `1`
  #
  # > The **Matrix** constructor is called with these parameters, and the resulting **Matrix** is tested for being Hermitian. If it is not, the constructor will throw a [**`HermitianConstructorError`**](#hce).
  constructor: (m, constant = 1) ->
    super(m, constant)
    unless @isHermitian()
      throw HermitianConstructorError 'Matrix is not Hermitian.'

# ___

# ## <section id='unitary'>Unitary:</section>
# ___
# The **`Unitary`** class provides a representation of [Unitary](http://en.wikipedia.org/wiki/Unitary_matrix) matrices, which are a special type of **Matrix** which has the property that *U<sub>ct</sub>U = I*, where *U<sub>ct</sub>* is the *conjugate transpose* of *U*, and *I* is an *Identity* matrix.
#
# In quantum systems, all matrices representing [gate](http://en.wikipedia.org/wiki/Quantum_gate) operations must be unitary. 
class Unitary extends Matrix
  # ### *constructor:*
  # > The **`Unitary`** constructor requires one parameters:
  #
  # > * A `2D Array` as a representation of the matrix, containing only [**`Complex`**](complex.html#complex) numbers: `m`
  #
  # >The constructor function also takes a single optional parameter.
  #
  # > * A `Number` which multiplies the whole matrix by a scaling value: `constant` - defaults to `1`
  #
  # > The **Matrix** constructor is called with these parameters, and the resulting **Matrix** is tested for being Unitary. If it is not, the constructor will throw a [**`UnitaryConstructorError`**](#uce).
  constructor: (m, constant = 1) ->
    super(m, constant)
    unless @isUnitary()
      throw UnitaryConstructorError 'Matrix is not Unitary.'

  # ___
  # ### Gate Constructor Functions:

  # These functions are attached to the **`Unitary`** class and provide easy access to some commonly generated quantum gates:

  # ### *Unitary.PauliX:*
  # > *Unitary.PauliX* creates a new **`Unitary`** that represents the PauliX (σ<sub>x</sub>) gate:
  # > 
  # >> <img src="../images/pauliX.png"/>
  @PauliX = ->
    new Unitary([[new $C(0), new $C(1)],
                 [new $C(1), new $C(0)]])

  # ### *Unitary.PauliY:*
  # > *Unitary.PauliY* creates a new **`Unitary`** that represents the PauliY (σ<sub>y</sub>) gate:
  # > 
  # >> <img src="../images/pauliY.png"/>
  @PauliY = ->
    new Unitary([[new $C(0), new $C('-i')],
                 [new $C('i'), new $C(0)]])

  # ### *Unitary.PauliZ:*
  # > *Unitary.PauliZ* creates a new **`Unitary`** that represents the PauliZ (σ<sub>z</sub>) gate:
  # > 
  # >> <img src="../images/pauliZ.png"/>
  @PauliZ = ->
    new Unitary([[new $C(1), new $C(0)],
                 [new $C(0), new $C(-1)]])

  # ### *Unitary.S:*
  # > *Unitary.S* creates a new **`Unitary`** that represents the S gate:
  # > 
  # >> <img src="../images/s.png"/>
  @S = ->
    new Unitary([[new $C(1), new $C(0)],
                 [new $C(0), new $C('i')]])

  # ### *Unitary.T:*
  # > *Unitary.T* creates a new **`Unitary`** that represents the Phase shift gate (with `θ` = `π / 4` by default):
  # > 
  # >> <img src="../images/t.png"/>
  @T = (θ) ->
    e = $C.Exp
    π = Math.PI
    if not θ?
      θ = π / 4
    iθ = new $C('i').multiply(θ)
    new Unitary([[new $C(1), new $C(0)],
                 [new $C(0), e(iθ)]])

  # ### *Unitary.Hadamard:*
  # > *Unitary.Hadamard* creates a new **`Unitary`** that represents the Hadamard gate:
  # > 
  # >> <img src="../images/hadamard.png"/>
  @Hadamard = ->
    oneOverRoot2 = 1 / Math.sqrt 2
    new Unitary([[new $C(1), new $C(1)],
                 [new $C(1), new $C(-1)]], oneOverRoot2)
  
  # ### *Unitary.SqrtNot:*
  # > *Unitary.SqrtNot* creates a new **`Unitary`** that represents the SqrtNot gate:
  # > 
  # >> <img src="../images/sqrtnot.png"/>
  @SqrtNot = ->
    oneOverRoot2 = 1 / Math.sqrt 2
    new Unitary([[new $C(1), new $C(-1)],
                 [new $C(1), new $C(1)]], oneOverRoot2)

  # ### *Unitary.CreateNBitHaystack:*
  # > *Unitary>CreateNBitHaystack* is used to create the Unitary oracle that is used in the Deutsch-Jozsa Algorithm.
  @CreateNBitDeutschJozsaOracle = (n, solution) ->
    range = [0...(2* Math.pow 2, n)]
    x = _.flatten([i,i] for i in [0...(range.length / 2)])
    y = (i % 2 for i in range)
    solution = solution.toString(2)
    while solution.length < range.length /2
      solution = "0#{solution}"
    fx = _.flatten([i,i] for i in solution.split '')
    yXORfx = (y[i] ^ fx[i] for i in range)
    xy = (parseInt "#{x[i].toString(2)}#{y[i].toString(2)}", 2 for i in range)
    xyXORfx = (parseInt "#{x[i].toString(2)}#{yXORfx[i].toString(2)}", 2 for i in range)
    matrix = $M.Zeroes n + 1
    for i in [0...xy.length]
      matrix.matrix[xy[i]][xyXORfx[i]] = new $C(1)
    matrix

  # ### *Unitary.CreateNBitHaystack:*
  # > *Unitary>CreateNBitHaystack* is used to create the Unitary oracle that is used in Grover's algorithm, with the appropriate rows flipped for the given solution, e.g.:
  # 
  # > For `n` = `2`, and `solution` = `3`
  # > 
  # >> <img src="../images/haystack.png"/>
  @CreateNBitHaystack = (n, solution) ->
    if solution >= Math.pow(2, n) or solution < 0
      throw MatrixMathError 'The solution must be smaller than 2^n and greater than 0.'
    matrix = $U.Identity(n + 1).matrix
    matrix[2 * solution][2 * solution] = new $C(0)
    matrix[2 * solution][2 * solution + 1] = new $C(1)
    matrix[2 * solution + 1][2 * solution] = new $C(1)
    matrix[2 * solution + 1][2 * solution + 1] = new $C(0)
    new $U(matrix)

# ___
# ## Exports:

# The [**`Matrix`**](#matrix), [**`Hermitian`**](#hermitian) and [**`Unitary`**](#unitary) classes are added to the global `root` object, with the aliases [**`$M`**](#matrix), [**`$O`**](#hermitian) and [**`$U`**](#unitary) respectively.
root = exports ? this
root.$M = root.Matrix = Matrix
root.$O = root.Hermitian = Hermitian
root.$U = root.Unitary = Unitary