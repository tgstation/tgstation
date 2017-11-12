# Differences with /tg/

The best practice to have while coding is to keep everything modularized, or the most possible. Sometimes, through,
 it's not possible and you're required to put an "hookup" proc call in a tg file. This file is intended to have a list
of those hookups, to not forget their locations and such.

As for now,updated from first pr to https://github.com/HippieStation/HippieStation/pull/600

## Edits list
### Gamemode changes
#### Added HoP as protected role in changeling.dm, clock_cult.dm, traitor.dm, and gave him a mindshield at roundstart in captain.dm

### Butts
#### Added butts as internal organs to aliens(alien.dm), humans(human.dm), monkeys(monkey.dm)
#### Gave organs a location instead of null in organ_internal.dm Insert(mob/living/carbon/M, special = 0)

### Teeth
#### Added lisp check in say.dm treat_message(message)

### Walls
#### Changed wall and reinf wall icon in reinf_walls.dm and walls.dm

### Admin verbs
#### Added aooc, fill_breach and reset_atmos in admin_verbs.dm admin_verbs_admin list
#### Added spawn as self dummy in secrets.dm

### Cluwnes
#### Added cluwne code to datumvars.dm line 1117
#### Added make cluwne button in human.dm vv_get_dropdown()

### Boxes, cabinets
#### Changed icons in boxes.dm, filingcabinet.dm, paperbin.dm, pen.dm

### Staple, wooden teeth, noose
#### Added said recipes in rods.dm, sheet_types.dm, cable.dm

### Vendings, dispensers
#### Changed said icons in reagent_dispenser.dm, vending.dm, vending_types.dm(in the latter, resetted wallmed and cart icons to tg)

### Species
#### Added code for hippie mutant bodyparts in bodyparts.dm (should_draw_hippie var)

### Glock 17
#### Added glock 17 in gang_datum.dm and rightandwrong.dm

### Throwing
#### Added throwing code in carbon.dm, throwing.dm subsystem, changed something in sensitive.dm(i can't understand what was changed?) and renamed cleanable folder to Cleanable
### CONTRIBUTING.md and README.md changed

### Cluwneban and catban
#### defines file in __DEFINES/hippie.dm(should be moved to hippiestation folder)
#### Edits in job.dm, datum_clockcult.dm, datum_cult.dm, game_mode.dm, gang.dm, revolution.dm, topic.dm, corpse.dm, preferences.dm, new_player.dm and human life.dm

## Hooks list
### Butts
#### checkbuttuniform(mob) in clothing.dm /obj/item/clothing/equipped(mob/user, slot)
#### checkbuttinspect(mob) in human_defense.dm /mob/living/carbon/human/grabbedby(mob/living/carbon/user, supress_message = 0)
#### checkbuttinsert(obj, mob) in species.dm /datum/species/proc/spec_attacked_by(obj/item/I, mob/living/user, obj/item/bodypart/affecting, intent, mob/living/carbon/human/H)
#### regeneratebutt() in organ_internal.dm Insert(mob/living/carbon/M, special = 0)

### Teeth
#### update_teeth() in dna.dm set_species(datum/species/mrace, icon_update = 1) and human.dm New()
#### tearoutteeth(carbon/C, mob/user) in tools.dm attack(mob/living/carbon/C, mob/user)
#### checklisp() in human life.dm handle_status_effects()
#### punchouttooth() in species.dm harm(mob/living/carbon/human/user, mob/living/carbon/human/target, datum/martial_art/attacker_style) and spec_attacked_by(obj/item/I, mob/living/user, obj/item/bodypart/affecting, intent, mob/living/carbon/human/H)

### Noose
#### checknoosedrop() in head.dm update_limb(dropping_limb, mob/living/carbon/source)

### Moths
#### add_hippie_choices(dat) tg location: code/modules/client/preferences.dm in ShowChoices proc, in mutant races bodypart preference entry.
#### hippie_pref_load(savefile/S) tg location: code/modules/client/preferences_savefile.dm in load_character proc, at the very end before the return.
#### hippie_pref_save(savefile/S) tg location: code/modules/client/preferences_savefile.dm in save_character proc, at the very end before the return.