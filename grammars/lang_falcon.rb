#!/usr/bin/ruby
# coding: utf-8

#
# ===== FALCON P.L GRAMMAR FILE
#

def cb_biz_string(my_reg)
  to_add = [{
          :pattern   => /\s*#{my_reg[2]}/,
          :style     => "funcName",
          :action    => "#pop"
          }]
  @allRules[:bizString] = to_add
end

dic_falcon = {
:falcon_root => [
    {:pattern => "(#!\/usr\/bin\/falcon)", :style => "Shebang"},
    { :pattern => '\b-?[0-9][0-9.xA-F]*\b', :style => "Integer"},
    { :pattern => '\b(default|try|case|catch|continue|select|while|loop|for|forfirst|formiddle|forlast|end|init|if|elif|else|break|switch|inspect)\b', :style => "Keywords" },
    { :pattern => '\b(bless|dropping|return|launch|from|global|const|sender|catch|raise|give|pass|directive|load|len|export|enum|try|select|object|print|printl|provides)\b', :style => "Keywords2"},
    { :pattern => '\b(NilType|IntegerType|NumericType|RangeType|MemBufType|FunctionType|StringType|ArrayType|DictionaryType|ObjectType|ClassType|MethodType|ExtMethodType|ClassMethodType|LibFuncType|OpaqueType)\b', :style => "Types"},
    { :pattern => '\b(allp|anyp|all|any|choice|iff|lit|map|filter|reduce|dolist|xmap|lbind|eval|floop|times|downto|upto|oob)\b', :style => "Keywords3"},
    { :pattern => '(\b(true|false|nil|on|fself|self)\b)',:style => "Special"},
    { :pattern => '\b(macro|cascade|innerfunc|static|def)\b', :style => "Entities"},
    { :pattern => '(\/\/.*)', :style => "Comment"},
    { :pattern => '\b(function)\b(\s+)([^(]+)', :style => ["Entities2","Root","funcName"]},
    { :pattern => '\b(class|object)\b(\s+)([^(]+)', :style => ["Entities2","Root","className"]},
    { :pattern => '\b(and|or|in|notin|not|from|to)\b', :style => "Logic"},
    { :pattern => '(\||\\|\.|<|>|@|=|:|\+|-|\*|\/|\^|\?|\!|%)', :style => "Operators"},
    { :pattern => '(,|;|\[|\]|\(|\)|\{|\})', :style => "Pars"},
    { :pattern => '\/\*', :style => "BlockComment", :action => "comment_big"},
    { :pattern => '(?<!\\\\)"', :style => "DoubleString", :action => "DoubleString"},
    { :pattern => "(?<!\\\\)'", :style => "SingleString", :action => "SingleString"},
    { :pattern => '\[com1\]', :discard => true, :style => "com1", :action => "com1"}
],

:comment_big => [
  {:pattern => /(\b(?:(?:https?|ftp):\/\/|mailto:)\S*[^\s!"\'',.:;?])/, :style => "Url"},
  { :pattern   => '\*\/', :style => "BlockComment", :action => "#pop"}],

:DoubleString => [
  { :pattern => '\$[a-zA-Z0-9_]+|\$\(.*?\)', :style => "Entities1"},
  { :pattern => '(?<!\\\\)"', :style => "DoubleString", :action => "#pop"}],

:SingleString => [
  {:pattern   => "(?<!\\\\)'", :style => "SingleString", :action => "#pop"}],

:com1 => [
  {:pattern => /(\b(?:(?:https?|ftp):\/\/|mailto:)\S*[^\s!"\'',.:;?])/, :style => "Url"},
  { :pattern => '\[com1\]', :discard => true, :style => "com1", :action => "#pop"}]

}