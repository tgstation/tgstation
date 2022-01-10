SUBSYSTEM_DEF(statpanels)
	name = "Stat Panels"
	wait = 4 SECONDS
	init_order = INIT_ORDER_STATPANELS
	priority = FIRE_PRIORITY_STATPANEL
	runlevels = RUNLEVELS_DEFAULT | RUNLEVEL_LOBBY
	var/list/currentrun = list()
	var/encoded_global_data
	var/mc_data_encoded
	var/list/cached_images = list()

/datum/controller/subsystem/statpanels/fire(resumed = FALSE)
	if (!resumed)
		var/datum/map_config/cached = SSmapping.next_map_config
		var/list/global_data = list(
			"Map: [SSmapping.config?.map_name || "Loading..."]",
			cached ? "Next Map: [cached.map_name]" : null,
			"Round ID: [GLOB.round_id ? GLOB.round_id : "NULL"]",
			"Server Time: [time2text(world.timeofday, "YYYY-MM-DD hh:mm:ss")]",
			"Round Time: [ROUND_TIME]",
			"Station Time: [station_time_timestamp()]",
			"Time Dilation: [round(SStime_track.time_dilation_current,1)]% AVG:([round(SStime_track.time_dilation_avg_fast,1)]%, [round(SStime_track.time_dilation_avg,1)]%, [round(SStime_track.time_dilation_avg_slow,1)]%)"
		)

		if(SSshuttle.emergency)
			var/ETA = SSshuttle.emergency.getModeStr()
			if(ETA)
				global_data += "[ETA] [SSshuttle.emergency.getTimerStr()]"
		encoded_global_data = url_encode(json_encode(global_data))
		src.currentrun = GLOB.clients.Copy()
		mc_data_encoded = null

	var/list/currentrun = src.currentrun
	while(length(currentrun))
		var/client/target = currentrun[length(currentrun)]
		currentrun.len--

		if(!target.statbrowser_ready)
			continue

		if(target.stat_tab == "Status")
			set_status_tab(target)

		if(!target.holder)
			target << output("", "statbrowser:remove_admin_tabs")
		else
			target << output("[!!(target.prefs.toggles & SPLIT_ADMIN_TABS)]", "statbrowser:update_split_admin_tabs")

			if(!("MC" in target.panel_tabs) || !("Tickets" in target.panel_tabs))
				target << output("[url_encode(target.holder.href_token)]", "statbrowser:add_admin_tabs")

			if(target.stat_tab == "MC")
				set_MC_tab(target)

			if(target.stat_tab == "Tickets")
				set_tickets_tab(target)

			if(!length(GLOB.sdql2_queries) && ("SDQL2" in target.panel_tabs))
				target << output("", "statbrowser:remove_sdql2")

			else if(length(GLOB.sdql2_queries) && (target.stat_tab == "SDQL2" || !("SDQL2" in target.panel_tabs)))
				set_SDQL2_tab(target)

		if(target.mob)
			var/mob/target_mob = target.mob
			if((target.stat_tab in target.spell_tabs) || !length(target.spell_tabs) && (length(target_mob.mob_spell_list) || length(target_mob.mind?.spell_list)))
				set_spells_tab(target, target_mob)

			if(target_mob?.listed_turf)
				if(!target_mob.TurfAdjacent(target_mob.listed_turf))
					target << output("", "statbrowser:remove_listedturf")
					target_mob.listed_turf = null

				else if(target.stat_tab == target_mob?.listed_turf.name || !(target_mob?.listed_turf.name in target.panel_tabs))
					set_turf_examine_tab(target, target_mob)

		if(MC_TICK_CHECK)
			return

/datum/controller/subsystem/statpanels/proc/set_status_tab(client/target)
	var/ping_str = url_encode("Ping: [round(target.lastping, 1)]ms (Average: [round(target.avgping, 1)]ms)")
	var/other_str = url_encode(json_encode(target.mob?.get_status_tab_items()))
	target << output("[encoded_global_data];[ping_str];[other_str]", "statbrowser:update")

/datum/controller/subsystem/statpanels/proc/set_MC_tab(client/target)
	var/turf/eye_turf = get_turf(target.eye)
	var/coord_entry = url_encode(COORD(eye_turf))
	if(!mc_data_encoded)
		generate_mc_data()
	target << output("[mc_data_encoded];[coord_entry]", "statbrowser:update_mc")

/datum/controller/subsystem/statpanels/proc/set_tickets_tab(client/target)
	var/list/ahelp_tickets = GLOB.ahelp_tickets.stat_entry()
	target << output("[url_encode(json_encode(ahelp_tickets))];", "statbrowser:update_tickets")
	var/datum/interview_manager/m = GLOB.interviews

	// get open interview count
	var/dc = 0
	for (var/ckey in m.open_interviews)
		var/datum/interview/current_interview = m.open_interviews[ckey]
		if (current_interview && !current_interview.owner)
			dc++
	var/stat_string = "([m.open_interviews.len - dc] online / [dc] disconnected)"

	// Prepare each queued interview
	var/list/queued = list()
	for (var/datum/interview/queued_interview in m.interview_queue)
		queued += list(list(
			"ref" = REF(queued_interview),
			"status" = "\[[queued_interview.pos_in_queue]\]: [queued_interview.owner_ckey][!queued_interview.owner ? " (DC)": ""] \[INT-[queued_interview.id]\]"
		))

	var/list/data = list(
		"status" = list(
			"Active:" = "[m.open_interviews.len] [stat_string]",
			"Queued:" = "[m.interview_queue.len]",
			"Closed:" = "[m.closed_interviews.len]"),
		"interviews" = queued
	)

	// Push update
	target << output("[url_encode(json_encode(data))];", "statbrowser:update_interviews")

/datum/controller/subsystem/statpanels/proc/set_SDQL2_tab(client/target)
	var/list/sdql2A = list()
	sdql2A[++sdql2A.len] = list("", "Access Global SDQL2 List", REF(GLOB.sdql2_vv_statobj))
	var/list/sdql2B = list()
	for(var/datum/sdql2_query/query as anything in GLOB.sdql2_queries)
		sdql2B = query.generate_stat()

	sdql2A += sdql2B
	target << output(url_encode(json_encode(sdql2A)), "statbrowser:update_sdql2")

/datum/controller/subsystem/statpanels/proc/set_spells_tab(client/target, mob/target_mob)
	var/list/proc_holders = target_mob.get_proc_holders()
	target.spell_tabs.Cut()

	for(var/proc_holder_list as anything in proc_holders)
		target.spell_tabs |= proc_holder_list[1]

	var/proc_holders_encoded = ""
	if(length(proc_holders))
		proc_holders_encoded = url_encode(json_encode(proc_holders))

	target << output("[url_encode(json_encode(target.spell_tabs))];[proc_holders_encoded]", "statbrowser:update_spells")

/datum/controller/subsystem/statpanels/proc/set_turf_examine_tab(client/target, mob/target_mob)
	var/list/overrides = list()
	var/list/turfitems = list()
	for(var/image/target_image as anything in target.images)
		if(!target_image.loc || target_image.loc.loc != target_mob.listed_turf || !target_image.override)
			continue
		overrides += target_image.loc

	turfitems[++turfitems.len] = list("[target_mob.listed_turf]", REF(target_mob.listed_turf), icon2html(target_mob.listed_turf, target, sourceonly=TRUE))

	for(var/atom/movable/turf_content as anything in target_mob.listed_turf)
		if(turf_content.mouse_opacity == MOUSE_OPACITY_TRANSPARENT)
			continue
		if(turf_content.invisibility > target_mob.see_invisible)
			continue
		if(turf_content in overrides)
			continue
		if(turf_content.IsObscured())
			continue

		if(length(turfitems) < 10) // only create images for the first 10 items on the turf, for performance reasons
			var/turf_content_ref = REF(turf_content)
			if(!(turf_content_ref in cached_images))
				cached_images += turf_content_ref
				turf_content.RegisterSignal(turf_content, COMSIG_PARENT_QDELETING, /atom/.proc/remove_from_cache) // we reset cache if anything in it gets deleted

				if(ismob(turf_content) || length(turf_content.overlays) > 2)
					turfitems[++turfitems.len] = list("[turf_content.name]", turf_content_ref, costly_icon2html(turf_content, target, sourceonly=TRUE))
				else
					turfitems[++turfitems.len] = list("[turf_content.name]", turf_content_ref, icon2html(turf_content, target, sourceonly=TRUE))
			else
				turfitems[++turfitems.len] = list("[turf_content.name]", turf_content_ref)
		else
			turfitems[++turfitems.len] = list("[turf_content.name]", REF(turf_content))

	turfitems = url_encode(json_encode(turfitems))
	target << output("[turfitems];", "statbrowser:update_listedturf")

/datum/controller/subsystem/statpanels/proc/generate_mc_data()
	var/list/mc_data = list(
		list("CPU:", world.cpu),
		list("Instances:", "[num2text(world.contents.len, 10)]"),
		list("World Time:", "[world.time]"),
		list("Globals:", GLOB.stat_entry(), "\ref[GLOB]"),
		list("[config]:", config.stat_entry(), "\ref[config]"),
		list("Byond:", "(FPS:[world.fps]) (TickCount:[world.time/world.tick_lag]) (TickDrift:[round(Master.tickdrift,1)]([round((Master.tickdrift/(world.time/world.tick_lag))*100,0.1)]%)) (Internal Tick Usage: [round(MAPTICK_LAST_INTERNAL_TICK_USAGE,0.1)]%)"),
		list("Master Controller:", Master.stat_entry(), "\ref[Master]"),
		list("Failsafe Controller:", Failsafe.stat_entry(), "\ref[Failsafe]"),
		list("","")
	)
	for(var/datum/controller/subsystem/sub_system as anything in Master.subsystems)
		mc_data[++mc_data.len] = list("\[[sub_system.state_letter()]][sub_system.name]", sub_system.stat_entry(), "\ref[sub_system]")
	mc_data[++mc_data.len] = list("Camera Net", "Cameras: [GLOB.cameranet.cameras.len] | Chunks: [GLOB.cameranet.chunks.len]", "\ref[GLOB.cameranet]")
	mc_data_encoded = url_encode(json_encode(mc_data))

///immediately update the active statpanel tab of the target client
/datum/controller/subsystem/statpanels/proc/immediate_send_stat_data(client/target)
	if(target.stat_tab == "Status")
		set_status_tab(target)
		return TRUE

	var/mob/target_mob = target.mob
	if((target.stat_tab in target.spell_tabs) || !length(target.spell_tabs) && (length(target_mob.mob_spell_list) || length(target_mob.mind?.spell_list)))
		set_spells_tab(target, target_mob)
		return TRUE

	if(target_mob?.listed_turf)
		if(!target_mob.TurfAdjacent(target_mob.listed_turf))
			target << output("", "statbrowser:remove_listedturf")
			target_mob.listed_turf = null

		else if(target.stat_tab == target_mob?.listed_turf.name || !(target_mob?.listed_turf.name in target.panel_tabs))
			set_turf_examine_tab(target, target_mob)
			return TRUE

	if(!target.holder)
		return FALSE

	if(target.stat_tab == "MC")
		set_MC_tab(target)
		return TRUE

	if(target.stat_tab == "Tickets")
		set_tickets_tab(target)
		return TRUE

	if(!length(GLOB.sdql2_queries) && ("SDQL2" in target.panel_tabs))
		target << output("", "statbrowser:remove_sdql2")

	else if(length(GLOB.sdql2_queries) && target.stat_tab == "SDQL2")
		set_SDQL2_tab(target)

/atom/proc/remove_from_cache()
	SIGNAL_HANDLER
	SSstatpanels.cached_images -= REF(src)

/// verbs that send information from the browser UI
/client/verb/set_tab(tab as text|null)
	set name = "Set Tab"
	set hidden = TRUE

	stat_tab = tab
	SSstatpanels.immediate_send_stat_data(src)

/client/verb/send_tabs(tabs as text|null)
	set name = "Send Tabs"
	set hidden = TRUE

	panel_tabs |= tabs

/client/verb/remove_tabs(tabs as text|null)
	set name = "Remove Tabs"
	set hidden = TRUE

	panel_tabs -= tabs

/client/verb/reset_tabs()
	set name = "Reset Tabs"
	set hidden = TRUE

	panel_tabs = list()

/client/verb/panel_ready()
	set name = "Panel Ready"
	set hidden = TRUE

	statbrowser_ready = TRUE
	init_verbs()

/client/verb/update_verbs()
	set name = "Update Verbs"
	set hidden = TRUE

	init_verbs()
