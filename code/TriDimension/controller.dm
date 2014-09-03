/obj/effect/landmark/zcontroller
	name = "Z-Level Controller"
	var/initialized = 0 // when set to 1, turfs will report to the controller
	var/up = 0	// 1 allows  up movement
	var/up_target = 0 // the Z-level that is above the current one
	var/down = 0 // 1 allows down movement
	var/down_target = 0 // the Z-level that is below the current one

	var/list/slow = list()
	var/list/normal = list()
	var/list/fast = list()

	var/slow_time
	var/normal_time
	var/fast_time

/obj/effect/landmark/zcontroller/New()
	..()
	for (var/turf/T in world)
		if (T.z == z)
			fast += T
	slow_time = world.time + 3000
	normal_time = world.time + 600
	fast_time = world.time + 10

	processing_objects.Add(src)

	initialized = 1
	return 1

/obj/effect/landmark/zcontroller/Del()
	processing_objects.Remove(src)
	return

/obj/effect/landmark/zcontroller/process()
	if (world.time > fast_time)
		calc(fast)
		fast_time = world.time + 10

	if (world.time > normal_time)
		calc(normal)
		normal_time = world.time + 600

/*	if (world.time > slow_time)
		calc(slow)
		slow_time = world.time + 3000 */
	return

/obj/effect/landmark/zcontroller/proc/add(var/list/L, var/I, var/transfer)
	while (L.len)
		var/turf/T = pick(L)

		L -= T
		slow -= T
		normal -= T
		fast -= T

		if(!T || !istype(T, /turf))
			continue

		switch (I)
			if(1)	slow += T
			if(2)	normal += T
			if(3)	fast += T

		if(transfer > 0)
			if(up)
				var/turf/controller_up = locate(1, 1, up_target)
				for(var/obj/effect/landmark/zcontroller/c_up in controller_up)
					var/list/temp = list()
					temp += locate(T.x, T.y, up_target)
					c_up.add(temp, I, transfer-1)

			if(down)
				var/turf/controller_down = locate(1, 1, down_target)
				for(var/obj/effect/landmark/zcontroller/c_down in controller_down)
					var/list/temp = list()
					temp += locate(T.x, T.y, down_target)
					c_down.add(temp, I, transfer-1)
	return

/turf
	var/list/z_overlays = list()

/turf/New()
	..()

	var/turf/controller = locate(1, 1, z)
	for(var/obj/effect/landmark/zcontroller/c in controller)
		if(c.initialized)
			var/list/turf = list()
			turf += src
			c.add(turf,3,1)

/turf/space/New()
	..()

	var/turf/controller = locate(1, 1, z)
	for(var/obj/effect/landmark/zcontroller/c in controller)
		if(c.initialized)
			var/list/turf = list()
			turf += src
			c.add(turf,3,1)

atom/movable/Move() //Hackish
	. = ..()

	var/turf/controllerlocation = locate(1, 1, src.z)
	for(var/obj/effect/landmark/zcontroller/controller in controllerlocation)
		if(controller.up || controller.down)
			var/list/temp = list()
			temp += locate(src.x, src.y, src.z)
			controller.add(temp,3,1)

/obj/effect/landmark/zcontroller/proc/calc(var/list/L)
	var/list/slowholder = list()
	var/list/normalholder = list()
	var/list/fastholder = list()
	var/new_list

	while(L.len)
		var/turf/T = pick(L)
		new_list = 0

		if(!T || !istype(T, /turf))
			L -= T
			continue

		T.overlays -= T.z_overlays
		T.z_overlays -= T.z_overlays

		if(down && (istype(T, /turf/space) || istype(T, /turf/simulated/floor/open)))
			var/turf/below = locate(T.x, T.y, down_target)
			if(below)
				if(!(istype(below, /turf/space) || istype(below, /turf/simulated/floor/open)))
					var/image/t_img = list()
					new_list = 1

					var/image/temp = image(below, dir=below.dir, layer = TURF_LAYER + 0.04)

					temp.color = rgb(127,127,127)
					temp.overlays += below.overlays
					t_img += temp
					T.overlays += t_img
					T.z_overlays += t_img

				// get objects
				var/image/o_img = list()
				for(var/obj/o in below)
					// ingore objects that have any form of invisibility
					if(o.invisibility) continue
					new_list = 2
					var/image/temp2 = image(o, dir=o.dir, layer = TURF_LAYER+0.05*o.layer)
					temp2.color = rgb(127,127,127)
					temp2.overlays += o.overlays
					o_img += temp2
					// you need to add a list to .overlays or it will not display any because space
				T.overlays += o_img
				T.z_overlays += o_img

				// get mobs
				var/image/m_img = list()
				for(var/mob/m in below)
					// ingore mobs that have any form of invisibility
					if(m.invisibility) continue
					// only add this tile to fastprocessing if there is a living mob, not a dead one
					if(istype(m, /mob/living)) new_list = 3
					var/image/temp2 = image(m, dir=m.dir, layer = TURF_LAYER+0.05*m.layer)
					temp2.color = rgb(127,127,127)
					temp2.overlays += m.overlays
					m_img += temp2
					// you need to add a list to .overlays or it will not display any because space
				T.overlays += m_img
				T.z_overlays += m_img

				T.overlays -= below.z_overlays
				T.z_overlays -= below.z_overlays

		// this is sadly impossible to use right now
		// the overlay is always opaque to mouseclicks and thus prevents interactions with everything except the turf
		/*if(up)
			var/turf/above = locate(T.x, T.y, up_target)
			if(above)
				var/eligeable = 0
				for(var/d in cardinal)
					var/turf/mT = get_step(above,d)
					if(istype(mT, /turf/space) || istype(mT, /turf/simulated/floor/open))
						eligeable = 1
					/*if(mT.opacity == 0)
						for(var/f in cardinal)
							var/turf/nT = get_step(mT,f)
							if(istype(nT, /turf/space) || istype(nT, /turf/simulated/floor/open))
								eligeable = 1*/
				if(istype(above, /turf/space) || istype(above, /turf/simulated/floor/open)) eligeable = 1
				if(eligeable == 1)
					if(!(istype(above, /turf/space) || istype(above, /turf/simulated/floor/open)))
						var/image/t_img = list()
						if(new_list < 1) new_list = 1

						above.overlays -= above.z_overlays
						var/image/temp = image(above, dir=above.dir, layer = 5 + 0.04)
						above.overlays += above.z_overlays

						temp.alpha = 100
						temp.overlays += above.overlays
						temp.overlays -= above.z_overlays
						t_img += temp
						T.overlays += t_img
						T.z_overlays += t_img

					// get objects
					var/image/o_img = list()
					for(var/obj/o in above)
						// ingore objects that have any form of invisibility
						if(o.invisibility) continue
						if(new_list < 2) new_list = 2
						var/image/temp2 = image(o, dir=o.dir, layer = 5+0.05*o.layer)
						temp2.alpha = 100
						temp2.overlays += o.overlays
						o_img += temp2
						// you need to add a list to .overlays or it will not display any because space
					T.overlays += o_img
					T.z_overlays += o_img

					// get mobs
					var/image/m_img = list()
					for(var/mob/m in above)
						// ingore mobs that have any form of invisibility
						if(m.invisibility) continue
						// only add this tile to fastprocessing if there is a living mob, not a dead one
						if(istype(m, /mob/living) && new_list < 3) new_list = 3
						var/image/temp2 = image(m, dir=m.dir, layer = 5+0.05*m.layer)
						temp2.alpha = 100
						temp2.overlays += m.overlays
						m_img += temp2
						// you need to add a list to .overlays or it will not display any because space
					T.overlays += m_img
					T.z_overlays += m_img

					T.overlays -= above.z_overlays
					T.z_overlays -= above.z_overlays*/

		L -= T

		if(new_list == 1)
			slowholder += T
		if(new_list == 2)
			normalholder += T
		if(new_list == 3)
			fastholder += T
			for(var/d in cardinal)
				var/turf/mT = get_step(T,d)
				if(!(mT in fastholder))
					fastholder += mT
				for(var/f in cardinal)
					var/turf/nT = get_step(mT,f)
					if(!(nT in fastholder))
						fastholder += nT

	add(slowholder,1, 0)
	add(normalholder, 2, 0)
	add(fastholder, 3, 0)
	return
