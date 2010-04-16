#!/usr/bin/ruby
# coding: utf-8

#
# ===== CLOJURE GRAMMAR FILE
#
module ClojureLang

  def Clojure_dic 
  {
  :clojure_root => [
                  { :pattern => '\b(:arglists|:doc|:file|:line|:macro|:name|:ns|:private|:tag|:test|new|alias|alter|and|apply|assert|class|cond|conj|count|do|doall|dorun|doseq|dosync|eval|filter|finally|find|first|fn|gen-class|gensym|if|import|inc|keys|let|list|loop|map|ns|or|print|println|quote|rand|recur|reduce|ref|repeat|require|rest|send|seq|set|sort|str|struct|sync|take|test|throw|trampoline|try|type|use|var|vec|when|while) ', :style => "Keywords2"},
                  { :pattern => '(?<!\\\\)"', :style => "DoubleString", :action => "DoubleString"},
                  { :pattern => '\b(def|defmacro|defn|defstruct|deref)\b', :style => "Keywords3"},
                  { :pattern => ';.*', :style => "Comment"},
                  { :pattern => '#!\/usr\/bin\/env clj\s*', :style => "Shebang"},
                  { :pattern => ':{1,2}[a-zA-Z0-9?!\-_+*\./=<>#]*', :style => "Keywords"},
                  { :pattern => '[.]|\||\\\\|<|>|=|:|\+|-|\*|\^|\$|\?|\!|%', :style => "Operators"},
                  { :pattern => "[*][a-z][A-Za-z0-9_\\-.]*[*]", :style => "Keywords1"},
                  { :pattern => "'[a-z][A-Za-z0-9_\\-.]*", :style => "Keywords2"},
                  { :pattern => ':[a-z][A-Za-z0-9_\\-.]*', :style => "Keywords3"},
                  {:pattern => ',|;|\[|\]|\(|\)|\{|\}', :style => "Pars"},
                  {:pattern => '\b-?[0-9][0-9.xA-F]*\b', :style => "Number"},
                ],
    
    ## Double string state
  :DoubleString => [
      { :pattern => '(?<!\\\\)"', :style => "DoubleString", :action => "#pop"}
    ]
  
  }
  end
end