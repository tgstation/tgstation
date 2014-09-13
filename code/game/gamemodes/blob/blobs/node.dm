/obj/effect/blob/node
	name = "blob node"
	icon = 'icons/mob/blob.dmi'
	icon_state = "blob_node"
	health = 100
	fire_resist = 2


	New(loc, var/h = 100)
		blob_nodes += src
		processing_objects.Add(src)
		..(loc, h)

	fire_act(datum/gas_mixture/air, exposed_temperature, exposed_volume)
		return

	Destroy()
		blob_nodes -= src
		processing_objects.Remove(src)
		..()

	Life()
		for(var/i = 1; i < 8; i += i)
			Pulse(5, i)
		health = min(initial(health), health + 1)

	update_icon()
		if(health <= 0)
			playsound(get_turf(src), 'sound/effects/blobsplatspecial.ogg', 50, 1)
			Delete()
			return
		return


	run_action()
		return 0