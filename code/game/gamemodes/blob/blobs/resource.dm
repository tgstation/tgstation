/obj/effect/blob/resource
	name = "resource blob"
	icon_state = "resource"
	desc = "Some smoke-producing blob creature thingy"
	health = 30
	maxhealth = 30
	fire_resist = 2
	var/resource_delay = 0
	spawning = 0
	layer = 6.4

	layer_new = 6.4
	icon_new = "resource"
	icon_classic = "blob_resource"

/obj/effect/blob/resource/New(loc,newlook = "new")
	..()
	blob_resources += src

	if(blob_looks[looks] == 64)
		flick("morph_resource",src)

/obj/effect/blob/resource/Destroy()
	blob_resources -= src
	if(!manual_remove && overmind)
		to_chat(overmind,"<span class='warning'>You lost a resource blob.</span>")
	..()

/obj/effect/blob/resource/update_health()
	if(health <= 0)
		dying = 1
		playsound(get_turf(src), 'sound/effects/blobsplatspecial.ogg', 50, 1)
		qdel(src)
		return
	return

/obj/effect/blob/resource/Pulse(var/pulse = 0, var/origin_dir = 0)
	if(!overmind)
		var/mob/camera/blob/B = (locate() in range(src,1))
		if(B)
			to_chat(B,"<span class='notice'>You take control of the resource blob.</span>")
			overmind = B
			update_icon()
	..()

/obj/effect/blob/resource/run_action()
	if(resource_delay > world.time)
		return 0

	resource_delay = world.time + (4 SECONDS)

	if(overmind)
		if(blob_looks[looks] == 64)
			anim(target = loc, a_icon = icon, flick_anim = "resourcepulse", sleeptime = 15, lay = 7.2, offX = -16, offY = -16, alph = 220)
		overmind.add_points(1)

	return 1

/obj/effect/blob/resource/update_icon(var/spawnend = 0)
	spawn(1)
		if(overmind)
			color = null
		else
			color = "#888888"

	if(blob_looks[looks] == 64)
		spawn(1)
			overlays.len = 0
			overlays += image(icon,"roots", layer = 3)

			if(!spawning)
				for(var/obj/effect/blob/B in orange(src,1))
					overlays += image(icon,"resourceconnect",dir = get_dir(src,B), layer = layer+0.1)
			if(spawnend)
				spawn(10)
					update_icon()

			..()
