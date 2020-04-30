# Welcome to Spoonerise -- a word game.
We've all done it; someone says a phrase, and you flip the first few letters
around, and sometimes, it makes an even funnier phrase. For example:
"Tomb Raider" becomes "Romb Taider".
Well, when I was in high school, we took it further -- probably too far -- and
made a rule set. This program follows those rules, which are listed below.

## Installation
From your terminal, clone the repository where you want it.
```sh
git clone https://github.com/evanthegrayt/spoonerise.git
cd spoonerise
```
#### Automated
Install as a gem via `rake`. This will be on RubyGems.org very soon.

```sh
rake install
```

To uninstall, run `rake uninstall`

#### Manual
If you aren't using `bundler`/`rake`, you can link the executable yourself. From
inside the base repository directory, run:
```sh
ln -s $PWD/bin/spoonerise /usr/local/bin/spoonerise
```
To uninstall, run `rm /usr/local/bin/spoonerise`

## Testing
To run the tests, you need `rspec`. This will be installed by `bundle install`,
but if you installed manually, you'll need to run `gem install rspec`. To run
the tests, run:
```sh
rspec spec/spoonerism_spec.rb
```

## Usage
Just pass the phrase as arguments:
```sh
$ spoonerise not too shabby # => tot shoo nabby
```
If it didn't flip the way you wanted it to, you can reverse it:
```sh
$ spoonerise -r not too shabby # => shot noo tabby
```
To get a list of all available options, run with `-h`.

You can also view the [API
documentation](https://evanthegrayt.github.io/spoonerise/doc/index.html).

## Logging
When saved, it will be logged to `log/spoonerise.log`. It will have the date,
the original phrase, the new phrase, and the options used to achieve the new
phrase.
```
I, [2019-03-22#57116]  INFO -- : [not too shabby] => [shot noo tabby] (Reverse)
```
I'm not totally happy with this. I think using `Logger` is probably overkill, as
it includes superfluous information. In the near future, I will probably just
change it to:
```
[2019-03-22]: [not too shabby] => [shot noo tabby] (Reverse)
```
Also, I when I have time, I intend on implementing a `LogFile` class, and give
the executable an option to read and search the log file. This will prevent the
user from having to manually open the log file.

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
