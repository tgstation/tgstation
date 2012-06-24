/obj/effect/blob/core
	name = "blob core"
	icon = 'blob.dmi'
	icon_state = "blob_core"
	health = 200
	brute_resist = 2
	fire_resist = 2


	New(loc, var/h = 200)
		blobs += src
		blob_cores += src
		processing_objects.Add(src)
		..(loc, h)


	Del()
		blob_cores -= src
		processing_objects.Remove(src)
		..()
		return


	update_icon()
		if(health <= 0)
			playsound(src.loc, 'splat.ogg', 50, 1)
			del(src)
			return
		return


	run_action()
		Pulse(0,1)
		Pulse(0,2)
		Pulse(0,4)
		Pulse(0,8)
		//Should have the fragments in here somewhere
		return 1


	proc/create_fragments(var/wave_size = 1)
		var/list/candidates = list()
		for(var/mob/dead/observer/G in world)
			if(G.client && G.client.be_alien)
				if(G.corpse)
					if(G.corpse.stat==2)
						candidates.Add(G)
				else
					candidates.Add(G)

		for(var/i = 0 to wave_size)
			if(!candidates.len)	break
			var/mob/dead/observer/G = pick(candidates)
			var/mob/living/blob/B = new/mob/living/blob(src.loc)
			if(G.client)
				G.client.screen.len = null
				B.ghost_name = G.real_name
				G.client.mob = B
				del(G)






