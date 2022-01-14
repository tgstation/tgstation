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

/datum/action/vehicle/sealed/mecha/mech_eject/Trigger()
	if(!owner)
		return
	if(!chassis || !(owner in chassis.occupants))
		return
	chassis.container_resist_act(owner)

/datum/action/vehicle/sealed/mecha/mech_toggle_internals
	name = "Toggle Internal Airtank Usage"
	button_icon_state = "mech_internals_off"

/datum/action/vehicle/sealed/mecha/mech_toggle_internals/Trigger()
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

/datum/action/vehicle/sealed/mecha/mech_cycle_equip/Trigger()
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

/datum/action/vehicle/sealed/mecha/mech_toggle_lights/Trigger()
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

/datum/action/vehicle/sealed/mecha/mech_view_stats/Trigger()
	if(!owner || !chassis || !(owner in chassis.occupants))
		return

	var/datum/browser/popup = new(owner , "exosuit")
	popup.set_content(chassis.get_stats_html(owner))
	popup.open()


/datum/action/vehicle/sealed/mecha/strafe
	name = "Toggle Strafing. Disabled when Alt is held."
	button_icon_state = "strafe"

/datum/action/vehicle/sealed/mecha/strafe/Trigger()
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

//////////////////////////////////////// Specific Ability Actions  ///////////////////////////////////////////////
//Need to be granted by the mech type, Not default abilities.

/datum/action/vehicle/sealed/mecha/mech_defense_mode
	name = "Toggle an energy shield that blocks all attacks from the faced direction at a heavy power cost."
	button_icon_state = "mech_defense_mode_off"

/datum/action/vehicle/sealed/mecha/mech_defense_mode/Trigger(forced_state = FALSE)
	SEND_SIGNAL(chassis, COMSIG_MECHA_ACTION_TRIGGER, owner, args) //Signal sent to the mech, to be handed to the shield. See durand.dm for more details

/datum/action/vehicle/sealed/mecha/mech_overload_mode
	name = "Toggle leg actuators overload"
	button_icon_state = "mech_overload_off"

/datum/action/vehicle/sealed/mecha/mech_overload_mode/Trigger(forced_state = null)
	if(!owner || !chassis || !(owner in chassis.occupants))
		return
	if(!isnull(forced_state))
		chassis.leg_overload_mode = forced_state
	else
		chassis.leg_overload_mode = !chassis.leg_overload_mode
	button_icon_state = "mech_overload_[chassis.leg_overload_mode ? "on" : "off"]"
	chassis.log_message("Toggled leg actuators overload.", LOG_MECHA)
	if(chassis.leg_overload_mode)
		chassis.movedelay = min(1, round(chassis.movedelay * 0.5))
		chassis.step_energy_drain = max(chassis.overload_step_energy_drain_min,chassis.step_energy_drain*chassis.leg_overload_coeff)
		chassis.balloon_alert(owner,"leg actuators overloaded")
	else
		chassis.movedelay = initial(chassis.movedelay)
		chassis.step_energy_drain = chassis.normal_step_energy_drain
		chassis.balloon_alert(owner, "you disable the overload")
	UpdateButtonIcon()

/datum/action/vehicle/sealed/mecha/mech_smoke
	name = "Smoke"
	button_icon_state = "mech_smoke"

/datum/action/vehicle/sealed/mecha/mech_smoke/Trigger()
	if(!owner || !chassis || !(owner in chassis.occupants))
		return
	if(!TIMER_COOLDOWN_CHECK(src, COOLDOWN_MECHA_SMOKE) && chassis.smoke_charges>0)
		chassis.smoke_system.start()
		chassis.smoke_charges--
		TIMER_COOLDOWN_START(src, COOLDOWN_MECHA_SMOKE, chassis.smoke_cooldown)


/datum/action/vehicle/sealed/mecha/mech_zoom
	name = "Zoom"
	button_icon_state = "mech_zoom_off"

/datum/action/vehicle/sealed/mecha/mech_zoom/Trigger()
	if(!owner || !chassis || !(owner in chassis.occupants))
		return
	if(owner.client)
		chassis.zoom_mode = !chassis.zoom_mode
		button_icon_state = "mech_zoom_[chassis.zoom_mode ? "on" : "off"]"
		chassis.log_message("Toggled zoom mode.", LOG_MECHA)
		to_chat(owner, "[icon2html(chassis, owner)]<font color='[chassis.zoom_mode?"blue":"red"]'>Zoom mode [chassis.zoom_mode?"en":"dis"]abled.</font>")
		if(chassis.zoom_mode)
			owner.client.view_size.setTo(4.5)
			SEND_SOUND(owner, sound('sound/mecha/imag_enh.ogg',volume=50))
		else
			owner.client.view_size.resetToDefault() //Let's not let this stack shall we?
		UpdateButtonIcon()

/datum/action/vehicle/sealed/mecha/mech_switch_damtype
	name = "Reconfigure arm microtool arrays"
	button_icon_state = "mech_damtype_brute"

/datum/action/vehicle/sealed/mecha/mech_switch_damtype/Trigger()
	if(!owner || !chassis || !(owner in chassis.occupants))
		return
	var/new_damtype
	switch(chassis.damtype)
		if(TOX)
			new_damtype = BRUTE
			chassis.balloon_alert(owner, "your punches will now deal brute damage")
		if(BRUTE)
			new_damtype = BURN
			chassis.balloon_alert(owner, "your punches will now deal burn damage")
		if(BURN)
			new_damtype = TOX
			chassis.balloon_alert(owner,"your punches will now deal toxin damage")
	chassis.damtype = new_damtype
	button_icon_state = "mech_damtype_[new_damtype]"
	playsound(chassis, 'sound/mecha/mechmove01.ogg', 50, TRUE)
	UpdateButtonIcon()

/datum/action/vehicle/sealed/mecha/mech_toggle_phasing
	name = "Toggle Phasing"
	button_icon_state = "mech_phasing_off"

/datum/action/vehicle/sealed/mecha/mech_toggle_phasing/Trigger()
	if(!owner || !chassis || !(owner in chassis.occupants))
		return
	chassis.phasing = chassis.phasing ? "" : "phasing"
	button_icon_state = "mech_phasing_[chassis.phasing ? "on" : "off"]"
	chassis.balloon_alert(owner, "[chassis.phasing ? "enabled" : "disabled"] phasing")
	UpdateButtonIcon()

///swap seats, for two person mecha
/datum/action/vehicle/sealed/mecha/swap_seat
	name = "Switch Seats"
	button_icon_state = "mech_seat_swap"

/datum/action/vehicle/sealed/mecha/swap_seat/Trigger()
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

#define SEARCH_COOLDOWN 1 MINUTES

/datum/action/vehicle/sealed/mecha/mech_search_ruins
	name = "Search for Ruins"
	button_icon_state = "mech_search_ruins"
	COOLDOWN_DECLARE(search_cooldown)

/datum/action/vehicle/sealed/mecha/mech_search_ruins/Trigger()
	if(!owner || !chassis || !(owner in chassis.occupants))
		return
	if(!COOLDOWN_FINISHED(src, search_cooldown))
		chassis.balloon_alert(owner, "on cooldown!")
		return
	if(!isliving(owner))
		return
	var/mob/living/living_owner = owner
	button_icon_state = "mech_search_ruins_cooldown"
	UpdateButtonIcon()
	COOLDOWN_START(src, search_cooldown, SEARCH_COOLDOWN)
	addtimer(VARSET_CALLBACK(src, button_icon_state, "mech_search_ruins"), SEARCH_COOLDOWN)
	addtimer(CALLBACK(src, .proc/UpdateButtonIcon), SEARCH_COOLDOWN)
	var/obj/pinpointed_ruin
	for(var/obj/effect/landmark/ruin/ruin_landmark as anything in GLOB.ruin_landmarks)
		if(ruin_landmark.z != chassis.z)
			continue
		if(!pinpointed_ruin || get_dist(ruin_landmark, chassis) < get_dist(pinpointed_ruin, chassis))
			pinpointed_ruin = ruin_landmark
	if(!pinpointed_ruin)
		chassis.balloon_alert(living_owner, "no ruins!")
		return
	var/datum/status_effect/agent_pinpointer/ruin_pinpointer = living_owner.apply_status_effect(/datum/status_effect/agent_pinpointer/ruin)
	ruin_pinpointer.RegisterSignal(living_owner, COMSIG_MOVABLE_MOVED, /datum/status_effect/agent_pinpointer/ruin.proc/cancel_self)
	ruin_pinpointer.scan_target = pinpointed_ruin
	chassis.balloon_alert(living_owner, "pinpointing nearest ruin")

/datum/status_effect/agent_pinpointer/ruin
	duration = SEARCH_COOLDOWN * 0.5
	alert_type = /atom/movable/screen/alert/status_effect/agent_pinpointer/ruin
	tick_interval = 3 SECONDS
	range_fuzz_factor = 0
	minimum_range = 5
	range_mid = 20
	range_far = 50

/datum/status_effect/agent_pinpointer/ruin/scan_for_target()
	return

/datum/status_effect/agent_pinpointer/ruin/proc/cancel_self(datum/source, atom/old_loc)
	SIGNAL_HANDLER

	qdel(src)

/atom/movable/screen/alert/status_effect/agent_pinpointer/ruin
	name = "Ruin Target"
	desc = "Searching for valuables..."

#undef SEARCH_COOLDOWN
