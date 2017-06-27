# Differences with /tg/

The best practice to have while coding is to keep everything modularized, or the most possible. Sometimes, through,
 it's not possible and you're required to put an "hookup" proc call in a tg file. This file is intended to have a list
of those hookups, to not forget their locations and such.

## Hookups list

### Moths
#### add_hippie_choices(dat) tg location: code/modules/client/preferences.dm in ShowChoices proc, in mutant races bodypart preference entry.
#### hippie_pref_load(savefile/S) tg location: code/modules/client/preferences_savefile.dm in load_character proc, at the very end before the return.
#### hippie_pref_save(savefile/S) tg location: code/modules/client/preferences_savefile.dm in save_character proc, at the very end before the return.