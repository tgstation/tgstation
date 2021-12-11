/**
 * Parent class for all implants
 */
/obj/item/implant
	name = "implant"
	icon = 'icons/obj/implants.dmi'
	icon_state = "generic" //Shows up as the action button icon
	actions_types = list(/datum/action/item_action/hands_free/activate)
	///true for implant types that can be activated, false for ones that are "always on" like mindshield implants
	var/activated = TRUE
	///the mob that's implanted with this
	var/mob/living/imp_in = null
	///implant color, used for selecting either the "b" version or the "r" version of the implant case sprite when the implant is in a case.
	var/implant_color = "b"
	///if false, upon implantation of a duplicate implant, an attempt to combine the new implant's uses with the old one's uses will be made, deleting the new implant if successful or stopping the implantation if not
	var/allow_multiple = FALSE
	///how many times this can do something, only relevant for implants with limited uses
	var/uses = -1
	item_flags = DROPDEL

/obj/item/implant/proc/activate()
	SEND_SIGNAL(src, COMSIG_IMPLANT_ACTIVATED)

/obj/item/implant/ui_action_click()
	INVOKE_ASYNC(src, .proc/activate, "action_button")

/obj/item/implant/proc/can_be_implanted_in(mob/living/target)
	if(issilicon(target))
		return FALSE

	if(isslime(target))
		return TRUE

	if(isanimal(target))
		var/mob/living/simple_animal/animal = target
		// Robots and most non-organics aren't healable.
		return animal.healable

	return TRUE

/**
 * What does the implant do upon injection?
 *
 * return true if the implant injects
 * return false if there is no room for implant / it fails
 * Arguments:
 * * mob/living/target - mob being implanted
 * * mob/user - mob doing the implanting
 * * silent - unused here
 * * force - if true, implantation will not fail if can_be_implanted_in returns false
 */
/obj/item/implant/proc/implant(mob/living/target, mob/user, silent = FALSE, force = FALSE)
	if(SEND_SIGNAL(src, COMSIG_IMPLANT_IMPLANTING, args) & COMPONENT_STOP_IMPLANTING)
		return
	LAZYINITLIST(target.implants)
	if(!force && !can_be_implanted_in(target))
		return FALSE

	for(var/X in target.implants)
		var/obj/item/implant/other_implant = X
		var/flags = SEND_SIGNAL(other_implant, COMSIG_IMPLANT_OTHER, args, src)
		if(flags & COMPONENT_STOP_IMPLANTING)
			UNSETEMPTY(target.implants)
			return FALSE
		if(flags & COMPONENT_DELETE_NEW_IMPLANT)
			UNSETEMPTY(target.implants)
			qdel(src)
			return TRUE
		if(flags & COMPONENT_DELETE_OLD_IMPLANT)
			qdel(other_implant)
			continue

		if(!istype(other_implant, type) || allow_multiple)
			continue

		if(other_implant.uses < initial(other_implant.uses)*2)
			if(uses == -1)
				other_implant.uses = -1
			else
				other_implant.uses = min(other_implant.uses + uses, initial(other_implant.uses)*2)
			qdel(src)
			return TRUE
		else
			return FALSE

	forceMove(target)
	imp_in = target
	target.implants += src
	if(activated)
		for(var/X in actions)
			var/datum/action/implant_action = X
			implant_action.Grant(target)
	if(ishuman(target))
		var/mob/living/carbon/human/target_human = target
		target_human.sec_hud_set_implants()

	if(user)
		log_combat(user, target, "implanted", "\a [name]")

	SEND_SIGNAL(src, COMSIG_IMPLANT_IMPLANTED, target, user, silent, force)
	return TRUE

/**
 * Remove implant from mob.
 *
 * This removes the effects of the implant and moves it out of the mob and into nullspace.
 * Arguments:
 * * mob/living/source - What the implant is being removed from
 * * silent - unused here
 * * special - unused here
 */
/obj/item/implant/proc/removed(mob/living/source, silent = FALSE, special = 0)
	moveToNullspace()
	imp_in = null
	source.implants -= src
	for(var/X in actions)
		var/datum/action/implant_action = X
		implant_action.Remove(source)
	if(ishuman(source))
		var/mob/living/carbon/human/human_source = source
		human_source.sec_hud_set_implants()

	SEND_SIGNAL(src, COMSIG_IMPLANT_REMOVED, source, silent, special)
	return TRUE

/obj/item/implant/Destroy()
	if(imp_in)
		removed(imp_in)
	return ..()
/**
 * Gets implant specifications for the implant pad
 */
/obj/item/implant/proc/get_data()
	return "No information available"

/obj/item/implant/dropped(mob/user)
	. = TRUE
	..()
