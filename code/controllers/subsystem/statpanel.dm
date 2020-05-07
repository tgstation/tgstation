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
		var/list/global_data = list(
			"Map: [SSmapping.config?.map_name || "Loading..."]",
			cached ? "Next Map: [cached.map_name]" : null,
			"Round ID: [GLOB.round_id ? GLOB.round_id : "NULL"]",
			"Server Time: [time2text(world.timeofday, "YYYY-MM-DD hh:mm:ss")]",
			"Round Time: [worldtime2text()]",
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
		C << output(url_encode(C.statpanel), "statbrowser:tab_change") // work around desyncs
		currentrun.len--
		var/ping_str = url_encode("Ping: [round(C.lastping, 1)]ms (Average: [round(C.avgping, 1)]ms)")
		var/other_str = url_encode(json_encode(C.mob.get_status_tab_items()))
		C << output("[encoded_global_data];[ping_str];[other_str]", "statbrowser:update")
		if(C.holder && C.statpanel == "MC")
			var/turf/T = get_turf(C.eye)
			var/coord_entry = url_encode(COORD(T))
			C << output("[mc_data_encoded];[coord_entry];[url_encode(C.holder.href_token)]", "statbrowser:update_mc")
		var/list/proc_holders = C.mob.get_proc_holders()
		C.spell_tabs.Cut()
		for(var/list/item in proc_holders)
			C.spell_tabs |= item[1]
		var/proc_holders_encoded = ""
		if(C.statpanel in C.spell_tabs)
			proc_holders_encoded = url_encode(json_encode(proc_holders))
		C << output("[url_encode(json_encode(C.spell_tabs))];[proc_holders_encoded]", "statbrowser:update_spells")
		if(MC_TICK_CHECK)
			return
