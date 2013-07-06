/obj/effect/blob/node
	name = "blob node"
	icon = 'icons/mob/blob.dmi'
	icon_state = "blob_node"
	health = 100
	brute_resist = 1
	fire_resist = 2


	New(loc, var/h = 100)
		blob_nodes += src
		processing_objects.Add(src)
		..(loc, h)


	Del()
		blob_nodes -= src
		processing_objects.Remove(src)
		..()
		return

	Life()
		for(var/i = 1; i < 8; i += i)
			Pulse(10, i)

	update_icon()
		if(health <= 0)
			playsound(src.loc, 'sound/effects/splat.ogg', 50, 1)
			del(src)
			return
		return


	run_action()
		return 0