var/list/total_extraction_beacons = list()

/obj/item/weapon/extraction_pack
	name = "fulton extraction pack"
	desc = "A balloon that can be used to extract equipment or personnel to a Fulton Recovery Beacon. Anything not bolted down can be moved. Link the pack to a beacon by using the pack in hand."
	icon = 'icons/obj/fulton.dmi'
	icon_state = "extraction_pack"
	w_class = WEIGHT_CLASS_NORMAL
	var/obj/structure/extraction_point/beacon
	var/list/beacon_networks = list("station")
	var/uses_left = 3
	var/can_use_indoors
	var/safe_for_living_creatures = 1

/obj/item/weapon/extraction_pack/examine()
	. = ..()
	usr.show_message("It has [uses_left] uses remaining.", 1)

/obj/item/weapon/extraction_pack/attack_self(mob/user)
	var/list/possible_beacons = list()
	for(var/B in total_extraction_beacons)
		var/obj/structure/extraction_point/EP = B
		if(EP.beacon_network in beacon_networks)
			possible_beacons += EP

	if(!possible_beacons.len)
		user << "There are no extraction beacons in existence!"
		return

	else
		var/A

		A = input("Select a beacon to connect to", "Balloon Extraction Pack", A) in possible_beacons

		if(!A)
			return
		beacon = A

/obj/item/weapon/extraction_pack/afterattack(atom/movable/A, mob/living/carbon/human/user, flag, params)
	if(!beacon)
		user << "[src] is not linked to a beacon, and cannot be used."
		return
	if(!can_use_indoors)
		var/area/area = get_area(A)
		if(!area.outdoors)
			user << "[src] can only be used on things that are outdoors!"
			return
	if(!flag)
		return
	if(!istype(A))
		return
	else
		if(!safe_for_living_creatures && check_for_living_mobs(A))
			user << "[src] is not safe for use with living creatures, they wouldn't survive the trip back!"
			return
		if(A.loc == user) // no extracting stuff you're holding
			return
		if(A.anchored)
			return
		user << "<span class='notice'>You start attaching the pack to [A]...</span>"
		if(do_after(user,50,target=A))
			user << "<span class='notice'>You attach the pack to [A] and activate it.</span>"
			if(loc == user || istype(user.back, /obj/item/weapon/storage/backpack))
				var/obj/item/weapon/storage/backpack/B = user.back
				if(B.can_be_inserted(src,stop_messages = 1))
					B.handle_item_insertion(src)
			uses_left--
			if(uses_left <= 0)
				user.drop_item(src)
				loc = A
			var/image/balloon
			var/image/balloon2
			var/image/balloon3
			if(isliving(A))
				var/mob/living/M = A
				M.Weaken(16) // Keep them from moving during the duration of the extraction
				M.buckled = 0 // Unbuckle them to prevent anchoring problems
			else
				A.anchored = 1
				A.density = 0
			var/obj/effect/extraction_holder/holder_obj = new(A.loc)
			holder_obj.appearance = A.appearance
			A.loc = holder_obj
			balloon2 = image('icons/obj/fulton_balloon.dmi',"fulton_expand")
			balloon2.pixel_y = 10
			balloon2.appearance_flags = RESET_COLOR | RESET_ALPHA | RESET_TRANSFORM
			holder_obj.overlays += balloon2
			sleep(4)
			balloon = image('icons/obj/fulton_balloon.dmi',"fulton_balloon")
			balloon.pixel_y = 10
			balloon.appearance_flags = RESET_COLOR | RESET_ALPHA | RESET_TRANSFORM
			holder_obj.overlays -= balloon2
			holder_obj.overlays += balloon
			playsound(holder_obj.loc, 'sound/items/fulext_deploy.wav', 50, 1, -3)
			animate(holder_obj, pixel_z = 10, time = 20)
			sleep(20)
			animate(holder_obj, pixel_z = 15, time = 10)
			sleep(10)
			animate(holder_obj, pixel_z = 10, time = 10)
			sleep(10)
			animate(holder_obj, pixel_z = 15, time = 10)
			sleep(10)
			animate(holder_obj, pixel_z = 10, time = 10)
			sleep(10)
			playsound(holder_obj.loc, 'sound/items/fultext_launch.wav', 50, 1, -3)
			animate(holder_obj, pixel_z = 1000, time = 30)
			if(ishuman(A))
				var/mob/living/carbon/human/L = A
				L.SetParalysis(0)
				L.drowsyness = 0
				L.sleeping = 0
			sleep(30)
			var/list/flooring_near_beacon = list()
			for(var/turf/open/floor in orange(1, beacon))
				flooring_near_beacon += floor
			holder_obj.loc = pick(flooring_near_beacon)
			animate(holder_obj, pixel_z = 10, time = 50)
			sleep(50)
			animate(holder_obj, pixel_z = 15, time = 10)
			sleep(10)
			animate(holder_obj, pixel_z = 10, time = 10)
			sleep(10)
			balloon3 = image('icons/obj/fulton_balloon.dmi',"fulton_retract")
			balloon3.pixel_y = 10
			balloon3.appearance_flags = RESET_COLOR | RESET_ALPHA | RESET_TRANSFORM
			holder_obj.overlays -= balloon
			holder_obj.overlays += balloon3
			sleep(4)
			holder_obj.overlays -= balloon3
			A.anchored = 0 // An item has to be unanchored to be extracted in the first place.
			A.density = initial(A.density)
			animate(holder_obj, pixel_z = 0, time = 5)
			sleep(5)
			A.loc = holder_obj.loc
			qdel(holder_obj)
			if(uses_left <= 0)
				qdel(src)


/obj/item/fulton_core
	name = "extraction beacon signaller"
	desc = "Emits a signal which fulton recovery devices can lock onto. Activate in hand to create a beacon."
	icon = 'icons/obj/stock_parts.dmi'
	icon_state = "subspace_amplifier"

/obj/item/fulton_core/attack_self(mob/user)
	if(do_after(user,15,target = user) && !QDELETED(src))
		new /obj/structure/extraction_point(get_turf(user))
		qdel(src)

/obj/structure/extraction_point
	name = "fulton recovery beacon"
	desc = "A beacon for the fulton recovery system. Hit a beacon with a pack to link the pack to a beacon."
	icon = 'icons/obj/fulton.dmi'
	icon_state = "extraction_point"
	anchored = 1
	density = 0
	var/beacon_network = "station"

/obj/structure/extraction_point/New()
	var/area/area_name = get_area(src)
	name += " ([rand(100,999)]) ([area_name.name])"
	total_extraction_beacons += src
	..()

/obj/structure/extraction_point/Destroy()
	total_extraction_beacons -= src
	..()

/obj/effect/extraction_holder
	name = "extraction holder"
	desc = "you shouldnt see this"
	var/atom/movable/stored_obj

/obj/item/weapon/extraction_pack/proc/check_for_living_mobs(atom/A)
	if(isliving(A))
		var/mob/living/L = A
		if(L.stat != DEAD)
			return 1
	for(var/thing in A.GetAllContents())
		if(isliving(A))
			var/mob/living/L = A
			if(L.stat != DEAD)
				return 1
	return 0