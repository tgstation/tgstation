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
	var/A

	A = input(user, "Area to jump to", "BOOYEA", A) as null|anything in GLOB.teleportlocs
	if(!src || QDELETED(src) || !user || !user.is_holding(src) || user.incapacitated() || !A || !uses)
		return
	var/area/thearea = GLOB.teleportlocs[A]

	var/datum/effect_system/smoke_spread/smoke = new
	smoke.set_up(2, user.loc)
	smoke.attach(user)
	smoke.start()
	var/list/L = list()
	for(var/turf/T in get_area_turfs(thearea.type))
		if(!T.is_blocked_turf())
			L += T

	if(!L.len)
		to_chat(user, "<span class='warning'>The spell matrix was unable to locate a suitable teleport destination for an unknown reason. Sorry.</span>")
		return

	if(do_teleport(user, pick(L), forceMove = TRUE, channel = TELEPORT_CHANNEL_MAGIC, forced = TRUE))
		smoke.start()
		uses--
		if(!uses)
			to_chat(user, "<span class='warning'>[src] has run out of uses and crumbles to dust!</span>")
			qdel(src)
		else
			to_chat(user, "<span class='notice'>[src] has [uses] use\s remaining.</span>")
	else
		to_chat(user, "<span class='warning'>The spell matrix was disrupted by something near the destination.</span>")
