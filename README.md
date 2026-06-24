# Welcome to Spoonerize -- a word game.
[![Build Status](https://img.shields.io/endpoint.svg?url=https%3A%2F%2Factions-badge.atrox.dev%2Fevanthegrayt%2Fspoonerize%2Fbadge%3Fref%3Dmaster&style=flat)](https://actions-badge.atrox.dev/evanthegrayt/spoonerize/goto?ref=master)
[![Gem Version](https://badge.fury.io/rb/spoonerize.svg)](https://badge.fury.io/rb/spoonerize)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

> Spoonerism *[noun]* a verbal error in which a speaker accidentally transposes
> the initial sounds or letters of two or more words, often to humorous effect.

You can view the documentation [here](https://evanthegrayt.github.io/spoonerize/)

## About
We've all done it; someone says a phrase, and you flip the first few letters
around, and sometimes, it makes an even funnier phrase. For example:
"Tomb Raider" becomes "Romb Taider".
Well, when I was in high school, we took it further -- probably too far -- and
made a rule set. This gem, which includes a command-line executable, follows
those rules, which are:

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
- "Y" is treated like a leading consonant by itself or before a vowel sound
(like "yellow"), but like a leading vowel before a consonant (like "yttrium").
- A lot of the time, the words won't look how they're supposed to sound, as you
go by how the word *used* to sound, not how it's spelled. For instance,
`$ spoonerize two new cuties` becomes "no cew twuties", but it would be
pronounced "new coo tooties", as the words retain their original sounds.


## Installation
### Automated
Just install the gem!

```sh
gem install spoonerize
```

If you don't have permission on your system to install Ruby or gems, I recommend
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
tot shoo nabby
Saving...

$ spoonerize -rs not too shabby
shot noo tabby
Saving...

$ spoonerize -p
not too shabby | tot shoo nabby | No Options
not too shabby | shot noo tabby | Reverse
```

Here is a list of all available options:

```
-r, --[no-]reverse               Reverse flipping
-l, --[no-]lazy                  Skip common words
-c, --[no-]consonants-only       Only flip consonant-starting words
-m, --[no-]map                   Print words mapping
-p, --[no-]print-log             Print all entries in the log
-s, --[no-]save                  Save results in log
    --exclude=WORD               Words to skip
```

## Web Usage
The gem also installs a small Sinatra app:

```sh
spoonerize-web
```

By default, Sinatra starts on its normal local development address. You can
choose a host or port when you need to:

```sh
spoonerize-web --host 127.0.0.1 --port 9292
```

Open the printed local URL in your browser, enter a phrase, choose any options,
and submit the form. The page reloads with the spoonerized result and keeps
your phrase and options in the form. Check "Save result" to write a successful
result to the configured log file.

The web app ships with the main gem for now, so `gem install spoonerize`
installs both `spoonerize` and `spoonerize-web`.

### Config File
You can create a Ruby config file called `~/.spoonerizerc`. The CLI loads this
file automatically before it parses command-line options, so options set in the
file can still be overridden at runtime by executable flags. The web app loads
the same file when it starts, and uses those values for the initial form
defaults.

```ruby
Spoonerize.configure do |config|
  config.excluded_words = []
  config.lazy = false
  config.consonants_only = false
  config.reverse = false
  config.logfile_name = File.expand_path("~/.cache/spoonerize/spoonerize.csv")
end
```

Because the file is Ruby, you can set only the values you want to change.

## API
The API is [fully
documented](https://evanthegrayt.github.io/spoonerize/), but below
are some quick examples of how you could use this in your Ruby code.

```ruby
require 'spoonerize'

spoonerism = Spoonerize::Spoonerism.new("not", "too", "shabby")

spoonerism.to_s
# => tot shoo nabby

reversed = Spoonerize::Spoonerism.new("not", "too", "shabby", reverse: true)
reversed.to_s
# => shot noo tabby

Spoonerize.configure do |config|
  config.logfile_name = File.expand_path("~/.cache/spoonerize/spoonerize.csv")
end
Spoonerize::Spoonerism.new("not", "too", "shabby").save
```

To leave vowel-starting words alone, enable consonants-only mode:

```ruby
Spoonerize::Spoonerism.new("turn", "up", "son", consonants_only: true).to_s
# => surn up ton
```

You can also configure global defaults before creating a spoonerism:

```ruby
Spoonerize.configure do |config|
  config.reverse = true
end

s = Spoonerize::Spoonerism.new("not", "too", "shabby")
s.spoonerize
# => shot noo tabby
```

Options passed directly to `Spoonerize::Spoonerism.new` only apply to that
instance.

Passing words as an array is deprecated and will be removed in Spoonerize 1.0:

```ruby
Spoonerize::Spoonerism.new(%w[not too shabby])
```

Or load a config file manually:

```ruby
Spoonerize.load_config_file("~/.spoonerizerc")
s = Spoonerize::Spoonerism.new("not", "too", "shabby")
```

## Self Promotion
I do these projects for fun, and I enjoy knowing that they're helpful to people.
Consider starring [the repository](https://github.com/evanthegrayt/spoonerize)
if you like it! If you love it, follow me [on
GitHub](https://github.com/evanthegrayt)!
