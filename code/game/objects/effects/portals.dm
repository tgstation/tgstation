/obj/effect/portal
	name = "portal"
	desc = "Looks stable, but still, best to test it with the clown first."
	icon = 'icons/obj/stationobjs.dmi'
	icon_state = "portal0"
	density = 0
	unacidable = 1//Can't destroy energy portals.
	var/obj/target = null
	var/obj/item/weapon/creator = null
	anchored = 1.0
	w_type=NOT_RECYCLABLE
	var/undergoing_deletion = 0

	var/list/exit_beams = list()

/obj/effect/portal/attack_hand(var/mob/user)
	spawn()
		src.teleport(user)

/obj/effect/portal/attackby(obj/item/weapon/O as obj, mob/user as mob)
	if(O == creator)
		to_chat(user, "<span class='warning'>You close the portal prematurely.</span>")
		qdel(src)
	else
		spawn()
			src.teleport(user)
/*
/obj/effect/portal/Bumped(mob/M as mob|obj)
	spawn()
		src.teleport(M)
*/
/obj/effect/portal/Crossed(AM as mob|obj,var/no_tp=0)
	if(no_tp)
		return
	if(istype(AM,/obj/item/projectile/beam))
		var/obj/item/projectile/beam/B = AM
		B.wait = 1
	spawn()
		src.teleport(AM)

/obj/effect/portal/CanPass(atom/movable/mover, turf/target, height=1.5, air_group = 0)
	if(istype(mover,/obj/effect/beam))
		return 0
	else
		return ..()

/obj/effect/portal/New(turf/loc,var/lifespan=300)
	..()
	playsound(loc,'sound/effects/portal_open.ogg',60,1)
	spawn(lifespan)
		qdel(src)

/obj/effect/portal/Destroy()
	if(undergoing_deletion)
		return
	undergoing_deletion = 1
	playsound(loc,'sound/effects/portal_close.ogg',60,1)

	purge_beams()

	if(target)
		if(istype(target,/obj/effect/portal) && !istype(creator,/obj/item/weapon/gun/portalgun))
			qdel(target)
		target = null
	if(creator)
		if(istype(creator,/obj/item/weapon/hand_tele))
			var/obj/item/weapon/hand_tele/H = creator
			H.portals -= src
			creator = null
		else if(istype(creator,/obj/item/weapon/gun/portalgun))
			var/obj/item/weapon/gun/portalgun/P = creator
			if(src == P.blue_portal)
				P.blue_portal = null
				P.sync_portals()
			else if(src == P.red_portal)
				P.red_portal = null
				P.sync_portals()

	var/datum/effect/effect/system/spark_spread/aeffect = new
	aeffect.set_up(5, 1, loc)
	aeffect.start()
	..()

/obj/effect/portal/cultify()
	return

/obj/effect/portal/singuloCanEat()
	return 0

/obj/effect/portal/singularity_act()
	return

/obj/effect/portal/singularity_pull()
	return

var/list/portal_cache = list()


/obj/effect/portal/proc/blend_icon(var/obj/effect/portal/P)
	var/turf/T = P.loc

	if(!("icon[initial(T.icon)]_iconstate[T.icon_state]" in portal_cache))//If the icon has not been added yet
		var/icon/I1 = icon(icon,"portal_mask")//Generate it.
		var/icon/I2 = icon(initial(T.icon),T.icon_state)
		I1.Blend(I2,ICON_MULTIPLY)
		portal_cache["icon[initial(T.icon)]_iconstate[T.icon_state]"] = I1 //And cache it!

	overlays += portal_cache["icon[initial(T.icon)]_iconstate[T.icon_state]"]

/obj/effect/portal/proc/teleport(atom/movable/M as mob|obj)
	if(istype(M, /obj/effect)) //sparks don't teleport
		return
	if (M.anchored&&istype(M, /obj/mecha))
		return
	if (!target)
		visible_message("<span class='warning'>The portal fails to find a destination and dissipates into thin air.</span>")
		qdel(src)
		return
	if (istype(M, /atom/movable))
		var/area/A = get_area(target)
		if(A && A.anti_ethereal)
			visible_message("<span class='sinister'>A dark form vaguely ressembling a hand reaches through the portal and tears it apart before anything can go through.</span>")
			qdel(src)
		else
			do_teleport(M, target, 0, 1, 1, 1, 'sound/effects/portal_enter.ogg', 'sound/effects/portal_exit.ogg')


/obj/effect/portal/beam_connect(var/obj/effect/beam/B)
	if(istype(B))
		if(B.HasSource(src))
			return // Prevent infinite loops.
		..()
	handle_beams()

/obj/effect/portal/beam_disconnect(var/obj/effect/beam/B)
	if(istype(B))
		if(B.HasSource(src))
			return // Prevent infinite loops.
		..()
	handle_beams()

/obj/effect/portal/handle_beams()
	if(target && istype(target,/obj/effect/portal))
		var/obj/effect/portal/PE = target
		PE.purge_beams()

	add_beams()

/obj/effect/portal/proc/purge_beams()
	for(var/obj/effect/beam/BE in exit_beams)
		exit_beams -= BE
		qdel(BE)

/obj/effect/portal/proc/add_beams()
	if((!beams) || (!beams.len) || !target || !istype(target,/obj/effect/portal))
		return

	var/obj/effect/portal/PE = target

	for(var/obj/effect/beam/emitter/BE in beams)
		var/list/spawners = list(src)
		spawners |= BE.sources
		var/obj/effect/beam/emitter/beam = new(PE.loc)
		beam.dir = BE.dir
		beam.power = BE.power
		beam.steps = BE.steps+1
		beam.emit(spawn_by=spawners)
		PE.exit_beams += beam
