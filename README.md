# Welcome to [Spoonerize](https://evanthegrayt.github.io/spoonerize) -- a word game
> Sponerism *[noun]* a verbal error in which a speaker accidentally transposes
> the initial sounds or letters of two or more words, often to humorous effect.

We've all done it; someone says a phrase, and you flip the first few letters
around, and sometimes, it makes an even funnier phrase. For example:
"Tomb Raider" becomes "Romb Taider".
Well, when I was in high school, we took it further -- probably too far -- and
made a rule set. This program follows those rules, which are listed below.

## Table of Contents
- [Installation](#installation)
  - [Automated](#automated)
  - [Manual](#manual)
- [Command Line Usage](#command-line-usage)
  - [Config file](#config-file)
- [API](#api)
  - [Documentation](https://evanthegrayt.github.io/spoonerize/doc/index.html)
- [Rules of the Game](#rules-of-the-game)
- [Self-Promotion](#self-promotion)

## Installation
### Automated
Just install the gem!

```sh
gem install spoonerize
```

If you don't have permission on your system to install ruby or gems, I recommend
using
[rbenv](http://www.rubyinside.com/rbenv-a-simple-new-ruby-version-management-tool-5302.html),
or you can try the manual methods below.


### Manual
From your terminal, clone the repository where you want it. From there, you have
a couple of installation options.

```sh
git clone https://github.com/evanthegrayt/spoonerize.git
cd spoonerize

# Use rake to build and install the gem.
rake install

# OR manually link the executable somewhere. If you use this method, you cannot
# move the repository after you link it!
ln -s $PWD/bin/spoonerize /usr/local/bin/spoonerize
```

## Command Line Usage
Call the executable and pass a phrase as arguments:

```sh
$ spoonerize not too shabby # => tot shoo nabby
```

If it didn't flip the way you wanted it to, you can reverse it:

```sh
$ spoonerize -r not too shabby # => shot noo tabby
```

If you find a phrase funny enough to save, you can pass the `-s` flag. This will
write the results to the logfile. You can print your log file with the `-p`
flag. It will show the original phrase, the end result, and the options used to
get the results. For example:

```
$ spoonerize -s not too shabby
Saving [tot shoo nabby] to ~/.cache/spoonerize/spoonerize.csv

$ spoonerize -rs not too shabby
Saving [shot noo tabby] to ~/.cache/spoonerize/spoonerize.csv

$ spoonerize -p
not too shabby | tot shoo nabby | No Options
not too shabby | shot noo tabby | Reverse
```

Here is a list of all available options:

```
-r, --[no-]reverse               Reverse flipping
-l, --[no-]lazy                  Skip small words
-m, --[no-]map                   Print words mapping
-p, --[no-]print                 Print all entries in the log
-s, --[no-]save                  Save results in log
    --exclude=WORDS              Words to skip
```

### Config File
You can create a config file called `~/.spoonerize.yml`. In this file, you can
change default options at runtime. Available settings are:

```yaml
# Setting       Default
excluded_words: []
lazy:           false
reverse:        false
logfile_name:   '~/.cache/spoonerize/spoonerize.csv'
```

Options set by this file can be overridden at runtime by the use of the
executable's flags.

## API
This readme isn't finished, but you can view [API
documentation](https://evanthegrayt.github.io/spoonerize/doc/index.html).

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
`$ spoonerize two new cuties` becomes "no cew twuties", but it would be
pronounced "new coo tooties", as the words retain their original sounds.

## Self Promotion
I do these projects for fun, and I enjoy knowing that they're helpful to people.
Consider starring [the repository](https://github.com/evanthegrayt/spoonerize)
if you like it! If you love it, follow me [on
github](https://github.com/evanthegrayt)!
