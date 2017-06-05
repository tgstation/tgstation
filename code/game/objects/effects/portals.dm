
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
	var/atmos_link = FALSE			//Link source/destination atmos.
	var/turf/open/atmos_source		//Atmos link source
	var/turf/open/atmos_destination	//Atmos link destination

/obj/effect/portal/attackby(obj/item/weapon/W, mob/user, params)
	if(user && Adjacent(user))
		user.forceMove(get_turf(src))
		teleport(user)

/obj/effect/portal/make_frozen_visual()
	return

/obj/effect/portal/Crossed(atom/movable/AM, oldloc)
	if(get_turf(oldloc) == get_turf(linked))
		return ..()
	if(!teleport(AM))
		return ..()

/obj/effect/portal/attack_tk(mob/user)
	return

/obj/effect/portal/attack_hand(mob/user)
	if(Adjacent(user))
		user.forceMove(get_turf(src))
		teleport(user)

/obj/effect/portal/Initialize(mapload, _creator, _lifespan = 300, obj/effect/portal/_linked = null, automatic_link = TRUE, hard_target_override = null, atmos_link_override = null)
	. = ..()
	GLOB.portals += src
	if(!istype(_linked) && automatic_link)
		return INITIALIZE_HINT_QDEL
	if(_lifespan > 0)
		QDEL_IN(src, _lifespan)
	if(!isnull(atmos_link_override))
		atmos_link = atmos_link_override
	link_portal(_linked)
	hardlinked = automatic_link
	creator = _creator

/obj/effect/portal/proc/link_portal(obj/effect/portal/newlink)
	linked = newlink
	if(atmos_link)
		unlink_atmos()
		link_atmos()

/obj/effect/portal/proc/link_atmos()
	if(atmos_source || atmos_destination)
		unlink_atmos()
	if(!isopenturf(get_turf(src)))
		return FALSE
	if(linked)
		if(isopenturf(get_turf(linked)))
			atmos_source = get_turf(src)
			atmos_destination = get_turf(linked)
	else if(hard_target)
		if(isopenturf(hard_target))
			atmos_source = get_turf(src)
			atmos_destination = hard_target
	else
		return FALSE
	if(!istype(atmos_source) || !istype(atmos_destination))
		return FALSE
	LAZYINITLIST(atmos_source.atmos_adjacent_turfs)
	LAZYINITLIST(atmos_destination.atmos_adjacent_turfs)
	if(atmos_source.atmos_adjacent_turfs[atmos_destination] || atmos_destination.atmos_adjacent_turfs[atmos_source])	//Already linked!
		return FALSE
	atmos_source.atmos_adjacent_turfs[atmos_destination] = TRUE
	atmos_destination.atmos_adjacent_turfs[atmos_source] = TRUE
	atmos_source.air_update_turf(FALSE)
	atmos_destination.air_update_turf(FALSE)

/obj/effect/portal/proc/unlink_atmos()
	if(istype(atmos_source))
		LAZYREMOVE(atmos_source.atmos_adjacent_turfs, atmos_destination)
		atmos_source = null
	if(istype(atmos_destination))
		LAZYREMOVE(atmos_destination.atmos_adjacent_turfs, atmos_source)
		atmos_destination = null

/obj/effect/portal/Destroy()				//Calls on_portal_destroy(destroyed portal, location of destroyed portal) on creator if creator has such call.
	if(creator && hascall(creator, "on_portal_destroy"))
		call(creator, "on_portal_destroy")(src, src.loc)
	creator = null
	GLOB.portals -= src
	unlink_atmos()
	if(hardlinked && !QDELETED(linked))
		QDEL_NULL(linked)
	else
		linked = null
	return ..()

/obj/effect/portal/proc/teleport(atom/movable/M)
	var/turf/real_target = get_link_target_turf()
	if(!istype(real_target))
		return FALSE
	if(ismegafauna(M))
		message_admins("[M] has used a portal at [ADMIN_COORDJMP(src)] made by [usr].")
	if(do_teleport(M, real_target, 0))
		if(istype(M, /obj/item/projectile))
			var/obj/item/projectile/P = M
			P.ignore_source_check = TRUE
		return TRUE
	return FALSE

/obj/effect/portal/proc/get_link_target_turf()
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
	return real_target

