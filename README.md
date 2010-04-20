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


See and launch the 'test1.rb' file, then go into the 'output_test_files' 
directory to see your generated 'out.html' file.

If you want view other themes, just edit 'main.css' and change the theme
accordingly to your need. (It is hardcoded atm)

## TODO & IDEAS

- adding more grammars;
- implement nested languages rules.