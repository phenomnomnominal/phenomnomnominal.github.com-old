# ### [Quantum Computer Simulator](../quantum.html)
# *complex.coffee* contains the **`Complex`** class.
# ___

# ## Error Types:
# Some specific **`Error`** types for the **`Complex`** class:

# <section id='cce'></section>
#
# * **`ComplexConstructorError`**:
#
# >> These errors are thrown when something is wrong in the [**`Complex`**](#complex) constructor
class ComplexConstructorError extends Error

# <section id='cme'></section>
#
# * **`ComplexMathError`**:
#
# >> These errors are thrown when something is mathematically wrong a **`Complex`** function
class ComplexMathError extends Error

# ___

# ## <section id='complex'>Complex:</section>
# ___
# The **`Complex`** class provides a representation of Complex numbers, stored as a real part and an imaginary part.
class Complex
  # ### *constructor:*
  # > The **`Complex`** constructor can work in several ways:
  #
  # 1. It can take two `Numbers`, `r` and `i`, representing the *real* and *imaginary* parts respectively.
  #
  # 2. It can take an exisitng **`Complex`**, and leave it as it is.
  #
  # 3. It can take a `String` in the form *a + bi*
  #
  # > If the arguments are of the incorrect types or in the wrong format, the constructor will throw a [**`ComplexConstructorError`**](#cce).
  constructor: (r = new Complex(0), i = 0) ->
    if _.isNumber(r) and _.isNumber(i)
      @r = r
      @i = i
    else if _.isString r
      if not _.isNaN +r
        return new Complex(+r)
      regexRealImag = /^([-+]?(?:\d+|\d*\.\d+)+)([-+]?(?:\d+|\d*\.\d+)?)?[i]$/i
      regexImag = /^([-+]?(?:\d+|\d*\.\d+)?)?[i]$/i
      string = r.replace /\s+/g, ""
      realImag = string.match regexRealImag
      imag = string.match regexImag
      unless realImag? or imag?
        throw ComplexConstructorError 'Invalid string input: expecting a +/- bi format.'
      if realImag?
        [ari, bri, cri] = realImag
      if imag?
        [ai, bi] = imag
      if realImag? and imag?
        
        @r = 0
        @i = +bi
      if realImag? and not imag?
        if cri is '-'
          cri = -1
        if cri is '+'
          cri = 1
        @r = +bri
        @i = +cri
      if not realImag? and imag?
        if not bi?
          @r = 0
          @i = 1
        if bi is '-'
          @r = 0
          @i = -1
    else if r instanceof Complex
      @r = r.r
      @i = r.i
    else
      throw ComplexConstructorError 'Incorrect Complex constructor arguments.'

  # ___
  # ### Utility Functions:
  
  # ### *toString:*
  # > **`toString`** overrides the default `Object` implementation of **`toString`** to provide a readable, limited precision representation of a **`Complex`**
  toString: ->
    r = if @r % 1 is 0 then Math.floor(@r) else @r.toFixed 2
    i = if @i % 1 is 0 then Math.floor(@i) else @i.toFixed 2
    if r isnt 0 and i is 0
      "#{r}"
    else if i isnt 0 and r is 0
      if i is -1
       "-i"
      else if i is 1
        "i"
      else 
        "#{i}i"
    else if r isnt 0 and i isnt 0
      "#{r} + #{i}i"
    else if r is 0 and i is 0
      "0"
      

  # ___
  # ### Prototypical Instance Functions:

  # These functions are attached to each instance of the **`Complex`** class - changing the function of one **`Complex`** changes the function on all other **`Complexes`** as well. These functions act on a **`Ket`** instance in place - the original object is modified.

  # ### *add:*
  # > **`add`** adds another **`Complex`** number to the current **`Complex`**. 
  add: (n) ->
    c = new Complex(n)
    @r += c.r
    @i += c.i
    this

  # ### *subtract:*
  # > **`subtract`** subtracts another **`Complex`** number from the current **`Complex`**.    
  subtract: (n) ->
    c = new Complex(n)
    @r -= c.r
    @i -= c.i
    this

  # ### *multiply:*
  # > **`multiply`** multiplies the current **`Complex`** by another **`Complex`** number.
  multiply: (n) ->
    c = new Complex(n)
    a = @r
    b = @i
    @r = a * c.r - b * c.i
    @i = b * c.r + a * c.i
    this

  # ### *divide:*
  # > **`divide`** divides the current **`Complex`** by another **`Complex`** number.
  divide: (n) ->
    c = new Complex(n)
    if c.r is 0 and c.i is 0
      throw ComplexMathError 'Divide: argument `c` cannot be 0 + 0i.'
    denominator = (c.r * c.r + c.i * c.i)
    a = @r
    b = @i
    @r = (a * c.r + b * c.i) / denominator
    @i = (b * c.r - a * c.i) / denominator
    this

  # ### *exp:*
  # > **`exp`** returns *e* to the power of the current **`Complex`** number.
  exp: ->
    @r = Math.cos @i
    @i = Math.sin @i
    this

  # ### *mag:*
  # > **`mag`** returns the magnitude (Vector length) of the current **`Complex`** number.  
  mag: ->
    Math.sqrt @r * @r + @i * @i

  # ### *conjugate:*
  # > **`conjugate`** returns the conjugate (negated complex part) of the current **`Complex`** number.  
  conjugate: ->
    @i *= -1
    this
  
  # ### *equals:*
  # > **`equals`** compares the current **`Complex`** number with another **`Complex`** to check for equality.
  equals: (n) ->
    c = new Complex(n)
    abs = Math.abs
    sign = (val) ->
      if val >= 0 then 1 else -1
    if sign(@r) is sign(c.r) and sign(@i) is sign(c.i)
      diffR = abs(@r) - abs(c.r)
      diffI = abs(@i) - abs(c.i)
      if -1e-10 < diffR < 1e-10 and -1e-10 < diffI < 1e-10 then yes else no
    else no

  # ___
  # ### Static Functions:

  # These functions belong to the **`Complex`** class - any object arguments are not modified and a new object is always returned.

  # ### *Complex.Add:*
  # > **`Complex.Add`** adds two **`Complex`** numbers together. 
  @Add: (a, b) ->
    a = new Complex(a)
    b = new Complex(b)
    a.add b
    
  # ### *Complex.Subtract:*
  # > **`Complex.Subtract`** subtracts one **`Complex`** number from another **`Complex`**.    
  @Subtract: (a, b) ->
    a = new Complex(a)
    b = new Complex(b)
    a.subtract b
    
  # ### *Complex.Multiply:*
  # > **`Complex.Multiply`** multiplies one **`Complex`** by another **`Complex`** number.
  @Multiply: (a, b) ->
    a = new Complex(a)
    b = new Complex(b)
    a.multiply b
  
  # ### *Complex.Divide:*
  # > **`Complex.Divide`** divides one **`Complex`** by another **`Complex`** number.
  @Divide: (a, b) ->
    a = new Complex(a)
    b = new Complex(b)
    a.divide b
    
  # ### *Complex.Exp:*
  # > **`Complex.Exp`** returns *e* to the power of a **`Complex`** number.
  @Exp: (n) ->
    c = new Complex(n)
    c.exp()
 
  # ### *Complex.Mag:*
  # > **`omplex.Mag`** returns the magnitude (Vector length) of a **`Complex`** number.  
  @Mag: (n) ->
    c = new Complex(n)
    c.mag()
    
  # ### *Complex.Conjugate:*
  # > **`Complex.Conjugate`** returns the conjugate (negated complex part) of a **`Complex`** number.  
  @Conjugate: (n) ->
    c = new Complex(n)
    c.conjugate()

  # ### *Complex.Equals:*
  # > **`Complex.Equals`** compares two **`Complex`** numbers to check for equality.
  @Equals: (a, b) ->
    a = new Complex(a)
    b = new Complex(b)
    a.equals b

# ___
# ## Exports:

# The [**`Complex`**](#Complex) class is added to the global `root` object, with the alias [**`$C`**](#complex).    
root = exports ? this
root.$C = root.Complex = Complex