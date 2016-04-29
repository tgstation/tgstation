/obj/effect/blob/node
	name = "blob node"
	icon_state = "node"
	desc = "Some pulsating blob creature thingy"
	health = 100
	maxhealth = 100
	fire_resist = 2
	custom_process=1
	layer = 6.8
	spawning = 0

	layer_new = 6.8
	icon_new = "node"
	icon_classic = "blob_node"

/obj/effect/blob/node/New(loc,newlook = "new")
	blob_nodes += src
	processing_objects.Add(src)
	..(loc, newlook)

	if(blob_looks[looks] == 64)
		flick("morph_node",src)

/obj/effect/blob/node/fire_act(datum/gas_mixture/air, exposed_temperature, exposed_volume)
	return

/obj/effect/blob/node/Destroy()
	blob_nodes -= src
	if(!manual_remove && overmind)
		to_chat(overmind,"<span class='warning'>A node blob that you had created has been destroyed.</span>")
	processing_objects.Remove(src)
	..()

/obj/effect/blob/node/Life()
	if(timestopped) return 0 //under effects of time magick

	if(blob_looks[looks] == 64)
		anim(target = loc, a_icon = icon, flick_anim = "nodepulse", sleeptime = 15, lay = 12, offX = -16, offY = -16, alph = 150)
		for(var/mob/M in viewers(src))
			M.playsound_local(loc, 'sound/effects/blob_pulse.ogg', 50, 0, null, FALLOFF_SOUNDS, 0)

	for(var/i = 1; i < 8; i += i)
		Pulse(5, i)

	if(health < maxhealth)
		health = min(maxhealth, health + 1)
		update_icon()

/obj/effect/blob/node/update_health()
	if(health <= 0)
		dying = 1
		playsound(get_turf(src), 'sound/effects/blobsplatspecial.ogg', 50, 1)
		Delete()
		return
	return

/obj/effect/blob/node/run_action()
	return 0

/obj/effect/blob/node/update_icon(var/spawnend = 0)
	if(blob_looks[looks] == 64)
		spawn(1)
			overlays.len = 0

			overlays += image(icon,"roots", layer = 3)

			if(!spawning)
				for(var/obj/effect/blob/B in orange(src,1))
					overlays += image(icon,"nodeconnect",dir = get_dir(src,B), layer = layer+0.1)
			if(spawnend)
				spawn(10)
					update_icon()


			..()

