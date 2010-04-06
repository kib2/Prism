#!/usr/bin/ruby
# coding: utf-8

## Prism.rb: a Generic Code Highlighter for Ruby
## Version: 1.0.0
## Started: April 04, 2010    
## Last changes: April 04, 2010
## Author: Kibleur Christophe.
## Website: http://kib2.free.fr/

require 'cgi' # Only for escaping HTML texts

## =============================================================================
##                             HTML-Formatter
## =============================================================================

class HtmlFormatter
    # The formatter is used by the highlighter to render 
    # a line of text to a given format
    attr_accessor :parent 
    attr_reader :parent

    def initialize()
      @parent = nil
    end
      
    def highlight(text, thestate)
        # We escape the text
        q = CGI.escapeHTML(text)
        if thestate == 'Root'
            ln = q
        elsif thestate == 'Url'
            ln = "<span class=\"#{thestate}\"><a href=\"#{q}\">#{q}</a></span>"
        else
            ln = "<span class=\"#{thestate}\">#{q}</span>"
        end
        
        ln
    end
end

## =============================================================================
##                            Highlighter Class
## =============================================================================
class HL
    attr_accessor :formatter, :language, :allRules, :callBacks, :states, :styles, :was_transit 
    attr_reader :formatter, :language, :allRules, :callBacks, :states, :styles, :was_transit
  
    def initialize(formatter, language)
      @formatter = formatter
      @language  = language
      # others
      @allRules = nil
      @callBacks = {}
      @lang_mod = nil
      @states = [] # will be filled at the end of initialize
      @styles = ['Root']
      @was_transit = false
      
      # setting the formatter and loading syntax
      @formatter.parent = self
      load_syntax_def(@language)
      @states.push( "#{@language}_root")
    end
    
    def load_syntax_def(lang)
      @allRules = open("grammars/lang_#{lang}.rb", 'r') {|f| eval f.read }

      # now, transform each pattern in a regexp, it is a lot quicker
      # than building a Regexp object every time we need one
      @allRules.each do |k,v|
          @allRules[k].each do |t|
            t[:pattern] = /#{t[:pattern]}/
          end
      end
    end

    #
    #    ==== MAIN ROUTINES FOR HANDLING HIGHLIGHTING
    #
    def updateMatchObject(me,m0,m1,r,m)
        me[:start] = m0
        me[:ends]  = m1
        me[:rule]  = r
        me[:match] = m[0]
        me[:reg]   = m #r[:pattern]
        me[:style] = r[:style]
        me[:callback] = r[:callback]
        return me
    end

    def getNextMatch(line)
        # This method returns the next regular expression matched on agiven
        # line according to the rules given inself.allRules

        lowest  = line.length
        longest = 0
        match   = false
        style   = nil
        me = { 
           :start => nil, :ends =>  nil, :rule    => nil,
           :match => nil, :style => nil, :pop     => false,
           :push  => nil, :reg   => nil, :transit => nil,
           :callback => nil 
             }
 
        @allRules[(@states[-1]).to_sym].each do |r|
            reg = r[:pattern]
            if (m = reg.match(line))
                m0 = m.begin(0)
                m1 = m.end(0)
                # the best rule is the one matchingfirst
                # or the longest one if 2 rules matches at the samepos
                if (m0 < lowest or (m0 == lowest and m1 >= longest) )
                    match    = true
                    me = updateMatchObject(me,m0,m1,r,m)
                    # update lowest andlongest
                    lowest   = m0
                    longest  = m1
                end
            end
        end
        
        if match
            # CALLBACKS rules
            if me[:rule].key?(:callback)
              #self.send(me[:rule][:callback], me[:reg])
              self.send(me[:rule][:callback], me[:reg])
            end
            
            # "action" is a state change (maybeseveral)
            if me[:rule].has_key?(:action)
                if me[:rule][:action] == "#pop"
                    me[:pop] = true
                else # we push astate
                    me[:push] = me[:rule][:action].to_sym
                end
                # Style transitions between state changes : experimental!
                if me[:rule].has_key?(:transit)
                    me[:transit] = me[:rule][:transit]
                end
            end
        else
            me[:start] = 0
            me[:ends]  = lowest # the linelength
            me[:style] = @styles[-1]
        end
        return me
    end
    
    def highlightLine(line)
        # Just highlights the given text with thehelp
        # of a correspondingFormatter
        
        # This test is used if a line isempty
        # and a rule is set to match it (ie wikisyntax)
        # we must then handle state changequickly
        me = getNextMatch(line)
        if line == '' 
            handlePush_Pop(me) 
            return ""
        end
        
        out = []

        while me = getNextMatch(line)

            if me[:start] != me[:ends] # start pos != end pos   
                if me[:reg] # a rulematched
                  
                    # highlight what has not matched with last style
                    if (me[:start]-1) >= 0
                      out << @formatter.highlight(line[0..(me[:start]-1)], @styles[-1])
                    end
                    # highlight withgroup 
                    if me[:style].class == Array 
                        num_of_times = me[:reg].captures.length
                        (1..num_of_times).each do |j|
                            cts = me[:reg][j] #line[ me.reg[j] ]
                            out << @formatter.highlight(cts, me[:style][j-1])
                        end
                        handlePush_Pop(me)
                    # highlight without groups
                    else  
                        out << @formatter.highlight( line[me[:start]..(me[:ends]-1)], me[:style])
                        handlePush_Pop(me)
                    end

                else # no rulematched (remember we set start and end)
                    out << @formatter.highlight( line[me[:start]..(me[:ends]-1)], @styles[-1] )
                    handlePush_Pop(me)
                end
                line = line[me[:ends]..line.length]
            else # we are at theend
                # self.handlePush_Pop(me)
                break 
            end # if me.reg
        end #while

        return out.join("")
    end
    ## 
    ## ==== STATE AND STYLE UPDATE METHODS
    ## 
    def handlePush_Pop(me)
        # we enter a new state, so save laststyle
        if me[:push]
            case me[:push].class
              when Array
                  me[:push].each do |theState|
                      @states.push(theState)
                  end
              else
                  @states.push(me[:push])
            end
            updateStyle(me)
        end
                    
        # Pop a state?
        if me[:pop]
            if @states.length > 1 
              @states.pop()
            end
            if @styles.length > 1 
              @styles.pop()
            end
            # Style transitions between state changes : experimental!
            if @was_transit
                @was_transit = false
                @styles.pop()
            end
        end
    end
    
    def updateStyle(me)
        case me[:style].class
            when Array
                @styles.push(me[:style][-1])
            else
                @styles.push(me[:style])
        end
        # When we change state, the next style is
        # set to the previous one by default.
        # Using transit rule, you can overide this behaviour.
        if me[:transit]
            @styles.push(me[:transit])
            @was_transit = true
        end
    end

    #
    # DIRECT HIGHLIGHTING METHODS
    #
    def from_string(code_in_text)
      code_in_text.gsub("\r\n", "\n")
      from_list(code_in_text.split("\n"))    
    end
    
    def from_list(code_in_array)
      num_of_lines = 0
      out = []
      code_in_array.each do |line|
        num_of_lines += 1
        out << highlightLine(line)
      end
      out.join("\n")
    end
    
    def from_file(in_file, out_file)
      num_of_lines = 0
      header = <<-eos
  <html>
   <head>
       <link rel="Stylesheet" type="text/css" href="main.css" />
   </head>
   <body>
        <div class="default">
          <pre class="code">
      eos
  
      footer = <<-eos
          </pre>
        </div>
   </body>
  </html>
      eos
  
      out = []
      s = File.size(in_file)
      File.open(in_file, 'r') do |f|
        while line = f.gets
          num_of_lines += 1
          out << highlightLine(line)
        end
      end
  
      File.open(out_file, "w") do |f|
        f << header + out.join("") + footer
      end
  
      puts "Output save in '#{out_file}' [total lines: #{num_of_lines}, Size: #{s}]"
      puts
    end
end