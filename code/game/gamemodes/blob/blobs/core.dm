/obj/effect/blob/core
	name = "blob core"
	icon = 'icons/mob/blob.dmi'
	icon_state = "blank_blob"
	health = 200
	fire_resist = 2
	var/mob/camera/blob/overmind = null // the blob core's overmind
	var/overmind_get_delay = 0 // we don't want to constantly try to find an overmind, do it every 30 seconds
	var/resource_delay = 0
	var/point_rate = 2
	var/is_offspring = null

/obj/effect/blob/core/New(loc, var/h = 200, var/client/new_overmind = null, var/new_rate = 2, offspring)
	blob_cores += src
	SSobj.processing |= src
	adjustcolors(color) //so it atleast appears
	if(!overmind)
		create_overmind(new_overmind)
	if(overmind)
		adjustcolors(overmind.blob_reagent_datum.color)
		update_desc(overmind.blob_reagent_datum.name)
	if(offspring)
		is_offspring = 1
	point_rate = new_rate
	..(loc, h)


/obj/effect/blob/core/adjustcolors(var/a_color)
	overlays.Cut()
	color = null
	var/image/I = new('icons/mob/blob.dmi', "blob")
	I.color = a_color
	overlays += I
	var/image/C = new('icons/mob/blob.dmi', "blob_core_overlay")
	overlays += C


/obj/effect/blob/core/Destroy()
	blob_cores -= src
	if(overmind)
		overmind.blob_core = null
	overmind = null
	SSobj.processing.Remove(src)
	..()

/obj/effect/blob/core/fire_act(datum/gas_mixture/air, exposed_temperature, exposed_volume)
	return

/obj/effect/blob/core/update_icon()
	if(health <= 0)
		qdel(src)
		return
	// update_icon is called when health changes so... call update_health in the overmind
	if(overmind)
		overmind.update_health()
	return

/obj/effect/blob/core/RegenHealth()
	return // Don't regen, we handle it in Life()

/obj/effect/blob/core/Life()
	if(!overmind)
		create_overmind()
	else
		if(resource_delay <= world.time)
			resource_delay = world.time + 10 // 1 second
			overmind.add_points(point_rate)
	health = min(initial(health), health + 1)
	if(overmind)
		overmind.update_health()
	for(var/i = 1; i < 8; i += i)
		Pulse(0, i, overmind.blob_reagent_datum.color)
	for(var/b_dir in alldirs)
		if(!prob(5))
			continue
		var/obj/effect/blob/normal/B = locate() in get_step(src, b_dir)
		if(B)
			B.change_to(/obj/effect/blob/shield)
			B.color = overmind.blob_reagent_datum.color
	color = null
	..()


/obj/effect/blob/core/proc/create_overmind(var/client/new_overmind, var/override_delay)

	if(overmind_get_delay > world.time && !override_delay)
		return

	overmind_get_delay = world.time + 300 // 30 seconds

	if(overmind)
		qdel(overmind)

	var/client/C = null
	var/list/candidates = list()

	if(!new_overmind)
		candidates = get_candidates(BE_BLOB)
		if(candidates.len)
			C = pick(candidates)
	else
		C = new_overmind

	if(C)
		var/mob/camera/blob/B = new(src.loc)
		B.key = C.key
		B.blob_core = src
		src.overmind = B
		color = overmind.blob_reagent_datum.color
		if(B.mind && !B.mind.special_role)
			B.mind.special_role = "Blob Overmind"
		update_desc(overmind.blob_reagent_datum.name)
		spawn(0)
			if(is_offspring)
				B.verbs -= /mob/camera/blob/verb/split_consciousness
		return 1
	return 0

