/obj/item/grenade/concussive
	name = "concussion grenade"
	desc = "Violently sends everything around from it at extreme speeds and stunning everyone caught in the blast for an extended period. It is set to detonate in 3 seconds."
	icon = 'icons/obj/weapons/grenade.dmi'
	icon_state = "concussive"
	inhand_icon_state = "flashbang"
	det_time = 3 SECONDS
	var/concussion_power = 7 //the overall range of the vortex.
	var/setting_type = 0
	var/concussion_force = MOVE_FORCE_EXTREMELY_STRONG

/obj/item/grenade/concussive/process()
	concussion_vortex()

/obj/item/grenade/concussive/detonate()
	update_mob()
	START_PROCESSING(SSobj, src)

	var/concussion_turf = get_turf(src)
	if(!concussion_turf)
		return

	playsound(concussion_turf, 'sound/weapons/conc_grenade.ogg', 50, TRUE)

	return

/obj/item/grenade/concussive/proc/concussion_vortex(turf/T, setting_type, range)
	var/concussion_turf = get_turf(src)
	if(!concussion_turf)
		return
	for(var/mob/living/M in view(concussion_power, concussion_turf))
		bang(get_turf(M), M)
	var/list/thrown_items = list()
	for(var/atom/movable/A in range(concussion_turf, concussion_power))
		if(A.anchored || thrown_items[A])
			continue
		var/throwtarget = get_edge_target_turf(concussion_turf, get_dir(concussion_turf, get_step_away(A, concussion_turf)))
		A.safe_throw_at(throwtarget, 10, 1, force = concussion_force)
		thrown_items[A] = A
	STOP_PROCESSING(SSobj, src)
	qdel(src)

/obj/item/grenade/concussive/proc/bang(turf/T , mob/living/M)
	if(M.stat == DEAD)	//They're dead!
		return
	M.Stun(8 SECONDS)
	M.Knockdown(20 SECONDS)
