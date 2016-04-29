/obj/effect/blob/core
	name = "blob core"
	icon_state = "core"
	desc = "Some big pulsating blob creature thingy"
	health = 200
	maxhealth = 200
	fire_resist = 2
	custom_process=1
	var/overmind_get_delay = 0 // we don't want to constantly try to find an overmind, do it every 30 seconds
	var/resource_delay = 0
	var/point_rate = 2
	var/mob/camera/blob/creator = null
	layer = 7
	var/core_warning_delay = 0
	var/previous_health = 200

	layer_new = 7
	icon_new = "core"
	icon_classic = "blob_core"


/obj/effect/blob/core/New(loc, var/h = 200, var/client/new_overmind = null, var/new_rate = 2, var/mob/camera/blob/C = null,newlook = "new")
	looks = newlook
	blob_cores += src
	processing_objects.Add(src)
	creator = C
	if(blob_looks[looks] == 64)
		if(new_overmind)
			flick("core_spawn",src)
		else
			flick("morph_core",src)
	playsound(src, get_sfx("gib"),50,1)
	if(!overmind)
		create_overmind(new_overmind)
	point_rate = new_rate
	..(loc, newlook)

/obj/effect/blob/core/Destroy()
	blob_cores -= src

	for(var/mob/camera/blob/O in blob_overminds)
		if(overmind && (O != overmind))
			to_chat(O,"<span class='danger'>A blob core has been destroyed! [overmind] lost his life!</span>")
		else
			to_chat(O,"<span class='warning'>A blob core has been destroyed. It had no overmind in control.</span>")

	if(overmind)
		for(var/obj/effect/blob/resource/R in blob_resources)
			if(R.overmind == overmind)
				R.overmind = null
				R.update_icon()
		qdel(overmind)
		overmind = null
	processing_objects.Remove(src)
	..()

/obj/effect/blob/core/fire_act(datum/gas_mixture/air, exposed_temperature, exposed_volume)
	return

/obj/effect/blob/core/update_health()
	if(overmind)
		overmind.update_health()
		if((health < previous_health) && (core_warning_delay <= world.time))
			resource_delay = world.time + (3 SECONDS)
			to_chat(overmind,"<span class='danger'>YOUR CORE IS UNDER ATTACK!</span>")

	previous_health = health

	if(health <= 0)
		dying = 1
		playsound(get_turf(src), 'sound/effects/blobkill.ogg', 50, 1)
		Delete()
		return
	return

/obj/effect/blob/core/Life()
	if(timestopped) return 0 //under effects of time magick

	if(!overmind)
		create_overmind()
	else
		if(resource_delay <= world.time)
			resource_delay = world.time + 10 // 1 second
			overmind.add_points(point_rate)

	if(health < maxhealth)
		health = min(maxhealth, health + 1)
		update_icon()

	if(!spawning)//no expanding on the first Life() tick

		if(blob_looks[looks] == 64)
			anim(target = loc, a_icon = icon, flick_anim = "corepulse", sleeptime = 15, lay = 12, offX = -16, offY = -16, alph = 200)
			for(var/mob/M in viewers(src))
				M.playsound_local(loc, 'sound/effects/blob_pulse.ogg', 50, 0, null, FALLOFF_SOUNDS, 0)

		var/turf/T = get_turf(overmind) //The overmind's mind can expand the blob
		var/obj/effect/blob/O = locate() in T //As long as it is 'thinking' about a blob already
		for(var/i = 1; i < 8; i += i)
			Pulse(0, i)
			if(istype(O))
				O.Pulse(0,i)
		for(var/b_dir in alldirs)
			if(!prob(5))
				continue
			var/obj/effect/blob/normal/B = locate() in get_step(src, b_dir)
			if(B)
				B.change_to(/obj/effect/blob/shield)
	else
		spawning = 0
	..()


/obj/effect/blob/core/run_action()
	return 0


/obj/effect/blob/core/proc/create_overmind(var/client/new_overmind)
	if(overmind_get_delay > world.time)
		return

	overmind_get_delay = world.time + 300 // 30 seconds

	if(overmind)
		qdel(overmind)
		overmind = null

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
		if(!B.blob_core.creator)//If this core is the first of its lineage (created by game mode/event/admins, instead of another overmind) it gets to choose its looks.
			B.verbs += /mob/camera/blob/proc/create_core
			spawn()
				var/chosen = input(B,"Select a blob looks", "Blob Looks", blob_looks[1]) as null|anything in blob_looks
				if(chosen)
					for(var/obj/effect/blob/nearby_blob in range(src,5))
						nearby_blob.looks = chosen
						nearby_blob.update_looks(1)

		if(istype(ticker.mode, /datum/game_mode/blob))
			var/datum/game_mode/blob/mode = ticker.mode
			mode.infected_crew += B.mind
		return 1
	return 0

/obj/effect/blob/core/update_icon(var/spawnend = 0)
	if(blob_looks[looks] == 64)
		spawn(1)
			overlays.len = 0

			overlays += image(icon,"roots", layer = 3)

			if(!spawning)
				for(var/obj/effect/blob/B in orange(src,1))
					overlays += image(icon,"coreconnect",dir = get_dir(src,B), layer = layer+0.1)
			if(spawnend)
				spawn(10)
					update_icon()

			..()
