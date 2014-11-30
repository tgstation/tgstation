/obj/effect/blob/core
	name = "blob core"
	icon = 'icons/mob/blob.dmi'
	icon_state = "blob_core"
	health = 200
	fire_resist = 2
	var/mob/camera/blob/overmind = null // the blob core's overmind
	var/overmind_get_delay = 0 // we don't want to constantly try to find an overmind, do it every 30 seconds
	var/resource_delay = 0
	var/point_rate = 2
	var/mob/camera/blob/creator = null

	New(loc, var/h = 200, var/client/new_overmind = null, var/new_rate = 2, var/mob/camera/blob/C = null)
		blob_cores += src
		processing_objects.Add(src)
		creator = C
		if(!overmind)
			create_overmind(new_overmind)
		point_rate = new_rate
		..(loc, h)


	Destroy()
		blob_cores -= src
		if(overmind)
			del(overmind)
		processing_objects.Remove(src)
		..()

	fire_act(datum/gas_mixture/air, exposed_temperature, exposed_volume)
		return

	update_icon()
		if(health <= 0)
			playsound(get_turf(src), 'sound/effects/blobkill.ogg', 50, 1)
			Delete()
			return
		return

	Life()
		if(!overmind)
			create_overmind()
		else
			if(resource_delay <= world.time)
				resource_delay = world.time + 10 // 1 second
				overmind.add_points(point_rate)
		health = min(initial(health), health + 1)
		for(var/i = 1; i < 8; i += i)
			Pulse(0, i)
		for(var/b_dir in alldirs)
			if(!prob(5))
				continue
			var/obj/effect/blob/normal/B = locate() in get_step(src, b_dir)
			if(B)
				B.change_to(/obj/effect/blob/shield)
		..()


	run_action()
		return 0


	proc/create_overmind(var/client/new_overmind)

		if(overmind_get_delay > world.time)
			return

		overmind_get_delay = world.time + 300 // 30 seconds

		if(overmind)
			del(overmind)

		var/client/C = null
		var/list/candidates = list()

		if(!new_overmind)
			candidates = get_candidates(ROLE_BLOB)
			if(candidates.len)
				C = pick(candidates)
		else
			C = new_overmind

		if(C)
			var/mob/camera/blob/B = new(src.loc)
			B.key = C.key
			B.blob_core = src
			src.overmind = B
			if(!B.blob_core.creator)
				B.verbs += /mob/camera/blob/proc/create_core
			if(istype(ticker.mode, /datum/game_mode/blob))
				var/datum/game_mode/blob/mode = ticker.mode
				mode.infected_crew += B.mind
			return 1
		return 0

