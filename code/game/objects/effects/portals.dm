
/proc/create_portal_pair(turf/source, turf/destination, _lifespan = 300, accuracy = 0, newtype = /obj/effect/portal, atmos_link_override)
	if(!istype(source) || !istype(destination))
		return
	var/turf/actual_destination = get_teleport_turf(destination, accuracy)
	var/obj/effect/portal/P1 = new newtype(source, _lifespan, null, FALSE, null, atmos_link_override)
	var/obj/effect/portal/P2 = new newtype(actual_destination, _lifespan, P1, TRUE, null, atmos_link_override)
	if(!istype(P1)||!istype(P2))
		return
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
	var/teleport_channel = TELEPORT_CHANNEL_BLUESPACE
	var/turf/hard_target			//For when a portal needs a hard target and isn't to be linked.
	var/atmos_link = FALSE			//Link source/destination atmos.
	var/turf/open/atmos_source		//Atmos link source
	var/turf/open/atmos_destination	//Atmos link destination
	var/allow_anchored = FALSE
	var/innate_accuracy_penalty = 0
	var/last_effect = 0
	var/force_teleport = FALSE

/obj/effect/portal/anom
	name = "wormhole"
	icon = 'icons/obj/objects.dmi'
	icon_state = "anom"
	layer = RIPPLE_LAYER
	mech_sized = TRUE
	teleport_channel = TELEPORT_CHANNEL_WORMHOLE

/obj/effect/portal/Move(newloc)
	for(var/T in newloc)
		if(istype(T, /obj/effect/portal))
			return FALSE
	return ..()

/obj/effect/portal/attackby(obj/item/W, mob/user, params)
	if(user && Adjacent(user))
		user.forceMove(get_turf(src))
		return TRUE

/obj/effect/portal/Crossed(atom/movable/AM, oldloc, force_stop = 0)
	if(force_stop)
		return ..()
	if(isobserver(AM))
		return ..()
	if(linked && (get_turf(oldloc) == get_turf(linked)))
		return ..()
	if(!teleport(AM))
		return ..()

/obj/effect/portal/attack_tk(mob/user)
	return

/obj/effect/portal/attack_hand(mob/user)
	. = ..()
	if(.)
		return
	if(get_turf(user) == get_turf(src))
		teleport(user)
	if(Adjacent(user))
		user.forceMove(get_turf(src))

/obj/effect/portal/Initialize(mapload, _lifespan = 0, obj/effect/portal/_linked, automatic_link = FALSE, turf/hard_target_override, atmos_link_override)
	. = ..()
	GLOB.portals += src
	if(!istype(_linked) && automatic_link)
		. = INITIALIZE_HINT_QDEL
		CRASH("Somebody fucked up.")
	if(_lifespan > 0)
		QDEL_IN(src, _lifespan)
	if(!isnull(atmos_link_override))
		atmos_link = atmos_link_override
	link_portal(_linked)
	hardlinked = automatic_link
	if(isturf(hard_target_override))
		hard_target = hard_target_override

/obj/effect/portal/singularity_pull()
	return

/obj/effect/portal/singularity_act()
	return

/obj/effect/portal/proc/link_portal(obj/effect/portal/newlink)
	linked = newlink
	if(atmos_link)
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
		if(istype(atmos_destination))
			LAZYREMOVE(atmos_source.atmos_adjacent_turfs, atmos_destination)
			atmos_source.ImmediateCalculateAdjacentTurfs() //Just in case they were next to each other
		atmos_source = null
	if(istype(atmos_destination))
		if(istype(atmos_source))
			LAZYREMOVE(atmos_destination.atmos_adjacent_turfs, atmos_source)
			atmos_destination.ImmediateCalculateAdjacentTurfs()
		atmos_destination = null

/obj/effect/portal/Destroy()
	GLOB.portals -= src
	unlink_atmos()
	if(hardlinked && !QDELETED(linked))
		QDEL_NULL(linked)
	else
		linked = null
	return ..()

/obj/effect/portal/attack_ghost(mob/dead/observer/O)
	if(!teleport(O, TRUE))
		return ..()

/obj/effect/portal/proc/teleport(atom/movable/M, force = FALSE)
	if(!force && (!istype(M) || iseffect(M) || (ismecha(M) && !mech_sized) || (!isobj(M) && !ismob(M)))) //Things that shouldn't teleport.
		return
	var/turf/real_target = get_link_target_turf()
	if(!istype(real_target))
		return FALSE
	if(!force && (!ismecha(M) && !istype(M, /obj/projectile) && M.anchored && !allow_anchored))
		return
	var/no_effect = FALSE
	if(last_effect == world.time)
		no_effect = TRUE
	else
		last_effect = world.time
	if(do_teleport(M, real_target, innate_accuracy_penalty, no_effects = no_effect, channel = teleport_channel, forced = force_teleport))
		if(istype(M, /obj/projectile))
			var/obj/projectile/P = M
			P.ignore_source_check = TRUE
		return TRUE
	return FALSE

/obj/effect/portal/proc/get_link_target_turf()
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

/obj/effect/portal/permanent
	name = "permanent portal"
	desc = "An unwavering portal that will never fade."
	hardlinked = FALSE // dont qdel my portal nerd
	force_teleport = TRUE // force teleports because they're a mapmaker tool
	var/id // var edit or set id in map editor

/obj/effect/portal/permanent/proc/set_linked()
	if(!id)
		return
	for(var/obj/effect/portal/permanent/P in GLOB.portals - src)
		if(P.id == id)
			P.linked = src
			linked = P
			break

/obj/effect/portal/permanent/teleport(atom/movable/M, force = FALSE)
	set_linked() // update portal links
	. = ..()

/obj/effect/portal/permanent/one_way // doesn't have a return portal, can have multiple exits, /obj/effect/landmark/portal_exit to mark them
	name = "one-way portal"
	desc = "You get the feeling that this might not be the safest thing you've ever done."

/obj/effect/portal/permanent/one_way/set_linked()
	if(!id)
		return
	var/list/possible_turfs = list()
	for(var/obj/effect/landmark/portal_exit/PE in GLOB.landmarks_list)
		if(PE.id == id)
			var/turf/T = get_turf(PE)
			if(T)
				possible_turfs |= T
	if(possible_turfs.len)
		hard_target = pick(possible_turfs)

/obj/effect/portal/permanent/one_way/one_use
	name = "one-use portal"
	desc = "This is probably the worst decision you'll ever make in your life."

/obj/effect/portal/permanent/one_way/one_use/teleport(atom/movable/M, force = FALSE)
	. = ..()
	qdel(src)
