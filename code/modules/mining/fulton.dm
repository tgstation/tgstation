GLOBAL_LIST_EMPTY(total_extraction_beacons)

/obj/item/extraction_pack
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
	var/max_force_fulton = MOVE_FORCE_STRONG

/obj/item/extraction_pack/examine()
	. = ..()
	. += "It has [uses_left] use\s remaining."

/obj/item/extraction_pack/attack_self(mob/user)
	var/list/possible_beacons = list()
	for(var/obj/structure/extraction_point/extraction_point as anything in GLOB.total_extraction_beacons)
		if(extraction_point.beacon_network in beacon_networks)
			possible_beacons += extraction_point
	if(!length(possible_beacons))
		to_chat(user, span_warning("There are no extraction beacons in existence!"))
		return
	else
		var/chosen_beacon = tgui_input_list(user, "Beacon to connect to", "Balloon Extraction Pack", sort_names(possible_beacons))
		if(isnull(chosen_beacon))
			return
		beacon = chosen_beacon
		to_chat(user, span_notice("You link the extraction pack to the beacon system."))

/obj/item/extraction_pack/afterattack(atom/movable/A, mob/living/carbon/human/user, flag, params)
	. = ..()
	. |= AFTERATTACK_PROCESSED_ITEM
	if(!beacon)
		to_chat(user, span_warning("[src] is not linked to a beacon, and cannot be used!"))
		return
	if(!(beacon in GLOB.total_extraction_beacons))
		beacon = null
		to_chat(user, span_warning("The connected beacon has been destroyed!"))
		return
	if(!can_use_indoors)
		var/area/area = get_area(A)
		if(!area.outdoors)
			to_chat(user, span_warning("[src] can only be used on things that are outdoors!"))
			return
	if(!flag)
		return
	if(!istype(A))
		return
	else
		if(!safe_for_living_creatures && check_for_living_mobs(A))
			to_chat(user, span_warning("[src] is not safe for use with living creatures, they wouldn't survive the trip back!"))
			return
		if(!isturf(A.loc)) // no extracting stuff inside other stuff
			return
		if(A.anchored || (A.move_resist > max_force_fulton))
			return
		to_chat(user, span_notice("You start attaching the pack to [A]..."))
		if(do_after(user,50,target=A))
			to_chat(user, span_notice("You attach the pack to [A] and activate it."))
			if(loc == user && istype(user.back, /obj/item/storage/backpack))
				var/obj/item/storage/backpack/B = user.back
				B.atom_storage?.attempt_insert(src, user)
			uses_left--
			if(uses_left <= 0)
				user.transferItemToLoc(src, A, TRUE)
			var/mutable_appearance/balloon
			var/mutable_appearance/balloon2
			var/mutable_appearance/balloon3
			if(isliving(A))
				var/mob/living/M = A
				M.Paralyze(320) // Keep them from moving during the duration of the extraction
				if(M.buckled)
					M.buckled.unbuckle_mob(M, TRUE) // Unbuckle them to prevent anchoring problems
			else
				A.set_anchored(TRUE)
				A.set_density(FALSE)
			var/obj/effect/extraction_holder/holder_obj = new(A.loc)
			holder_obj.appearance = A.appearance
			A.forceMove(holder_obj)
			balloon2 = mutable_appearance('icons/obj/fulton_balloon.dmi', "fulton_expand")
			balloon2.pixel_y = 10
			balloon2.appearance_flags = RESET_COLOR | RESET_ALPHA | RESET_TRANSFORM
			holder_obj.add_overlay(balloon2)
			sleep(0.4 SECONDS)
			balloon = mutable_appearance('icons/obj/fulton_balloon.dmi', "fulton_balloon")
			balloon.pixel_y = 10
			balloon.appearance_flags = RESET_COLOR | RESET_ALPHA | RESET_TRANSFORM
			holder_obj.cut_overlay(balloon2)
			holder_obj.add_overlay(balloon)
			playsound(holder_obj.loc, 'sound/items/fultext_deploy.ogg', 50, TRUE, -3)
			animate(holder_obj, pixel_z = 10, time = 20)
			sleep(2 SECONDS)
			animate(holder_obj, pixel_z = 15, time = 10)
			sleep(1 SECONDS)
			animate(holder_obj, pixel_z = 10, time = 10)
			sleep(1 SECONDS)
			animate(holder_obj, pixel_z = 15, time = 10)
			sleep(1 SECONDS)
			animate(holder_obj, pixel_z = 10, time = 10)
			sleep(1 SECONDS)
			playsound(holder_obj.loc, 'sound/items/fultext_launch.ogg', 50, TRUE, -3)
			animate(holder_obj, pixel_z = 1000, time = 30)
			if(ishuman(A))
				var/mob/living/carbon/human/L = A
				L.SetUnconscious(0)
				L.remove_status_effect(/datum/status_effect/drowsiness)
				L.SetSleeping(0)
			sleep(3 SECONDS)
			var/list/flooring_near_beacon = list()
			for(var/turf/open/floor in orange(1, beacon))
				flooring_near_beacon += floor
			holder_obj.forceMove(pick(flooring_near_beacon))
			animate(holder_obj, pixel_z = 10, time = 50)
			sleep(5 SECONDS)
			animate(holder_obj, pixel_z = 15, time = 10)
			sleep(1 SECONDS)
			animate(holder_obj, pixel_z = 10, time = 10)
			sleep(1 SECONDS)
			balloon3 = mutable_appearance('icons/obj/fulton_balloon.dmi', "fulton_retract")
			balloon3.pixel_y = 10
			balloon3.appearance_flags = RESET_COLOR | RESET_ALPHA | RESET_TRANSFORM
			holder_obj.cut_overlay(balloon)
			holder_obj.add_overlay(balloon3)
			sleep(0.4 SECONDS)
			holder_obj.cut_overlay(balloon3)
			A.set_anchored(FALSE) // An item has to be unanchored to be extracted in the first place.
			A.set_density(initial(A.density))
			animate(holder_obj, pixel_z = 0, time = 5)
			sleep(0.5 SECONDS)
			A.forceMove(holder_obj.loc)
			qdel(holder_obj)
			if(uses_left <= 0)
				qdel(src)


/obj/item/fulton_core
	name = "extraction beacon assembly kit"
	desc = "When built, emits a signal which fulton recovery devices can lock onto. Activate in hand to unfold into a beacon."
	icon = 'icons/obj/fulton.dmi'
	icon_state = "folded_extraction"

/obj/item/fulton_core/attack_self(mob/user)
	if(do_after(user,15,target = user) && !QDELETED(src))
		new /obj/structure/extraction_point(get_turf(user))
		playsound(src, 'sound/items/deconstruct.ogg', vol = 50, vary = TRUE, extrarange = MEDIUM_RANGE_SOUND_EXTRARANGE)
		qdel(src)

/obj/structure/extraction_point
	name = "fulton recovery beacon"
	desc = "A beacon for the fulton recovery system. Activate a pack in your hand to link it to a beacon."
	icon = 'icons/obj/fulton.dmi'
	icon_state = "extraction_point"
	anchored = TRUE
	density = FALSE
	var/beacon_network = "station"

/obj/structure/extraction_point/Initialize(mapload)
	. = ..()
	name += " ([rand(100,999)]) ([get_area_name(src, TRUE)])"
	GLOB.total_extraction_beacons += src
	update_appearance(UPDATE_OVERLAYS)

/obj/structure/extraction_point/Destroy()
	GLOB.total_extraction_beacons -= src
	return ..()

/obj/structure/extraction_point/update_overlays()
	. = ..()
	. += emissive_appearance(icon, "[icon_state]_light", src, alpha = src.alpha)

/obj/effect/extraction_holder
	name = "extraction holder"
	desc = "you shouldn't see this"
	var/atom/movable/stored_obj

/obj/item/extraction_pack/proc/check_for_living_mobs(atom/A)
	if(isliving(A))
		var/mob/living/L = A
		if(L.stat != DEAD)
			return TRUE
	for(var/thing in A.get_all_contents())
		if(isliving(A))
			var/mob/living/L = A
			if(L.stat != DEAD)
				return TRUE
	return FALSE

/obj/effect/extraction_holder/singularity_act()
	return

/obj/effect/extraction_holder/singularity_pull()
	return
