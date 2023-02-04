ADMIN_VERB(debug, display_air_status, "Display Air Status", "", R_DEBUG, turf/target in view())
	atmos_scan(user=usr, target=target, silent=TRUE)

ADMIN_VERB(debug, unfreeze_everyone, "Unfreeze Everyone", "When movement gets fucked", R_ADMIN)
	var/largest_move_time = 0
	var/largest_click_time = 0
	var/mob/largest_move_mob = null
	var/mob/largest_click_mob = null
	for(var/mob/frozen_mob as anything in GLOB.player_list)
		if(frozen_mob.next_move >= largest_move_time)
			largest_move_mob = frozen_mob
			if(frozen_mob.next_move > world.time)
				largest_move_time = frozen_mob.next_move - world.time
			else
				largest_move_time = 1
		if(frozen_mob.next_click >= largest_click_time)
			largest_click_mob = frozen_mob
			if(frozen_mob.next_click > world.time)
				largest_click_time = frozen_mob.next_click - world.time
			else
				largest_click_time = 0
		log_admin("DEBUG: [key_name(frozen_mob)]  next_move = [frozen_mob.next_move]  lastDblClick = [frozen_mob.next_click]  world.time = [world.time]")
		frozen_mob.next_move = 1
		frozen_mob.next_click = 0
	message_admins("[ADMIN_LOOKUPFLW(largest_move_mob)] had the largest move delay with [largest_move_time] frames / [DisplayTimeText(largest_move_time)]!")
	message_admins("[ADMIN_LOOKUPFLW(largest_click_mob)] had the largest click delay with [largest_click_time] frames / [DisplayTimeText(largest_click_time)]!")
	message_admins("world.time = [world.time]")

ADMIN_VERB(debug, radio_report, "Radio Report", "", R_DEBUG)
	var/output = "<b>Radio Report</b><hr>"
	for (var/fq in SSradio.frequencies)
		output += "<b>Freq: [fq]</b><br>"
		var/datum/radio_frequency/fqs = SSradio.frequencies[fq]
		if (!fqs)
			output += "&nbsp;&nbsp;<b>ERROR</b><br>"
			continue
		for (var/filter in fqs.devices)
			var/list/filtered = fqs.devices[filter]
			if (!filtered)
				output += "&nbsp;&nbsp;[filter]: ERROR<br>"
				continue
			output += "&nbsp;&nbsp;[filter]: [filtered.len]<br>"
			for(var/datum/weakref/device_ref as anything in filtered)
				var/atom/device = device_ref.resolve()
				if(!device)
					filtered -= device_ref
					continue
				if (istype(device, /atom))
					var/atom/A = device
					output += "&nbsp;&nbsp;&nbsp;&nbsp;[device] ([AREACOORD(A)])<br>"
				else
					output += "&nbsp;&nbsp;&nbsp;&nbsp;[device]<br>"
	usr << browse(output,"window=radioreport")

ADMIN_VERB(server, toggle_cdn, "Toggle CDN", "", R_SERVER|R_DEBUG)
	var/static/admin_disabled_cdn_transport = null
	if (alert(usr, "Are you sure you want to toggle the CDN asset transport?", "Confirm", "Yes", "No") != "Yes")
		return
	var/current_transport = CONFIG_GET(string/asset_transport)
	if (!current_transport || current_transport == "simple")
		if (admin_disabled_cdn_transport)
			CONFIG_SET(string/asset_transport, admin_disabled_cdn_transport)
			admin_disabled_cdn_transport = null
			SSassets.OnConfigLoad()
			message_admins("[key_name_admin(usr)] re-enabled the CDN asset transport")
			log_admin("[key_name(usr)] re-enabled the CDN asset transport")
		else
			to_chat(usr, span_adminnotice("The CDN is not enabled!"))
			if (tgui_alert(usr, "The CDN asset transport is not enabled! If you having issues with assets you can also try disabling filename mutations.", "The CDN asset transport is not enabled!", list("Try disabling filename mutations", "Nevermind")) == "Try disabling filename mutations")
				SSassets.transport.dont_mutate_filenames = !SSassets.transport.dont_mutate_filenames
				message_admins("[key_name_admin(usr)] [(SSassets.transport.dont_mutate_filenames ? "disabled" : "re-enabled")] asset filename transforms")
				log_admin("[key_name(usr)] [(SSassets.transport.dont_mutate_filenames ? "disabled" : "re-enabled")] asset filename transforms")
	else
		admin_disabled_cdn_transport = current_transport
		CONFIG_SET(string/asset_transport, "simple")
		SSassets.OnConfigLoad()
		message_admins("[key_name_admin(usr)] disabled the CDN asset transport")
		log_admin("[key_name(usr)] disabled the CDN asset transport")
