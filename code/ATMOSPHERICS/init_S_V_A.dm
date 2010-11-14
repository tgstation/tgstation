datum/controller/game_controller
	proc/find_air_alarms()
		var/list/processed_areas = list()
		for(var/area/A in world)
			if(A in processed_areas) continue
			processed_areas += connect_area_atmos_machinery(A)
		return


/proc/connect_area_atmos_machinery(var/area/A)
	var/area/M = A.master //we want to search master area, not only L(number) one

	var/uniq_id = md5(M.name)//hash works like a charm
	var/list/alarms = list()
	var/list/scrubbers = list()
	var/list/vents = list()
	var/list/processed_areas = list()
	var/i = 0 //used in id_tag and name generation

	if(M.related && M.related.len)//if has relatives
		for(var/area/Rel in M.related)//check all relatives
			if(Rel == M) continue //same parent area.
			processed_areas += Rel
			if(Rel.contents && Rel.contents.len)
				for(var/obj/machinery/O in Rel.contents)
					switch(O.type)
						if(/obj/machinery/alarm)
							alarms += O
						if(/obj/machinery/atmospherics/unary/vent_scrubber)
							if(O:id_tag) continue
							scrubbers += O
						if(/obj/machinery/atmospherics/unary/vent_pump)
							if(O:id) continue
							vents += O
						else continue
/*
				for(var/obj/machinery/alarm/Al in Rel.contents)//find air alarms in area, append to list
					alarms += Al
				for(var/obj/machinery/atmospherics/unary/vent_scrubber/V in Rel.contents)//find scrubbers in area, append to list
					if(V.id_tag) continue//already connected to air alarm
					scrubbers += V
				for(var/obj/machinery/atmospherics/unary/vent_pump/P in Rel.contents)
					if(P.id) continue
					vents += P
*/

	if(!alarms.len || (!scrubbers.len && !vents.len)) return

	i = 0
	if(scrubbers.len) //if scrubbers found in area
		for(var/obj/machinery/atmospherics/unary/vent_scrubber/Sc in scrubbers)//iterate over found scrubbers
//					if(Sc.id_tag) continue
			var/dist = 127 //max value returned by get_dist
			var/obj/machinery/alarm/target_alarm = null
			for(var/obj/machinery/alarm/Al in alarms)//iterate over found alarms
				var/temp_dist = get_dist(Sc.loc, Al.loc)//if distance between current scrubber and current alarm < previous distance, set this alarm as target to connect to
				if(temp_dist<dist)
					target_alarm = Al
					dist = temp_dist
			if(target_alarm) //if target(closest) air alarm found,
				Sc.id_tag = "[uniq_id]_scr_[i++]" //set scrubber id_tag
				Sc.frequency = target_alarm.frequency //set scrubber frequency (alarm frequency)
				var/d_name = "[M.name] Air Scrubber #[i]" //displayed name
				target_alarm.sensors[Sc.id_tag] = d_name //append scrubber to alarm 'sensors' list
				Sc.name = d_name //set scrubber name
				Sc.set_frequency(Sc.frequency)
				//debug
				//world << "[Sc.name] in [M.name] is set to frequency [Sc.frequency] with ID [Sc.id_tag]"
				//debug
	i = 0
	if(vents.len) //if vents found in area
		for(var/obj/machinery/atmospherics/unary/vent_pump/P in vents)//iterate over found vents
//					if(P.id) continue
			var/dist = 127 //max value returned by get_dist
			var/obj/machinery/alarm/target_alarm = null
			for(var/obj/machinery/alarm/Al in alarms)//iterate over found alarms
				var/temp_dist = get_dist(P.loc, Al.loc)//if distance between current vent and current alarm < previous distance, set this alarm as target to connect to
				if(temp_dist<dist)
					target_alarm = Al
					dist = temp_dist
			if(target_alarm) //if target(closest) air alarm found,
				P.id = "[uniq_id]_vpump_[i++]" //set vent id
				P.frequency = target_alarm.frequency //set vent frequency (alarm frequency)
				var/d_name = "[M.name] Vent Pump #[i]" //displayed name
				target_alarm.vents[P.id] = d_name //append vent to alarm 'vents' list
				P.name = d_name //set vent name
				P.set_frequency(P.frequency)
				//debug
				//world << "[Sc.name] in [M.name] is set to frequency [Sc.frequency] with ID [Sc.id_tag]"
				//debug

	return processed_areas