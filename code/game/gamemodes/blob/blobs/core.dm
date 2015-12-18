/obj/effect/blob/core
	name = "blob core"
	icon = 'icons/mob/blob.dmi'
	icon_state = "blank_blob"
	desc = "A huge, pulsating yellow mass."
	health = 400
	maxhealth = 400
	explosion_block = 6
	point_return = -1
	atmosblock = 1
	var/overmind_get_delay = 0 //we don't want to constantly try to find an overmind, this var tracks when we'll try to get an overmind again
	var/resource_delay = 0
	var/point_rate = 2
	var/is_offspring = 0


/obj/effect/blob/core/New(loc, var/h = 200, var/client/new_overmind = null, var/new_rate = 2, offspring)
	blob_cores += src
	SSobj.processing |= src
	update_icon() //so it atleast appears
	if(offspring)
		is_offspring = 1
	if(!overmind)
		create_overmind(new_overmind)
	if(overmind)
		update_icon()
	point_rate = new_rate
	..(loc, h)

/obj/effect/blob/core/update_icon()
	overlays.Cut()
	color = null
	var/image/I = new('icons/mob/blob.dmi', "blob")
	if(overmind)
		I.color = overmind.blob_reagent_datum.color
	overlays += I
	var/image/C = new('icons/mob/blob.dmi', "blob_core_overlay")
	overlays += C

/obj/effect/blob/core/PulseAnimation()
	return

/obj/effect/blob/core/Destroy()
	blob_cores -= src
	if(overmind)
		overmind.blob_core = null
	overmind = null
	SSobj.processing.Remove(src)
	return ..()

/obj/effect/blob/core/fire_act(datum/gas_mixture/air, exposed_temperature, exposed_volume)
	return

/obj/effect/blob/core/ex_act(severity, target)
	return

/obj/effect/blob/core/check_health()
	..()
	if(overmind) //we should have an overmind, but...
		overmind.update_health()

/obj/effect/blob/core/RegenHealth()
	return // Don't regen, we handle it in Life()

/obj/effect/blob/core/Life()
	if(!overmind)
		create_overmind()
	else
		if(resource_delay <= world.time)
			resource_delay = world.time + 10 // 1 second
			overmind.add_points(point_rate)
	health = min(maxhealth, health+health_regen)
	if(overmind)
		overmind.update_health()
	Pulse_Area(overmind, 12, 4, 3)
	for(var/b_dir in alldirs)
		if(!prob(5))
			continue
		var/obj/effect/blob/normal/B = locate() in get_step(src, b_dir)
		if(B)
			B.change_to(/obj/effect/blob/shield, overmind)
	..()


/obj/effect/blob/core/proc/create_overmind(client/new_overmind, override_delay)
	if(overmind_get_delay > world.time && !override_delay)
		return

	overmind_get_delay = world.time + 150 //if this fails, we'll try again in 15 seconds

	if(overmind)
		qdel(overmind)

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
		if(B.mind && !B.mind.special_role)
			B.mind.special_role = "Blob Overmind"
		if(is_offspring)
			B.verbs -= /mob/camera/blob/verb/split_consciousness
		return 1
	return 0
