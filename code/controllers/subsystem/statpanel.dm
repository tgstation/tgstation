SUBSYSTEM_DEF(statpanels)
	name = "Stat Panels"
	wait = 4
	init_order = INIT_ORDER_STATPANELS
	runlevels = RUNLEVELS_DEFAULT | RUNLEVEL_LOBBY
	var/list/currentrun = list()
	var/encoded_global_data
	var/mc_data_encoded

/datum/controller/subsystem/statpanels/fire(resumed = 0)
	if (!resumed)
		var/datum/map_config/cached = SSmapping.next_map_config
		var/round_time = world.time - SSticker.round_start_time
		var/list/global_data = list(
			"Map: [SSmapping.config?.map_name || "Loading..."]",
			cached ? "Next Map: [cached.map_name]" : null,
			"Round ID: [GLOB.round_id ? GLOB.round_id : "NULL"]",
			"Server Time: [time2text(world.timeofday, "YYYY-MM-DD hh:mm:ss")]",
			"Round Time: [round_time > MIDNIGHT_ROLLOVER ? "[round(round_time/MIDNIGHT_ROLLOVER)]:[worldtime2text()]" : worldtime2text()]",
			"Station Time: [station_time_timestamp()]",
			"Time Dilation: [round(SStime_track.time_dilation_current,1)]% AVG:([round(SStime_track.time_dilation_avg_fast,1)]%, [round(SStime_track.time_dilation_avg,1)]%, [round(SStime_track.time_dilation_avg_slow,1)]%)"
		)

		if(SSshuttle.emergency)
			var/ETA = SSshuttle.emergency.getModeStr()
			if(ETA)
				global_data += "[ETA] [SSshuttle.emergency.getTimerStr()]"
		encoded_global_data = url_encode(json_encode(global_data))

		var/list/mc_data = list(
			list("CPU:", world.cpu),
			list("Instances:", "[num2text(world.contents.len, 10)]"),
			list("World Time:", "[world.time]"),
			list("Globals:", "Edit", "\ref[GLOB]"),
			list("[config]:", "Edit", "\ref[config]"),
			list("Byond:", "(FPS:[world.fps]) (TickCount:[world.time/world.tick_lag]) (TickDrift:[round(Master.tickdrift,1)]([round((Master.tickdrift/(world.time/world.tick_lag))*100,0.1)]%))"),
			list("Master Controller:", Master ? "(TickRate:[Master.processing]) (Iteration:[Master.iteration])" : "ERROR", "\ref[Master]"),
			list("Failsafe Controller:", Failsafe ? "Defcon: [Failsafe.defcon_pretty()] (Interval: [Failsafe.processing_interval] | Iteration: [Failsafe.master_iteration])" : "ERROR", "\ref[Failsafe]"),
			list("","")
		)
		for(var/datum/controller/subsystem/SS in Master.subsystems)
			mc_data[++mc_data.len] = list("\[[SS.state_letter()]][SS.name]", SS.stat_entry(), "\ref[SS]")
		mc_data[++mc_data.len] = list("Camera Net", "Cameras: [GLOB.cameranet.cameras.len] | Chunks: [GLOB.cameranet.chunks.len]", "\ref[GLOB.cameranet]")
		mc_data_encoded = url_encode(json_encode(mc_data))
		src.currentrun = GLOB.clients.Copy()

	var/list/currentrun = src.currentrun
	while(currentrun.len)
		var/client/C = currentrun[currentrun.len]
		currentrun.len--
		var/ping_str = url_encode("Ping: [round(C.lastping, 1)]ms (Average: [round(C.avgping, 1)]ms)")
		var/other_str = url_encode(json_encode(C.mob.get_status_tab_items()))
		C << output("[encoded_global_data];[ping_str];[other_str]", "statbrowser:update")
		if(C.holder)
			var/turf/T = get_turf(C.eye)
			var/coord_entry = url_encode(COORD(T))
			C << output("[mc_data_encoded];[coord_entry];[url_encode(C.holder.href_token)]", "statbrowser:update_mc")
			var/list/L = GLOB.ahelp_tickets.stat_entry()
			C << output("[url_encode(json_encode(L))];", "statbrowser:update_tickets")
			if(length(GLOB.sdql2_queries))
				var/list/sqdl2A = list()
				sqdl2A[++sqdl2A.len] = list("", "Access Global SDQL2 List", REF(GLOB.sdql2_vv_statobj))
				var/list/sqdl2B = list()
				for(var/i in GLOB.sdql2_queries)
					var/datum/sdql2_query/Q = i
					sqdl2B = Q.generate_stat()
				sqdl2A += sqdl2B
				C << output(url_encode(json_encode(sqdl2A)), "statbrowser:update_sqdl2")
			else
				C << output("", "statbrowser:remove_sqdl2")
		else
			C << output("", "statbrowser:remove_admin_tabs")
		var/list/proc_holders = C.mob.get_proc_holders()
		C.spell_tabs.Cut()
		for(var/I in proc_holders)
			var/list/item = I
			C.spell_tabs |= item[1]
		var/proc_holders_encoded = ""
		if(length(proc_holders))
			proc_holders_encoded = url_encode(json_encode(proc_holders))
		C << output("[url_encode(json_encode(C.spell_tabs))];[proc_holders_encoded]", "statbrowser:update_spells")
		if(C.mob && C.mob.listed_turf)
			var/mob/M = C.mob
			if(!M.TurfAdjacent(M.listed_turf))
				C << output("", "statbrowser:remove_listedturf")
				M.listed_turf = null
			else
				var/list/overrides = list()
				var/list/turfitems = list()
				for(var/image/I in C.images)
					if(I.loc && I.loc.loc == M.listed_turf && I.override)
						overrides += I.loc
				for(var/atom/A in M.listed_turf)
					if(!A.mouse_opacity)
						continue
					if(A.invisibility > M.see_invisible)
						continue
					if(overrides.len && (A in overrides))
						continue
					if(A.IsObscured())
						continue
					if(length(turfitems) < 30) // only create images for the first 30 items on the turf, for performance reasons
						var/icon/atom_image = getFlatIcon(A)
						C << browse_rsc(atom_image, "[REF(A)].png")
						turfitems[++turfitems.len] = list("[A.name]", REF(A), "[REF(A)].png")
					else
						turfitems[++turfitems.len] = list("[A.name]", REF(A))
				turfitems = url_encode(json_encode(turfitems))
				C << output("[turfitems];", "statbrowser:update_listedturf")
		if(MC_TICK_CHECK)
			return
