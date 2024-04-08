/obj/item/slime_mutation_syringe
	name = "slime mutation syringe"
	desc = "Infuses a mutation into a slime."

	icon = 'monkestation/code/modules/slimecore/icons/slimes.dmi'
	icon_state = "mutation_syringe"

	///the path we infuse
	var/datum/slime_trait/infusing_trait_path
	/// have we been used?
	var/used = FALSE


/obj/item/slime_mutation_syringe/afterattack(atom/target, mob/user, proximity_flag, click_parameters)
	. = ..()
	if(!infusing_trait_path || used)
		return
	if(!istype(target, /mob/living/basic/slime))
		return

	var/mob/living/basic/slime/slime = target
	if(slime.add_trait(infusing_trait_path))
		used = TRUE
		icon_state = "mutation_syringe-empty"
		to_chat(user, span_notice("You inject [target] with [src]."))


/obj/item/slime_mutation_syringe/cleaner
	name = "cleaner slime mutation syringe"
	infusing_trait_path = /datum/slime_trait/cleaner

/obj/item/slime_mutation_syringe/polluter
	name = "polluter slime mutation syringe"
	infusing_trait_path = /datum/slime_trait/polluter

/obj/item/slime_mutation_syringe/gooey_cat
	name = "gooey cat slime mutation syringe"
	infusing_trait_path = /datum/slime_trait/visual/cat

/obj/item/slime_mutation_syringe/radioactive
	name = "radioactive slime mutation syringe"
	infusing_trait_path = /datum/slime_trait/radioactive

/obj/item/slime_mutation_syringe/never_evolving
	name = "never splitting slime mutation syringe"
	infusing_trait_path = /datum/slime_trait/never_evolving

/obj/item/slime_mutation_syringe/never_ooze
	name = "never ooze slime mutation syringe"
	infusing_trait_path = /datum/slime_trait/never_ooze

/obj/item/slime_mutation_syringe/soda_slime
	name = "soda slime mutation syringe"
	infusing_trait_path = /datum/slime_trait/soda_slime

/obj/item/slime_mutation_syringe/beer_slime
	name = "beer slime mutation syringe"
	infusing_trait_path = /datum/slime_trait/beer_slime

/obj/item/slime_mutation_syringe_random
	name = "slime mutation syringe"
	desc = "Infuses a mutation into a slime."

	icon = 'monkestation/code/modules/slimecore/icons/slimes.dmi'
	icon_state = "mutation_syringe"

	/// have we been used?
	var/used = FALSE


/obj/item/slime_mutation_syringe_random/afterattack(atom/target, mob/user, proximity_flag, click_parameters)
	. = ..()
	if(used)
		return
	if(!istype(target, /mob/living/basic/slime))
		return

	var/mob/living/basic/slime/slime = target
	slime.start_mutating(TRUE)
	used = TRUE
	icon_state = "mutation_syringe-empty"
	to_chat(user, span_notice("You inject [target] with [src]."))
