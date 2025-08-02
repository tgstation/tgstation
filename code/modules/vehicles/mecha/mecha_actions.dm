/***************** MECHA ACTIONS *****************/

/obj/vehicle/sealed/mecha/generate_action_type()
	. = ..()
	if(istype(., /datum/action/vehicle/sealed/mecha))
		var/datum/action/vehicle/sealed/mecha/mecha_action = .
		mecha_action.set_chassis(src)

/datum/action/vehicle/sealed/mecha
	button_icon = 'icons/mob/actions/actions_mecha.dmi'
	var/obj/vehicle/sealed/mecha/chassis

/datum/action/vehicle/sealed/mecha/Destroy()
	chassis = null
	return ..()

///Sets the chassis var of our mecha action to the referenced mecha. Used during actions generation in
///generate_action_type() chain.
/datum/action/vehicle/sealed/mecha/proc/set_chassis(passed_chassis)
	chassis = passed_chassis

/datum/action/vehicle/sealed/mecha/mech_eject
	name = "Eject From Mech"
	button_icon_state = "mech_eject"

/datum/action/vehicle/sealed/mecha/mech_eject/Trigger(mob/clicker, trigger_flags)
	if(!..())
		return
	if(!chassis || !(owner in chassis.occupants))
		return
	chassis.container_resist_act(owner)

/datum/action/vehicle/sealed/mecha/mech_toggle_cabin_seal
	name = "Toggle Cabin Airtight"
	button_icon_state = "mech_cabin_open"
	desc = "Airtight cabin preserves internal air and can be pressurized with a mounted air tank."

/datum/action/vehicle/sealed/mecha/mech_toggle_cabin_seal/Trigger(mob/clicker, trigger_flags)
	if(!..())
		return
	if(!chassis || !(owner in chassis.occupants))
		return
	chassis.set_cabin_seal(owner, !chassis.cabin_sealed)

/datum/action/vehicle/sealed/mecha/mech_toggle_lights
	name = "Toggle Lights"
	button_icon_state = "mech_lights_off"

/datum/action/vehicle/sealed/mecha/mech_toggle_lights/Trigger(mob/clicker, trigger_flags)
	if(!..())
		return
	if(!chassis || !(owner in chassis.occupants))
		return
	chassis.toggle_lights(user = owner)

/datum/action/vehicle/sealed/mecha/mech_view_stats
	name = "View Stats"
	button_icon_state = "mech_view_stats"

/datum/action/vehicle/sealed/mecha/mech_view_stats/Trigger(mob/clicker, trigger_flags)
	if(!..())
		return
	if(!chassis || !(owner in chassis.occupants))
		return

	chassis.ui_interact(owner)

/datum/action/vehicle/sealed/mecha/mech_toggle_safeties
	name = "Toggle Equipment Safeties"
	button_icon_state = "mech_safeties_off"

/datum/action/vehicle/sealed/mecha/mech_toggle_safeties/set_chassis(passed_chassis)
	. = ..()
	RegisterSignal(chassis, COMSIG_MECH_SAFETIES_TOGGLE, PROC_REF(update_action_icon))

/datum/action/vehicle/sealed/mecha/mech_toggle_safeties/Trigger(mob/clicker, trigger_flags)
	if(!..())
		return
	if(!chassis || !(owner in chassis.occupants))
		return

	chassis.set_safety(owner)

/datum/action/vehicle/sealed/mecha/mech_toggle_safeties/apply_button_icon(atom/movable/screen/movable/action_button/current_button, force)
	button_icon_state = "mech_safeties_[chassis.weapons_safety ? "on" : "off"]"
	return ..()

/datum/action/vehicle/sealed/mecha/mech_toggle_safeties/proc/update_action_icon()
	SIGNAL_HANDLER
	build_all_button_icons()

/datum/action/vehicle/sealed/mecha/strafe
	name = "Toggle Strafing. Disabled when Alt is held."
	button_icon_state = "strafe"

/datum/action/vehicle/sealed/mecha/strafe/Trigger(mob/clicker, trigger_flags)
	if(!..())
		return
	if(!chassis || !(owner in chassis.occupants))
		return

	chassis.toggle_strafe()


/obj/vehicle/sealed/mecha/proc/toggle_strafe()
	if(!(mecha_flags & CAN_STRAFE))
		to_chat(occupants, "this mecha doesn't support strafing!")
		return

	strafe = !strafe

	for(var/mob/occupant in occupants)
		balloon_alert(occupant, "strafing [strafe?"on":"off"]")
		occupant.playsound_local(src, 'sound/machines/terminal/terminal_eject.ogg', 50, TRUE)
	log_message("Toggled strafing mode [strafe?"on":"off"].", LOG_MECHA)

	for(var/occupant in occupants)
		var/datum/action/action = LAZYACCESSASSOC(occupant_actions, occupant, /datum/action/vehicle/sealed/mecha/strafe)
		action?.build_all_button_icons()

///swap seats, for two person mecha
/datum/action/vehicle/sealed/mecha/swap_seat
	name = "Switch Seats"
	button_icon_state = "mech_seat_swap"

/datum/action/vehicle/sealed/mecha/swap_seat/Trigger(mob/clicker, trigger_flags)
	if(!..())
		return
	if(!chassis || !(owner in chassis.occupants))
		return

	if(chassis.occupants.len == chassis.max_occupants)
		chassis.balloon_alert(owner, "other seat occupied!")
		return
	var/list/drivers = chassis.return_drivers()
	chassis.balloon_alert(owner, "moving to other seat...")
	chassis.is_currently_ejecting = TRUE
	if(!do_after(owner, chassis.has_gravity() ? chassis.exit_delay : 0 , target = chassis))
		chassis.balloon_alert(owner, "interrupted!")
		chassis.is_currently_ejecting = FALSE
		return
	chassis.is_currently_ejecting = FALSE
	if(owner in drivers)
		chassis.balloon_alert(owner, "controlling gunner seat")
		chassis.remove_control_flags(owner, VEHICLE_CONTROL_DRIVE|VEHICLE_CONTROL_SETTINGS)
		chassis.add_control_flags(owner, VEHICLE_CONTROL_MELEE|VEHICLE_CONTROL_EQUIPMENT)
	else
		chassis.balloon_alert(owner, "controlling pilot seat")
		chassis.remove_control_flags(owner, VEHICLE_CONTROL_MELEE|VEHICLE_CONTROL_EQUIPMENT)
		chassis.add_control_flags(owner, VEHICLE_CONTROL_DRIVE|VEHICLE_CONTROL_SETTINGS)
	chassis.update_icon_state()

/datum/action/vehicle/sealed/mecha/mech_overclock
	name = "Toggle overclocking"
	button_icon_state = "mech_overload_off"

/datum/action/vehicle/sealed/mecha/mech_overclock/Trigger(trigger_flags, forced_state = null)
	if(!..())
		return
	if(!chassis || !(owner in chassis.occupants))
		return
	chassis.toggle_overclock(forced_state)
	button_icon_state = "mech_overload_[chassis.overclock_mode ? "on" : "off"]"
	build_all_button_icons()
