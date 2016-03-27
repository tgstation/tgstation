var/list/normal_extraction_beacons = list()
var/list/total_extraction_beacons = list()

/obj/item/weapon/extraction_pack
	name = "Fulton Recovery Pack"
	desc = "A balloon that can be used to extract a target to a Fulton Recovery Beacon. Anything not bolted down can be moved. Link the pack to a beacon by using the pack in hand."
	icon = 'icons/obj/fulton.dmi'
	icon_state = "extraction_pack"
	var/obj/machinery/extraction_point/beacon
	var/is_syndie = 0
	var/uses_left = 12

/obj/item/weapon/extraction_pack/examine()
	. = ..()
	usr.show_message("It has [uses_left] uses remaining.", 1)

/obj/item/weapon/extraction_pack/advanced
	name = "Advanced Fulton Recovery Pack"
	uses_left = 24

/obj/item/weapon/extraction_pack/super
	name = "Super Fulton Recovery Pack"
	uses_left = 48

/obj/item/weapon/extraction_pack/syndicate
	name = "syndicate fulton recovery pack"
	is_syndie = 1
	uses_left = 9999

/obj/item/weapon/extraction_pack/attack_self(mob/user)
	if(!total_extraction_beacons.len)
		user << "There are no extraction beacons in existance!"
		return
	else
		var/A
		if(is_syndie)
			A = input("Select a beacon to connect to", "Balloon Extraction Pack", A) in total_extraction_beacons
		else
			A = input("Select a beacon to connect to", "Balloon Extraction Pack", A) in normal_extraction_beacons
		if(!A)
			return
		beacon = A
		return

/obj/item/weapon/extraction_pack/afterattack(atom/movable/A, mob/living/carbon/human/user, flag, params)
	if(!beacon)
		user << "[src] is not linked to a beacon, and cannot be used."
		return
	if(!flag)
		return
	if(!istype(A))
		return
	else
		if(A.loc == user || A == user) // no extracting stuff you're holding in your hands/yourself
			return
		if(A.anchored)
			return
		user << "<span class='notice'>You start attaching the pack to [A]...</span>"
		if(do_after(user,50,target=A))
			user << "<span class='notice'>You attach the pack to [A] and activate it.</span>"
			uses_left--
			if(uses_left <= 0)
				user.drop_item(src)
				loc = A
			var/image/balloon
			var/image/balloon2
			var/image/balloon3
			if(istype(A, /mob/living))
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
			if(istype(A, /mob/living/carbon/human))
				var/mob/living/carbon/human/L = A
				L.forcesay(extraction_appends) // ";HELP BL-AAAAAAAAAAAAAAAAHHHHHHHHH"
				L.SetParalysis(0) // wakey wakey
				L.drowsyness = 0
				L.sleeping = 0
			sleep(30)
			var/list/flooring_near_beacon = list()
			for(var/turf/simulated/floor/floor in orange(1, beacon))
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
			return
/obj/machinery/extraction_point
	name = "Fulton Recovery Beacon"
	desc = "A beacon for the fulton recovery system. Hit a beacon with a pack to link the pack to a beacon."
	icon = 'icons/obj/fulton.dmi'
	icon_state = "extraction_point"
	anchored = 1
	density = 0
	var/is_syndie = 0

/obj/machinery/extraction_point/syndicate
	name = "syndicate fulton recovery point"
	is_syndie = 1

/obj/machinery/extraction_point/New()
	var/area/area_name = get_area(src)
	name += " ([rand(100,999)]) ([area_name.name])"
	total_extraction_beacons += src
	if(!is_syndie)
		normal_extraction_beacons += src
	..()
	component_parts = list()
	component_parts += new /obj/item/weapon/circuitboard/extraction_point(null)
	component_parts += new /obj/item/weapon/stock_parts/manipulator(null)

/obj/machinery/extraction_point/Destroy()
	total_extraction_beacons -= src
	if(!is_syndie)
		normal_extraction_beacons -= src
	..()

/obj/effect/extraction_holder
	name = "extraction holder"
	desc = "you shouldnt see this"
	var/atom/movable/stored_obj