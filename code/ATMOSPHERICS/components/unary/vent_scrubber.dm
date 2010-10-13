/obj/machinery/atmospherics/unary/vent_scrubber
	icon = 'vent_scrubber.dmi'
	icon_state = "off"

	name = "Air Scrubber"
	desc = "Has a valve and pump attached to it"

	level = 1

	var/id_tag = null
	var/frequency = 1439
	var/datum/radio_frequency/radio_connection

	var/on = 0
	var/scrubbing = 1 //0 = siphoning, 1 = scrubbing
	var/scrub_CO2 = 1
	var/scrub_Toxins = 0

	var/volume_rate = 120
	var/panic = 0 //is this scrubber panicked?

	update_icon()
		if(on)//&&node)//seems to be broken
			if(scrubbing)
				icon_state = "[level == 1 && istype(loc, /turf/simulated) ? "h" : "" ]on"
			else
				icon_state = "[level == 1 && istype(loc, /turf/simulated) ? "h" : "" ]in"
		else
			icon_state = "[level == 1 && istype(loc, /turf/simulated) ? "h" : "" ]off"
			//on = 0

		return


	proc
		set_frequency(new_frequency)
			radio_controller.remove_object(src, "[frequency]")
			frequency = new_frequency
			radio_connection = radio_controller.add_object(src, "[frequency]")

		broadcast_status()
			if(!radio_connection)
				return 0

			var/datum/signal/signal = new
			signal.transmission_method = 1 //radio signal
			signal.data["tag"] = id_tag
			signal.data["timestamp"] = air_master.current_cycle
			signal.data["on"] = on
			signal.data["scrubbing"] = scrubbing
			signal.data["panic"] = panic
			signal.data["filter_co2"] = scrub_CO2
			signal.data["filter_toxins"] = scrub_Toxins
			radio_connection.post_signal(src, signal)

			return 1

		//This is probably not a good place for this, since it messes with all scrubbers and alarms in area. Maybe it's better to move this to area code.
		//It has its issues. Just place additional air alarm closer to the scrubbers, or assign scrubbers manually
		find_air_alarm()
			if(src.id_tag) return //id_tag assigned
			var/area/A = get_area(loc)
			var/area/M = A.master //we want to search master area, not only L(number) one

			var/uniq_id = md5(M.name)//hash works like a charm
			var/list/alarms = list()
			var/list/scrubbers = list()
			var/i = 0 //used in id_tag and scrubber name generation

			if(M.related && M.related.len)//if has relatives
				for(var/area/Rel in M.related)//check all relatives
					if(Rel == M) continue //same parent area.
					if(Rel.contents && Rel.contents.len)
						for(var/obj/machinery/alarm/Al in Rel.contents)//find air alarms in area, append to list
							alarms += Al
						for(var/obj/machinery/atmospherics/unary/vent_scrubber/V in Rel.contents)//find scrubbers in area, append to list
							if(V.id_tag) continue//already connected to air alarm
							scrubbers += V

			if(scrubbers.len&&alarms.len) //if scrubbers & alarms found in area
				for(var/obj/machinery/atmospherics/unary/vent_scrubber/Sc in scrubbers)//iterate over found scrubbers
					var/dist = 127 //max value returned by get_dist
					var/obj/machinery/alarm/target_alarm = null
					for(var/obj/machinery/alarm/Al in alarms)//iterate over found alarms
						var/temp_dist = get_dist(Sc.loc, Al.loc)//if distance between current scrubber and current alarm < previous distance, set this alarm as target to connect to
						if(temp_dist<dist)
							target_alarm = Al
							dist = temp_dist
					if(target_alarm) //if target(closest) air alarm found,
						Sc.id_tag = "[uniq_id]_[i++]" //set scrubber id_tag
						Sc.frequency = target_alarm.frequency //set scrubber frequency (alarm frequency)
						var/d_name = "[M.name] Air Scrubber #[i]" //displayed name
						target_alarm.sensors[Sc.id_tag] = d_name //append scrubber to alarm 'sensor' list
						Sc.name = d_name //set scrubber name
						//debug
						//world << "[Sc.name] in [M.name] is set to frequency [Sc.frequency] with ID [Sc.id_tag]"
						//debug

	initialize()
		find_air_alarm()
		set_frequency(frequency)
		update_icon()


	process()
		..()
		if(!(stat & (NOPOWER|BROKEN)))
			broadcast_status()
		else
			return 0

		if(!on)
			return 0

		var/datum/gas_mixture/environment = loc.return_air()

		if(scrubbing)
			if((environment.toxins>0) || (environment.carbon_dioxide>0) || (environment.trace_gases.len>0))
				var/transfer_moles = min(1, volume_rate/environment.volume)*environment.total_moles()

				//Take a gas sample
				var/datum/gas_mixture/removed = loc.remove_air(transfer_moles)

				//Filter it
				var/datum/gas_mixture/filtered_out = new
				filtered_out.temperature = removed.temperature
				if(scrub_Toxins)
					filtered_out.toxins = removed.toxins
					removed.toxins = 0
				if(scrub_CO2)
					filtered_out.carbon_dioxide = removed.carbon_dioxide
					removed.carbon_dioxide = 0

				if(removed.trace_gases.len>0)
					for(var/datum/gas/trace_gas in removed.trace_gases)
						if(istype(trace_gas, /datum/gas/oxygen_agent_b))
							removed.trace_gases -= trace_gas
							filtered_out.trace_gases += trace_gas

				//Remix the resulting gases
				air_contents.merge(filtered_out)

				loc.assume_air(removed)

				if(network)
					network.update = 1

		else //Just siphoning all air
			var/transfer_moles = environment.total_moles()*(volume_rate/environment.volume)

			var/datum/gas_mixture/removed = loc.remove_air(transfer_moles)

			air_contents.merge(removed)

			if(network)
				network.update = 1

		return 1
/* //unused piece of code
	hide(var/i) //to make the little pipe section invisible, the icon changes.
		if(on&&node)
			if(scrubbing)
				icon_state = "[i == 1 && istype(loc, /turf/simulated) ? "h" : "" ]on"
			else
				icon_state = "[i == 1 && istype(loc, /turf/simulated) ? "h" : "" ]in"
		else
			icon_state = "[i == 1 && istype(loc, /turf/simulated) ? "h" : "" ]off"
			on = 0
		return
*/

	receive_signal(datum/signal/signal)
		if(signal.data["tag"] && (signal.data["tag"] != id_tag))
			return ..()

		switch(signal.data["command"])
			if("toggle_power")
				on = !on
			if("toggle_scrubbing")
				scrubbing = !scrubbing
			if("toggle_co2_scrub")
				scrub_CO2 = !scrub_CO2
			if("toggle_tox_scrub")
				scrub_Toxins = !scrub_Toxins
			if("toggle_panic_siphon")
				panic = !panic
				if(panic)
					on = 1
					scrubbing = 0
					volume_rate = 2000
				else
					scrubbing = 1
					volume_rate = 120

		if(signal.data["tag"])
			spawn(2) broadcast_status()
		update_icon()
		return ..()
