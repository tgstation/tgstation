
/proc/create_portal_pair(turf/source, turf/destination, _creator = null, _lifespan = 300, accuracy = 0)
	if(!istype(source) || !istype(destination))
		return
	var/turf/actual_destination = get_teleport_turf(destination, accuracy)
	var/obj/effect/portal/P1 = new(source, _creator, _lifespan, null, FALSE)
	var/obj/effect/portal/P2 = new(actual_destination, _creator, _lifespan, P1, TRUE)
	P1.link_portal(P2)
	P1.hardlinked = TRUE
	return list(P1, P2)

/obj/effect/portal
	name = "portal"
	desc = "Looks unstable. Best to test it with the clown."
	icon = 'icons/obj/stationobjs.dmi'
	icon_state = "portal"
	anchored = TRUE
	var/mech_sized = FALSE
	var/obj/effect/portal/linked
	var/hardlinked = TRUE			//Requires a linked portal at all times. Destroy if there's no linked portal, if there is destroy it when this one is deleted.
	var/creator
	var/turf/hard_target			//For when a portal needs a hard target and isn't to be linked.

/obj/effect/portal/attackby(obj/item/weapon/W, mob/user, params)
	if(user && Adjacent(user))
		teleport(user)

/obj/effect/portal/make_frozen_visual()
	return

/obj/effect/portal/Crossed(atom/movable/AM)
	if(!teleport(AM))
		return ..()

/obj/effect/portal/attack_tk(mob/user)
	return

/obj/effect/portal/attack_hand(mob/user)
	if(Adjacent(user))
		teleport(user)

/obj/effect/portal/Initialize(mapload, _creator, _lifespan = 300, obj/effect/portal/_linked = null, automatic_link = TRUE, hard_target_override = null)
	. = ..()
	GLOB.portals += src
	if(!istype(_linked) && automatic_link)
		return INITIALIZE_HINT_QDEL
	if(_lifespan > 0)
		QDEL_IN(src, _lifespan)
	link_portal(_linked)
	hardlinked = automatic_link
	creator = _creator

/obj/effect/portal/proc/link_portal(obj/effect/portal/newlink)
	linked = newlink
	if(newlink)
		var/turf/T = get_turf(src)
		T.atmos_adjacent_turfs[get_turf(newlink)] = TRUE

/obj/effect/portal/Destroy()				//Calls on_portal_destroy(destroyed portal, location of destroyed portal) on creator if creator has such call.
	if(creator && hascall(creator, "on_portal_destroy"))
		call(creator, "on_portal_destroy")(src, src.loc)
	creator = null
	GLOB.portals -= src
	var/turf/T = get_turf(src)
	if(linked)
		var/turf/LT = get_turf(linked)
		if(!T.Adjacent(LT)) //if we're adjacent, we're probably meant to be atmos-adjacent
			T.atmos_adjacent_turfs -= LT
	if(hardlinked && !QDELETED(linked))
		QDEL_NULL(linked)
	else
		linked = null
	return ..()

/obj/effect/portal/proc/teleport(atom/movable/M)
	if(!istype(M) || istype(M, /obj/effect) || (istype(M, /obj/mecha) && !mech_sized) || (!isobj(M) && !ismob(M))) //Things that shouldn't teleport.
		return
	var/turf/real_target
	if(!istype(linked) || QDELETED(linked))
		if(hardlinked)
			qdel(src)
		if(!istype(hard_target) || QDELETED(hard_target))
			hard_target = null
			return
		else
			real_target = hard_target
			linked = null
	else
		real_target = get_turf(linked)
	if(ismegafauna(M))
		message_admins("[M] has used a portal at [ADMIN_COORDJMP(src)] made by [usr].")
	do_teleport(M, real_target, 0)
