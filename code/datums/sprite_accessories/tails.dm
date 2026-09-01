/datum/sprite_accessory/tails
	em_block = TRUE
	/// Describes which tail spine sprites to use, if any.
	var/spine_key = NONE

///Used for fish-infused tails, which come in different flavors.
/datum/sprite_accessory/tails/fish
	icon = 'icons/mob/human/fish_features.dmi'
	color_src = TRUE

/datum/sprite_accessory/tails/fish/simple
	name = "Simple"
	icon_state = "simple"

/datum/sprite_accessory/tails/fish/crescent
	name = "Crescent"
	icon_state = "crescent"

/datum/sprite_accessory/tails/fish/long
	name = "Long"
	icon_state = "long"
	center = TRUE
	dimension_x = 38

/datum/sprite_accessory/tails/fish/shark
	name = "Shark"
	icon_state = "shark"

/datum/sprite_accessory/tails/fish/chonky
	name = "Chonky"
	icon_state = "chonky"
	center = TRUE
	dimension_x = 36

/datum/sprite_accessory/tails/lizard
	icon = 'icons/mob/human/species/lizard/lizard_tails.dmi'
	spine_key = SPINE_KEY_LIZARD

/datum/sprite_accessory/tails/lizard/none
	name = SPRITE_ACCESSORY_NONE
	icon_state = "none"
	natural_spawn = FALSE

/datum/sprite_accessory/tails/lizard/smooth
	name = "Smooth"
	icon_state = "smooth"

/datum/sprite_accessory/tails/lizard/dtiger
	name = "Dark Tiger"
	icon_state = "dtiger"

/datum/sprite_accessory/tails/lizard/ltiger
	name = "Light Tiger"
	icon_state = "ltiger"

/datum/sprite_accessory/tails/lizard/spikes
	name = "Spikes"
	icon_state = "spikes"

/datum/sprite_accessory/tails/lizard/short
	name = "Short"
	icon_state = "short"
	spine_key = NONE

/datum/sprite_accessory/tails/felinid/cat
	name = "Cat"
	icon = 'icons/mob/human/cat_features.dmi'
	icon_state = "default"
	color_src = HAIR_COLOR

/datum/sprite_accessory/tails/monkey

/datum/sprite_accessory/tails/monkey/none
	name = SPRITE_ACCESSORY_NONE
	icon_state = "none"
	natural_spawn = FALSE

/datum/sprite_accessory/tails/monkey/default
	name = "Monkey"
	icon = 'icons/mob/human/species/monkey/monkey_tail.dmi'
	icon_state = "default"
	color_src = FALSE

/datum/sprite_accessory/tails/xeno
	icon_state = "default"
	color_src = FALSE
	center = TRUE

/datum/sprite_accessory/tails/xeno/default
	name = "Xeno"
	icon = 'icons/mob/human/species/alien/tail_xenomorph.dmi'
	dimension_x = 40

/datum/sprite_accessory/tails/xeno/queen
	name = "Xeno Queen"
	icon = 'icons/mob/human/species/alien/tail_xenomorph_queen.dmi'
	dimension_x = 64
