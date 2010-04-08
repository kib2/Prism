#!/usr/bin/ruby
# coding: utf-8

=begin
  This is the String Test, See here for a reference:
  http://www.devarticles.com/c/a/Ruby-on-Rails/Strings-in-Ruby/1/
=end

comedy = %!As You Like It!
puts "=== FROM A STRING"

history = %[Henry V]
puts "=== FROM A STRING"

tragedy = %(Julius Ceasar)
puts "=== FROM A STRING"

sonnet = <<29 
When in disgrace with fortune and men's eyes
I all alone beweep my outcast state,
And trouble deaf heaven with my bootless cries,
And look upon myself, and curse my fate, 
Wishing me like to one more rich in hope, 
Featured like him, like him with friends possessed,
Desiring this man's art, and that man's scope,
With what I most enjoy contented least; 
Yet in these thoughts my self almost despising,
Haply I think on thee, and then my state, 
Like to the lark at break of day arising 
From sullen earth, sings hymns at heaven's gate;
For thy sweet love remembered such wealth brings
That then I scorn to change my state with kings. 
29

some __FILE__ here

sonnet = <<hamlet # same as double-quoted string
O my prophetic soul! My uncle!
hamlet

sonnet = <<"hamlet" # again as double-quoted string
O my prophetic soul! M\\y uncle!
hamlet

sonnet = <<'ghost' # same as single-quoted string
Pity me not, but lend thy serious hearing 
To what I shall unfold.
ghost

my_dir = <<`dir` # same as back ticks
ls -l 
dir

ind = <<-hello # for indentation
    Hello, Matz!
hello

__END__

puts

sonnet = <<hamlet # same as double-quoted string
O my prophetic soul! My uncle!
hamlet

sonnet = <<"hamlet" # again as double-quoted string
O my prophetic soul! M\\y uncle!
hamlet

sonnet = <<'ghost' # same as single-quoted string
Pity me not, but lend thy serious hearing 
To what I shall unfold.
ghost

my_dir = <<`dir` # same as back ticks
ls -l 
dir

ind = <<-hello # for indentation
    Hello, Matz!
hello