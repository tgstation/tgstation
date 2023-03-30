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
	icon_state = "ninja-explosive0"
	inhand_icon_state = "ninja-explosive"
	boom_sizes = list(4, 8, 12)
	///Weakref to the mob that has planted the charge
	var/datum/weakref/detonator
	///The only area that the charge is allowed to be planted, and detonated in
	var/area/detonation_area

/obj/item/grenade/c4/ninja/Destroy()
	detonator = null
	detonation_area = null
	return ..()

/**
 * set_detonation_area
 *
 * Proc used to set the allowed location for charge detonation
 *
 * Arguments
 * * datum/antagonist/ninja/ninja_antag - The antag datum for the owner of the c4
 */
/obj/item/grenade/c4/ninja/proc/set_detonation_area(datum/antagonist/ninja/ninja_antag)
	if (!ninja_antag)
		return
	var/datum/objective/plant_explosive/objective = locate() in ninja_antag.objectives
	if (!objective)
		return
	detonation_area = objective.detonation_location

/obj/item/grenade/c4/ninja/afterattack(atom/movable/AM, mob/ninja, flag)
	if(!IS_SPACE_NINJA(ninja))
		to_chat(ninja, span_notice("While it appears normal, you can't seem to detonate the charge."))
		return
	. |= AFTERATTACK_PROCESSED_ITEM
	if (!check_loc(ninja))
		return .
	detonator = WEAKREF(ninja)
	return . | ..()

/obj/item/grenade/c4/ninja/detonate(mob/living/lanced_by)
	if(!check_loc(detonator.resolve())) // if its moved, deactivate the c4
		var/obj/item/grenade/c4/ninja/new_c4 = new /obj/item/grenade/c4/ninja(target.loc)
		new_c4.detonation_area = detonation_area
		new_c4.say("Invalid location!")
		target.cut_overlay(plastic_overlay, TRUE)
		qdel(src)
		return
	//Since we already did the checks in afterattack, the denonator must be a ninja with the bomb objective.
	if(!detonator)
		return
	var/mob/ninja = detonator.resolve()
	. = ..()
	if(!.)
		return
	if (isnull(ninja))
		return
	var/datum/antagonist/ninja/ninja_antag = ninja.mind.has_antag_datum(/datum/antagonist/ninja)
	var/datum/objective/plant_explosive/objective = locate() in ninja_antag.objectives
	objective.completed = TRUE

/**
 * check_loc
 *
 * Checks to see if the c4 is in the correct place when being planted.
 *
 * Arguments
 * * mob/user - The planter of the c4
 */
/obj/item/grenade/c4/ninja/proc/check_loc(mob/user)
	if(!detonation_area)
		to_chat(user, span_notice("You can't seem to activate the charge.  It's location-locked, but you don't know where to detonate it."))
		return FALSE
	if((get_area(target) != detonation_area) && (get_area(src) != detonation_area))
		if (!active)
			to_chat(user, span_notice("This isn't the location you're supposed to use this!"))
		return FALSE
	return TRUE
