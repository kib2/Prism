#!/usr/bin/ruby
# coding: utf-8

require 'Prism'

# Change this according to your needs
INPUT_DIR = 'input_test_files/'
#INPUT_FILE = 'ruby1.rb' # 'coderay_scanner.rb' # 'peg.fal' #'ruby1.rb'
INPUT_FILE = 'erb_test.txt'
OUTPUT_DIR = 'output_test_files/'

tests = { :ruby => ['ruby1.rb', 'coderay_scanner.rb'],
  :clojure => ['test.clj'],
  :falcon => ['peg.fal'],
  :javascript => ['ruby1.rb'],
  :xml => ['xml_test.xml'],
  :erb => ['erb_test.erb'],
  :css => ['css_test.css'],
}

tests.each do |key, value|
  value.each do |val|
    formatter = HtmlFormatter.new()
    h = HL.new(formatter, key.to_s)
    h.from_file(INPUT_DIR + val, OUTPUT_DIR + val + '_out.html')
  end
end

## # A little benchmark against Pygments
## t0 = Time.now
## formatter = HtmlFormatter.new()
## # In HL constructor, the second parameter is the language
## # file name minus the 'lang_' prefix.
## h = HL.new(formatter, "erb") # so we choose 'lang_rb.rb' for Ruby :)
## h.from_file(INPUT_DIR + INPUT_FILE, OUTPUT_DIR + 'out.html')
## t1 = Time.now
## puts "Ruby's Prism took #{t1-t0} second(s) to highlight.\nPython's Pygments took 0.34 second.[http://pygments.org/demo/37/]\nDo you ## STILL think Ruby's so slow ?"
## puts "...and what about Pygments's size ?! Prism is just about ~300 lines long"
## puts
##
## puts "=== FROM A STRING"
## puts h.from_string("formatter = HtmlFormatter.new()")
## puts
##
## puts "=== FROM A LIST OF STRINGS"
## puts h.from_list(["formatter = HtmlFormatter.new()",
##                   "h.from_file(INPUT_DIR + INPUT_FILE, OUTPUT_DIR + 'out.html')"])
## puts
