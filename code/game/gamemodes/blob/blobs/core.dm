/obj/effect/blob/core
	name = "blob core"
<<<<<<< HEAD
	icon = 'icons/mob/blob.dmi'
	icon_state = "blank_blob"
	desc = "A huge, pulsating yellow mass."
	health = 400
	maxhealth = 400
	explosion_block = 6
	point_return = -1
	atmosblock = 1
	health_regen = 0 //we regen in Life() instead of when pulsed
	var/core_regen = 2
	var/overmind_get_delay = 0 //we don't want to constantly try to find an overmind, this var tracks when we'll try to get an overmind again
	var/resource_delay = 0
	var/point_rate = 2


/obj/effect/blob/core/New(loc, client/new_overmind = null, new_rate = 2, placed = 0)
	blob_cores += src
	START_PROCESSING(SSobj, src)
	poi_list |= src
	update_icon() //so it atleast appears
	if(!placed && !overmind)
		create_overmind(new_overmind)
	if(overmind)
		update_icon()
	point_rate = new_rate
	..()

/obj/effect/blob/core/scannerreport()
	return "Directs the blob's expansion, gradually expands, and sustains nearby blob spores and blobbernauts."

/obj/effect/blob/core/update_icon()
	cut_overlays()
	color = null
	var/image/I = new('icons/mob/blob.dmi', "blob")
	if(overmind)
		I.color = overmind.blob_reagent_datum.color
	add_overlay(I)
	var/image/C = new('icons/mob/blob.dmi', "blob_core_overlay")
	add_overlay(C)

/obj/effect/blob/core/Destroy()
	blob_cores -= src
	if(overmind)
		overmind.blob_core = null
	overmind = null
	STOP_PROCESSING(SSobj, src)
	poi_list -= src
	return ..()
=======
	icon_state = "core"
	desc = "Some big pulsating blob creature thingy"
	health = 200
	maxhealth = 200
	fire_resist = 2
	custom_process=1
	var/overmind_get_delay = 0 // we don't want to constantly try to find an overmind, do it every 30 seconds
	var/resource_delay = 0
	var/last_resource_collection
	var/point_rate = 2
	var/mob/camera/blob/creator = null
	layer = 7
	var/core_warning_delay = 0
	var/previous_health = 200

	layer_new = 7
	icon_new = "core"
	icon_classic = "blob_core"


/obj/effect/blob/core/New(loc, var/h = 200, var/client/new_overmind = null, var/new_rate = 2, var/mob/camera/blob/C = null,newlook = "new",no_morph = 0)
	looks = newlook
	blob_cores += src
	processing_objects.Add(src)
	creator = C
	if((blob_looks[looks] == 64) && !no_morph)
		if(new_overmind)
			flick("core_spawn",src)
		else
			flick("morph_core",src)
	playsound(src, get_sfx("gib"),50,1)
	if(!overmind)
		create_overmind(new_overmind)
	point_rate = new_rate
	last_resource_collection = world.time
	..(loc, newlook)

/obj/effect/blob/core/Destroy()
	blob_cores -= src

	for(var/mob/camera/blob/O in blob_overminds)
		if(overmind && (O != overmind))
			to_chat(O,"<span class='danger'>A blob core has been destroyed! [overmind] lost his life!</span> <b><a href='?src=\ref[O];blobjump=\ref[loc]'>(JUMP)</a></b>")
		else
			to_chat(O,"<span class='warning'>A blob core has been destroyed. It had no overmind in control.</span> <b><a href='?src=\ref[O];blobjump=\ref[loc]'>(JUMP)</a></b>")

	if(overmind)
		for(var/obj/effect/blob/resource/R in blob_resources)
			if(R.overmind == overmind)
				R.overmind = null
				R.update_icon()
		qdel(overmind)
		overmind = null
	processing_objects.Remove(src)
	..()
>>>>>>> ccb55b121a3fd5338fc56a602424016009566488

/obj/effect/blob/core/fire_act(datum/gas_mixture/air, exposed_temperature, exposed_volume)
	return

<<<<<<< HEAD
/obj/effect/blob/core/ex_act(severity, target)
	var/damage = 50 - 10 * severity //remember, the core takes half brute damage, so this is 20/15/10 damage based on severity
	take_damage(damage, BRUTE)

/obj/effect/blob/core/check_health()
	..()
	if(overmind) //we should have an overmind, but...
		overmind.update_health_hud()

/obj/effect/blob/core/Life()
	if(!overmind)
		create_overmind()
	else
		if(resource_delay <= world.time)
			resource_delay = world.time + 10 // 1 second
			overmind.add_points(point_rate)
	health = min(maxhealth, health+core_regen)
	if(overmind)
		overmind.update_health_hud()
	Pulse_Area(overmind, 12, 4, 3)
	for(var/obj/effect/blob/normal/B in range(1, src))
		if(prob(5))
			B.change_to(/obj/effect/blob/shield/core, overmind)
	..()


/obj/effect/blob/core/proc/create_overmind(client/new_overmind, override_delay)
	if(overmind_get_delay > world.time && !override_delay)
		return

	overmind_get_delay = world.time + 150 //if this fails, we'll try again in 15 seconds

	if(overmind)
		qdel(overmind)
=======
/obj/effect/blob/core/update_health()
	if(overmind)
		overmind.update_health()
		if((health < previous_health) && (core_warning_delay <= world.time))
			resource_delay = world.time + (3 SECONDS)
			to_chat(overmind,"<span class='danger'>YOUR CORE IS UNDER ATTACK!</span> <b><a href='?src=\ref[overmind];blobjump=\ref[loc]'>(JUMP)</a></b>")

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
		var/points_to_collect = Clamp(point_rate*round((world.time-last_resource_collection)/10), 0, 10)
		overmind.add_points(points_to_collect)
		last_resource_collection = world.time

	if(health < maxhealth)
		health = min(maxhealth, health + 1)
		update_icon()

	if(!spawning)//no expanding on the first Life() tick

		if(blob_looks[looks] == 64)
			anim(target = loc, a_icon = icon, flick_anim = "corepulse", sleeptime = 15, lay = 12, offX = -16, offY = -16, alph = 200)
			for(var/mob/M in viewers(src))
				M.playsound_local(loc, adminblob_beat, 50, 0, null, FALLOFF_SOUNDS, 0)

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
>>>>>>> ccb55b121a3fd5338fc56a602424016009566488

	var/client/C = null
	var/list/candidates = list()

	if(!new_overmind)
		candidates = get_candidates(ROLE_BLOB)
<<<<<<< HEAD
=======

		for(var/client/candidate in candidates)
			if(istype(candidate.eye,/obj/item/projectile/meteor/blob/core))
				candidates -= candidate

>>>>>>> ccb55b121a3fd5338fc56a602424016009566488
		if(candidates.len)
			C = pick(candidates)
	else
		C = new_overmind

	if(C)
<<<<<<< HEAD
		var/mob/camera/blob/B = new(src.loc, 1)
		B.key = C.key
		B.blob_core = src
		src.overmind = B
		update_icon()
		if(B.mind && !B.mind.special_role)
			B.mind.special_role = "Blob Overmind"
		return 1
	return 0
=======
		var/mob/camera/blob/B = new(src.loc)
		B.key = C.key
		B.blob_core = src
		src.overmind = B

		B.special_blobs += src
		B.hud_used.blob_hud()
		B.update_specialblobs()

		if(!B.blob_core.creator)//If this core is the first of its lineage (created by game mode/event/admins, instead of another overmind) it gets to choose its looks.
			var/new_name = "Blob Overmind ([rand(1, 999)])"
			B.name = new_name
			B.real_name = new_name
			for(var/mob/camera/blob/O in blob_overminds)
				if(O != B)
					to_chat(O,"<span class='notice'>[B] has appeared and just started a new blob! <a href='?src=\ref[O];blobjump=\ref[loc]'>(JUMP)</a></span>")

			B.verbs += /mob/camera/blob/proc/create_core
			spawn()
				var/can_choose_from = blob_looks - "adminbus"
				var/chosen = input(B,"Select a blob looks", "Blob Looks", blob_looks[1]) as null|anything in can_choose_from
				if(chosen)
					for(var/obj/effect/blob/nearby_blob in range(src,5))
						nearby_blob.looks = chosen
						nearby_blob.update_looks(1)
		else
			var/new_name = "Blob Cerebrate ([rand(1, 999)])"
			B.name = new_name
			B.real_name = new_name
			B.gui_icons.blob_spawncore.icon_state = ""
			B.gui_icons.blob_spawncore.name = ""
			for(var/mob/camera/blob/O in blob_overminds)
				if(O != B)
					to_chat(O,"<span class='notice'>A new blob cerebrate has started thinking inside a blob core! [B] joins the blob! <a href='?src=\ref[O];blobjump=\ref[loc]'>(JUMP)</a></span>")



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
>>>>>>> ccb55b121a3fd5338fc56a602424016009566488
