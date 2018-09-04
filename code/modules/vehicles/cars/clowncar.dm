/obj/vehicle/sealed/car/clowncar
	name = "clown car"
	desc = "How someone could even fit in there is beyond me."
	icon_state = "clowncar"
	max_integrity = 500
	armor = list("melee" = 70, "bullet" = 40, "laser" = 40, "energy" = 0, "bomb" = 30, "bio" = 0, "rad" = 0, "fire" = 80, "acid" = 80)
	enter_delay = 20
	max_occupants = 50
	movedelay = 0.6
	car_traits = CAN_KIDNAP
	key_type = /obj/item/bikehorn
	key_type_exact = FALSE

/obj/vehicle/sealed/car/clowncar/generate_actions()
	. = ..()
	initialize_controller_action_type(/datum/action/vehicle/sealed/horn/clowncar, VEHICLE_CONTROL_DRIVE)

/obj/vehicle/sealed/car/clowncar/auto_assign_occupant_flags(mob/M)
	if(ishuman(M))
		var/mob/living/carbon/human/H = M
		if(H.mind && H.mind.assigned_role == "Clown") //Ensures only clowns can drive the car. (Including more at once)
			add_control_flags(M, VEHICLE_CONTROL_DRIVE|VEHICLE_CONTROL_PERMISSION)
		return
	add_control_flags(M, VEHICLE_CONTROL_KIDNAPPED)

/obj/vehicle/sealed/car/clowncar/mob_forced_enter(mob/M, silent = FALSE)
	. = ..()
	playsound(src, pick('sound/vehicles/clowncar_load1.ogg', 'sound/vehicles/clowncar_load2.ogg'), 75)

/obj/vehicle/sealed/car/clowncar/take_damage(damage_amount, damage_type = BRUTE, damage_flag = 0, sound_effect = 1, attack_dir)
	. = ..()
	if(prob(33))
		visible_message("<span class='danger'>[src] spews out a ton of space lube!</span>")
		new /obj/effect/particle_effect/foam(loc) //YEET

/obj/vehicle/sealed/car/clowncar/Bump(atom/movable/M)
	..()
	if(iscarbon(M))
		var/mob/living/carbon/C = M
		C.Knockdown(50)
		C.visible_message("<span class='warning'>[src] rams into [C] and sucks him up!</span>") //fuck off shezza this isn't ERP.
		mob_forced_enter(C)

		playsound(src, pick('sound/vehicles/clowncar_ram1.ogg', 'sound/vehicles/clowncar_ram2.ogg', 'sound/vehicles/clowncar_ram3.ogg'), 75)
	else if(istype(M, /turf/closed))
		visible_message("<span class='warning'>[src] rams into [M] and crashes!</span>")
		playsound(src, pick('sound/vehicles/clowncar_crash1.ogg', 'sound/vehicles/clowncar_crash2.ogg'), 75)
		playsound(src, 'sound/vehicles/clowncar_crashpins.ogg', 75)
		DumpMobs(TRUE)

/obj/vehicle/sealed/car/clowncar/deconstruct(disassembled = TRUE)
  . = ..()
  playsound(src, 'sound/vehicles/clowncar_fart.ogg', 100)
