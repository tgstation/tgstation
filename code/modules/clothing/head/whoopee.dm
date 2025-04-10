/// Whoopee cushion for the april fools mail pool
/// I fear what would happen if this were to be released outside of april fools but there's a `check_holidays()` in there just in case
/obj/item/clothing/head/costume/whoopee
	name = "whoopee cushion"
	desc = "A relic of archaic humor technology."
	icon = 'icons/obj/holiday/holiday_misc.dmi'
	icon_state = "whoopee"
	inhand_icon_state = null
	force = 0
	throwforce = 0
	throw_speed = 2
	throw_range = 5
	w_class = WEIGHT_CLASS_SMALL
	attack_verb_continuous = list("pranks", "braps", "farts")
	attack_verb_simple = list("prank", "brap", "fart")
	resistance_flags = NONE
	/// The totally classic sounds it makes
	var/list/fecal_funnies = list(
		'sound/effects/brap/brap1.ogg'=1,
		'sound/effects/brap/brap2.ogg'=1,
		'sound/effects/brap/brap3.ogg'=1,
		'sound/effects/brap/brap4.ogg'=1,
		)
	/// The amount of steps that it takes for the sound to play. On april fools this gets lowered to 1 (same # as clown shoes)
	var/step_delay = 10

/obj/item/clothing/head/costume/whoopee/Initialize(mapload)
	. = ..()
	if(check_holidays(APRIL_FOOLS))
		step_delay = 1
	LoadComponent(/datum/component/squeak, fecal_funnies, 50, falloff_exponent = 20, step_delay_override = step_delay)
