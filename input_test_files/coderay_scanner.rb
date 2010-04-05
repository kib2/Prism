module CodeRay
  module Scanners

class Ruby < Scanner

  RESERVED_WORDS = [
    'and', 'def', 'end', 'in', 'or', 'unless', 'begin',
    'defined?', 'ensure', 'module', 'redo', 'super', 'until',
    'BEGIN', 'break', 'do', 'next', 'rescue', 'then',
    'when', 'END', 'case', 'else', 'for', 'retry',
    'while', 'alias', 'class', 'elsif', 'if', 'not', 'return',
    'undef', 'yield',
  ]

  DEF_KEYWORDS = ['def']
  MODULE_KEYWORDS = ['class', 'module']
  DEF_NEW_STATE = WordList.new(:initial).
    add(DEF_KEYWORDS, :def_expected).
    add(MODULE_KEYWORDS, :module_expected)

  WORDS_ALLOWING_REGEXP = [
    'and', 'or', 'not', 'while', 'until', 'unless', 'if', 'elsif', 'when'
  ]
  REGEXP_ALLOWED = WordList.new(false).
    add(WORDS_ALLOWING_REGEXP, :set)

  PREDEFINED_CONSTANTS = [
    'nil', 'true', 'false', 'self',
    'DATA', 'ARGV', 'ARGF', '__FILE__', '__LINE__',
  ]

  IDENT_KIND = WordList.new(:ident).
    add(RESERVED_WORDS, :reserved).
    add(PREDEFINED_CONSTANTS, :pre_constant)

  METHOD_NAME = / #{IDENT} [?!]? /xo
  METHOD_NAME_EX = /
   #{METHOD_NAME}  # common methods: split, foo=, empty?, gsub!
   | \*\*?         # multiplication and power
   | [-+~]@?       # plus, minus
   | [\/%&|^`]     # division, modulo or format strings, &and, |or, ^xor, `system`
   | \[\]=?        # array getter and setter
   | <=?>? | >=?   # comparison, rocket operator
   | << | >>       # append or shift left, shift right
   | ===?          # simple equality and case equality
  /ox
  GLOBAL_VARIABLE = / \$ (?: #{IDENT} | \d+ | [~&+`'=\/,;_.<>!@0$?*":F\\] | -[a-zA-Z_0-9] ) /ox

  DOUBLEQ = / "  [^"\#\\]*  (?: (?: \#\{.*?\} | \#(?:$")?  | \\. ) [^"\#\\]*  )* "?  /ox
  SINGLEQ = / '  [^'\\]*    (?:                              \\.   [^'\\]*    )* '?  /ox
  STRING  = / #{SINGLEQ} | #{DOUBLEQ} /ox
  SHELL   = / `  [^`\#\\]*  (?: (?: \#\{.*?\} | \#(?:$`)?  | \\. ) [^`\#\\]*  )* `?  /ox
  REGEXP  = / \/ [^\/\#\\]* (?: (?: \#\{.*?\} | \#(?:$\/)? | \\. ) [^\/\#\\]* )* \/? /ox

  DECIMAL = /\d+(?:_\d+)*/  # doesn't recognize 09 as octal error
  OCTAL = /0_?[0-7]+(?:_[0-7]+)*/
  HEXADECIMAL = /0x[0-9A-Fa-f]+(?:_[0-9A-Fa-f]+)*/
  BINARY = /0b[01]+(?:_[01]+)*/

  EXPONENT = / [eE] [+-]? #{DECIMAL} /ox
  FLOAT = / #{DECIMAL} (?: #{EXPONENT} | \. #{DECIMAL} #{EXPONENT}? ) /
  INTEGER = /#{OCTAL}|#{HEXADECIMAL}|#{BINARY}|#{DECIMAL}/

  def reset
    super
    @regexp_allowed = false
  end

  def next_token
    return if @scanner.eos?

    kind = :error
    if @scanner.scan(/\s+/)  # in every state
      kind = :space
      @regexp_allowed = :set if @regexp_allowed or @scanner.matched.index(?\n)  # delayed flag setting

    elsif @state == :def_expected
      if @scanner.scan(/ (?: (?:#{IDENT}(?:\.|::))* | (?:@@?|$)? #{IDENT}(?:\.|::) ) #{METHOD_NAME_EX} /ox)
        kind = :method
        @state = :initial
      else
        @scanner.getch
      end
      @state = :initial

    elsif @state == :module_expected
      if @scanner.scan(/<</)
        kind = :operator
      else
        if @scanner.scan(/ (?: #{IDENT} (?:\.|::))* #{IDENT} /ox)
          kind = :method
        else
          @scanner.getch
        end
        @state = :initial
      end

    elsif # state == :initial
      # IDENTIFIERS, KEYWORDS
      if @scanner.scan(GLOBAL_VARIABLE)
        kind = :global_variable
      elsif @scanner.scan(/ @@ #{IDENT} /ox)
        kind = :class_variable
      elsif @scanner.scan(/ @ #{IDENT} /ox)
        kind = :instance_variable
      elsif @scanner.scan(/ __END__\n ( (?!\#CODE\#) .* )? | \#[^\n]* | =begin(?=\s).*? \n=end(?=\s|\z)(?:[^\n]*)? /mx)
        kind = :comment
      elsif @scanner.scan(METHOD_NAME)
        if @last_token_dot
          kind = :ident
        else
          matched = @scanner.matched
          kind = IDENT_KIND[matched]
          if kind == :ident and matched =~ /^[A-Z]/
            kind = :constant
          elsif kind == :reserved
            @state = DEF_NEW_STATE[matched]
            @regexp_allowed = REGEXP_ALLOWED[matched]
          end
        end

      elsif @scanner.scan(STRING)
        kind = :string
      elsif @scanner.scan(SHELL)
        kind = :shell
      elsif @scanner.scan(/<<
        (?:
          ([a-zA-Z_0-9]+)
            (?: .*? ^\1$ | .* )
        |
          -([a-zA-Z_0-9]+)
            (?: .*? ^\s*\2$ | .* )
        |
          (["\'`]) (.+?) \3
            (?: .*? ^\4$ | .* )
        |
          - (["\'`]) (.+?) \5
            (?: .*? ^\s*\6$ | .* )
        )
      /mxo)
        kind = :string
      elsif @scanner.scan(/\//) and @regexp_allowed
        @scanner.unscan
        @scanner.scan(REGEXP)
        kind = :regexp
/%(?:[Qqxrw](?:\([^)#\\\\]*(?:(?:#\{.*?\}|#|\\\\.)[^)#\\\\]*)*\)?|\[[^\]#\\\\]*(?:(?:#\{.*?\}|#|\\\\.)[^\]#\\\\]*)*\]?|\{[^}#\\\\]*(?:(?:#\{.*?\}|#|\\\\.)[^}#\\\\]*)*\}?|<[^>#\\\\]*(?:(?:#\{.*?\}|#|\\\\.)[^>#\\\\]*)*>?|([^a-zA-Z\\\\])(?:(?!\1)[^#\\\\])*(?:(?:#\{.*?\}|#|\\\\.)(?:(?!\1)[^#\\\\])*)*\1?)|\([^)#\\\\]*(?:(?:#\{.*?\}|#|\\\\.)[^)#\\\\]*)*\)?|\[[^\]#\\\\]*(?:(?:#\{.*?\}|#|\\\\.)[^\]#\\\\]*)*\]?|\{[^}#\\\\]*(?:(?:#\{.*?\}|#|\\\\.)[^}#\\\\]*)*\}?|<[^>#\\\\]*(?:(?:#\{.*?\}|#|\\\\.)[^>#\\\\]*)*>?|([^a-zA-Z\s\\\\])(?:(?!\2)[^#\\\\])*(?:(?:#\{.*?\}|#|\\\\.)(?:(?!\2)[^#\\\\])*)*\2?|\\\\[^#\\\\]*(?:(?:#\{.*?\}|#)[^#\\\\]*)*\\\\?)/
      elsif @scanner.scan(/:(?:#{GLOBAL_VARIABLE}|#{METHOD_NAME_EX}|#{STRING})/ox)
        kind = :symbol
      elsif @scanner.scan(/
        \? (?:
          [^\s\\]
        |
          \\ (?:M-\\C-|C-\\M-|M-\\c|c\\M-|c|C-|M-))? (?: \\ (?: . | [0-7]{3} | x[0-9A-Fa-f][0-9A-Fa-f] )
        )
      /mox)
        kind = :integer

      elsif @scanner.scan(/ [-+*\/%=<>;,|&!()\[\]{}~?] | \.\.?\.? | ::? /x)
        kind = :operator
        @regexp_allowed = :set if @scanner.matched[-1,1] =~ /[~=!<>|&^,\(\[+\-\/\*%]\z/
      elsif @scanner.scan(FLOAT)
        kind = :float
      elsif @scanner.scan(INTEGER)
        kind = :integer
      else
        @scanner.getch
      end
    end

    token = Token.new @scanner.matched, kind

    if kind == :regexp
      token.text << @scanner.scan(/[eimnosux]*/)
    end

    @regexp_allowed = (@regexp_allowed == :set)  # delayed flag setting

    token
  end
end

register Ruby, 'ruby', 'rb'

  end
end
module CodeRay
  module Scanners

class Ruby < Scanner

  RESERVED_WORDS = [
    'and', 'def', 'end', 'in', 'or', 'unless', 'begin',
    'defined?', 'ensure', 'module', 'redo', 'super', 'until',
    'BEGIN', 'break', 'do', 'next', 'rescue', 'then',
    'when', 'END', 'case', 'else', 'for', 'retry',
    'while', 'alias', 'class', 'elsif', 'if', 'not', 'return',
    'undef', 'yield',
  ]

  DEF_KEYWORDS = ['def']
  MODULE_KEYWORDS = ['class', 'module']
  DEF_NEW_STATE = WordList.new(:initial).
    add(DEF_KEYWORDS, :def_expected).
    add(MODULE_KEYWORDS, :module_expected)

  WORDS_ALLOWING_REGEXP = [
    'and', 'or', 'not', 'while', 'until', 'unless', 'if', 'elsif', 'when'
  ]
  REGEXP_ALLOWED = WordList.new(false).
    add(WORDS_ALLOWING_REGEXP, :set)

  PREDEFINED_CONSTANTS = [
    'nil', 'true', 'false', 'self',
    'DATA', 'ARGV', 'ARGF', '__FILE__', '__LINE__',
  ]

  IDENT_KIND = WordList.new(:ident).
    add(RESERVED_WORDS, :reserved).
    add(PREDEFINED_CONSTANTS, :pre_constant)

  METHOD_NAME = / #{IDENT} [?!]? /xo
  METHOD_NAME_EX = /
   #{METHOD_NAME}  # common methods: split, foo=, empty?, gsub!
   | \*\*?         # multiplication and power
   | [-+~]@?       # plus, minus
   | [\/%&|^`]     # division, modulo or format strings, &and, |or, ^xor, `system`
   | \[\]=?        # array getter and setter
   | <=?>? | >=?   # comparison, rocket operator
   | << | >>       # append or shift left, shift right
   | ===?          # simple equality and case equality
  /ox
  GLOBAL_VARIABLE = / \$ (?: #{IDENT} | \d+ | [~&+`'=\/,;_.<>!@0$?*":F\\] | -[a-zA-Z_0-9] ) /ox

  DOUBLEQ = / "  [^"\#\\]*  (?: (?: \#\{.*?\} | \#(?:$")?  | \\. ) [^"\#\\]*  )* "?  /ox
  SINGLEQ = / '  [^'\\]*    (?:                              \\.   [^'\\]*    )* '?  /ox
  STRING  = / #{SINGLEQ} | #{DOUBLEQ} /ox
  SHELL   = / `  [^`\#\\]*  (?: (?: \#\{.*?\} | \#(?:$`)?  | \\. ) [^`\#\\]*  )* `?  /ox
  REGEXP  = / \/ [^\/\#\\]* (?: (?: \#\{.*?\} | \#(?:$\/)? | \\. ) [^\/\#\\]* )* \/? /ox

  DECIMAL = /\d+(?:_\d+)*/  # doesn't recognize 09 as octal error
  OCTAL = /0_?[0-7]+(?:_[0-7]+)*/
  HEXADECIMAL = /0x[0-9A-Fa-f]+(?:_[0-9A-Fa-f]+)*/
  BINARY = /0b[01]+(?:_[01]+)*/

  EXPONENT = / [eE] [+-]? #{DECIMAL} /ox
  FLOAT = / #{DECIMAL} (?: #{EXPONENT} | \. #{DECIMAL} #{EXPONENT}? ) /
  INTEGER = /#{OCTAL}|#{HEXADECIMAL}|#{BINARY}|#{DECIMAL}/

  def reset
    super
    @regexp_allowed = false
  end

  def next_token
    return if @scanner.eos?

    kind = :error
    if @scanner.scan(/\s+/)  # in every state
      kind = :space
      @regexp_allowed = :set if @regexp_allowed or @scanner.matched.index(?\n)  # delayed flag setting

    elsif @state == :def_expected
      if @scanner.scan(/ (?: (?:#{IDENT}(?:\.|::))* | (?:@@?|$)? #{IDENT}(?:\.|::) ) #{METHOD_NAME_EX} /ox)
        kind = :method
        @state = :initial
      else
        @scanner.getch
      end
      @state = :initial

    elsif @state == :module_expected
      if @scanner.scan(/<</)
        kind = :operator
      else
        if @scanner.scan(/ (?: #{IDENT} (?:\.|::))* #{IDENT} /ox)
          kind = :method
        else
          @scanner.getch
        end
        @state = :initial
      end

    elsif # state == :initial
      # IDENTIFIERS, KEYWORDS
      if @scanner.scan(GLOBAL_VARIABLE)
        kind = :global_variable
      elsif @scanner.scan(/ @@ #{IDENT} /ox)
        kind = :class_variable
      elsif @scanner.scan(/ @ #{IDENT} /ox)
        kind = :instance_variable
      elsif @scanner.scan(/ __END__\n ( (?!\#CODE\#) .* )? | \#[^\n]* | =begin(?=\s).*? \n=end(?=\s|\z)(?:[^\n]*)? /mx)
        kind = :comment
      elsif @scanner.scan(METHOD_NAME)
        if @last_token_dot
          kind = :ident
        else
          matched = @scanner.matched
          kind = IDENT_KIND[matched]
          if kind == :ident and matched =~ /^[A-Z]/
            kind = :constant
          elsif kind == :reserved
            @state = DEF_NEW_STATE[matched]
            @regexp_allowed = REGEXP_ALLOWED[matched]
          end
        end

      elsif @scanner.scan(STRING)
        kind = :string
      elsif @scanner.scan(SHELL)
        kind = :shell
      elsif @scanner.scan(/<<
        (?:
          ([a-zA-Z_0-9]+)
            (?: .*? ^\1$ | .* )
        |
          -([a-zA-Z_0-9]+)
            (?: .*? ^\s*\2$ | .* )
        |
          (["\'`]) (.+?) \3
            (?: .*? ^\4$ | .* )
        |
          - (["\'`]) (.+?) \5
            (?: .*? ^\s*\6$ | .* )
        )
      /mxo)
        kind = :string
      elsif @scanner.scan(/\//) and @regexp_allowed
        @scanner.unscan
        @scanner.scan(REGEXP)
        kind = :regexp
/%(?:[Qqxrw](?:\([^)#\\\\]*(?:(?:#\{.*?\}|#|\\\\.)[^)#\\\\]*)*\)?|\[[^\]#\\\\]*(?:(?:#\{.*?\}|#|\\\\.)[^\]#\\\\]*)*\]?|\{[^}#\\\\]*(?:(?:#\{.*?\}|#|\\\\.)[^}#\\\\]*)*\}?|<[^>#\\\\]*(?:(?:#\{.*?\}|#|\\\\.)[^>#\\\\]*)*>?|([^a-zA-Z\\\\])(?:(?!\1)[^#\\\\])*(?:(?:#\{.*?\}|#|\\\\.)(?:(?!\1)[^#\\\\])*)*\1?)|\([^)#\\\\]*(?:(?:#\{.*?\}|#|\\\\.)[^)#\\\\]*)*\)?|\[[^\]#\\\\]*(?:(?:#\{.*?\}|#|\\\\.)[^\]#\\\\]*)*\]?|\{[^}#\\\\]*(?:(?:#\{.*?\}|#|\\\\.)[^}#\\\\]*)*\}?|<[^>#\\\\]*(?:(?:#\{.*?\}|#|\\\\.)[^>#\\\\]*)*>?|([^a-zA-Z\s\\\\])(?:(?!\2)[^#\\\\])*(?:(?:#\{.*?\}|#|\\\\.)(?:(?!\2)[^#\\\\])*)*\2?|\\\\[^#\\\\]*(?:(?:#\{.*?\}|#)[^#\\\\]*)*\\\\?)/
      elsif @scanner.scan(/:(?:#{GLOBAL_VARIABLE}|#{METHOD_NAME_EX}|#{STRING})/ox)
        kind = :symbol
      elsif @scanner.scan(/
        \? (?:
          [^\s\\]
        |
          \\ (?:M-\\C-|C-\\M-|M-\\c|c\\M-|c|C-|M-))? (?: \\ (?: . | [0-7]{3} | x[0-9A-Fa-f][0-9A-Fa-f] )
        )
      /mox)
        kind = :integer

      elsif @scanner.scan(/ [-+*\/%=<>;,|&!()\[\]{}~?] | \.\.?\.? | ::? /x)
        kind = :operator
        @regexp_allowed = :set if @scanner.matched[-1,1] =~ /[~=!<>|&^,\(\[+\-\/\*%]\z/
      elsif @scanner.scan(FLOAT)
        kind = :float
      elsif @scanner.scan(INTEGER)
        kind = :integer
      else
        @scanner.getch
      end
    end

    token = Token.new @scanner.matched, kind

    if kind == :regexp
      token.text << @scanner.scan(/[eimnosux]*/)
    end

    @regexp_allowed = (@regexp_allowed == :set)  # delayed flag setting

    token
  end
end

register Ruby, 'ruby', 'rb'

  end
end
module CodeRay
  module Scanners

class Ruby < Scanner

  RESERVED_WORDS = [
    'and', 'def', 'end', 'in', 'or', 'unless', 'begin',
    'defined?', 'ensure', 'module', 'redo', 'super', 'until',
    'BEGIN', 'break', 'do', 'next', 'rescue', 'then',
    'when', 'END', 'case', 'else', 'for', 'retry',
    'while', 'alias', 'class', 'elsif', 'if', 'not', 'return',
    'undef', 'yield',
  ]

  DEF_KEYWORDS = ['def']
  MODULE_KEYWORDS = ['class', 'module']
  DEF_NEW_STATE = WordList.new(:initial).
    add(DEF_KEYWORDS, :def_expected).
    add(MODULE_KEYWORDS, :module_expected)

  WORDS_ALLOWING_REGEXP = [
    'and', 'or', 'not', 'while', 'until', 'unless', 'if', 'elsif', 'when'
  ]
  REGEXP_ALLOWED = WordList.new(false).
    add(WORDS_ALLOWING_REGEXP, :set)

  PREDEFINED_CONSTANTS = [
    'nil', 'true', 'false', 'self',
    'DATA', 'ARGV', 'ARGF', '__FILE__', '__LINE__',
  ]

  IDENT_KIND = WordList.new(:ident).
    add(RESERVED_WORDS, :reserved).
    add(PREDEFINED_CONSTANTS, :pre_constant)

  METHOD_NAME = / #{IDENT} [?!]? /xo
  METHOD_NAME_EX = /
   #{METHOD_NAME}  # common methods: split, foo=, empty?, gsub!
   | \*\*?         # multiplication and power
   | [-+~]@?       # plus, minus
   | [\/%&|^`]     # division, modulo or format strings, &and, |or, ^xor, `system`
   | \[\]=?        # array getter and setter
   | <=?>? | >=?   # comparison, rocket operator
   | << | >>       # append or shift left, shift right
   | ===?          # simple equality and case equality
  /ox
  GLOBAL_VARIABLE = / \$ (?: #{IDENT} | \d+ | [~&+`'=\/,;_.<>!@0$?*":F\\] | -[a-zA-Z_0-9] ) /ox

  DOUBLEQ = / "  [^"\#\\]*  (?: (?: \#\{.*?\} | \#(?:$")?  | \\. ) [^"\#\\]*  )* "?  /ox
  SINGLEQ = / '  [^'\\]*    (?:                              \\.   [^'\\]*    )* '?  /ox
  STRING  = / #{SINGLEQ} | #{DOUBLEQ} /ox
  SHELL   = / `  [^`\#\\]*  (?: (?: \#\{.*?\} | \#(?:$`)?  | \\. ) [^`\#\\]*  )* `?  /ox
  REGEXP  = / \/ [^\/\#\\]* (?: (?: \#\{.*?\} | \#(?:$\/)? | \\. ) [^\/\#\\]* )* \/? /ox

  DECIMAL = /\d+(?:_\d+)*/  # doesn't recognize 09 as octal error
  OCTAL = /0_?[0-7]+(?:_[0-7]+)*/
  HEXADECIMAL = /0x[0-9A-Fa-f]+(?:_[0-9A-Fa-f]+)*/
  BINARY = /0b[01]+(?:_[01]+)*/

  EXPONENT = / [eE] [+-]? #{DECIMAL} /ox
  FLOAT = / #{DECIMAL} (?: #{EXPONENT} | \. #{DECIMAL} #{EXPONENT}? ) /
  INTEGER = /#{OCTAL}|#{HEXADECIMAL}|#{BINARY}|#{DECIMAL}/

  def reset
    super
    @regexp_allowed = false
  end

  def next_token
    return if @scanner.eos?

    kind = :error
    if @scanner.scan(/\s+/)  # in every state
      kind = :space
      @regexp_allowed = :set if @regexp_allowed or @scanner.matched.index(?\n)  # delayed flag setting

    elsif @state == :def_expected
      if @scanner.scan(/ (?: (?:#{IDENT}(?:\.|::))* | (?:@@?|$)? #{IDENT}(?:\.|::) ) #{METHOD_NAME_EX} /ox)
        kind = :method
        @state = :initial
      else
        @scanner.getch
      end
      @state = :initial

    elsif @state == :module_expected
      if @scanner.scan(/<</)
        kind = :operator
      else
        if @scanner.scan(/ (?: #{IDENT} (?:\.|::))* #{IDENT} /ox)
          kind = :method
        else
          @scanner.getch
        end
        @state = :initial
      end

    elsif # state == :initial
      # IDENTIFIERS, KEYWORDS
      if @scanner.scan(GLOBAL_VARIABLE)
        kind = :global_variable
      elsif @scanner.scan(/ @@ #{IDENT} /ox)
        kind = :class_variable
      elsif @scanner.scan(/ @ #{IDENT} /ox)
        kind = :instance_variable
      elsif @scanner.scan(/ __END__\n ( (?!\#CODE\#) .* )? | \#[^\n]* | =begin(?=\s).*? \n=end(?=\s|\z)(?:[^\n]*)? /mx)
        kind = :comment
      elsif @scanner.scan(METHOD_NAME)
        if @last_token_dot
          kind = :ident
        else
          matched = @scanner.matched
          kind = IDENT_KIND[matched]
          if kind == :ident and matched =~ /^[A-Z]/
            kind = :constant
          elsif kind == :reserved
            @state = DEF_NEW_STATE[matched]
            @regexp_allowed = REGEXP_ALLOWED[matched]
          end
        end

      elsif @scanner.scan(STRING)
        kind = :string
      elsif @scanner.scan(SHELL)
        kind = :shell
      elsif @scanner.scan(/<<
        (?:
          ([a-zA-Z_0-9]+)
            (?: .*? ^\1$ | .* )
        |
          -([a-zA-Z_0-9]+)
            (?: .*? ^\s*\2$ | .* )
        |
          (["\'`]) (.+?) \3
            (?: .*? ^\4$ | .* )
        |
          - (["\'`]) (.+?) \5
            (?: .*? ^\s*\6$ | .* )
        )
      /mxo)
        kind = :string
      elsif @scanner.scan(/\//) and @regexp_allowed
        @scanner.unscan
        @scanner.scan(REGEXP)
        kind = :regexp
/%(?:[Qqxrw](?:\([^)#\\\\]*(?:(?:#\{.*?\}|#|\\\\.)[^)#\\\\]*)*\)?|\[[^\]#\\\\]*(?:(?:#\{.*?\}|#|\\\\.)[^\]#\\\\]*)*\]?|\{[^}#\\\\]*(?:(?:#\{.*?\}|#|\\\\.)[^}#\\\\]*)*\}?|<[^>#\\\\]*(?:(?:#\{.*?\}|#|\\\\.)[^>#\\\\]*)*>?|([^a-zA-Z\\\\])(?:(?!\1)[^#\\\\])*(?:(?:#\{.*?\}|#|\\\\.)(?:(?!\1)[^#\\\\])*)*\1?)|\([^)#\\\\]*(?:(?:#\{.*?\}|#|\\\\.)[^)#\\\\]*)*\)?|\[[^\]#\\\\]*(?:(?:#\{.*?\}|#|\\\\.)[^\]#\\\\]*)*\]?|\{[^}#\\\\]*(?:(?:#\{.*?\}|#|\\\\.)[^}#\\\\]*)*\}?|<[^>#\\\\]*(?:(?:#\{.*?\}|#|\\\\.)[^>#\\\\]*)*>?|([^a-zA-Z\s\\\\])(?:(?!\2)[^#\\\\])*(?:(?:#\{.*?\}|#|\\\\.)(?:(?!\2)[^#\\\\])*)*\2?|\\\\[^#\\\\]*(?:(?:#\{.*?\}|#)[^#\\\\]*)*\\\\?)/
      elsif @scanner.scan(/:(?:#{GLOBAL_VARIABLE}|#{METHOD_NAME_EX}|#{STRING})/ox)
        kind = :symbol
      elsif @scanner.scan(/
        \? (?:
          [^\s\\]
        |
          \\ (?:M-\\C-|C-\\M-|M-\\c|c\\M-|c|C-|M-))? (?: \\ (?: . | [0-7]{3} | x[0-9A-Fa-f][0-9A-Fa-f] )
        )
      /mox)
        kind = :integer

      elsif @scanner.scan(/ [-+*\/%=<>;,|&!()\[\]{}~?] | \.\.?\.? | ::? /x)
        kind = :operator
        @regexp_allowed = :set if @scanner.matched[-1,1] =~ /[~=!<>|&^,\(\[+\-\/\*%]\z/
      elsif @scanner.scan(FLOAT)
        kind = :float
      elsif @scanner.scan(INTEGER)
        kind = :integer
      else
        @scanner.getch
      end
    end

    token = Token.new @scanner.matched, kind

    if kind == :regexp
      token.text << @scanner.scan(/[eimnosux]*/)
    end

    @regexp_allowed = (@regexp_allowed == :set)  # delayed flag setting

    token
  end
end

register Ruby, 'ruby', 'rb'

  end
end
module CodeRay
  module Scanners

class Ruby < Scanner

  RESERVED_WORDS = [
    'and', 'def', 'end', 'in', 'or', 'unless', 'begin',
    'defined?', 'ensure', 'module', 'redo', 'super', 'until',
    'BEGIN', 'break', 'do', 'next', 'rescue', 'then',
    'when', 'END', 'case', 'else', 'for', 'retry',
    'while', 'alias', 'class', 'elsif', 'if', 'not', 'return',
    'undef', 'yield',
  ]

  DEF_KEYWORDS = ['def']
  MODULE_KEYWORDS = ['class', 'module']
  DEF_NEW_STATE = WordList.new(:initial).
    add(DEF_KEYWORDS, :def_expected).
    add(MODULE_KEYWORDS, :module_expected)

  WORDS_ALLOWING_REGEXP = [
    'and', 'or', 'not', 'while', 'until', 'unless', 'if', 'elsif', 'when'
  ]
  REGEXP_ALLOWED = WordList.new(false).
    add(WORDS_ALLOWING_REGEXP, :set)

  PREDEFINED_CONSTANTS = [
    'nil', 'true', 'false', 'self',
    'DATA', 'ARGV', 'ARGF', '__FILE__', '__LINE__',
  ]

  IDENT_KIND = WordList.new(:ident).
    add(RESERVED_WORDS, :reserved).
    add(PREDEFINED_CONSTANTS, :pre_constant)

  METHOD_NAME = / #{IDENT} [?!]? /xo
  METHOD_NAME_EX = /
   #{METHOD_NAME}  # common methods: split, foo=, empty?, gsub!
   | \*\*?         # multiplication and power
   | [-+~]@?       # plus, minus
   | [\/%&|^`]     # division, modulo or format strings, &and, |or, ^xor, `system`
   | \[\]=?        # array getter and setter
   | <=?>? | >=?   # comparison, rocket operator
   | << | >>       # append or shift left, shift right
   | ===?          # simple equality and case equality
  /ox
  GLOBAL_VARIABLE = / \$ (?: #{IDENT} | \d+ | [~&+`'=\/,;_.<>!@0$?*":F\\] | -[a-zA-Z_0-9] ) /ox

  DOUBLEQ = / "  [^"\#\\]*  (?: (?: \#\{.*?\} | \#(?:$")?  | \\. ) [^"\#\\]*  )* "?  /ox
  SINGLEQ = / '  [^'\\]*    (?:                              \\.   [^'\\]*    )* '?  /ox
  STRING  = / #{SINGLEQ} | #{DOUBLEQ} /ox
  SHELL   = / `  [^`\#\\]*  (?: (?: \#\{.*?\} | \#(?:$`)?  | \\. ) [^`\#\\]*  )* `?  /ox
  REGEXP  = / \/ [^\/\#\\]* (?: (?: \#\{.*?\} | \#(?:$\/)? | \\. ) [^\/\#\\]* )* \/? /ox

  DECIMAL = /\d+(?:_\d+)*/  # doesn't recognize 09 as octal error
  OCTAL = /0_?[0-7]+(?:_[0-7]+)*/
  HEXADECIMAL = /0x[0-9A-Fa-f]+(?:_[0-9A-Fa-f]+)*/
  BINARY = /0b[01]+(?:_[01]+)*/

  EXPONENT = / [eE] [+-]? #{DECIMAL} /ox
  FLOAT = / #{DECIMAL} (?: #{EXPONENT} | \. #{DECIMAL} #{EXPONENT}? ) /
