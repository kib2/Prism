#!/usr/bin/ruby
# coding: utf-8

require 'Prism'

# Change this according to your needs
INPUT_DIR  = 'input_test_files/'
INPUT_FILE = 'erb_test.txt'
OUTPUT_DIR = 'output_test_files/'

tests = {
  :ruby       => ['ruby1.rb', 'coderay_scanner.rb'],
  :clojure    => ['test.clj'],
  :falcon     => ['peg.fal'],
  :javascript => ['ruby1.rb'],
  :xml        => ['xml_test.xml'],
  :erb        => ['erb_test.erb'],
  :css        => ['css_test.css'],
}

tests.each do |key, value|
  value.each do |val|
    formatter = HtmlFormatter.new()
    h = HL.new(formatter, key.to_s)
    h.from_file(INPUT_DIR + val, OUTPUT_DIR + val + '_out.html')
  end
end