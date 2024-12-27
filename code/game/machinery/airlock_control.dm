// This code allows for airlocks to be controlled externally by setting an id_tag and comm frequency (disables ID access)
/obj/machinery/door/airlock
	opens_with_door_remote = TRUE

	/// The current state of the airlock, used to construct the airlock overlays
	var/airlock_state
	var/frequency

/// Forces the airlock to unbolt and open
/obj/machinery/door/airlock/proc/secure_open()
	locked = FALSE
	update_appearance()

	stoplag(0.2 SECONDS)
	open(FORCING_DOOR_CHECKS)

	locked = TRUE
	update_appearance()

/// Forces the airlock to close and bolt
/obj/machinery/door/airlock/proc/secure_close(force_crush = FALSE)
	locked = FALSE
	close(forced = TRUE, force_crush = force_crush)

	locked = TRUE
	stoplag(0.2 SECONDS)
	update_appearance()

/obj/machinery/door/airlock/on_magic_unlock(datum/source, datum/action/cooldown/spell/aoe/knock/spell, mob/living/caster)
	// Airlocks should unlock themselves when knock is casted, THEN open up.
	locked = FALSE
	return ..()

/obj/machinery/airlock_sensor
	icon = 'icons/obj/machines/wallmounts.dmi'
	icon_state = "airlock_sensor_off"
	base_icon_state = "airlock_sensor"
	name = "airlock sensor"
	resistance_flags = FIRE_PROOF

	power_channel = AREA_USAGE_ENVIRON

	var/master_tag

	var/on = TRUE
	var/alert = FALSE

/obj/machinery/airlock_sensor/incinerator_ordmix
	id_tag = INCINERATOR_ORDMIX_AIRLOCK_SENSOR
	master_tag = INCINERATOR_ORDMIX_AIRLOCK_CONTROLLER

/obj/machinery/airlock_sensor/incinerator_atmos
	id_tag = INCINERATOR_ATMOS_AIRLOCK_SENSOR
	master_tag = INCINERATOR_ATMOS_AIRLOCK_CONTROLLER

/obj/machinery/airlock_sensor/incinerator_syndicatelava
	id_tag = INCINERATOR_SYNDICATELAVA_AIRLOCK_SENSOR
	master_tag = INCINERATOR_SYNDICATELAVA_AIRLOCK_CONTROLLER

/obj/machinery/airlock_sensor/update_icon_state()
	if(!on)
		icon_state = "[base_icon_state]_off"
	else
		if(alert)
			icon_state = "[base_icon_state]_alert"
		else
			icon_state = "[base_icon_state]_standby"
	return ..()

/obj/machinery/airlock_sensor/attack_hand(mob/user, list/modifiers)
	. = ..()
	if(.)
		return

	var/obj/machinery/airlock_controller/airlock_controller = GLOB.objects_by_id_tag[master_tag]
	airlock_controller?.cycle()

	flick("airlock_sensor_cycle", src)

/obj/machinery/airlock_sensor/process()
	if(on)
		var/datum/gas_mixture/air_sample = return_air()
		var/pressure = round(air_sample.return_pressure(),0.1)
		alert = (pressure < ONE_ATMOSPHERE*0.8)

	update_appearance()
