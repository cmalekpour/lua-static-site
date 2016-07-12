# lua-static-site
Simple static site generator written in Lua. The code is extremely short, and provides only basic features. I use this for my own blog.

# Installing

To install, you will need the markdown and luafilesystem packages from luarocks

```
luarocks install markdown
luarocks install luafilesystem
```

# Usage

You can edit config settings in a small table at the top of ```static.lua```. Markdown posts should be placed in the input directory, and the output will be put in the output directory.

To run, simply execute static.lua.

```lua static.lua```

# Post format

```
Post ID on first line
Title on second line
Date on third line
Post content below. The rest of the file
will be read, so you can use as many lines as you want
```

The generator also supports a very simple templating language. Some strings in the template will be replaced with post metadata
```
#{id} => post id
#{title) => post title
#{date} => post date
#{author} => author from config file
#{nextpost} => title of next post, formatted as lowercase alphanumeric w/ spaces as dashes
#{prevpost} => title of prev post, formatted as lowercase alphanumeric w/ spaces as dashes
```
There are also certain control blocks that the generator supports
```
#{isnextpost} ... #{/isnextpost} => will only output the inner contents if there is a next post
#{isprevpost} ... #{/isprevpost} => will only output the inner contents if there is a previous post
```
