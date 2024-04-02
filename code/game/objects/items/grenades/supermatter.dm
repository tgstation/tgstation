/obj/item/grenade/supermatter
	name = "supermatter grenade"
	desc = "Pulls in everything nearby and then produces a minor explosion. It is set to detonate in 3 seconds."
	icon = 'icons/obj/weapons/grenade.dmi'
	icon_state = "supermatter"
	inhand_icon_state = "flashbang"
	det_time = 3 SECONDS
	var/supermatter_power = 7 //the overall range of the vortex.
	var/setting_type = 0

/obj/item/grenade/supermatter/process()
	supermatter_vortex()

/obj/item/grenade/supermatter/detonate()
	update_mob()
	START_PROCESSING(SSobj, src)

	var/supermatter_turf = get_turf(src)
	if(!supermatter_turf)
		return

	playsound(supermatter_turf, 'sound/effects/supermatter_start.ogg', 50, TRUE)

	sleep(5 SECONDS)
	supermatter_kaboom()
	return

/obj/item/grenade/supermatter/proc/supermatter_vortex(turf/T, setting_type, range)
	var/supermatter_turf = get_turf(src)
	if(!supermatter_turf)
		return
	for(var/mob/living/M in view(supermatter_power, supermatter_turf))
		bang(get_turf(M), M)
	playsound(supermatter_turf, 'sound/effects/supermatter_loop.ogg', 50, TRUE)
	for(var/atom/movable/X in orange(supermatter_power, supermatter_turf))
		if(iseffect(X))
			continue
		if(!X.anchored)
			var/distance = get_dist(X, supermatter_turf)
			var/moving_power = max((supermatter_power*3) - distance, 1)
			if(moving_power > 2) //if the vortex is powerful and we're close, we get thrown
				if(setting_type)
					var/atom/throw_target = get_edge_target_turf(X, get_dir(X, get_step_away(X, T)))
					X.throw_at(throw_target, moving_power, 1)
				else
					X.throw_at(supermatter_turf, moving_power, 1)
			else
				spawn(0) //so everything moves at the same time.
					if(setting_type)
						for(var/i = 0, i < moving_power, i++)
							sleep(0.2 SECONDS)
							if(!step_away(X, supermatter_turf))
								break
					else
						for(var/i = 0, i < moving_power, i++)
							sleep(0.2 SECONDS)
							if(!step_towards(X, supermatter_turf))
								break

/obj/item/grenade/supermatter/proc/bang(turf/T , mob/living/M)
	if(M.stat == DEAD)	//They're dead!
		return
	M.Stun(1 SECONDS)
	M.Knockdown(4 SECONDS)

/obj/item/grenade/supermatter/proc/supermatter_kaboom()
	var/supermatter_turf = get_turf(src)
	if(!supermatter_turf)
		return

	STOP_PROCESSING(SSobj, src)
	playsound(supermatter_turf, 'sound/effects/supermatter_end.ogg', 50, TRUE)
	explosion(src, 0, 0, 6, flame_range = 0)
	qdel(src)

