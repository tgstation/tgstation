/obj/item/slime_mutation_syringe
	name = "slime mutation syringe"
	desc = "Infuses a mutation into a slime."

	icon = 'monkestation/code/modules/slimecore/icons/slimes.dmi'
	icon_state = "mutation_syringe"

	w_class = WEIGHT_CLASS_SMALL

	/// Type path of the slime trait to infuse.
	var/datum/slime_trait/infusing_trait_path
	/// Amount of uses remaining.
	var/uses = 1

/obj/item/slime_mutation_syringe/examine(mob/user)
	. = ..()
	if(uses)
		. += span_notice("It has <b>[uses]</b> uses left.")
	else
		. += span_warning("It has been completely used up.")

/obj/item/slime_mutation_syringe/afterattack(atom/target, mob/user, proximity_flag, click_parameters)
	. = ..()
	if(!uses)
		user.balloon_alert(user, "used up")
		to_chat(user, span_warning("[src] has been completely used up!"))
		return
	if(!istype(target, /mob/living/basic/slime))
		return

	var/mob/living/basic/slime/slime = target

	if(ispath(infusing_trait_path) && !slime.add_trait(infusing_trait_path))
		return

	uses--
	update_icon_state()
	user.balloon_alert_to_viewers("injected mutator")
	to_chat(user, span_notice("You inject [target] with [src]."))
	on_inject(slime)
	if(uses <= 0)
		ADD_TRAIT(src, TRAIT_TRASH_ITEM, INNATE_TRAIT)

/obj/item/slime_mutation_syringe/proc/on_inject(mob/living/basic/slime/target)

/obj/item/slime_mutation_syringe/update_icon_state()
	. = ..()
	icon_state = uses ? initial(icon_state) : "[initial(icon_state)]-empty"

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

/obj/item/slime_mutation_syringe/random_color
	name = "random color slime mutation syringe"

/obj/item/slime_mutation_syringe/random_color/on_inject(mob/living/basic/slime/slime)
	slime.start_mutating(TRUE)
