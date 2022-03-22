/***************** MECHA ACTIONS *****************/

/obj/vehicle/sealed/mecha/generate_action_type()
	. = ..()
	if(istype(., /datum/action/vehicle/sealed/mecha))
		var/datum/action/vehicle/sealed/mecha/mecha = .
		mecha.chassis = src


/datum/action/vehicle/sealed/mecha
	icon_icon = 'icons/mob/actions/actions_mecha.dmi'
	var/obj/vehicle/sealed/mecha/chassis

/datum/action/vehicle/sealed/mecha/Destroy()
	chassis = null
	return ..()

/datum/action/vehicle/sealed/mecha/mech_eject
	name = "Eject From Mech"
	button_icon_state = "mech_eject"

/datum/action/vehicle/sealed/mecha/mech_eject/Trigger(trigger_flags)
	if(!owner)
		return
	if(!chassis || !(owner in chassis.occupants))
		return
	chassis.container_resist_act(owner)

/datum/action/vehicle/sealed/mecha/mech_toggle_internals
	name = "Toggle Internal Airtank Usage"
	button_icon_state = "mech_internals_off"

/datum/action/vehicle/sealed/mecha/mech_toggle_internals/Trigger(trigger_flags)
	if(!owner || !chassis || !(owner in chassis.occupants))
		return

	chassis.use_internal_tank = !chassis.use_internal_tank
	button_icon_state = "mech_internals_[chassis.use_internal_tank ? "on" : "off"]"
	chassis.balloon_alert(owner, "taking air from [chassis.use_internal_tank ? "internal airtank" : "environment"]")
	chassis.log_message("Now taking air from [chassis.use_internal_tank?"internal airtank":"environment"].", LOG_MECHA)
	UpdateButtonIcon()

/datum/action/vehicle/sealed/mecha/mech_cycle_equip
	name = "Cycle Equipment"
	button_icon_state = "mech_cycle_equip_off"

/datum/action/vehicle/sealed/mecha/mech_cycle_equip/Trigger(trigger_flags)
	if(!owner || !chassis || !(owner in chassis.occupants))
		return

	var/list/available_equipment = list()
	for(var/e in chassis.equipment)
		var/obj/item/mecha_parts/mecha_equipment/equipment = e
		if(equipment.selectable)
			available_equipment += equipment

	if(available_equipment.len == 0)
		chassis.balloon_alert(owner, "no equipment available")
		playsound(chassis,'sound/machines/terminal_error.ogg', 40, FALSE)
		return
	if(!chassis.selected)
		chassis.selected = available_equipment[1]
		chassis.balloon_alert(owner, "[chassis.selected] selected")
		send_byjax(chassis.occupants,"exosuit.browser","eq_list",chassis.get_equipment_list())
		button_icon_state = "mech_cycle_equip_on"
		playsound(chassis,'sound/machines/piston_raise.ogg', 40, TRUE)
		UpdateButtonIcon()
		return
	var/number = 0
	for(var/equipment in available_equipment)
		number++
		if(equipment != chassis.selected)
			continue
		if(available_equipment.len == number)
			chassis.selected = null
			chassis.balloon_alert(owner, "switched to no equipment")
			button_icon_state = "mech_cycle_equip_off"
			playsound(chassis,'sound/machines/piston_lower.ogg', 40, TRUE)
		else
			chassis.selected = available_equipment[number+1]
			chassis.balloon_alert(owner, "switched to [chassis.selected]")
			button_icon_state = "mech_cycle_equip_on"
			playsound(chassis,'sound/machines/piston_raise.ogg', 40, TRUE)
		send_byjax(chassis.occupants,"exosuit.browser","eq_list",chassis.get_equipment_list())
		UpdateButtonIcon()
		return


/datum/action/vehicle/sealed/mecha/mech_toggle_lights
	name = "Toggle Lights"
	button_icon_state = "mech_lights_off"

/datum/action/vehicle/sealed/mecha/mech_toggle_lights/Trigger(trigger_flags)
	if(!owner || !chassis || !(owner in chassis.occupants))
		return

	if(!(chassis.mecha_flags & HAS_LIGHTS))
		chassis.balloon_alert(owner, "the mech lights are broken!")
		return
	chassis.mecha_flags ^= LIGHTS_ON
	if(chassis.mecha_flags & LIGHTS_ON)
		button_icon_state = "mech_lights_on"
	else
		button_icon_state = "mech_lights_off"
	chassis.set_light_on(chassis.mecha_flags & LIGHTS_ON)
	chassis.balloon_alert(owner, "toggled lights [chassis.mecha_flags & LIGHTS_ON ? "on":"off"]")
	playsound(chassis,'sound/machines/clockcult/brass_skewer.ogg', 40, TRUE)
	chassis.log_message("Toggled lights [(chassis.mecha_flags & LIGHTS_ON)?"on":"off"].", LOG_MECHA)
	UpdateButtonIcon()

/datum/action/vehicle/sealed/mecha/mech_view_stats
	name = "View Stats"
	button_icon_state = "mech_view_stats"

/datum/action/vehicle/sealed/mecha/mech_view_stats/Trigger(trigger_flags)
	if(!owner || !chassis || !(owner in chassis.occupants))
		return

	var/datum/browser/popup = new(owner , "exosuit")
	popup.set_content(chassis.get_stats_html(owner))
	popup.open()


/datum/action/vehicle/sealed/mecha/strafe
	name = "Toggle Strafing. Disabled when Alt is held."
	button_icon_state = "strafe"

/datum/action/vehicle/sealed/mecha/strafe/Trigger(trigger_flags)
	if(!owner || !chassis || !(owner in chassis.occupants))
		return

	chassis.toggle_strafe()

/obj/vehicle/sealed/mecha/AltClick(mob/living/user)
	if(!(user in occupants) || !user.canUseTopic(src))
		return
	if(!(user in return_controllers_with_flag(VEHICLE_CONTROL_DRIVE)))
		to_chat(user, span_warning("You're in the wrong seat to control movement."))
		return

	toggle_strafe()

/obj/vehicle/sealed/mecha/proc/toggle_strafe()
	if(!(mecha_flags & CANSTRAFE))
		to_chat(occupants, "this mecha doesn't support strafing!")
		return

	strafe = !strafe

	to_chat(occupants, "strafing mode [strafe?"on":"off"].")
	log_message("Toggled strafing mode [strafe?"on":"off"].", LOG_MECHA)

	for(var/occupant in occupants)
		var/datum/action/action = LAZYACCESSASSOC(occupant_actions, occupant, /datum/action/vehicle/sealed/mecha/strafe)
		action?.UpdateButtonIcon()

///swap seats, for two person mecha
/datum/action/vehicle/sealed/mecha/swap_seat
	name = "Switch Seats"
	button_icon_state = "mech_seat_swap"

/datum/action/vehicle/sealed/mecha/swap_seat/Trigger(trigger_flags)
	if(!owner || !chassis || !(owner in chassis.occupants))
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
