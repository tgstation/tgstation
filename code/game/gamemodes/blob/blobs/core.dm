/obj/effect/blob/core
	name = "blob core"
	icon = 'icons/mob/blob.dmi'
	icon_state = "blob_core"
	health = 200
	brute_resist = 2
	fire_resist = 2
	var/mob/camera/blob/overmind = null // the blob core's overmind
	var/overmind_get_delay = 0 // we don't want to constantly try to find an overmind, do it every 30 seconds

	New(loc, var/h = 200)
		blobs += src
		blob_cores += src
		processing_objects.Add(src)
		if(!overmind)
			create_overmind()
		..(loc, h)


	Del()
		blob_cores -= src
		if(overmind)
			del(overmind)
		processing_objects.Remove(src)
		..()
		return


	update_icon()
		if(health <= 0)
			playsound(src.loc, 'sound/effects/splat.ogg', 50, 1)
			del(src)
			return
		return

	Life()
		if(!overmind)
			create_overmind()
		else
			overmind.add_points(1)
		for(var/i = 1; i < 8; i += i)
			Pulse(0, i)
		for(var/b_dir in alldirs)
			if(prob(50))
				continue
			var/obj/effect/blob/normal/B = locate() in get_step(src, b_dir)
			if(B)
				B.change_to(/obj/effect/blob/shield)
		..()


	run_action()
		return 0


	proc/create_overmind()

		if(overmind_get_delay > world.time)
			return

		overmind_get_delay = world.time + 300 // 30 seconds

		if(overmind)
			del(overmind)

		var/list/candidates = get_candidates(BE_ALIEN)
		if(candidates.len)
			var/mob/camera/blob/B = new(src.loc)
			var/client/C = pick(candidates)
			B.key = C.key
			B.blob_core = src
			src.overmind = B

			B << "<span class='notice'>You are the overmind!</span>"
			B << "You are the overmind and can control the blob by placing new blob pieces such as..."
			B << "<b>Normal Blob</b> will expand your reach and allow you to create barriers."
			B << "<b>Shield Blob</b> is a strong and expensive blob piece which can take more damage."
			B << "<b>Resourece Blob</b> is a blob which will collect more resources for you, try to build these earlier to get a strong income."
			B << "<b>Node Blob</b> is a blob which will grow, like the core. Unlike the core it won't give you income."
			B << "<b>Factory Blob</b> is a blob which will spawn pods which will attack nearby food."

			return 1
		return 0

