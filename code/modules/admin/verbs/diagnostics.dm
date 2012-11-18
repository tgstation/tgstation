/client/proc
	general_report()
		set category = "Debug"
		set name = "Show General Report"

		if(!master_controller)
			usr << alert("Master_controller not found.")

		var/mobs = 0
		for(var/mob/M in mob_list)
			mobs++

		var/output = {"<B>GENERAL SYSTEMS REPORT</B><HR>
<B>General Processing Data</B><BR>
<B># of Machines:</B> [machines.len]<BR>
<B># of Pipe Networks:</B> [pipe_networks.len]<BR>
<B># of Processing Items:</B> [processing_objects.len]<BR>
<B># of Power Nets:</B> [powernets.len]<BR>
<B># of Mobs:</B> [mobs]<BR>
"}

		usr << browse(output,"window=generalreport")
		feedback_add_details("admin_verb","SGR") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

//todo:
	air_report()
		set category = "Debug"
		set name = "Show Air Report"

		usr << "\red This proc is unavailable."
		/*
		if(!master_controller || !air_master)
			alert(usr,"Master_controller or air_master not found.","Air Report")
			return 0

		var/active_groups = 0
		var/inactive_groups = 0
		var/active_tiles = 0
		for(var/datum/air_group/group in air_master.air_groups)
			if(group.group_processing)
				active_groups++
			else
				inactive_groups++
				active_tiles += group.members.len

		var/hotspots = 0
		for(var/obj/effect/hotspot/hotspot in world)
			hotspots++

		var/output = {"<B>AIR SYSTEMS REPORT</B><HR>
<B>General Processing Data</B><BR>
<B># of Groups:</B> [air_master.air_groups.len]<BR>
---- <I>Active:</I> [active_groups]<BR>
---- <I>Inactive:</I> [inactive_groups]<BR>
-------- <I>Tiles:</I> [active_tiles]<BR>
<B># of Active Singletons:</B> [air_master.active_singletons.len]<BR>
<BR>
<B>Special Processing Data</B><BR>
<B>Hotspot Processing:</B> [hotspots]<BR>
<B>High Temperature Processing:</B> [air_master.active_super_conductivity.len]<BR>
<B>High Pressure Processing:</B> [air_master.high_pressure_delta.len] (not yet implemented)<BR>
<BR>
<B>Geometry Processing Data</B><BR>
<B>Group Rebuild:</B> [air_master.groups_to_rebuild.len]<BR>
<B>Tile Update:</B> [air_master.tiles_to_update.len]<BR>
"}

		usr << browse(output,"window=airreport")
		feedback_add_details("admin_verb","SAR") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!
		*/

//todo:
	air_status(turf/target as turf)
		set category = "Debug"
		set name = "Display Air Status"

		usr << "\red This proc is unavailable."
		/*
		if(!isturf(target))
			return

		var/datum/gas_mixture/GM = target.return_air()
		var/burning = 0
		if(istype(target, /turf/simulated))
			var/turf/simulated/T = target
			if(T.active_hotspot)
				burning = 1

		usr << "\blue @[target.x],[target.y] ([GM.group_multiplier]): O:[GM.oxygen] T:[GM.toxins] N:[GM.nitrogen] C:[GM.carbon_dioxide] w [GM.temperature] Kelvin, [GM.return_pressure()] kPa [(burning)?("\red BURNING"):(null)]"
		for(var/datum/gas/trace_gas in GM.trace_gases)
			usr << "[trace_gas.type]: [trace_gas.moles]"
		feedback_add_details("admin_verb","DAST") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!
		*/

	fix_next_move()
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
			if(M.lastDblClick >= largest_click_time)
				largest_click_mob = M
				if(M.lastDblClick > world.time)
					largest_click_time = M.lastDblClick - world.time
				else
					largest_click_time = 0
			log_admin("DEBUG: [key_name(M)]  next_move = [M.next_move]  lastDblClick = [M.lastDblClick]  world.time = [world.time]")
			M.next_move = 1
			M.lastDblClick = 0
		message_admins("[key_name_admin(largest_move_mob)] had the largest move delay with [largest_move_time] frames / [largest_move_time/10] seconds!", 1)
		message_admins("[key_name_admin(largest_click_mob)] had the largest click delay with [largest_click_time] frames / [largest_click_time/10] seconds!", 1)
		message_admins("world.time = [world.time]", 1)
		feedback_add_details("admin_verb","UFE") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!
		return

	radio_report()
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
		for (var/fq in radio_controller.frequencies)
			output += "<b>Freq: [fq]</b><br>"
			var/list/datum/radio_frequency/fqs = radio_controller.frequencies[fq]
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

	reload_admins()
		set name = "Reload Admins"
		set category = "Debug"

		if(!(usr.client.holder && usr.client.holder.level >= 6)) // protect and prevent
			usr << "\red Not a good cop"
			return

		message_admins("[usr] manually reloaded admins.txt and moderators.txt")
		usr << "You reload admins.txt and moderators.txt"
		world.load_admins()
		world.load_mods()
		feedback_add_details("admin_verb","RLDA") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

//todo:
	jump_to_dead_group()
		set name = "Jump to dead group"
		set category = "Debug"

		usr << "\red This proc is unavailable."
		/*
		if(!holder)
			src << "Only administrators may use this command."
			return

		if(!air_master)
			usr << "Cannot find air_system"
			return
		var/datum/air_group/dead_groups = list()
		for(var/datum/air_group/group in air_master.air_groups)
			if (!group.group_processing)
				dead_groups += group
		var/datum/air_group/dest_group = pick(dead_groups)
		usr.loc = pick(dest_group.members)
		feedback_add_details("admin_verb","JDAG") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!
		return
		*/

	kill_airgroup()
		set name = "Kill Local Airgroup"
		set desc = "Use this to allow manual manupliation of atmospherics."
		set category = "Debug"
		usr << "\red This proc is unavailable."
		/*
		if(!holder)
			src << "Only administrators may use this command."
			return

		if(!air_master)
			usr << "Cannot find air_system"
			return

		var/turf/T = get_turf(usr)
		if(istype(T, /turf/simulated))
			var/datum/air_group/AG = T:parent
			AG.next_check = 30
			AG.group_processing = 0
		else
			usr << "Local airgroup is unsimulated!"
		feedback_add_detail("admin_verb","KLAG") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!
		*/
