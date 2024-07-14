///Checks whether NTNet is available by ensuring at least one relay exists and is operational.
/proc/find_functional_ntnet_relay()
	// Check all relays. If we have at least one working relay, ntos is up.
	for(var/obj/machinery/ntnet_relay/relays as anything in SSmachines.get_machines_by_type(/obj/machinery/ntnet_relay))
		if(!relays.is_operational)
			continue
		return TRUE
	return FALSE

// Relays don't handle any actual communication. Global NTNet datum does that, relays only tell the datum if it should or shouldn't work.
/obj/machinery/ntnet_relay
	name = "NTNet Quantum Relay"
	desc = "A very complex router and transmitter capable of connecting electronic devices together. Looks fragile."
	use_power = ACTIVE_POWER_USE
	active_power_usage = BASE_MACHINE_ACTIVE_CONSUMPTION * 10 //10kW, apropriate for machine that keeps massive cross-Zlevel wireless network operational. Used to be 20 but that actually drained the smes one round
	icon = 'icons/obj/machines/telecomms.dmi'
	icon_state = "bus"
	density = TRUE
	circuit = /obj/item/circuitboard/machine/ntnet_relay

	///On / off status for the relay machine, toggleable by the user.
	var/relay_enabled = TRUE
	///(D)DoS-attack-related failure causing it not to be operational any longer.
	var/dos_failure = FALSE
	var/list/dos_sources = list() // Backwards reference for qdel() stuff
	var/uid
	var/static/gl_uid = 1

	// Denial of Service attack variables
	var/dos_overload = 0 // Amount of DoS "packets" in this relay's buffer
	var/dos_capacity = 500 // Amount of DoS "packets" in buffer required to crash the relay
	var/dos_dissipate = 0.5 // Amount of DoS "packets" dissipated over time.

/obj/machinery/ntnet_relay/Initialize(mapload)
	. = ..()
	uid = gl_uid++
	var/list/current_machines = SSmachines.get_machines_by_type(/obj/machinery/ntnet_relay)
	SSmodular_computers.add_log("New quantum relay activated. Current amount of linked relays: [current_machines.len]")

/obj/machinery/ntnet_relay/Destroy()
	. = ..()
	var/list/machines_left = SSmachines.get_machines_by_type(/obj/machinery/ntnet_relay)
	SSmodular_computers.add_log("Quantum relay connection severed. Current amount of linked relays: [machines_left.len]")
	for(var/datum/computer_file/program/ntnet_dos/D in dos_sources)
		D.target = null
		D.error = "Connection to quantum relay severed"

///Proc called to change the value of the `relay_enabled` variable and append behavior related to its change.
/obj/machinery/ntnet_relay/proc/set_relay_enabled(new_value)
	if(new_value == relay_enabled)
		return
	. = relay_enabled
	relay_enabled = new_value
	if(.) //Turned off
		set_is_operational(FALSE)
	else if(!dos_failure && !(machine_stat & (NOPOWER|BROKEN|MAINT))) //Turned on
		set_is_operational(TRUE)

///Proc called to change the value of the `dos_failure` variable and append behavior related to its change.
/obj/machinery/ntnet_relay/proc/set_dos_failure(new_value)
	if(new_value == dos_failure)
		return
	. = dos_failure
	dos_failure = new_value
	if(.) //Failure ended
		if(relay_enabled && !(machine_stat & (NOPOWER|BROKEN|MAINT)))
			set_is_operational(TRUE)
	else //Failure started
		set_is_operational(FALSE)

/obj/machinery/ntnet_relay/on_set_machine_stat(old_value)
	if(old_value & (NOPOWER|BROKEN|MAINT))
		if(relay_enabled && !dos_failure && !(machine_stat & (NOPOWER|BROKEN|MAINT))) //From off to on.
			set_is_operational(TRUE)
	else if(machine_stat & (NOPOWER|BROKEN|MAINT)) //From on to off.
		set_is_operational(FALSE)

/obj/machinery/ntnet_relay/update_icon_state()
	icon_state = "bus[is_operational ? null : "_off"]"
	return ..()

/obj/machinery/ntnet_relay/process(seconds_per_tick)
	update_use_power(is_operational ? ACTIVE_POWER_USE : IDLE_POWER_USE)

	update_appearance()

	if(dos_overload > 0)
		dos_overload = max(0, dos_overload - dos_dissipate * seconds_per_tick)

	// If DoS traffic exceeded capacity, crash.
	if((dos_overload > dos_capacity) && !dos_failure)
		set_dos_failure(TRUE)
		update_appearance()
		SSmodular_computers.add_log("Quantum relay switched from normal operation mode to overload recovery mode.")
	// If the DoS buffer reaches 0 again, restart.
	if((dos_overload == 0) && dos_failure)
		set_dos_failure(FALSE)
		update_appearance()
		SSmodular_computers.add_log("Quantum relay switched from overload recovery mode to normal operation mode.")
	return TRUE

/obj/machinery/ntnet_relay/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "NtnetRelay")
		ui.open()

/obj/machinery/ntnet_relay/ui_data(mob/user)
	var/list/data = list()
	data["enabled"] = relay_enabled
	data["dos_capacity"] = dos_capacity
	data["dos_overload"] = dos_overload
	data["dos_crashed"] = dos_failure
	return data

/obj/machinery/ntnet_relay/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if(.)
		return
	switch(action)
		if("restart")
			dos_overload = 0
			set_dos_failure(FALSE)
			update_appearance()
			SSmodular_computers.add_log("Quantum relay manually restarted from overload recovery mode to normal operation mode.")
			return TRUE
		if("toggle")
			set_relay_enabled(!relay_enabled)
			SSmodular_computers.add_log("Quantum relay manually [relay_enabled ? "enabled" : "disabled"].")
			update_appearance()
			return TRUE
