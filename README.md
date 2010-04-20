# Prism

Prism's intention is to be a generic syntax highlighter, ie a one that you can 
extend **easily**.

Be aware that Prism has only been tested on a Ruby 1.9.x version. I think it
should also work with 1.8.x, but some grammar files may have then have a 
few problems.

## Grammars

At the moment, here are the supported grammars :

- Ruby
- Erb Ruby files
- Falcon
- XML (and HTML)
- JavaScript
- CSS

And you can also add your ones easily.

## Usage

First, you'll need an HtmlFormatter instance.
Then, you'll need an highlighter instance. That is, an HL object; ie :

  formatter = HtmlFormatter.new()
  h = HL.new(formatter, "rb")

There are 3 methods avaible with your HL instance:

* from_string(code_in_text)
* from_list(code_in_array)
* from_file(in_file, out_file)

There are 3 test files 'test1.rb' to 'test3.rb'. Run them, then go into 
the 'output_test_files' directory to see your generated html files.

If you want view other themes, just edit 'main.css' and change the theme
accordingly to your need. (It is hardcoded atm)

## HELP

I'll greatly appreciate any help on this project, just leave me a mail at:

  ['k','i','b','l','e','u','r','.','c','h','r','i','s','t','o','p','h','e','@','gmail.com'].join('')

## TODO & IDEAS

- adding more grammars;
- implement nested languages rules.