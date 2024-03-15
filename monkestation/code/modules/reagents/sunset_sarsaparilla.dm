//tada modularized now (please merge this back in)

/datum/reagent/consumable/sunset_sarsaparilla
	name = "Sunset Sarsaparilla"
	description = "Build Mass with Sass!"
	color = "#633504" // rgb: 99, 53, 4
	quality = DRINK_VERYGOOD
	taste_description = "the wild west"
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED

/datum/glass_style/drinking_glass/sunset_sarsaparilla
	required required_drink_type = /datum/reagent/consumable/sunset_sarsaparilla
	name = "glass of Sunset Sarsparilla"
	desc = "Locally sourced from your nearest nuclear wasteland."
	icon = 'monkestation/icons/obj/drinks/soda.dmi'
	icon_state = "sunset_sarsparillaglass"

/datum/reagent/consumable/sunset_sarsaparilla/on_mob_life(mob/living/carbon/drinker)
	. = ..()
	drinker.heal_bodypart_damage(brute = 2.5)
	drinker.heal_bodypart_damage(burn = 2.5)

