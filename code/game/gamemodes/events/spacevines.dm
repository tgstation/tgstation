//Carn: Spacevines random event.
/proc/spacevine_infestation(var/potency_min=70, var/potency_max=100, var/maturation_min=2, var/maturation_max=6)
	spawn() //to stop the secrets panel hanging
		var/list/turf/simulated/floor/turfs = list() //list of all the empty floor turfs in the hallway areas
		for(var/areapath in typesof(/area/hallway))
			var/area/A = locate(areapath)
			for(var/turf/simulated/floor/F in A.contents)
				if(!is_blocked_turf(F))
					turfs += F

		if(turfs.len) //Pick a turf to spawn at if we can
			var/turf/simulated/floor/T = pick(turfs)
			var/datum/seed/seed = plant_controller.create_random_seed(1)
			seed.spread = 2 // So it will function properly as vines.
			seed.potency = rand(potency_min, potency_max) // 70-100 potency will help guarantee a wide spread and powerful effects.
			seed.maturation = rand(maturation_min, maturation_max)

			var/obj/effect/plantsegment/vine = new(T,seed,start_fully_mature = 1)
			vine.process()

			message_admins("<span class='notice'>Event: Spacevines spawned at [T.loc] <A HREF='?_src_=holder;adminplayerobservecoodjump=1;X=[T.x];Y=[T.y];Z=[T.z]'>(JMP)</a></span>")
			return
		message_admins("<span class='notice'>Event: Spacevines failed to find a viable turf.</span>")