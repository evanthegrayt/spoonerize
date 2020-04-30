# Welcome to [Spoonerise](https://evanthegrayt.github.io/spoonerise) -- a word game
We've all done it; someone says a phrase, and you flip the first few letters
around, and sometimes, it makes an even funnier phrase. For example:
"Tomb Raider" becomes "Romb Taider".
Well, when I was in high school, we took it further -- probably too far -- and
made a rule set. This program follows those rules, which are listed below.

## Installation
### Automated
Just install the gem!

```sh
gem install spoonerise
```

If you don't have permission on your system to install ruby or gems, I recommend
using
[rbenv](http://www.rubyinside.com/rbenv-a-simple-new-ruby-version-management-tool-5302.html),
or you can try the manual methods below.


### Manual
From your terminal, clone the repository where you want it. From there, you have
a couple of installation options.

```sh
git clone https://github.com/evanthegrayt/spoonerise.git
cd spoonerise

# Use rake to build and install the gem.
rake install

# OR manually link the executable somewhere. If you use this method, you cannot
# move the repository after you link it!
ln -s $PWD/bin/spoonerise /usr/local/bin/spoonerise
```

If you find a phrase funny enough to save, you can pass the `-s` flag. This will
write the results to the logfile. You can print your log file with the `-p`
flag. It will show the original phrase, the end result, and the options used to
get the results. For example:

```
$ spoonerise -s not too shabby
Saving [tot shoo nabby] to /Users/evan.gray/workflow/spoonerise/log/spoonerise.csv

$ spoonerise -rs not too shabby
Saving [shot noo tabby] to /Users/evan.gray/workflow/spoonerise/log/spoonerise.csv

$ spoonerise -p
not too shabby | tot shoo nabby | No Options
not too shabby | shot noo tabby | Reverse
```

## Command Line Usage
Call the executable and pass a phrase as arguments:
```sh
$ spoonerise not too shabby # => tot shoo nabby
```
If it didn't flip the way you wanted it to, you can reverse it:
```sh
$ spoonerise -r not too shabby # => shot noo tabby
```
To get a list of all available options, run with `-h`.

## API
This readme isn't finished, but you can view [API
documentation](https://evanthegrayt.github.io/spoonerise/doc/index.html).

## Rules of the Game
- Each word drops its leading consonant group and takes the leading consonant
group of the next word.
- If the word has no leading consonants, nothing is dropped, but it still
receives the next word's leading consonants if it has any.
- If the next word has no leading consonants, the current word receives no
consonants, but will still lose its own if it has any.
- When being "lazy", common words ("the", "his", etc.) remain unchanged.
- If the word to pull from is excluded, that word is skipped, and you pull the
leading consonants from the next non-excluded word.
- "Q" and "U" should stay together (like "queen").
- A lot of the time, the words won't look how they're supposed to sound, as you
go by how the word *used* to sound, not how it's spelled. For instance,
`$ spoonerise two new cuties` becomes "no cew twuties", but it would be
pronounced "new coo tooties", as the words retain their original sounds.

## Self Promotion
I do these projects for fun, and I enjoy knowing that they're helpful to people.
Consider starring [the repository](https://github.com/evanthegrayt/spoonerise)
if you like it! If you love it, follow me [on
github](https://github.com/evanthegrayt)!
