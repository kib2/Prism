#!/usr/bin/ruby
# coding: utf-8

require 'Prism'
require 'benchmark'

# Change this according to your needs
INPUT_DIR = 'input_test_files/'
INPUT_FILE = 'hl_test.rb'
OUTPUT_DIR = 'output_test_files/'
OUTPUT_FILE = 'benchmark.html'

content = File.read(INPUT_DIR + INPUT_FILE)
 
Benchmark.bm(11) do |b|
  b.report do
    50.times.each do
      formatter = HtmlFormatter.new()
      h = HL.new(formatter, 'ruby')
      h.from_file(INPUT_DIR + INPUT_FILE, OUTPUT_DIR + OUTPUT_FILE )
    end
  end
end

Benchmark.bm(11) do |b|
  b.report do
    50.times.each do
      formatter = HtmlFormatter.new()
      h = HL.new(formatter, 'ruby')
      h.from_string(content)
    end
  end
end