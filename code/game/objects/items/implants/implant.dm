/**
 * Parent class for all implants
 */
/obj/item/implant
	name = "implant"
	icon = 'icons/hud/implants.dmi'
	icon_state = "generic" //Shows up as the action button icon
	item_flags = ABSTRACT | DROPDEL
	resistance_flags = INDESTRUCTIBLE
	// This gives the user an action button that allows them to activate the implant.
	// If the implant needs no action button, then null this out.
	// Or, if you want to add a unique action button, then replace this.
	actions_types = list(/datum/action/item_action/hands_free/activate)
	///the mob that's implanted with this
	var/mob/living/imp_in = null
	///implant color, used for selecting either the "b" version or the "r" version of the implant case sprite when the implant is in a case.
	var/implant_color = "b"
	///if false, upon implantation of a duplicate implant, an attempt to combine the new implant's uses with the old one's uses will be made, deleting the new implant if successful or stopping the implantation if not
	var/allow_multiple = FALSE
	///how many times this can do something, only relevant for implants with limited uses
	var/uses = -1
	///our implant flags
	var/implant_flags = NONE
	///what icon state will we represent ourselves with on the hud?
	var/hud_icon_state = null


/obj/item/implant/proc/activate()
	SEND_SIGNAL(src, COMSIG_IMPLANT_ACTIVATED)

/obj/item/implant/ui_action_click()
	INVOKE_ASYNC(src, PROC_REF(activate), "action_button")

/obj/item/implant/item_action_slot_check(slot, mob/user)
	return user == imp_in

/obj/item/implant/proc/can_be_implanted_in(mob/living/target)
	if(issilicon(target))
		return FALSE

	if(isslime(target))
		return TRUE

	if(!isanimal_or_basicmob(target))
		return TRUE

	return !(target.mob_biotypes & (MOB_ROBOTIC|MOB_MINERAL|MOB_SPIRIT))

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

	var/security_implants = 0 //Used to track how many implants with the "security" flag are in the user.
	for(var/obj/item/implant/other_implant as anything in target.implants)
		var/flags = SEND_SIGNAL(other_implant, COMSIG_IMPLANT_OTHER, args, src)
		if(flags & COMPONENT_STOP_IMPLANTING)
			UNSETEMPTY(target.implants)
			return FALSE
		if(!force && (other_implant.implant_flags & IMPLANT_TYPE_SECURITY))
			security_implants++
			if(security_implants >= SECURITY_IMPLANT_CAP) //We've found too many security implants in this mob, and will reject implantation by normal means
				balloon_alert(user, "too many security implants!")
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
	for(var/datum/action/implant_action as anything in actions)
		implant_action.Grant(target)
	if(ishuman(target))
		var/mob/living/carbon/human/target_human = target
		target_human.sec_hud_set_implants()

	if(user)
		log_combat(user, target, "implanted", "\a [name]")

	SEND_SIGNAL(src, COMSIG_IMPLANT_IMPLANTED, target, user, silent, force)
	GLOB.tracked_implants += src
	return TRUE

/**
 * Remove implant from mob.
 *
 * This removes the effects of the implant and moves it out of the mob and into nullspace.
 * Arguments:
 * * mob/living/source - What the implant is being removed from
 * * silent - unused here
 * * special - Set to true if removed by admin panel, should bypass any side effects
 */
/obj/item/implant/proc/removed(mob/living/source, silent = FALSE, special = 0)
	moveToNullspace()
	imp_in = null
	source.implants -= src
	for(var/datum/action/implant_action as anything in actions)
		implant_action.Remove(source)
	if(ishuman(source))
		var/mob/living/carbon/human/human_source = source
		human_source.sec_hud_set_implants()

	SEND_SIGNAL(src, COMSIG_IMPLANT_REMOVED, source, silent, special)
	GLOB.tracked_implants -= src
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

/// Determines if the implant is visible on the implant management console.
/// Note that this would only ever be called on implants currently inserted into a mob.
/obj/item/implant/proc/is_shown_on_console(obj/machinery/computer/prisoner/management/console)
	return FALSE

/**
 * Returns a list of information to show on the implant management console for this implant
 *
 * Unlike normal UI data, the keys of the list are shown on the UI itself, so they should be human readable.
 */
/obj/item/implant/proc/get_management_console_data()
	RETURN_TYPE(/list)

	var/list/info_shown = list()
	info_shown["ID"] = imp_in.name
	return info_shown

/**
 * Returns a list of "structs" that translate into buttons displayed on the implant management console
 *
 * The struct should have the following keys:
 * * name - the name of the button, optional if button_icon is set
 * * icon - the icon of the button, optional if button_name is set
 * * color - the color of the button, optional
 * * tooltip - the tooltip of the button, optional
 * * action_key - the key that will be passed to handle_management_console_action when the button is clicked
 * * action_params - optional, additional params passed when the button is clicked
 */
/obj/item/implant/proc/get_management_console_buttons()
	SHOULD_CALL_PARENT(TRUE)
	RETURN_TYPE(/list)

	var/list/buttons = list()
	UNTYPED_LIST_ADD(buttons, list(
		"name" = "Self Destruct",
		"color" = "bad",
		"tooltip" = "Destoys the implant from within the user harmlessly.",
		"action_key" = "self_destruct",
	))
	return buttons

/**
 * Handles a button click on the implant management console
 *
 * * user - the mob clicking the button
 * * params - the params passed to the button, as if this were a ui_act handler.
 * See params["implant_action"] for the action key passed to the button
 * (which should correspond to a button returned by get_management_console_buttons)
 * * console - the console the button was clicked on
 */
/obj/item/implant/proc/handle_management_console_action(mob/user, list/params, obj/machinery/computer/prisoner/management/console)
	SHOULD_CALL_PARENT(TRUE)

	if(params["implant_action"] == "self_destruct")
		var/warning = tgui_alert(user, "Activation will harmlessly self-destruct this implant. Proceed?", "You sure?", list("Yes", "No"))
		if(warning != "Yes" || QDELETED(src) || QDELETED(user) || QDELETED(console) || isnull(imp_in))
			return TRUE
		if(!console.is_operational || !user.can_perform_action(console, NEED_DEXTERITY|ALLOW_SILICON_REACH))
			return TRUE

		to_chat(imp_in, span_hear("You feel a tiny jolt from inside of you as one of your implants fizzles out."))
		do_sparks(number = 2, cardinal_only = FALSE, source = imp_in)
		deconstruct()
		return TRUE
