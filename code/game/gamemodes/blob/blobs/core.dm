/obj/effect/blob/core
	name = "blob core"
	icon = 'icons/mob/blob.dmi'
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
		for(var/mob/dead/observer/G in player_list)
			if(G.client.be_alien)
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

/*
	Pulse(var/pulse = 0, var/origin_dir = 0)//Todo: Fix spaceblob expand
		set background = 1
		if(pulse > 20)	return
		//Looking for another blob to pulse
		var/list/dirs = list(1,2,4,8)
		dirs.Remove(origin_dir)//Dont pulse the guy who pulsed us
		for(var/i = 1 to 4)
			if(!dirs.len)	break
			var/dirn = pick(dirs)
			dirs.Remove(dirn)
			var/turf/T = get_step(src, dirn)
			var/obj/effect/blob/B = (locate(/obj/effect/blob) in T)
			if(!B)
				expand(T)//No blob here so try and expand
				return
			B.Pulse((pulse+1),get_dir(src.loc,T))
			return
		return
*/