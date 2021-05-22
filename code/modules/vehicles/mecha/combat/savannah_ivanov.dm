/**
 * ## Savannah-Ivanov!
 *
 * A two person mecha that delegates moving to the driver and shooting to the pilot.
 * ...Hilarious, right?
 */
/obj/vehicle/sealed/mecha/combat/savannah_ivanov
	name = "\improper Savannah-Ivanov"
	desc = "An incredibly historic mecha, mostly out of common use because of it being from a time where mecha designers delegated functions to two pilots. \
			Because the Savannah-Ivanov needed to store two people, it is an absolute tank that, with two coordinated pilots, could absolutely mash even the \
			most menacing of single-pilot opponents."
	icon = 'icons/mecha/coop_mech.dmi'
	base_icon_state = "savannah_ivanov"
	icon_state = "savannah_ivanov_0_0"
	movedelay = 3
	dir_in = 2 //Facing South.
	max_integrity = 450 //really tanky, like damn
	deflect_chance = 25
	armor = list(MELEE = 45, BULLET = 40, LASER = 30, ENERGY = 30, BOMB = 40, BIO = 0, RAD = 80, FIRE = 100, ACID = 100)
	max_temperature = 30000
	infra_luminosity = 3
	wreckage = /obj/structure/mecha_wreckage/savannah_ivanov
	internal_damage_threshold = 25
	max_occupants = 2

/obj/vehicle/sealed/mecha/combat/savannah_ivanov/get_mecha_occupancy_state()
	var/driver_present = length(driver_amount()) > 0
	var/gunner_present = length(return_controllers_with_flag(VEHICLE_CONTROL_EQUIPMENT)) > 0
	return "[base_icon_state]_[driver_present]_[gunner_present]"

/obj/vehicle/sealed/mecha/combat/savannah_ivanov/auto_assign_occupant_flags(mob/new_occupant)
	if(driver_amount() < max_drivers) //movement
		add_control_flags(new_occupant, VEHICLE_CONTROL_DRIVE|VEHICLE_CONTROL_SETTINGS)
	else //weapons
		add_control_flags(new_occupant, VEHICLE_CONTROL_MELEE|VEHICLE_CONTROL_EQUIPMENT)

/obj/vehicle/sealed/mecha/generate_actions()
	. = ..()
	initialize_passenger_action_type(/datum/action/vehicle/sealed/mecha/swap_seat)
	//uncomment when ready
	//initialize_controller_action_type(/datum/action/vehicle/sealed/mecha/skyfall, VEHICLE_CONTROL_DRIVE)
	//initialize_controller_action_type(/datum/action/vehicle/sealed/mecha/missile_strike, VEHICLE_CONTROL_EQUIPMENT)
