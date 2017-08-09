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

	to_chat(usr, "<span class='adminnotice'>@[target.x],[target.y]: [GM.temperature] Kelvin, [GM.return_pressure()] kPa [(burning)?("\red BURNING"):(null)]</span>")
	for(var/id in GM_gases)
		to_chat(usr, "[GM_gases[id][GAS_META][META_GAS_NAME]]: [GM_gases[id][MOLES]]")
	SSblackbox.add_details("admin_verb","Show Air Status") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

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
	SSblackbox.add_details("admin_verb","Unfreeze Everyone") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!
	return

/client/proc/radio_report()
	set category = "Debug"
	set name = "Radio report"

	var/filters = list(
		"1" = "GLOB.RADIO_TO_AIRALARM",
		"2" = "GLOB.RADIO_FROM_AIRALARM",
		"3" = "GLOB.RADIO_CHAT",
		"4" = "GLOB.RADIO_ATMOSIA",
		"5" = "GLOB.RADIO_NAVBEACONS",
		"6" = "GLOB.RADIO_AIRLOCK",
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
				if (istype(device, /atom))
					var/atom/A = device
					output += "&nbsp;&nbsp;&nbsp;&nbsp;[device] ([A.x],[A.y],[A.z] in area [get_area(device)])<br>"
				else
					output += "&nbsp;&nbsp;&nbsp;&nbsp;[device]<br>"

	usr << browse(output,"window=radioreport")
	SSblackbox.add_details("admin_verb","Show Radio Report") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/client/proc/reload_admins()
	set name = "Reload Admins"
	set category = "Admin"

	if(!src.holder)
		return

	var/confirm = alert(src, "Are you sure you want to reload all admins?", "Confirm", "Yes", "No")
	if(confirm !="Yes")
		return

	load_admins()
	SSblackbox.add_details("admin_verb","Reload All Admins") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!
	message_admins("[key_name_admin(usr)] manually reloaded admins")
