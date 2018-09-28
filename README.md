# Welcome to PakJib -- a word game.
We've all done it; someone says a phrase, and you flip the first few letters
around, and sometimes, it makes an even funnier phrase. For example:
"Tomb Raider" becomes "Romb Taider".
Well, when I was in high school, we took it further -- probably too far -- and
made a rule set. This program follows those rules, which are listed below.

## Installation
Clone the repository where you want it. If you have `rake` installed (`gem
install rake`), run:
```sh
rake
```
This will link the executable in your path (`/usr/local/bin`).

If you aren't using `rake`, you can link the executable yourself. From inside
the base repository directory, run:
```sh
ln -s $PWD/bin/pakjib /usr/local/bin/pakjib
```

To uninstall, run `rake uninstall`, or simply `rm /usr/local/bin/pakjib`


## Usage
Just pass the phrase as arguments:
```sh
pakjib this is my phrase
```
Options include:
```sh
-r # Reverse the order of the flipping
-l # Lazy -- ignore common small words, like "the", "an", "his", etc.
-s # Save the results in a log file to laugh at later
--exclude=list,of,words # Words you don't want altered.
-h # See all available options
```

## Rules of the Game
- Each word drops its leading consonant group and takes the leading consonant
group of the next word.
- If the word has no leading consonants, nothing is dropped, but it still
receives the next word's leading consonants if it has any.
- If the next word has no leading consonants, the current word receives no
consonants, but will still lose its own if it has any.
- Single-letter words ("a", "I") remain unchanged.
- When being "lazy", common words ("the", "his", etc.) remain unchanged.
- If the word to pull from is excluded, that word is skipped, and you pull the
leading consonants from the next non-excluded word.
- "Q" and "U" should stay together (like "queen").

## Known issues
I haven't written the unit tests yet...

