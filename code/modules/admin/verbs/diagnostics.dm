/client/proc/air_status(turf/target)
	set category = "Debug"
	set name = "Display Air Status"

	if(!isturf(target))
		return

	var/datum/gas_mixture/GM = target.return_air()
	var/list/GM_gases
	var/burning = 0
	if(isopenturf(target))
		var/turf/open/T = target
		if(T.active_hotspot)
			burning = 1

	usr << "<span class='adminnotice'>@[target.x],[target.y]: [GM.temperature] Kelvin, [GM.return_pressure()] kPa [(burning)?("\red BURNING"):(null)]</span>"
	for(var/id in GM_gases)
		usr << "[GM_gases[id][GAS_META][META_GAS_NAME]]: [GM_gases[id][MOLES]]"
	feedback_add_details("admin_verb","DAST") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/client/proc/fix_next_move()
	set category = "Debug"
	set name = "Unfreeze Everyone"
	var/largest_move_time = 0
	var/largest_click_time = 0
	var/mob/largest_move_mob = null
	var/mob/largest_click_mob = null
	for(var/mob/M in world)
		if(!M.client)
			continue
		if(M.next_move >= largest_move_time)
			largest_move_mob = M
			if(M.next_move > world.time)
				largest_move_time = M.next_move - world.time
			else
				largest_move_time = 1
		if(M.next_click >= largest_click_time)
			largest_click_mob = M
			if(M.next_click > world.time)
				largest_click_time = M.next_click - world.time
			else
				largest_click_time = 0
		log_admin("DEBUG: [key_name(M)]  next_move = [M.next_move]  lastDblClick = [M.next_click]  world.time = [world.time]")
		M.next_move = 1
		M.next_click = 0
	message_admins("[key_name_admin(largest_move_mob)] had the largest move delay with [largest_move_time] frames / [largest_move_time/10] seconds!")
	message_admins("[key_name_admin(largest_click_mob)] had the largest click delay with [largest_click_time] frames / [largest_click_time/10] seconds!")
	message_admins("world.time = [world.time]")
	feedback_add_details("admin_verb","UFE") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!
	return

/client/proc/radio_report()
	set category = "Debug"
	set name = "Radio report"

	var/filters = list(
		"1" = "RADIO_TO_AIRALARM",
		"2" = "RADIO_FROM_AIRALARM",
		"3" = "RADIO_CHAT",
		"4" = "RADIO_ATMOSIA",
		"5" = "RADIO_NAVBEACONS",
		"6" = "RADIO_AIRLOCK",
		"7" = "RADIO_SECBOT",
		"8" = "RADIO_MULEBOT",
		"_default" = "NO_FILTER"
		)
	var/output = "<b>Radio Report</b><hr>"
	for (var/fq in SSradio.frequencies)
		output += "<b>Freq: [fq]</b><br>"
		var/list/datum/radio_frequency/fqs = SSradio.frequencies[fq]
		if (!fqs)
			output += "&nbsp;&nbsp;<b>ERROR</b><br>"
			continue
		for (var/filter in fqs.devices)
			var/list/f = fqs.devices[filter]
			if (!f)
				output += "&nbsp;&nbsp;[filters[filter]]: ERROR<br>"
				continue
			output += "&nbsp;&nbsp;[filters[filter]]: [f.len]<br>"
			for (var/device in f)
				if (isobj(device))
					output += "&nbsp;&nbsp;&nbsp;&nbsp;[device] ([device:x],[device:y],[device:z] in area [get_area(device:loc)])<br>"
				else
					output += "&nbsp;&nbsp;&nbsp;&nbsp;[device]<br>"

	usr << browse(output,"window=radioreport")
	feedback_add_details("admin_verb","RR") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/client/proc/reload_admins()
	set name = "Reload Admins"
	set category = "Admin"

	if(!src.holder)
		return

	var/confirm = alert(src, "Are you sure you want to reload all admins?", "Confirm", "Yes", "No")
	if(confirm !="Yes")
		return

	load_admins()
	feedback_add_details("admin_verb","RLDA") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!
	message_admins("[key_name_admin(usr)] manually reloaded admins")
