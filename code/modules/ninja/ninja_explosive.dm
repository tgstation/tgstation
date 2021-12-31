/**
 * # Spider Charge
 *
 * A unique version of c4 possessed only by the space ninja.  Has a stronger blast radius.
 * Can only be detonated by space ninjas with the bombing objective.  Can only be set up where the objective says it can.
 * When it primes, the space ninja responsible will have their objective set to complete.
 *
 */
/obj/item/grenade/c4/ninja
	name = "spider charge"
	desc = "A modified C-4 charge supplied to you by the Spider Clan.  Its explosive power has been juiced up, but only works in one specific area."
	boom_sizes = list(4, 8, 12)
	var/mob/detonator = null

/obj/item/grenade/c4/ninja/afterattack(atom/movable/AM, mob/user, flag)
	var/datum/antagonist/ninja/ninja_antag = user.mind.has_antag_datum(/datum/antagonist/ninja)
	if(!ninja_antag)
		to_chat(user, span_notice("While it appears normal, you can't seem to detonate the charge."))
		return
	if (!check_loc(user, ninja_antag))
		return
	detonator = user
	return ..()

/obj/item/grenade/c4/ninja/detonate(mob/living/lanced_by)
	var/datum/antagonist/ninja/ninja_antag = detonator.mind.has_antag_datum(/datum/antagonist/ninja)
	if(!check_loc(detonator, ninja_antag)) // if its moved, deactivate the c4
		new /obj/item/grenade/c4/ninja(target.loc)
		target.cut_overlay(plastic_overlay, TRUE)
		qdel(src)
		return
	. = ..()
	//Since we already did the checks in afterattack, the denonator must be a ninja with the bomb objective.
	if(!detonator)
		return
	var/datum/objective/plant_explosive/objective = locate() in ninja_antag.objectives
	objective.completed = TRUE

/obj/item/grenade/c4/ninja/proc/check_loc(mob/user, datum/antagonist/ninja/ninja_antag)
	var/datum/objective/plant_explosive/objective = locate() in ninja_antag.objectives
	if(active)
		say("Invalid location!") // TODO: make c4 code not be complete shit and actually set active to true
		return
	if(!objective)
		to_chat(user, span_notice("You can't seem to activate the charge.  It's location-locked, but you don't know where to detonate it."))
		return FALSE
	if(objective.detonation_location != get_area(user))
		to_chat(user, span_notice("This isn't the location you're supposed to use this!"))
		return FALSE
	return TRUE
