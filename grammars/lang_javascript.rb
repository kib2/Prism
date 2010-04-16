#!/usr/bin/ruby
# coding: utf-8

#
# ===== JAVASCRIPT GRAMMAR FILE
#
module JavascriptLang
  def Javascript_dic 
    {
    :javascript_root => [
      { :pattern => '(?<!\\\\)"', :style => "DoubleString", :action => "DoubleString"},
      { :pattern => "(?<!\\\\)'", :style => "SingleString", :action => "SingleString"},
      { :pattern => '\/\*', :style => "BlockComment", :action => "comment_big"},
      { :pattern => '\b-?[0-9][0-9.xA-F]*\b', :style => "Number"},
      { :pattern => '/.*?/', :style => "Regex"},
      { :pattern => '\b(abstract|break|case|catch|class|continue|debugger|default|delete|do|else|export|extends|final|finally|for|goto|if|implements|import|in|instanceof|interface|native|new|package|private|protected|public|return|static|super|switch|synchronized|this|throw|throws|transient|try|typeof|var|void|while|with)\b', :style => "Keywords"},
      { :pattern => '(\b(boolean|byte|char|const|double|enum|float|int|long|short|volatile)\b)', :style => "Types"},
      { :pattern => '(\b(true|false|nil)\b)', :style => "Logic"},
      { :pattern => '(\||\\|\.|<|>|@|=|:|\+|-|\*|\/|\^|\?|\!|%)', :style => "Operators"},
      { :pattern => '(,|;|\[|\]|\(|\)|\{|\})', :style => "Pars"},
      { :pattern => '\b(function)\b(\s+)([a-zA-Z0-9_]+)?', :style => ["Keywords3","Root","funcName"]},
    ],
    
    ## Double string state
    :DoubleString => [
        {:pattern => '(?<!\\\\)"', :style => "DoubleString", :action => "#pop"}
    ],
    
    ## Single string state
    :SingleString => [
        {:pattern => "(?<!\\\\)'", :style => "SingleString", :action => "#pop"}
    ],
    
    ## Comment block state
    :comment_big => [
    { :pattern   => '\*\/', :style => "BlockComment", :action => "#pop"}
    ],
    
  }
  end
end