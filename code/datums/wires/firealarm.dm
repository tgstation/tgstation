/datum/wires/firealarm
	holder_type = /obj/machinery/firealarm
	proper_name = "Fire Alarm"

/datum/wires/firealarm/New(atom/holder)
	wires = list(
		WIRE_FIRE_DETECT, // toggles whether it can activate automatically
		WIRE_FIRE_RESET, // resets fire alarm
		WIRE_FIRE_TRIGGER, // triggers fire alarm
	)
	add_duds(1)
	return ..()

/datum/wires/firealarm/interactable(mob/user)
	var/obj/machinery/firealarm/alarm = holder
	return ..() && alarm.panel_open && alarm.buildstage == FIRE_ALARM_BUILD_SECURED

/datum/wires/firealarm/get_status()
	var/obj/machinery/airalarm/alarm = holder
	var/list/status = list()
	status += "The thermal sensor light is [alarm.my_area?.fire_detect ? "on" : "off"]."
	return status

/datum/wires/firealarm/on_pulse(wire, mob/living/user)
	var/obj/machinery/firealarm/alarm = holder
	switch(wire)
		if(WIRE_FIRE_DETECT)
			alarm.toggle_fire_detect(user, silent = TRUE)
		if(WIRE_FIRE_TRIGGER)
			alarm.alarm(user, silent = TRUE)
		if(WIRE_FIRE_RESET)
			alarm.reset(user, silent = TRUE)

/datum/wires/firealarm/on_cut(wire, mend, mob/living/source)
	var/obj/machinery/firealarm/alarm = holder
	switch(wire)
		if(WIRE_FIRE_DETECT)
			// blocks multitool toggle, though wirecutter toggle "bypasses" this
			alarm.can_toggle_detection = !mend
			var/num_cut = 0
			for(var/obj/machinery/firealarm/firealarm in alarm.my_area?.firealarms)
				if(WIRE_FIRE_DETECT in firealarm.wires?.cut_wires)
					num_cut += 1
			// if mending, restore fire detection
			if(mend)
				alarm.enable_fire_detect(source)
			// or if cutting and all fire alarms in the area are cut, disable fire detection
			else if(length(alarm.my_area?.firealarms) == num_cut)
				alarm.disable_fire_detect(source)
		if(WIRE_FIRE_TRIGGER)
			// does not reset() or alarm() - it's now stuck on or off
			alarm.can_trigger = !mend
		if(WIRE_FIRE_RESET)
			// does not reset() or alarm() - it's now stuck on or off
			alarm.can_reset = !mend

/datum/wires/firealarm/always_reveal_wire(color)
	// to maintain previous behavior of "anyone can multitool a fire alarm to disable it"
	return get_color_of_wire(WIRE_FIRE_DETECT) == color
