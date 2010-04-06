#!/usr/bin/ruby
# coding: utf-8

require 'Prism'

INPUT_DIR = 'input_test_files/'
INPUT_FILE = 'coderay_scanner.rb' #'coderay_scanner.rb'
OUTPUT_DIR = 'output_test_files/'

t0 = Time.now
formatter = HtmlFormatter.new()
h = HL.new(formatter, "rb")
h.from_file(INPUT_DIR + INPUT_FILE, OUTPUT_DIR + 'out.html')
t1 = Time.now
puts "Ruby's Prism took #{t1-t0} second(s) to highlight.\nPython's Pygments took 0.34 second.[http://pygments.org/demo/37/]\nDo you STILL think Ruby's so slow ?"
puts "...and what about Pygments's size ?! Prism is just about ~300 lines long"
