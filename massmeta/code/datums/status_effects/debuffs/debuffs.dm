/datum/status_effect/progenitor_curse
	duration = 200
	tick_interval = 5

/datum/status_effect/progenitor_curse/tick()
	if(owner.stat == DEAD)
		return
	var/grab_dir = turn(owner.dir, rand(-180, 180)) //grab them from a random direction
	var/turf/spawn_turf = get_ranged_target_turf(owner, grab_dir, 5)
	if(spawn_turf)
		grasp(spawn_turf)

/datum/status_effect/progenitor_curse/proc/grasp(turf/spawn_turf)
	set waitfor = FALSE
	new/obj/effect/temp_visual/dir_setting/curse/grasp_portal(spawn_turf, owner.dir)
	playsound(spawn_turf, 'sound/effects/curse2.ogg', 80, 1, -1)
	var/obj/projectile/curse_hand/progenitor/C = new (spawn_turf)
	C.preparePixelProjectile(owner, spawn_turf)
	C.fire()
