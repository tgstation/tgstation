/obj/item/grenade/whitehole
	name = "whitehole grenade"
	desc = "Violently sends everything around from it at extreme speeds before exploding violently. It is set to detonate in 3 seconds."
	icon = 'icons/obj/weapons/grenade.dmi'
	icon_state = "whitehole"
	inhand_icon_state = "flashbang"
	det_time = 3 SECONDS
	var/whitehole_power = 7 //the overall range of the vortex.
	var/setting_type = 0
	var/whitehole_force = MOVE_FORCE_EXTREMELY_STRONG

/obj/item/grenade/whitehole/process()
	whitehole_vortex()

/obj/item/grenade/whitehole/detonate()
	update_mob()
	START_PROCESSING(SSobj, src)

	var/whitehole_turf = get_turf(src)
	if(!whitehole_turf)
		return

	playsound(whitehole_turf, 'sound/effects/whitehole_start.ogg', 50, TRUE)

	sleep(5 SECONDS)
	whitehole_kaboom()
	return

/obj/item/grenade/whitehole/proc/whitehole_vortex(turf/T, setting_type, range)
	var/whitehole_turf = get_turf(src)
	if(!whitehole_turf)
		return
	for(var/mob/living/M in view(whitehole_power, whitehole_turf))
		bang(get_turf(M), M)
	playsound(whitehole_turf, 'sound/effects/whitehole_loop.ogg', 50, TRUE)
	var/list/thrown_items = list()
	for(var/atom/movable/A in range(whitehole_turf, whitehole_power))
		if(A.anchored || thrown_items[A])
			continue
		var/throwtarget = get_edge_target_turf(whitehole_turf, get_dir(whitehole_turf, get_step_away(A, whitehole_turf)))
		A.safe_throw_at(throwtarget, 10, 1, force = whitehole_force)
		thrown_items[A] = A

/obj/item/grenade/whitehole/proc/bang(turf/T , mob/living/M)
	if(M.stat == DEAD)	//They're dead!
		return
	M.Stun(3 SECONDS)
	M.Knockdown(10 SECONDS)

/obj/item/grenade/whitehole/proc/whitehole_kaboom()
	var/whitehole_turf = get_turf(src)
	if(!whitehole_turf)
		return

	STOP_PROCESSING(SSobj, src)
	//playsound(supermatter_turf, 'sound/effects/supermatter_end.ogg', 50, TRUE)
	explosion(src, 0, 4, 6, flame_range = 0)
	qdel(src)