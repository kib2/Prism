{
:rb_root => [
              {:pattern => '(<<-)(.*)', :style => ["Operators","Operators"], "callback" => "cb_longString"},
              {:pattern => '(?<!\\\\)"', :style => "DoubleString", :action => "DoubleString"},
              {:pattern => "(?<!')'", :style => "SingleString", :action => "SingleString"},
              {:pattern => '%Q\{', :style => "SingleString", :action => "QuotedString"},
              {:pattern => '(<<)(.*)$', :style => ["SingleString","FuncName"], 
               :action => "bizString", :callback => 'cb_biz', :transit => "SingleString"},
              {:pattern => '=begin', :style => "BlockComment", :action => "BlockComment"},
              {:pattern => '(?<!\\\\)\/', :style => "Regex", :action => "regexp"},
              {:pattern => 'attr_accessor|attr_reader', :style => "Entities2"},
              {:pattern => '#!\/usr\/bin\/ruby\s*', :style => "Shebang"},
              {:pattern => '#.*', :style => "Comment"},
              {:pattern => '\b-?[0-9][0-9.xA-F]*\b', :style => "Number"},
              {:pattern => '\b[A-Z_]+\b', :style => "Constant1"},
              {:pattern => '\b(alias|and|BEGIN|begin|break|case|define_method|defined|each|each_with_index|else|elsif|END|end|ensure|for|if|include|in|new|next|not|or|puts|raise|redo|rescue|retry|require|return|super|then|throw|undef|unless|until|when|while|yield)\b', :style => "Keywords"},
              {:pattern => '\b(Array|Bignum|Binding|Class|Continuation|Dir|Exception|FalseClass|File::Stat|File|Fixnum|Fload|Hash|Integer|IO|MatchData|Method|Module|NilClass|Numeric|Object|Proc|Range|Regexp|String|Struct::TMS|Symbol|ThreadGroup|Thread|Time|TrueClass)\b', :style => "Keywords2"},
              {:pattern => '\b(do)\b', :style => "Keywords3"},
              {:pattern => '(:)([A-Za-z][A-Za-z0-9_]*)', :style => ["Operators","Types"]},
              {:pattern => '(@[a-z][A-Za-z0-9_]*)', :style => "Dico"},
              {:pattern => '[.]|\||\\\\|<|>|=|:|\+|-|\*|\^|\?|\!|%', :style => "Operators"},
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
                      {:pattern => '\\\\\d', :style => "Entities"},
                      {:pattern => '(?<!\\\\)"', :style => "DoubleString", :action => "#pop"}
  ],
  
  ## Single string state
  :SingleString => [
                      {:pattern => '\$\w+|\$\(.*?\)', :style => "Entities"},
                      {:pattern => '\\\d', :style => "Entities"},
                      {:pattern => "(?<!\\\\)'", :style => "SingleString", :action => "#pop"}
  ],
  
  ## Quoted string state
  :QuotedString => [
                      {:pattern => '\$\w+|\$\(.*?\)', :style => "Entities"},
                      {:pattern => '\}', :style => "SingleString", :action => "#pop"}
  ],
  
  ## Comment block state
  :BlockComment => [
                      {:pattern => '"', :style => "DoubleString", :action => "DoubleString"},
                      {:pattern => '=end', :style => "BlockComment", :action => "#pop"}
  ],
  
  ## Regexps
  :regexp       => [
                      {:pattern => '(?<!\\\\)(\/)([mox]*)?', :style => ["Regex","RegexOptions"], :action => "#pop"},
                      {:pattern => '(\\\\\\\\\/)([mox]*)?', :style => ["Regex","RegexOptions"], :action => "#pop"},
                      {:pattern => '\#\{.*?\}', :style => "Entities"}
                    ]
}