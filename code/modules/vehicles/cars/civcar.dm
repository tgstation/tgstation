
/obj/vehicle/sealed/car/civ
	name = "car"
	desc = "This used to be a pedestrian-focused station, and now all these cars are ruining it!" //ok boomer
	icon_state = "car"
	max_integrity = 300
	armor = list("melee" = 70, "bullet" = 40, "laser" = 40, "energy" = 0, "bomb" = 30, "bio" = 0, "rad" = 0, "fire" = 80, "acid" = 80)
	enter_delay = 50 //No speed escapes
	max_occupants = 5
	movedelay = 1.15
	material_flags = MATERIAL_AFFECT_STATISTICS | MATERIAL_COLOR | MATERIAL_ADD_PREFIX
	var/obj/item/card/id/linked_id = null
	var/can_drive = FALSE


/obj/vehicle/sealed/car/civ/Initialize()
	var/datum/material/M = pick(subtypesof(/datum/material))
	custom_materials = list()
	custom_materials[M] = 10000
	. = ..()

/obj/vehicle/sealed/car/civ/generate_actions()
	. = ..()
	initialize_controller_action_type(/datum/action/vehicle/sealed/horn, VEHICLE_CONTROL_DRIVE)

/obj/vehicle/sealed/car/civ/Cross(atom/movable/AM)
	. = ..()
	if(!isliving(AM))
		return
	var/mob/living/L = AM
	if(!(L.mobility_flags & MOBILITY_STAND) && !L.buckle_lying)
		for(var/i in return_drivers())
			if(!ishuman(i))
				continue
			var/mob/living/carbon/human/boomer = i
			boomer.say(pick("DON'T LIE IN FRONT OF MY CAR YA FUCKIN' KNOB!!", "HEY! I'M DRIVIN' HERE!!", "YOU ARE RUINING MY SUSPENSION, CUNT!"), forced="car crash")
			L.adjustBruteLoss(5) //tires burn
			return

/obj/vehicle/sealed/car/civ/Bump(atom/A)
	. = ..()
	if(!isliving(A))
		return
	var/mob/living/L = A
	for(var/i in return_drivers())
		if(!ishuman(i))
			continue
		var/mob/living/carbon/human/boomer = i
		boomer.say(pick("HOLY SHIT MY PAINT IS RUINED!!", "I LEASED THIS YOU DICK!!", "GET OUT OF THE WAY! I WILL END YOU!!", "WHAT THE FUCK!? DO YOU KNOW HOW EXPENSIVE CARS ARE?!!", "GET OFF THE ROAD YOU BRAINDEAD TROGLODYTE!!", "GET OUT OF THE GODDAMN WAY!!"), forced="car crash")
	var/throw_dir = turn(src.dir, pick(-90, 90))
	var/throw_target = get_edge_target_turf(L, throw_dir)
	playsound(src, pick('sound/vehicles/clowncar_ram1.ogg', 'sound/vehicles/clowncar_ram2.ogg', 'sound/vehicles/clowncar_ram3.ogg'), 75)
	L.throw_at(throw_target, rand(2,3), 4)
	L.adjustBruteLoss(2) //NT guaranteed baby bumpers

/obj/vehicle/sealed/car/civ/auto_assign_occupant_flags(mob/M)
	if(ishuman(M))
		var/mob/living/carbon/human/H = M
		var/obj/item/card/id/used_id = H.get_idcard(TRUE)
		if(used_id == linked_id)
			add_control_flags(H, VEHICLE_CONTROL_DRIVE|VEHICLE_CONTROL_PERMISSION)

/*
/obj/vehicle/sealed/car/civ/key_check(mob/M)
	if(!can_drive)
		to_chat(M, "<span class='notice'>You need to start the car with the owner's ID!</span>")
		return FALSE
	return TRUE
*/

/obj/vehicle/sealed/car/civ/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/card/id))
		if(!linked_id)
			linked_id = I
			to_chat(user, "<span class='notice'>You link your ID to the car!</span>")
			return
		can_drive = !can_drive
		if(can_drive)
			to_chat(user, "<span class='notice'>You start the car!</span>")
		else
			to_chat(user, "<span class='notice'>You turn off the car!</span>")
		return
	return ..()

/obj/vehicle/sealed/car/civ/mob_try_enter(mob/M)
	if(!linked_id)
		to_chat(M, "<span class='notice'>You need to link the car to your ID first!</span>")
		return FALSE
	return ..()

/obj/item/car_beacon
	name = "car beacon"
	desc = "Get your NT sponsored vehicle delivered to you."
	icon = 'icons/obj/objects.dmi'
	icon_state = "floor_beacon"
	var/used

/obj/item/car_beacon/attack_self()
	if(used)
		return
	loc.visible_message("<span class='warning'>\The [src] begins to beep loudly!</span>")
	used = TRUE
	addtimer(CALLBACK(src, .proc/launch_payload), 40)

/obj/item/car_beacon/proc/launch_payload()
	var/obj/structure/closet/supplypod/centcompod/toLaunch = new()

	new /obj/vehicle/sealed/car/civ(toLaunch)

	new /obj/effect/pod_landingzone(drop_location(), toLaunch)
	qdel(src)
