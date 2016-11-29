/obj/structure/blob/core
	name = "blob core"
	icon = 'icons/mob/blob.dmi'
	icon_state = "blank_blob"
	desc = "A huge, pulsating yellow mass."
	obj_integrity = 400
	max_integrity = 400
	armor = list(melee = 0, bullet = 0, laser = 0, energy = 0, bomb = 0, bio = 0, rad = 0, fire = 75, acid = 90)
	explosion_block = 6
	point_return = -1
	health_regen = 0 //we regen in Life() instead of when pulsed
	var/core_regen = 2
	var/overmind_get_delay = 0 //we don't want to constantly try to find an overmind, this var tracks when we'll try to get an overmind again
	var/resource_delay = 0
	var/point_rate = 2


/obj/structure/blob/core/New(loc, client/new_overmind = null, new_rate = 2, placed = 0)
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

/obj/structure/blob/core/scannerreport()
	return "Directs the blob's expansion, gradually expands, and sustains nearby blob spores and blobbernauts."

/obj/structure/blob/core/update_icon()
	cut_overlays()
	color = null
	var/image/I = new('icons/mob/blob.dmi', "blob")
	if(overmind)
		I.color = overmind.blob_reagent_datum.color
	add_overlay(I)
	var/image/C = new('icons/mob/blob.dmi', "blob_core_overlay")
	add_overlay(C)

/obj/structure/blob/core/Destroy()
	blob_cores -= src
	if(overmind)
		overmind.blob_core = null
	overmind = null
	STOP_PROCESSING(SSobj, src)
	poi_list -= src
	return ..()

/obj/structure/blob/core/ex_act(severity, target)
	var/damage = 50 - 10 * severity //remember, the core takes half brute damage, so this is 20/15/10 damage based on severity
	take_damage(damage, BRUTE, "bomb", 0)

/obj/structure/blob/core/take_damage(damage_amount, damage_type = BRUTE, damage_flag = 0, sound_effect = 1, attack_dir, overmind_reagent_trigger = 1)
	. = ..()
	if(obj_integrity > 0)
		if(overmind) //we should have an overmind, but...
			overmind.update_health_hud()

/obj/structure/blob/core/Life()
	if(qdeleted(src))
		return
	if(!overmind)
		create_overmind()
	else
		if(resource_delay <= world.time)
			resource_delay = world.time + 10 // 1 second
			overmind.add_points(point_rate)
	obj_integrity = min(max_integrity, obj_integrity+core_regen)
	if(overmind)
		overmind.update_health_hud()
	Pulse_Area(overmind, 12, 4, 3)
	for(var/obj/structure/blob/normal/B in range(1, src))
		if(prob(5))
			B.change_to(/obj/structure/blob/shield/core, overmind)
	..()


/obj/structure/blob/core/proc/create_overmind(client/new_overmind, override_delay)
	if(overmind_get_delay > world.time && !override_delay)
		return

	overmind_get_delay = world.time + 150 //if this fails, we'll try again in 15 seconds

	if(overmind)
		qdel(overmind)

	var/client/C = null
	var/list/candidates = list()

	if(!new_overmind)
		candidates = pollCandidatesForMob("Do you want to play as a blob overmind?", ROLE_BLOB, null, ROLE_BLOB, 50, src) //we're technically not a mob but behave similarly
		if(candidates.len)
			C = pick(candidates)
	else
		C = new_overmind

	if(C)
		var/mob/camera/blob/B = new(src.loc, 1)
		B.key = C.key
		B.blob_core = src
		src.overmind = B
		update_icon()
		if(B.mind && !B.mind.special_role)
			B.mind.special_role = "Blob Overmind"
		return 1
	return 0
