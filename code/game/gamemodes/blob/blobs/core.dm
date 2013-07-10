/obj/effect/blob/core
	name = "blob core"
	icon = 'icons/mob/blob.dmi'
	icon_state = "blob_core"
	health = 200
	brute_resist = 2
	fire_resist = 2
	var/mob/camera/blob/overmind = null // the blob core's overmind
	var/overmind_get_delay = 0 // we don't want to constantly try to find an overmind, do it every 30 seconds
	var/resource_delay = 0

	New(loc, var/h = 200, var/client/new_overmind = null)
		blob_cores += src
		processing_objects.Add(src)
		if(!overmind)
			create_overmind(new_overmind)
		..(loc, h)


	Del()
		blob_cores -= src
		if(overmind)
			del(overmind)
		processing_objects.Remove(src)
		..()
		return

	fire_act(datum/gas_mixture/air, exposed_temperature, exposed_volume)
		return

	update_icon()
		if(health <= 0)
			playsound(src.loc, 'sound/effects/splat.ogg', 50, 1)
			Delete()
			return
		return

	Life()
		if(!overmind)
			create_overmind()
		else
			if(resource_delay <= world.time)
				resource_delay = world.time + 10 // 1 second
				overmind.add_points(2)
		health = min(initial(health), health + 1)
		for(var/i = 1; i < 8; i += i)
			Pulse(0, i)
		for(var/b_dir in alldirs)
			if(!prob(10))
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
			candidates = get_candidates(BE_ALIEN)
			if(candidates.len)
				C = pick(candidates)
		else
			C = new_overmind

		if(C)
			var/mob/camera/blob/B = new(src.loc)
			B.key = C.key
			B.blob_core = src
			src.overmind = B

			B << "<span class='notice'>You are the overmind!</span>"
			B << "You are the overmind and can control the blob by placing new blob pieces such as..."
			B << "<b>Normal Blob</b> will expand your reach and allow you to upgrade into special blobs that perform certain functions."
			B << "<b>Shield Blob</b> is a strong and expensive blob which can take more damage. It is fireproof and can block air, use this to protect yourself from station fires."
			B << "<b>Resource Blob</b> is a blob which will collect more resources for you, try to build these earlier to get a strong income. It will benefit from being near your core or multiple nodes, by having an increased resource rate; put it alone and it won't create resources at all."
			B << "<b>Node Blob</b> is a blob which will grow, like the core. Unlike the core it won't give you a small income but it can power resource and factory blobs to increase their rate."
			B << "<b>Factory Blob</b> is a blob which will spawn blob spores which will attack nearby food. Putting this nearby nodes and your core will increase the spawn rate; put it alone and it will not spawn any spores."

			return 1
		return 0

