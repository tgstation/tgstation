/// We can't reuse the builtin SPRITE_ACCESSORY_BLANK as a bunch of code for CI and consistenthumans are reliant on it to force species parts on in screenshot tests & similar.
/// Thus, we need a custom ID for each part, and to maintain consistency we SHOULD be using /part/none::name but CI alt tests don't like that for some reason.
#define DOPPLER_SPRITE_ACCESSORY_NOTAIL "No Tail"
#define DOPPLER_SPRITE_ACCESSORY_NOEARS "No Ears"
#define DOPPLER_SPRITE_ACCESSORY_NOSNOUT "No Snout"
#define DOPPLER_SPRITE_ACCESSORY_NOWINGS "No Wings"

/// Hi!  This file is here to work around some order-of-operations issues consistent humans & a couple other things have.
/// If our overrides aren't loaded in early enough default TG stuff will end up in the critical [1] slot and break things.

/// Wings
/datum/sprite_accessory/wings_more/none
	icon = 'modular_doppler/modular_customization/accessories/code/~overrides/icons/fallbacks.dmi'
	name = DOPPLER_SPRITE_ACCESSORY_NOWINGS
	icon_state = "none"

/datum/sprite_accessory/moth_wings/none
	icon = 'modular_doppler/modular_customization/accessories/code/~overrides/icons/fallbacks.dmi'
	name = DOPPLER_SPRITE_ACCESSORY_NOWINGS
	icon_state = "none"

/datum/sprite_accessory/moth_antennae/none
	icon = 'modular_doppler/modular_customization/accessories/code/~overrides/icons/fallbacks.dmi'
	name = "No Antennae"
	icon_state = "none"

/datum/sprite_accessory/fluff/none
	icon = 'modular_doppler/modular_customization/accessories/code/~overrides/icons/fallbacks.dmi'
	name = "No Fluff"
	icon_state = "none"

/// Ears
/datum/sprite_accessory/ears/none
	icon = 'modular_doppler/modular_customization/accessories/code/~overrides/icons/fallbacks.dmi'
	name = DOPPLER_SPRITE_ACCESSORY_NOEARS
	icon_state = "none"

/datum/sprite_accessory/ears_more/lizard/none
	icon = 'modular_doppler/modular_customization/accessories/code/~overrides/icons/fallbacks.dmi'
	name = DOPPLER_SPRITE_ACCESSORY_NOEARS
	icon_state = /datum/sprite_accessory/ears/none::icon_state

/datum/sprite_accessory/ears_more/dog/none
	icon = 'modular_doppler/modular_customization/accessories/code/~overrides/icons/fallbacks.dmi'
	name = DOPPLER_SPRITE_ACCESSORY_NOEARS
	icon_state = /datum/sprite_accessory/ears/none::icon_state

/datum/sprite_accessory/ears_more/fox/none
	icon = 'modular_doppler/modular_customization/accessories/code/~overrides/icons/fallbacks.dmi'
	name = DOPPLER_SPRITE_ACCESSORY_NOEARS
	icon_state = /datum/sprite_accessory/ears/none::icon_state

/datum/sprite_accessory/ears_more/bunny/none
	icon = 'modular_doppler/modular_customization/accessories/code/~overrides/icons/fallbacks.dmi'
	name = DOPPLER_SPRITE_ACCESSORY_NOEARS
	icon_state = /datum/sprite_accessory/ears/none::icon_state

/datum/sprite_accessory/ears_more/mouse/none
	icon = 'modular_doppler/modular_customization/accessories/code/~overrides/icons/fallbacks.dmi'
	name = DOPPLER_SPRITE_ACCESSORY_NOEARS
	icon_state = /datum/sprite_accessory/ears/none::icon_state

/datum/sprite_accessory/ears_more/monkey/none
	icon = 'modular_doppler/modular_customization/accessories/code/~overrides/icons/fallbacks.dmi'
	name = DOPPLER_SPRITE_ACCESSORY_NOEARS
	icon_state = /datum/sprite_accessory/ears/none::icon_state

/datum/sprite_accessory/ears_more/deer/none
	icon = 'modular_doppler/modular_customization/accessories/code/~overrides/icons/fallbacks.dmi'
	name = DOPPLER_SPRITE_ACCESSORY_NOEARS
	icon_state = /datum/sprite_accessory/ears/none::icon_state

/datum/sprite_accessory/ears_more/fish/none
	icon = 'modular_doppler/modular_customization/accessories/code/~overrides/icons/fallbacks.dmi'
	name = DOPPLER_SPRITE_ACCESSORY_NOEARS
	icon_state = /datum/sprite_accessory/ears/none::icon_state

/datum/sprite_accessory/ears_more/bird/none
	icon = 'modular_doppler/modular_customization/accessories/code/~overrides/icons/fallbacks.dmi'
	name = DOPPLER_SPRITE_ACCESSORY_NOEARS
	icon_state = /datum/sprite_accessory/ears/none::icon_state

/datum/sprite_accessory/ears_more/bug/none
	icon = 'modular_doppler/modular_customization/accessories/code/~overrides/icons/fallbacks.dmi'
	name = DOPPLER_SPRITE_ACCESSORY_NOEARS
	icon_state = /datum/sprite_accessory/ears/none::icon_state

/datum/sprite_accessory/ears_more/humanoid/none
	icon = 'modular_doppler/modular_customization/accessories/code/~overrides/icons/fallbacks.dmi'
	name = DOPPLER_SPRITE_ACCESSORY_NOEARS
	icon_state = /datum/sprite_accessory/ears/none::icon_state

/datum/sprite_accessory/ears_more/cybernetic/none
	icon = 'modular_doppler/modular_customization/accessories/code/~overrides/icons/fallbacks.dmi'
	name = DOPPLER_SPRITE_ACCESSORY_NOEARS
	icon_state = /datum/sprite_accessory/ears/none::icon_state

/datum/sprite_accessory/ears_more/alien/none
	icon = 'modular_doppler/modular_customization/accessories/code/~overrides/icons/fallbacks.dmi'
	name = DOPPLER_SPRITE_ACCESSORY_NOEARS
	icon_state = /datum/sprite_accessory/ears/none::icon_state

/// Tail time
/datum/sprite_accessory/tails/none
	icon = 'modular_doppler/modular_customization/accessories/code/~overrides/icons/fallbacks.dmi'
	name = DOPPLER_SPRITE_ACCESSORY_NOTAIL
	icon_state = "none"

/datum/sprite_accessory/tails/lizard/none
	icon = /datum/sprite_accessory/tails/none::icon
	name = DOPPLER_SPRITE_ACCESSORY_NOTAIL
	icon_state = /datum/sprite_accessory/tails/none::icon_state

/datum/sprite_accessory/tails/human/none
	icon = /datum/sprite_accessory/tails/none::icon
	name = DOPPLER_SPRITE_ACCESSORY_NOTAIL
	icon_state = /datum/sprite_accessory/tails/none::icon_state

/datum/sprite_accessory/tails/monkey/none
	icon = /datum/sprite_accessory/tails/none::icon
	name = DOPPLER_SPRITE_ACCESSORY_NOTAIL
	icon_state = /datum/sprite_accessory/tails/none::icon_state

/datum/sprite_accessory/tails/dog/none
	icon = /datum/sprite_accessory/tails/none::icon
	name = DOPPLER_SPRITE_ACCESSORY_NOTAIL
	icon_state = /datum/sprite_accessory/tails/none::icon_state

/datum/sprite_accessory/tails/fox/none
	icon = /datum/sprite_accessory/tails/none::icon
	name = DOPPLER_SPRITE_ACCESSORY_NOTAIL
	icon_state = /datum/sprite_accessory/tails/none::icon_state

/datum/sprite_accessory/tails/bunny/none
	icon = /datum/sprite_accessory/tails/none::icon
	name = DOPPLER_SPRITE_ACCESSORY_NOTAIL
	icon_state = /datum/sprite_accessory/tails/none::icon_state

/datum/sprite_accessory/tails/mouse/none
	icon = /datum/sprite_accessory/tails/none::icon
	name = DOPPLER_SPRITE_ACCESSORY_NOTAIL
	icon_state = /datum/sprite_accessory/tails/none::icon_state

/datum/sprite_accessory/tails/bird/none
	icon = /datum/sprite_accessory/tails/none::icon
	name = DOPPLER_SPRITE_ACCESSORY_NOTAIL
	icon_state = /datum/sprite_accessory/tails/none::icon_state

/datum/sprite_accessory/tails/deer/none
	icon = /datum/sprite_accessory/tails/none::icon
	name = DOPPLER_SPRITE_ACCESSORY_NOTAIL
	icon_state = /datum/sprite_accessory/tails/none::icon_state

/datum/sprite_accessory/tails/fish/none
	icon = /datum/sprite_accessory/tails/none::icon
	name = DOPPLER_SPRITE_ACCESSORY_NOTAIL
	icon_state = /datum/sprite_accessory/tails/none::icon_state

/datum/sprite_accessory/tails/bug/none
	icon = /datum/sprite_accessory/tails/none::icon
	name = DOPPLER_SPRITE_ACCESSORY_NOTAIL
	icon_state = /datum/sprite_accessory/tails/none::icon_state

/datum/sprite_accessory/tails/cybernetic/none
	icon = /datum/sprite_accessory/tails/none::icon
	name = DOPPLER_SPRITE_ACCESSORY_NOTAIL
	icon_state = /datum/sprite_accessory/tails/none::icon_state

/datum/sprite_accessory/tails/humanoid/none
	icon = /datum/sprite_accessory/tails/none::icon
	name = DOPPLER_SPRITE_ACCESSORY_NOTAIL
	icon_state = /datum/sprite_accessory/tails/none::icon_state

/datum/sprite_accessory/tails/alien/none
	icon = /datum/sprite_accessory/tails/none::icon
	name = DOPPLER_SPRITE_ACCESSORY_NOTAIL
	icon_state = /datum/sprite_accessory/tails/none::icon_state

/// Lizard exclusive 🦎
/datum/sprite_accessory/snouts/none
	icon = 'modular_doppler/modular_customization/accessories/code/~overrides/icons/fallbacks.dmi'
	name = DOPPLER_SPRITE_ACCESSORY_NOSNOUT
	icon_state = "none"

/datum/sprite_accessory/lizard_markings/none
	icon = 'modular_doppler/modular_customization/accessories/code/~overrides/icons/fallbacks.dmi'
	name = "No Markings"
	icon_state = "none"

/datum/sprite_accessory/frills/none
	icon = 'modular_doppler/modular_customization/accessories/code/~overrides/icons/fallbacks.dmi'
	name = "No Frills"
	icon_state = "none"

/datum/sprite_accessory/horns/none
	icon = 'modular_doppler/modular_customization/accessories/code/~overrides/icons/fallbacks.dmi'
	name = "No Horns"
	icon_state = "none"

/// Linter sacrifice.  We only need this in the one file I suppose.
#undef DOPPLER_SPRITE_ACCESSORY_NOTAIL
#undef DOPPLER_SPRITE_ACCESSORY_NOEARS
#undef DOPPLER_SPRITE_ACCESSORY_NOSNOUT
#undef DOPPLER_SPRITE_ACCESSORY_NOWINGS
