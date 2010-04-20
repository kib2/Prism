#!/usr/bin/ruby
# coding: utf-8

#
# ===== CSS GRAMMAR FILE
#

module CssLang

  # Callback when coming out from PropertyValue
  def cb_ppt_value(me)
    if @states.length > 1
      @states.pop()
    end
    if @styles.length > 1
      @styles.pop()
    end
    @styles = ['Root']
  end

  def Css_dic
    {
  :css_root => [
      {:pattern => '(?<!\\\\)"', :style => "DoubleString", :action => "DoubleString"},
      {:pattern => "(?<!\\\\)'", :style => "SingleString", :action => "SingleString"},
      {:pattern => '\/\*', :style => "BlockComment", :action => "BlockComment"},

      {:pattern => '\b(?i:a|abbr|acronym|address|area|b|base|big|blockquote|body|br|button|caption|cite|code|col|colgroup|dd|del|dfn|div|dl|dt|em|fieldset|form|frame|frameset|(h[1-6])|head|hr|html|i|iframe|img|input|ins|kbd|label|legend|li|link|map|meta|noframes|noscript|object|ol|optgroup|option|p|param|pre|q|samp|script|select|small|span|strike|strong|style|sub|sup|table|tbody|td|textarea|tfoot|th|thead|title|tr|tt|ul|var)\b', :style => "Tag"},
      {:pattern => '\.[a-zA-Z0-9_-]+', :style => "className"},
      {:pattern => '#[a-zA-Z0-9_-]+', :style => "funcName"},
      {:pattern => '\*', :style => "Keywords4"},
      {:pattern => ':\b(active|after|before|first-letter|first-line|hover|link|visited)\b', :style => "Keywords5"},

      {:pattern => '\{', :style => "Pars", :action => "PropertyList"}
    ],

  ## PropertyList State {...}
  :PropertyList => [
    {:pattern => '\/\*', :style => "BlockComment", :action => "BlockComment"},
    {:pattern => '\s*(?=[a-z_=])', :style => "Keywords2", :action => "PropertyName"},
    {:pattern => '\}', :style => "Pars", :action => "#pop"},
  ],

  ## PropertyValue State
  :PropertyValue => [
      {:pattern => '(?<!\\\\)"', :style => "DoubleString", :action => "DoubleString"},
      {:pattern => "(?<!\\\\)'", :style => "SingleString", :action => "SingleString"},
      {:pattern => '\/\*', :style => "BlockComment", :action => "BlockComment"},
    {:pattern => '\b(absolute|all-scroll|always|auto|baseline|below|bidi-override|block|bold|bolder|both|bottom|break-all|break-word|capitalize|center|char|circle|col-resize|collapse|crosshair|dashed|decimal|default|disabled|disc|distribute-all-lines|distribute-letter|distribute-space|distribute|dotted|double|e-resize|ellipsis|fixed|groove|hand|help|hidden|horizontal|ideograph-alpha|ideograph-numeric|ideograph-parenthesis|ideograph-space|inactive|inherit|inline-block|inline|inset|inside|inter-ideograph|inter-word|italic|justify|keep-all|left|lighter|line-edge|line-through|line|list-item|loose|lower-alpha|lower-roman|lowercase|lr-tb|ltr|medium|middle|move|n-resize|ne-resize|newspaper|no-drop|no-repeat|nw-resize|none|normal|not-allowed|nowrap|oblique|outset|outside|overline|pointer|progress|relative|repeat-x|repeat-y|repeat|right|ridge|row-resize|rtl|s-resize|scroll|se-resize|separate|small-caps|solid|square|static|strict|super|sw-resize|table-footer-group|table-header-group|tb-rl|text-bottom|text-top|text|thick|thin|top|transparent|underline|upper-alpha|upper-roman|uppercase|vertical-ideographic|vertical-text|visible|w-resize|wait|whitespace)\b', :style => "Keywords4"},
    {:pattern => 'important', :style => "Keywords5"},
    {:pattern => '(\b(?i:arial|century|comic|courier|garamond|georgia|helvetica|impact|lucida|symbol|system|tahoma|times|trebuchet|utopia|verdana|webdings|sans-serif|serif|monospace)\b)', :style => "Keywords3"},
    {:pattern => '(-|\+)?[0-9]*\.[0-9]+', :style => "Number"},
    {:pattern => '(-|\+)?[0-9]+', :style => "Integer"},
    {:pattern => '(px|pt|cm|mm|in|em|ex|pc)\b|%' , :style => "Types"},
    {:pattern => ',', :style => "Pars"},
    {:pattern => '(#)([0-9a-fA-F]{3}|[0-9a-fA-F]{6})\b', :style => "Special"},
    {:pattern => ';', :style => "Pars", :callback => "cb_ppt_value", :action => "#pop"},
  ],

  ## PropertyName State
  :PropertyName => [
    {:pattern => '\/\*', :style => "BlockComment", :action => "BlockComment"},

    {:pattern => '\b_(azimuth|background-attachment|background-color|background-image|background-position|background-repeat|background|border-bottom-color|border-bottom-style|border-bottom-width|border-bottom|border-collapse|border-color|border-left-color|border-left-style|border-left-width|border-left|border-right-color|border-right-style|border-right-width|border-right|border-spacing|border-style|border-top-color|border-top-style|border-top-width|border-top|border-width|border|bottom|caption-side|clear|clip|color|content|counter-increment|counter-reset|cue-after|cue-before|cue|cursor|direction|display|elevation|empty-cells|float|font-family|font-size-adjust|font-size|font-stretch|font-style|font-variant|font-weight|font|height|left|letter-spacing|line-height|list-style-image|list-style-position|list-style-type|list-style|margin-bottom|margin-left|margin-right|margin-top|marker-offset|margin|marks|max-height|max-width|min-height|min-width|-moz-border-radius|orphans|outline-color|outline-style|outline-width|outline|overflow|padding-bottom|padding-left|padding-right|padding-top|padding|page-break-after|page-break-before|page-break-inside|page|pause-after|pause-before|pause|pitch-range|pitch|play-during|position|quotes|richness|right|size|speak-header|speak-numeral|speak-punctuation|speech-rate|speak|stress|table-layout|text-align|text-decoration|text-indent|text-shadow|text-transform|top|unicode-bidi|vertical-align|visibility|voice-family|volume|white-space|widows|width|word-spacing|z-index)\b', :style => "Keywords1"},
    {:pattern => '\b(azimuth|background-attachment|background-color|background-image|background-position|background-repeat|background|border-bottom-color|border-bottom-style|border-bottom-width|border-bottom|border-collapse|border-color|border-left-color|border-left-style|border-left-width|border-left|border-right-color|border-right-style|border-right-width|border-right|border-spacing|border-style|border-top-color|border-top-style|border-top-width|border-top|border-width|border|bottom|caption-side|clear|clip|color|content|counter-increment|counter-reset|cue-after|cue-before|cue|cursor|direction|display|elevation|empty-cells|float|font-family|font-size-adjust|font-size|font-stretch|font-style|font-variant|font-weight|font|height|left|letter-spacing|line-height|list-style-image|list-style-position|list-style-type|list-style|margin-bottom|margin-left|margin-right|margin-top|marker-offset|margin|marks|max-height|max-width|min-height|min-width|-moz-border-radius|orphans|outline-color|outline-style|outline-width|outline|overflow|padding-bottom|padding-left|padding-right|padding-top|padding|page-break-after|page-break-before|page-break-inside|page|pause-after|pause-before|pause|pitch-range|pitch|play-during|position|quotes|richness|right|size|speak-header|speak-numeral|speak-punctuation|speech-rate|speak|stress|table-layout|text-align|text-decoration|text-indent|text-shadow|text-transform|top|unicode-bidi|vertical-align|visibility|voice-family|volume|white-space|widows|width|word-spacing|z-index)\b', :style => "Keywords2"},
    {:pattern => ':', :style => "Pars", :action => "PropertyValue", :transit => "Root" },

  ], # end PropertyName State

  ## Double string state
  :DoubleString => [
      {:pattern => '(?<!\\\\)"', :style => "DoubleString", :action => "#pop"}
    ],

  ## Single string state
  :SingleString => [
      {:pattern => "(?<!\\\\)'", :style => "SingleString", :action => "#pop"}
    ],

  ## BlockComment state
  :BlockComment => [
      { :pattern   => '\*\/', :style => "BlockComment", :action => "#pop"}
      ],

  }

  end

end # Module