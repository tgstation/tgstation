//NEEDS MAJOR CODE CLEANUP.

//This one just pops one projectile in direction user is facing, irrelevant of max_targets etc
/obj/effect/proc_holder/spell/targeted/projectile/dumbfire
	name = "Dumbfire projectile"

/obj/effect/proc_holder/spell/targeted/projectile/dumbfire/choose_targets(mob/user = usr)
	var/turf/T = get_turf(user)
	for(var/i in 1 to range-1)
		var/turf/new_turf = get_step(T, user.dir)
		if(new_turf.density)
			break
		T = new_turf
	perform(list(T),user = user)
