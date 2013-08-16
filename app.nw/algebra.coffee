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
  calculate: (spelling) ->
    chars = spelling.text.split ''
    xlit_chars = ((if (index = @left.indexOf ch)  == -1 then ch \
      else @right.charAt(index)) for ch in chars)
    result = xlit_chars.join ''
    if result == spelling.text
      [spelling]
    else [
      text: result
      type: spelling.type ? 'normal'
      syllables: spelling.syllables.slice 0
      ancestor: spelling
      modifier: @
    ]

class Transformation extends Calculation
  @parse: (args, Klass = Transformation) ->
    return null if args.length != 2
    x = new Klass
    try
      x.left = new RegExp args[0], 'g'
      x.right = args[1]
    catch error
      console.error "error parsing transformation: #{error}"
      return null
    return x
  calculate: (spelling) ->
    result = spelling.text.replace @left, @right
    if result == spelling.text
      [spelling]
    else [
      text: result
      type: spelling.type ? 'normal'
      syllables: spelling.syllables.slice 0
      ancestor: spelling
      modifier: @
    ]

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
  calculate: (spelling) ->
    if spelling.text.match @pattern
      []
    else
      [spelling]

class Derivation extends Transformation
  @parse: (args) -> super args, Derivation
  calculate: (spelling) ->
    result = super spelling
    if result[0] != spelling
      result[0].type = 'derived'
      result[0].modifier = @
      result.push spelling
    result

class Fuzzing extends Derivation
  @parse: (args) -> super args, Fuzzing
  calculate: (spelling) ->
    result = super spelling
    if result[0] != spelling
      result[0].type = 'fuzzy'
      result[0].modifier = @
    result

class Abbreviation extends Derivation
  @parse: (args) -> super args, Abbreviation
  calculate: (spelling) ->
    result = super spelling
    if result[0] != spelling
      result[0].type = 'abbrev'
      result[0].modifier = @
    result

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
  calculate: (spelling) -> @calc.calculate spelling

class Script
  constructor: (@mapping) ->

  toString: ->
    (k for k, v of @mapping).join ' '

  @fromSyllabary: (syllabary) ->
      script = new Script {}
      for x in syllabary
        script.mapping[x] =
          text: x
          type: 'normal'
          syllables: [x]
      script

class Algebra
  constructor: (@rules) ->

  formatString: (str) ->
    spelling =
      text: str
      type: 'normal'
      syllables: [str]
    for r in @rules
      a = r.calculate spelling
      return '' if a.length == 0
      spelling = r.resultSpelling = a[0]
    spelling.text

  makeProjection: (script) ->
    for r in @rules
      current = script.mapping
      next = {}
      for k, w of current
        a = r.calculate w
        for x in a
          unless x.text of next
            next[x.text] = x
            continue
          y = next[x.text]
          unless y.type is 'merged'
            y = next[x.text] =
              text: x.text
              type: 'merged'
              syllables: y.syllables.slice 0
              threads: [y]
              modifier: r.calc
          for s in x.syllables
            if not s in y.syllables
              y.syllables.push s
          y.threads.push x
      script = r.resultScript = new Script next
      console.log r.formula, script
    script
