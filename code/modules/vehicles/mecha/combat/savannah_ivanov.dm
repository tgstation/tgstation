/**
 * ## Savannah-Ivanov!
 *
 * A two person mecha that delegates moving to the driver and shooting to the pilot.
 * ...Hilarious, right?
 */
/obj/vehicle/sealed/mecha/combat/savannah_ivanov
	name = "\improper Savannah-Ivanov"
	desc = "An insanely overbulked mecha that handily crushes single-pilot opponents. The price is that you need two pilots to use it."
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
	///ivanov strike ability cooldown
	COOLDOWN_DECLARE(ivanov_strike_cooldown)
	///cooldown time between strike uses
	var/ivanov_strike_cooldown_time = 40 SECONDS
	///toggled by ivanov strike, TRUE when signals are hooked to intercept clicks.
	var/aiming_ivanov = FALSE

/obj/vehicle/sealed/mecha/combat/savannah_ivanov/get_mecha_occupancy_state()
	var/driver_present = driver_amount() != 0
	var/gunner_present = return_amount_of_controllers_with_flag(VEHICLE_CONTROL_EQUIPMENT) > 0
	return "[base_icon_state]_[gunner_present]_[driver_present]"

/obj/vehicle/sealed/mecha/combat/savannah_ivanov/auto_assign_occupant_flags(mob/new_occupant)
	if(driver_amount() < max_drivers) //movement
		add_control_flags(new_occupant, VEHICLE_CONTROL_DRIVE|VEHICLE_CONTROL_SETTINGS)
	else //weapons
		add_control_flags(new_occupant, VEHICLE_CONTROL_MELEE|VEHICLE_CONTROL_EQUIPMENT)

/obj/vehicle/sealed/mecha/combat/savannah_ivanov/generate_actions()
	initialize_passenger_action_type(/datum/action/vehicle/sealed/mecha/swap_seat)
	. = ..()
	//uncomment when ready
	//initialize_controller_action_type(/datum/action/vehicle/sealed/mecha/skyfall, VEHICLE_CONTROL_DRIVE)
	initialize_controller_action_type(/datum/action/vehicle/sealed/mecha/ivanov_strike, VEHICLE_CONTROL_EQUIPMENT)

/obj/vehicle/sealed/mecha/combat/savannah_ivanov/remove_occupant(mob/getting_out)
	//gunner getting out ends any ivanov aiming
	if(aiming_ivanov && (getting_out in return_controllers_with_flag(VEHICLE_CONTROL_EQUIPMENT)))
		end_missile_targeting(getting_out)
	. = ..()

/obj/vehicle/sealed/mecha/combat/savannah_ivanov/proc/start_missile_targeting(mob/gunner, silent = TRUE)
	if(!silent)
		to_chat(gunner, "<span class='warning'>Ivanov Strike targeting process booted. \
		Your next click will fire the missile (provided you are facing the right direction).</span>")
	aiming_ivanov = TRUE
	RegisterSignal(src, COMSIG_MECHA_MELEE_CLICK, .proc/on_melee_click)
	RegisterSignal(src, COMSIG_MECHA_EQUIPMENT_CLICK, .proc/on_equipment_click)
	gunner.client.mouse_override_icon = 'icons/effects/mouse_pointers/supplypod_down_target.dmi'
	gunner.update_mouse_pointer()

/obj/vehicle/sealed/mecha/combat/savannah_ivanov/proc/end_missile_targeting(mob/gunner, silent = TRUE)
	if(!silent)
		to_chat(gunner, "<span class='warning'>Ivanov Strike targeting process killed. Your next click will act normally.</span>")
	aiming_ivanov = FALSE
	UnregisterSignal(src, list(COMSIG_MECHA_MELEE_CLICK, COMSIG_MECHA_EQUIPMENT_CLICK))
	gunner.client.mouse_override_icon = null
	gunner.update_mouse_pointer()

///signal called from clicking with no equipment
/obj/vehicle/sealed/mecha/combat/savannah_ivanov/proc/on_melee_click(datum/source, mob/living/pilot, atom/target, on_cooldown, is_adjacent)
	SIGNAL_HANDLER
	if(!target)
		return
	drop_missile(pilot, get_turf(target))

///signal called from clicking with equipment
/obj/vehicle/sealed/mecha/combat/savannah_ivanov/proc/on_equipment_click(datum/source, mob/living/pilot, atom/target)
	SIGNAL_HANDLER
	if(!target)
		return
	drop_missile(pilot, get_turf(target))

/obj/vehicle/sealed/mecha/combat/savannah_ivanov/proc/drop_missile(mob/gunner, turf/target_turf)
	end_missile_targeting(gunner)
	COOLDOWN_START(src, ivanov_strike_cooldown, ivanov_strike_cooldown_time)
	podspawn(list(
		"target" = target_turf,
		"style" = STYLE_MISSILE,
		"effectMissile" = TRUE,
		"explosionSize" = list(0,1,2,3)
	))
	var/datum/action/vehicle/sealed/mecha/strike_action = occupant_actions[gunner][/datum/action/vehicle/sealed/mecha/ivanov_strike]
	strike_action.button_icon_state = "mech_ivanov_cooldown"
	strike_action.UpdateButtonIcon()
	addtimer(VARSET_CALLBACK(strike_action, button_icon_state, initial(strike_action.button_icon_state)), ivanov_strike_cooldown_time)

/datum/action/vehicle/sealed/mecha/ivanov_strike
	name = "Ivanov Strike"
	button_icon_state = "mech_ivanov"

/datum/action/vehicle/sealed/mecha/ivanov_strike/Trigger()
	if(!owner || !chassis || !(owner in chassis.occupants))
		return
	var/obj/vehicle/sealed/mecha/combat/savannah_ivanov/ivanov_mecha = chassis
	if(!COOLDOWN_FINISHED(ivanov_mecha, ivanov_strike_cooldown))
		var/timeleft = COOLDOWN_TIMELEFT(ivanov_mecha, ivanov_strike_cooldown)
		to_chat(owner, "<span class='warning'>You need to wait [DisplayTimeText(timeleft)] before firing another Ivanov Strike.</span>")
		return
	ivanov_mecha.aiming_ivanov ? ivanov_mecha.end_missile_targeting(owner, silent = FALSE) : ivanov_mecha.start_missile_targeting(owner, silent = FALSE)
