
/obj/effect/portal
	name = "portal"
	desc = "Looks unstable. Best to test it with the clown."
	icon = 'icons/obj/stationobjs.dmi'
	icon_state = "portal"
	density = 1
	var/obj/item/target = null
	var/creator = null
	anchored = 1
	var/precision = 1 // how close to the portal you will teleport. 0 = on the portal, 1 = adjacent
	var/mech_sized = FALSE

/obj/effect/portal/Bumped(mob/M as mob|obj)
	teleport(M)

/obj/effect/portal/attack_tk(mob/user)
	return

/obj/effect/portal/attack_hand(mob/user)
	if(Adjacent(user))
		teleport(user)

/obj/effect/portal/attackby(obj/item/weapon/W, mob/user, params)
	if(user && Adjacent(user))
		teleport(user)

/obj/effect/portal/make_frozen_visual()
	return

/obj/effect/portal/New(loc, turf/target, creator=null, lifespan=300)
	..()
	portals += src
	src.target = target
	src.creator = creator

	var/area/A = get_area(target)
	if(A && A.noteleport) // No point in persisting if the target is unreachable.
		qdel(src)
		return
	if(lifespan > 0)
		QDEL_IN(src, lifespan)

/obj/effect/portal/Destroy()
	portals -= src
	if(istype(creator, /obj/item/weapon/hand_tele))
		var/obj/item/weapon/hand_tele/O = creator
		O.active_portals--
	else if(istype(creator, /obj/item/weapon/gun/energy/wormhole_projector))
		var/obj/item/weapon/gun/energy/wormhole_projector/P = creator
		P.portal_destroyed(src)
	creator = null
	return ..()

/obj/effect/portal/proc/teleport(atom/movable/M as mob|obj)
	if(istype(M, /obj/effect)) //sparks don't teleport
		return
	if(M.anchored)
		if(!(istype(M, /obj/mecha) && mech_sized))
			return
	if (!( target ))
		qdel(src)
		return
	if (istype(M, /atom/movable))
		if(ismegafauna(M))
			message_admins("[M] (<A HREF='?_src_=holder;adminplayerobservefollow=\ref[M]'>FLW</A>) has teleported through [src].")
		do_teleport(M, target, precision) ///You will appear adjacent to the beacon


