/**
 * ## Savannah-Ivanov!
 *
 * A two person mecha that delegates moving to the driver and shooting to the pilot.
 * ...Hilarious, right?
 */
/obj/vehicle/sealed/mecha/combat/savannah_ivanov
	name = "\improper Savannah-Ivanov"
	desc = "An incredibly ancient mecha, mostly out of common use because of it being from a time where mecha designers delegated functions to two pilots. \
			Because the Savannah-Ivanov needed to store two people, it is a hulking, armored tank that, with two coordinated pilots, could absolutely mash even the \
			most menacing of single-pilot opponents."
	icon = 'icons/mecha/coop_mech.dmi'
	icon_state = "savannah_ivanov_0_0"
	movedelay = 3
	dir_in = 2 //Facing South.
	max_integrity = 450 //really tanky, like damn
	deflect_chance = 25
	armor = list(MELEE = 45, BULLET = 40, LASER = 30, ENERGY = 30, BOMB = 40, BIO = 0, RAD = 80, FIRE = 100, ACID = 100)
	max_temperature = 30000
	infra_luminosity = 3
	wreckage = /obj/structure/mecha_wreckage/savannah_ivanov
	melee_can_hit = FALSE
	add_req_access = 1
	internal_damage_threshold = 25
	max_occupants = 2

/obj/vehicle/sealed/mecha/combat/savannah_ivanov/get_mecha_occupancy_state()
	var/driver_present = driver_amount() ? TRUE : FALSE
	var/gunner_present = return_controllers_with_flag(VEHICLE_CONTROL_EQUIPMENT) ? TRUE : FALSE
	return "[base_icon_state]_[driver_present]_[gunner_present]"

/obj/vehicle/sealed/mecha/combat/savannah_ivanov/auto_assign_occupant_flags(mob/M)
	if(driver_amount() < max_drivers) //movement
		add_control_flags(M, VEHICLE_CONTROL_DRIVE|VEHICLE_CONTROL_PERMISSION)
	else //weapons
		add_control_flags(M, VEHICLE_CONTROL_MECHAPUNCH|VEHICLE_CONTROL_EQUIPMENT)

