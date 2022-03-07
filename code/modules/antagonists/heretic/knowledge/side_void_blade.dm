#define RISEN_MAX_HEALTH 125

/datum/heretic_knowledge/limited_amount/risen_corpse
	name = "Shattered Risen"
	desc = "Allows you to transmute a corpse with a soul, a pair of latex or nitrile gloves, and \
		and any exosuit clothing (such as armor) to create a Shattered Risen. \
		Shattered Risen are strong ghouls that have 125 health, but cannot hold items, \
		instead having two brutal weapons for hands. You can only create one at a time."
	gain_text = "I witnessed a cold, rending force drag this corpse back to near-life. \
		When it moves, it crunches like broken glass. Its hands are no longer recognizable as human - \
		each clenched fist contains a brutal nest of sharp bone-shards instead."
	next_knowledge = list(
		/datum/heretic_knowledge/cold_snap,
		/datum/heretic_knowledge/blade_dance,
	)
	required_atoms = list(
		/obj/item/clothing/suit = 1,
		/obj/item/clothing/gloves/color/latex = 1,
		/mob/living/carbon/human = 1,
	)
	limit = 1
	cost = 1
	route = PATH_SIDE

/datum/heretic_knowledge/limited_amount/risen_corpse/recipe_snowflake_check(mob/living/user, list/atoms, list/selected_atoms, turf/loc)
	. = ..()
	if(!.)
		return FALSE

	for(var/mob/living/carbon/human/body in atoms)
		if(body.stat != DEAD || !IS_VALID_GHOUL_MOB(body) || HAS_TRAIT(body, TRAIT_HUSK))
			atoms -= body
			continue

		// We will only grab bodies with minds that have ghosts (with clients)
		if(!body.mind?.get_ghost(ghosts_with_clients = TRUE))
			atoms -= body
			continue

	if(!(locate(/mob/living/carbon/human) in atoms))
		loc.balloon_alert(user, "ritual failed, no valid body!")
		return FALSE

	return TRUE

/datum/heretic_knowledge/limited_amount/risen_corpse/on_finished_recipe(mob/living/user, list/selected_atoms, turf/loc)
	var/mob/living/carbon/human/soon_to_be_ghoul = locate() in selected_atoms
	if(QDELETED(soon_to_be_ghoul)) // No body? No ritual
		stack_trace("[type] reached on_finished_recipe without a human in selected_atoms to make a ghoul out of.")
		loc.balloon_alert(user, "ritual failed, no valid body!")
		return FALSE

	soon_to_be_ghoul.grab_ghost()
	if(!soon_to_be_ghoul.mind || !soon_to_be_ghoul.client)
		stack_trace("[type] reached on_finished_recipe without a minded / cliented human in selected_atoms to make a ghoul out of.")
		loc.balloon_alert(user, "ritual failed, no valid body!")
		return FALSE

	LAZYADD(created_items, WEAKREF(soon_to_be_ghoul))
	selected_atoms -= soon_to_be_ghoul

	log_game("[key_name(user)] created a shattered risen out of [key_name(soon_to_be_ghoul)].")
	message_admins("[ADMIN_LOOKUPFLW(user)] shattered risen out of [ADMIN_LOOKUPFLW(soon_to_be_ghoul)].")

	soon_to_be_ghoul.apply_status_effect(/datum/status_effect/ghoul, RISEN_MAX_HEALTH, user.mind)
	RegisterSignal(soon_to_be_ghoul, COMSIG_ANTAGONIST_REMOVED, .proc/free_ghoul_slot)


/datum/heretic_knowledge/limited_amount/risen_corpse/proc/free_ghoul_slot(mob/living/carbon/human/source, datum/antagonist/removed)
	SIGNAL_HANDLER

	if(!istype(removed, /datum/antagonist/heretic_monster))
		return

	LAZYREMOVE(created_items, WEAKREF(source))

#undef RISEN_MAX_HEALTH
