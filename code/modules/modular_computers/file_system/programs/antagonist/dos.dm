/datum/computer_file/program/ntnet_dos
	filename = "ntn_dos"
	filedesc = "DoS Traffic Generator"
	program_icon_state = "hostile"
	extended_desc = "This advanced script can perform denial of service attacks against NTNet quantum relays. The system administrator will probably notice this. Multiple devices can run this program together against same relay for increased effect"
	size = 20
	requires_ntnet = 1
	available_on_ntnet = 0
	available_on_syndinet = 1
	var/obj/machinery/ntnet_relay/target = null
	var/dos_speed = 0
	var/error = ""
	var/executed = 0

/datum/computer_file/program/ntnet_dos/process_tick()
	dos_speed = 0
	switch(ntnet_status)
		if(1)
			dos_speed = NTNETSPEED_LOWSIGNAL * 10
		if(2)
			dos_speed = NTNETSPEED_HIGHSIGNAL * 10
		if(3)
			dos_speed = NTNETSPEED_ETHERNET * 10
	if(target && executed)
		target.dos_overload += dos_speed
		if(!target.is_operational())
			target.dos_sources.Remove(src)
			target = null
			error = "Connection to destination relay lost."

/datum/computer_file/program/ntnet_dos/kill_program(forced = FALSE)
	if(target)
		target.dos_sources.Remove(src)
	target = null
	executed = 0

	..()


/datum/computer_file/program/ntnet_dos/ui_interact(mob/user, ui_key = "main", datum/tgui/ui = null, force_open = 0, datum/tgui/master_ui = null, datum/ui_state/state = GLOB.default_state)

	ui = SStgui.try_update_ui(user, src, ui_key, ui, force_open)
	if (!ui)
		ui = new(user, src, ui_key, "ntnet_dos", "DoS Traffic Generator", 400, 250, state = state)
		ui.set_style("syndicate")
		ui.set_autoupdate(state = 1)
		ui.open()



/datum/computer_file/program/ntnet_dos/ui_act(action, params)
	if(..())
		return 1
	switch(action)
		if("PRG_target_relay")
			for(var/obj/machinery/ntnet_relay/R in GLOB.ntnet_global.relays)
				if("[R.uid]" == params["targid"])
					target = R
			return 1
		if("PRG_reset")
			if(target)
				target.dos_sources.Remove(src)
				target = null
			executed = 0
			error = ""
			return 1
		if("PRG_execute")
			if(target)
				executed = 1
				target.dos_sources.Add(src)
				if(GLOB.ntnet_global.intrusion_detection_enabled)
					var/obj/item/weapon/computer_hardware/network_card/network_card = computer.all_components[MC_NET]
					GLOB.ntnet_global.add_log("IDS WARNING - Excess traffic flood targeting relay [target.uid] detected from device: [network_card.get_network_tag()]")
					GLOB.ntnet_global.intrusion_detection_alarm = 1
			return 1

/datum/computer_file/program/ntnet_dos/ui_data(mob/user)
	if(!GLOB.ntnet_global)
		return

	var/list/data = list()

	data = get_header_data()

	if(error)
		data["error"] = error
	else if(target && executed)
		data["target"] = 1
		data["speed"] = dos_speed

		// This is mostly visual, generate some strings of 1s and 0s
		// Probability of 1 is equal of completion percentage of DoS attack on this relay.
		// Combined with UI updates this adds quite nice effect to the UI
		var/percentage = target.dos_overload * 100 / target.dos_capacity
		data["dos_strings"] = list()
		for(var/j, j<10, j++)
			var/string = ""
			for(var/i, i<20, i++)
				string = "[string][prob(percentage)]"
			data["dos_strings"] += list(list("nums" = string))
	else
		data["relays"] = list()
		for(var/obj/machinery/ntnet_relay/R in GLOB.ntnet_global.relays)
			data["relays"] += list(list("id" = R.uid))
		data["focus"] = target ? target.uid : null

	return data