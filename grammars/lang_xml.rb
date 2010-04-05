{
:xml_root => [
    {:pattern => '<\?', :style => "Shebang", :action => "Prologue"},
    {:pattern => '<\!--', :style => "BlockComment", :action => "Comment"},
    {:pattern => '(</?)([a-zA-Z0-9_]+)', :style => ["Entities1","Entities3"], :action => "Tag"},
    {:pattern => '</?', :style => "Entities1", :action => "Tag"},
    {:pattern => '\&(.*?);', :style => "Entities2"},
    {:pattern => '(?<!\\\\)"', :style => "DoubleString", :action => "DoubleString"},
    {:pattern => "(?<!\\\\)'", :style => "SingleString", :action => "SingleString"},
],

:Tag => [
  {:pattern => '(?<!\\\\)"', :style => "DoubleString", :action => "DoubleString"},
  {:pattern => "(?<!\\\\)'", :style => "SingleString", :action => "SingleString"},
  { :pattern => '([a-zA-Z0-9_]+)(\s*)(=)', :style => ["funcName","Root","Operators"]},
  { :pattern => '>', :style => "Entities1", :action => "#pop"},
  { :pattern => '/>', :style => "Entities1", :action => "#pop"}],

:Comment => [
  { :pattern => '-->', :style => "BlockComment", :action => "#pop"}],

:Prologue => [
  { :pattern => '([a-zA-Z0-9_]+)(\s*)(=)', :style => ["funcName","Root","Operators"]},
  {:pattern => '(?<!\\\\)"', :style => "DoubleString", :action => "DoubleString"},
  {:pattern => "(?<!\\\\)'", :style => "SingleString", :action => "SingleString"},
  { :pattern => '\?>', :style => "Shebang", :action => "#pop"}],
  
:DoubleString => [
  { :pattern => '(?<!\\\\)"', :style => "DoubleString", :action => "#pop"}],

:SingleString => [
  {:pattern   => "(?<!\\\\)'", :style => "SingleString", :action => "#pop"}],

}