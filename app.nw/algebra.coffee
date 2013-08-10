class Calculation
  @parse: (formula) ->
    prefix = null
    a = formula.split ''
    sep = formula.search /[^a-z]/
    if sep == -1
      console.error "invalid calculation: missing separator"
      return null
    separator = formula.charAt(sep)
    operands = formula.split(separator)
    if formula.charAt(formula.length - 1) == separator
      operands.pop()  # trailing separator
    operator = operands.shift()
    unless operator of @factories
      console.error "unknown calculation: #{operator}"
      return null
    @factories[operator].parse operands

class Transliteration extends Calculation
  @parse: (args) ->
    return null if args.length != 2
    x = new Transliteration
    [x.left, x.right] = args[0..1]
    if x.left.length != x.right.length
      console.error "error parsing transliteration"
      return null
    return x

class Transformation extends Calculation
  @parse: (args) ->
    return null if args.length != 2
    x = new Transformation
    try
      [x.left, x.right] = (new RegExp a, 'g' for a in args[0..1])
    catch error
      console.error "error parsing transformation: #{error}"
      return null
    return x

class Erasion extends Calculation
  @parse: (args) ->
    return null if args.length != 1
    x = new Erasion
    try
      x.pattern = new RegExp args[0], 'g'
    catch error
      console.error "error parsing erasion: #{error}"
      return null
    return x

class Derivation extends Transformation
  @parse: (args) -> super args

class Fuzzing extends Derivation
  @parse: (args) -> super args

class Abbreviation extends Derivation
  @parse: (args) -> super args

Calculation.factories =
  xlit: Transliteration
  xform: Transformation
  erase: Erasion
  derive: Derivation
  fuzz: Fuzzing
  abbrev: Abbreviation

class Rule
  constructor: (@formula) ->
    @calc = Calculation.parse(@formula)
    @error = !@calc
