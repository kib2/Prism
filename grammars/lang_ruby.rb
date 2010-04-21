#!/usr/bin/ruby
# coding: utf-8

#
# ===== RUBY GRAMMAR FILE
#

module RubyLang

  # General Delimited Strings Callback
  # BEWARE THAT :pattern should be a REGEXP !
  
  def cb_gds(me)
    pattern = me[:reg][2]

    if ['[','(','{'].include?(pattern)
      pattern = {'[' => ']', '(' => ')', '{' => '}'}[pattern]
    end
    s = /[#{Regexp.escape(pattern)}]/

    @allRules[:gdsString] = [
      {:pattern => /\#\{/, 
       :style => "Pars",
       :transit => "Entities", 
       :action => "NestedI"},
      
      {:pattern   => s, # '}'
       :style     => "Operators",
       :action    => "#pop"
      }
    ]
    #puts PP.pp(@allRules)
    #@allRules[:gdsString] = to_add
  end

  # Here Documents Callback
  def cb_hd(me)
    pattern = me[:reg][2]
    ["'",'"','`','-'].each do |chr|
      pattern = pattern.gsub(chr,'')
    end
    res = Regexp.escape(pattern)

    to_add = [
            {:pattern => '\\\\', :style => "Entities"},
            {
            :pattern   => /\s*#{res}/,
            :style     => "Operators",
            :action    => "#pop"
            }]
    @allRules[:hdString] = to_add
  end

  def Ruby_dic
    {
  :ruby_root => [
      {:pattern => '\b__END__\b', :style => "Special", :action => "ToEnd", :transit => "BlockComment"},
      {:pattern => '\b[A-Z0-9_]+\b', :style => "Special"},
      {:pattern => '(?<!\\\\)"', :style => "DoubleString", :action => "DoubleString"},
      {:pattern => "(?<!')'", :style => "SingleString", :action => "SingleString"},
      # General Delimited Strings:
      {:pattern => '(%)([\[(!{])', :style => "Operators", :transit => "SingleString", :action => "gdsString", :callback => 'cb_gds'},
      {:pattern => '(%)[Qqx]([\[(!{])', :style => "Operators", :transit => "SingleString", :action => "gdsString", :callback => 'cb_gds'},
      # Here Documents
      {:pattern => /(<<[-]?)([a-zA-Z0-9_"`']+)/, :style => "Operators", :action  => "hdString", :callback => 'cb_hd', :transit => "SingleString"},

      # block comments
      {:pattern => '=begin', :style => "BlockComment", :action => "BlockComment"},
      # Regexps !
      {:pattern => '(\/[^\n]*\/)([mox]*)?', :style => ["Regex","RegexOptions"]},
      {:pattern => '(%r)(\{(?:\}|#\{[A-Za-z0-9]+\}|[^}])*\})', :style => ["RegexOptions","Regex"]},
      # Others
      {:pattern => 'attr_accessor|attr_reader', :style => "Entities2"},
      {:pattern => '#!\/usr\/bin\/ruby\s*', :style => "Shebang"},
      {:pattern => '#.*', :style => "Comment"},
      {:pattern => '\b-?[0-9][0-9.xA-F]*\b', :style => "Number"},
      {:pattern => '\b(alias|and|BEGIN|begin|break|case|define_method|defined|each|each_with_index|else|elsif|END|end|ensure|for|if|include|in|new|next|not|or|puts|raise|redo|rescue|retry|require|return|super|then|throw|undef|unless|until|when|while|yield)\b', :style => "Keywords"},
      {:pattern => '\b(Array|Bignum|Binding|Class|Continuation|Dir|Exception|FalseClass|File::Stat|File|Fixnum|Fload|Hash|Integer|IO|MatchData|Method|Module|NilClass|Numeric|Object|Proc|Range|Regexp|String|Struct::TMS|Symbol|ThreadGroup|Thread|Time|TrueClass)\b', :style => "Keywords2"},
      {:pattern => '\b(do)\b', :style => "Keywords3"},
      {:pattern => '(:)([A-Za-z][A-Za-z0-9_]*)', :style => ["Operators","Types"]},
      {:pattern => '(@[a-z][A-Za-z0-9_]*)', :style => "Dico"},
      {:pattern => '[.]|\||\\\\|<|>|=|:|\+|-|\*|\^|\$|\?|\!|%', :style => "Operators"},
      {:pattern => ',|;|\[|\]|\(|\)|\{|\}', :style => "Pars"},
      {:pattern => '\b(true|false|nil|self)\b', :style => "Logic"},
      {:pattern => '\b(class)\b(\s+)([a-zA-Z0-9_]+)', :style => ["Entities3","Root","className"]},
      {:pattern => '\b(class)\b(\s+)([a-zA-Z0-9_]+)(\s+?)(<?)(\s+?)([a-zA-Z0-9_]+?)', :style => ["Entities3","Root","className","Root","Operators","Root","className"]},
      {:pattern => '\b(def)\b(\s+)(\w+)', :style => ["Entities2","Root","funcName"]},
      {:pattern => '\b(module)\b(\s+)([a-zA-Z0-9_]+)', :style => ["Entities4","Root","className"]}
    ],

    ## Double string state
  :DoubleString => [
      {:pattern => '\#\{.*?\}', :style => "Entities"},
      {:pattern => "\\\\", :style => "SingleString", :action => "Escape1"},
      {:pattern => '"', :style => "DoubleString", :action => "#pop"}
      #{:pattern => '(?<!\\\\)"', :style => "DoubleString", :action => "#pop"}
    ],

    ## Single string state
  :SingleString => [
      {:pattern => "\\\\", :style => "SingleString", :action => "Escape2"},
      {:pattern => "'", :style => "SingleString", :action => "#pop"}
      #{:pattern => "(?<!\\\\)'", :style => "SingleString", :action => "#pop"}
    ],
    
    ## Double string escape
  :Escape1 => [
      {:pattern => '\\"', :style => "SingleString", :action => "#pop"},
      {:pattern => ".", :style => "SingleString", :action => "#pop"}
    ],
    
    ## Single string escape
  :Escape2 => [
      {:pattern => "\\'", :style => "SingleString", :action => "#pop"},
      {:pattern => ".", :style => "SingleString", :action => "#pop"}
    ],

    ## Comment block state
  :BlockComment => [
      {:pattern => /(\b(?:(?:https?|ftp):\/\/|mailto:)\S*[^\s!"\'',.:;?])/, :style => "Url"},
      {:pattern => '"', :style => "DoubleString", :action => "DoubleString"},
      {:pattern => '=end', :style => "BlockComment", :action => "#pop"}
    ],

    ## Regexps
  :regexp       => [
      {:pattern => '(?<!\\\\)(\/)([mox]*)?', :style => ["Regex","RegexOptions"], :action => "#pop"},
      {:pattern => '(\\\\\\\\\/)([mox]*)?', :style => ["Regex","RegexOptions"], :action => "#pop"},
      {:pattern => '\#\{.*?\}', :style => "Entities"}
  ],

  # ToEnd
  :ToEnd => [],
    
  # NestedI (Used inside %Q{...} strings wich can contain #{...} expansions )
  :NestedI => [{:pattern => '\}', :style => "Pars", :action => "#pop"}],
  }

  end

end # Module