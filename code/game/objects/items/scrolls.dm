/obj/item/teleportation_scroll
	name = "scroll of teleportation"
	desc = "A scroll for moving around."
	icon = 'icons/obj/wizard.dmi'
	icon_state = "scroll"
	worn_icon_state = "scroll"
	w_class = WEIGHT_CLASS_SMALL
	inhand_icon_state = "paper"
	throw_speed = 3
	throw_range = 7
	resistance_flags = FLAMMABLE
	/// Number of uses remaining
	var/uses = 4

/obj/item/teleportation_scroll/apprentice
	name = "lesser scroll of teleportation"
	uses = 1

/obj/item/teleportation_scroll/examine(mob/user)
	. = ..()
	if(uses > 0)
		. += "It has [uses] use\s remaining."

/obj/item/teleportation_scroll/attack_self(mob/user)
	if(!uses)
		return
	if(!ishuman(user))
		return
	var/mob/living/carbon/human/human_user = user
	if(human_user.incapacitated())
		return
	if(!human_user.is_holding(src))
		return
	teleportscroll(human_user)

/**
 * Shows a list of a possible teleport destinations to a user and then teleports him to to his chosen destination
 *
 * Arguments:
 * * user The mob that is being teleported
 */
/obj/item/teleportation_scroll/proc/teleportscroll(mob/user)
	if(!length(GLOB.teleportlocs))
		to_chat(user, span_warning("There are no locations available"))
		return
	var/jump_target = tgui_input_list(user, "Area to jump to", "BOOYEA", GLOB.teleportlocs)
	if(isnull(jump_target))
		return
	if(!src || QDELETED(src) || !user || !user.is_holding(src) || user.incapacitated() || !uses)
		return
	var/area/thearea = GLOB.teleportlocs[jump_target]

	var/datum/effect_system/fluid_spread/smoke/smoke = new
	smoke.set_up(2, location = user.loc)
	smoke.attach(user)
	smoke.start()
	var/list/possible_locations = list()
	for(var/turf/target_turf in get_area_turfs(thearea.type))
		if(!target_turf.is_blocked_turf())
			possible_locations += target_turf

	if(!length(possible_locations))
		to_chat(user, span_warning("The spell matrix was unable to locate a suitable teleport destination for an unknown reason."))
		return

	if(do_teleport(user, pick(possible_locations), channel = TELEPORT_CHANNEL_MAGIC, forced = TRUE))
		smoke.start()
		uses--
		if(!uses)
			to_chat(user, span_warning("[src] has run out of uses and crumbles to dust!"))
			qdel(src)
		else
			to_chat(user, span_notice("[src] has [uses] use\s remaining."))
	else
		to_chat(user, span_warning("The spell matrix was disrupted by something near the destination."))
