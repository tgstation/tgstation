GLOBAL_DATUM(everyone_a_traitor, /datum/everyone_is_a_traitor_controller)

/client/proc/secrets() //Creates a verb for admins to open up the ui
	set name = "Secrets"
	set desc = "Abuse harder than you ever have before with this handy dandy semi-misc stuff menu"
	set category = "Admin.Game"
	SSblackbox.record_feedback("tally", "admin_verb", 1, "Secrets Panel") // If you are copy-pasting this, ensure the 4th parameter is unique to the new proc!
	var/datum/secrets_menu/tgui = new(usr)//create the datum
	tgui.ui_interact(usr)//datum has a tgui component, here we open the window

/datum/secrets_menu
	var/client/holder //client of whoever is using this datum
	var/is_debugger = FALSE
	var/is_funmin = FALSE

/datum/secrets_menu/New(user)//user can either be a client or a mob due to byondcode(tm)
	if (istype(user, /client))
		var/client/user_client = user
		holder = user_client //if its a client, assign it to holder
	else
		var/mob/user_mob = user
		holder = user_mob.client //if its a mob, assign the mob's client to holder

	is_debugger = check_rights(R_DEBUG)
	is_funmin = check_rights(R_FUN)

/datum/secrets_menu/ui_state(mob/user)
	return GLOB.admin_state

/datum/secrets_menu/ui_close()
	qdel(src)

/datum/secrets_menu/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "Secrets")
		ui.open()

/datum/secrets_menu/ui_data(mob/user)
	var/list/data = list()
	data["is_debugger"] = is_debugger
	data["is_funmin"] = is_funmin
	return data

#define THUNDERDOME_TEMPLATE_FILE "admin_thunderdome.dmm"
#define HIGHLANDER_DELAY_TEXT "40 seconds (crush the hope of a normal shift)"
/datum/secrets_menu/ui_act(action, params)
	. = ..()
	if(.)
		return
	if((action != "admin_log" || action != "show_admins") && !check_rights(R_ADMIN))
		return
	var/datum/round_event/E
	switch(action)
		//Generic Buttons anyone can use.
		if("admin_log")
			var/dat = "<meta charset='UTF-8'><B>Admin Log<HR></B>"
			for(var/l in GLOB.admin_activities)
				dat += "<li>[l]</li>"
			if(!GLOB.admin_activities.len)
				dat += "No-one has done anything this round!"
			holder << browse(dat, "window=admin_log")
		if("show_admins")
			var/dat = "<meta charset='UTF-8'><B>Current admins:</B><HR>"
			if(GLOB.admin_datums)
				for(var/ckey in GLOB.admin_datums)
					var/datum/admins/D = GLOB.admin_datums[ckey]
					dat += "[ckey] - [D.rank_names()]<br>"
				holder << browse(dat, "window=showadmins;size=600x500")
		//Buttons for debug.
		if("maint_access_engiebrig")
			if(!is_debugger)
				return
			for(var/obj/machinery/door/airlock/maintenance/doors as anything in SSmachines.get_machines_by_type_and_subtypes(/obj/machinery/door/airlock/maintenance))
				if ((ACCESS_MAINT_TUNNELS in doors.req_access) || (ACCESS_MAINT_TUNNELS in doors.req_one_access))
					doors.req_access = list()
					doors.req_one_access = list(ACCESS_BRIG, ACCESS_ENGINEERING)
			message_admins("[key_name_admin(holder)] made all maint doors engineering and brig access-only.")
		if("maint_access_brig")
			if(!is_debugger)
				return
			for(var/obj/machinery/door/airlock/maintenance/doors as anything in SSmachines.get_machines_by_type_and_subtypes(/obj/machinery/door/airlock/maintenance))
				if ((ACCESS_MAINT_TUNNELS in doors.req_access) || (ACCESS_MAINT_TUNNELS in doors.req_one_access))
					doors.req_access = list(ACCESS_BRIG)
					doors.req_one_access = list()
			message_admins("[key_name_admin(holder)] made all maint doors brig access-only.")
		if("infinite_sec")
			if(!is_debugger)
				return
			var/datum/job/sec_job = SSjob.GetJobType(/datum/job/security_officer)
			sec_job.total_positions = -1
			sec_job.spawn_positions = -1
			message_admins("[key_name_admin(holder)] has removed the cap on security officers.")

		//Buttons for helpful stuff. This is where people land in the tgui
		if("clear_virus")
			var/choice = tgui_alert(usr, "Are you sure you want to cure all disease?",, list("Yes", "Cancel"))
			if(choice == "Yes")
				message_admins("[key_name_admin(holder)] has cured all diseases.")
				for(var/thing in SSdisease.active_diseases)
					var/datum/disease/D = thing
					D.cure(0)

		if("list_bombers")
			holder.list_bombers()

		if("list_signalers")
			holder.list_signalers()

		if("list_lawchanges")
			holder.list_law_changes()

		if("showailaws")
			holder.check_ai_laws()

		if("manifest")
			holder.show_manifest()

		if("dna")
			holder.list_dna()

		if("fingerprints")
			holder.list_fingerprints()

		if("ctfbutton")
			toggle_id_ctf(holder, CTF_GHOST_CTF_GAME_ID)

		if("tdomereset")
			var/delete_mobs = tgui_alert(usr, "Clear all mobs?", "Thunderdome Reset", list("Yes", "No", "Cancel"))
			if(!delete_mobs || delete_mobs == "Cancel")
				return

			log_admin("[key_name(holder)] reset the thunderdome to default with delete_mobs marked as [delete_mobs].")
			message_admins(span_adminnotice("[key_name_admin(holder)] reset the thunderdome to default with delete_mobs marked as [delete_mobs]."))

			var/area/thunderdome = GLOB.areas_by_type[/area/centcom/tdome/arena]
			if(delete_mobs == "Yes")
				for(var/mob/living/mob in thunderdome)
					qdel(mob) //Clear mobs
			for(var/obj/obj in thunderdome)
				if(!istype(obj, /obj/machinery/camera))
					qdel(obj) //Clear objects

			var/datum/map_template/thunderdome_template = SSmapping.map_templates[THUNDERDOME_TEMPLATE_FILE]
			thunderdome_template.should_place_on_top = FALSE
			var/turf/thunderdome_corner = locate(thunderdome.x - 3, thunderdome.y - 1, 1) // have to do a little bit of coord manipulation to get it in the right spot
			thunderdome_template.load(thunderdome_corner)

		if("set_name")
			var/new_name = input(holder, "Please input a new name for the station.", "What?", "") as text|null
			if(!new_name)
				return
			set_station_name(new_name)
			log_admin("[key_name(holder)] renamed the station to \"[new_name]\".")
			message_admins(span_adminnotice("[key_name_admin(holder)] renamed the station to: [new_name]."))
			priority_announce("[command_name()] has renamed the station to \"[new_name]\".")
		if("reset_name")
			var/confirmed = tgui_alert(usr,"Are you sure you want to reset the station name?", "Confirm", list("Yes", "No", "Cancel"))
			if(confirmed != "Yes")
				return
			var/new_name = new_station_name()
			set_station_name(new_name)
			log_admin("[key_name(holder)] reset the station name.")
			message_admins(span_adminnotice("[key_name_admin(holder)] reset the station name."))
			priority_announce("[command_name()] has renamed the station to \"[new_name]\".")
		if("night_shift_set")
			var/val = tgui_alert(holder, "What do you want to set night shift to? This will override the automatic system until set to automatic again.", "Night Shift", list("On", "Off", "Automatic"))
			switch(val)
				if("Automatic")
					if(CONFIG_GET(flag/enable_night_shifts))
						SSnightshift.can_fire = TRUE
						SSnightshift.fire()
					else
						SSnightshift.update_nightshift(active = FALSE, announce = TRUE, forced = TRUE)
				if("On")
					SSnightshift.can_fire = FALSE
					SSnightshift.update_nightshift(active = TRUE, announce = TRUE, forced = TRUE)
				if("Off")
					SSnightshift.can_fire = FALSE
					SSnightshift.update_nightshift(active = FALSE, announce = TRUE, forced = TRUE)
		if("moveferry")
			SSblackbox.record_feedback("nested tally", "admin_secrets_fun_used", 1, list("Send CentCom Ferry"))
			if(!SSshuttle.toggleShuttle("ferry","ferry_home","ferry_away"))
				message_admins("[key_name_admin(holder)] moved the CentCom ferry")
				log_admin("[key_name(holder)] moved the CentCom ferry")
		if("togglearrivals")
			var/obj/docking_port/mobile/arrivals/A = SSshuttle.arrivals
			if(A)
				var/new_perma = !A.perma_docked
				A.perma_docked = new_perma
				SSblackbox.record_feedback("nested tally", "admin_toggle", 1, list("Permadock Arrivals Shuttle", "[new_perma ? "Enabled" : "Disabled"]"))
				message_admins("[key_name_admin(holder)] [new_perma ? "stopped" : "started"] the arrivals shuttle")
				log_admin("[key_name(holder)] [new_perma ? "stopped" : "started"] the arrivals shuttle")
			else
				to_chat(holder, span_admin("There is no arrivals shuttle."), confidential = TRUE)
		if("movelaborshuttle")
			SSblackbox.record_feedback("nested tally", "admin_secrets_fun_used", 1, list("Send Labor Shuttle"))
			if(!SSshuttle.toggleShuttle("laborcamp","laborcamp_home","laborcamp_away"))
				message_admins("[key_name_admin(holder)] moved labor shuttle")
				log_admin("[key_name(holder)] moved the labor shuttle")
		//!fun! buttons.
		if("virus")
			if(!is_funmin)
				return
			SSblackbox.record_feedback("nested tally", "admin_secrets_fun_used", 1, list("Virus Outbreak"))
			switch(tgui_alert(usr,"Do you want this to be a random disease or do you have something in mind?",,list("Make Your Own","Random","Choose")))
				if("Make Your Own")
					AdminCreateVirus(holder)
				if("Random")
					force_event(/datum/round_event_control/disease_outbreak)
				if("Choose")
					var/virus = input("Choose the virus to spread", "BIOHAZARD") as null|anything in sort_list(typesof(/datum/disease), GLOBAL_PROC_REF(cmp_typepaths_asc))
					var/datum/round_event_control/disease_outbreak/DC = locate(/datum/round_event_control/disease_outbreak) in SSevents.control
					var/datum/round_event/disease_outbreak/DO = DC.run_event()
					DO.virus_type = virus
					E = DO
		if("allspecies")
			if(!is_funmin)
				return
			var/result = input(holder, "Please choose a new species","Species") as null|anything in GLOB.species_list
			if(result)
				SSblackbox.record_feedback("nested tally", "admin_secrets_fun_used", 1, list("Mass Species Change", "[result]"))
				log_admin("[key_name(holder)] turned all humans into [result]")
				message_admins("\blue [key_name_admin(holder)] turned all humans into [result]")
				var/newtype = GLOB.species_list[result]
				for(var/i in GLOB.human_list)
					var/mob/living/carbon/human/H = i
					H.set_species(newtype)
		if("power")
			if(!is_funmin)
				return
			SSblackbox.record_feedback("nested tally", "admin_secrets_fun_used", 1, list("Power All APCs"))
			log_admin("[key_name(holder)] made all areas powered")
			message_admins(span_adminnotice("[key_name_admin(holder)] made all areas powered"))
			power_restore()
		if("unpower")
			if(!is_funmin)
				return
			SSblackbox.record_feedback("nested tally", "admin_secrets_fun_used", 1, list("Depower All APCs"))
			log_admin("[key_name(holder)] made all areas unpowered")
			message_admins(span_adminnotice("[key_name_admin(holder)] made all areas unpowered"))
			power_failure()
		if("quickpower")
			if(!is_funmin)
				return
			SSblackbox.record_feedback("nested tally", "admin_secrets_fun_used", 1, list("Power All SMESs"))
			log_admin("[key_name(holder)] made all SMESs powered")
			message_admins(span_adminnotice("[key_name_admin(holder)] made all SMESs powered"))
			power_restore_quick()
		if("anon_name")
			if(!is_funmin)
				return
			holder.anon_names()
			SSblackbox.record_feedback("nested tally", "admin_secrets_fun_used", 1, list("Anonymous Names"))
		if("tripleAI")
			if(!is_funmin)
				return
			holder.triple_ai()
			SSblackbox.record_feedback("nested tally", "admin_secrets_fun_used", 1, list("Triple AI"))
		if("onlyone")
			if(!is_funmin)
				return
			var/response = tgui_alert(usr,"Delay by 40 seconds?", "There can, in fact, only be one", list("Instant!", HIGHLANDER_DELAY_TEXT))
			switch(response)
				if("Instant!")
					holder.only_one()
				if(HIGHLANDER_DELAY_TEXT)
					holder.only_one_delayed()
				else
					return
			SSblackbox.record_feedback("nested tally", "admin_secrets_fun_used", 1, list("There Can Be Only One"))
		if("guns")
			if(!is_funmin)
				return
			SSblackbox.record_feedback("nested tally", "admin_secrets_fun_used", 1, list("Summon Guns"))
			var/survivor_probability = 0
			switch(tgui_alert(usr,"Do you want this to create survivors antagonists?",,list("No Antags","Some Antags","All Antags!")))
				if("Some Antags")
					survivor_probability = 25
				if("All Antags!")
					survivor_probability = 100

			summon_guns(holder.mob, survivor_probability)

		if("magic")
			if(!is_funmin)
				return
			SSblackbox.record_feedback("nested tally", "admin_secrets_fun_used", 1, list("Summon Magic"))
			var/survivor_probability = 0
			switch(tgui_alert(usr,"Do you want this to create magician antagonists?",,list("No Antags","Some Antags","All Antags!")))
				if("Some Antags")
					survivor_probability = 25
				if("All Antags!")
					survivor_probability = 100

			summon_magic(holder.mob, survivor_probability)

		if("towerOfBabel")
			if(!is_funmin)
				return
			if(tgui_alert(usr,"Would you like to randomize language for everyone?",,list("Yes","No")) == "Yes")
				SSblackbox.record_feedback("nested tally", "admin_secrets_fun_used", 1, list("Tower of babel"))
				holder.tower_of_babel()

		if("cureTowerOfBabel")
			if(!is_funmin)
				return
			holder.tower_of_babel_undo()

		if("events")
			if(!is_funmin)
				return
			if(SSevents.wizardmode)
				switch(tgui_alert(usr,"What would you like to do?",,list("Intensify Summon Events","Turn Off Summon Events","Nothing")))
					if("Intensify Summon Events")
						summon_events(holder)
						SSblackbox.record_feedback("nested tally", "admin_secrets_fun_used", 1, list("Summon Events", "Intensify"))
					if("Turn Off Summon Events")
						SSevents.toggleWizardmode()
						SSevents.resetFrequency()
						SSblackbox.record_feedback("nested tally", "admin_secrets_fun_used", 1, list("Summon Events", "Disable"))
			else
				if(tgui_alert(usr,"Do you want to toggle summon events on?",,list("Yes","No")) == "Yes")
					summon_events(holder)
					SSblackbox.record_feedback("nested tally", "admin_secrets_fun_used", 1, list("Summon Events", "Activate"))

		if("eagles")
			if(!is_funmin)
				return
			SSblackbox.record_feedback("nested tally", "admin_secrets_fun_used", 1, list("Egalitarian Station"))
			for(var/obj/machinery/door/airlock/W as anything in SSmachines.get_machines_by_type_and_subtypes(/obj/machinery/door/airlock))
				if(is_station_level(W.z) && !istype(get_area(W), /area/station/command) && !istype(get_area(W), /area/station/commons) && !istype(get_area(W), /area/station/service) && !istype(get_area(W), /area/station/command/heads_quarters) && !istype(get_area(W), /area/station/security/prison))
					W.req_access = list()
			message_admins("[key_name_admin(holder)] activated Egalitarian Station mode")
			priority_announce("CentCom airlock control override activated. Please take this time to get acquainted with your coworkers.", null, SSstation.announcer.get_rand_report_sound())
		if("ancap")
			if(!is_funmin)
				return
			SSblackbox.record_feedback("nested tally", "admin_secrets_fun_used", 1, list("Anarcho-capitalist Station"))
			SSeconomy.full_ancap = !SSeconomy.full_ancap
			message_admins("[key_name_admin(holder)] toggled Anarcho-capitalist mode")
			if(SSeconomy.full_ancap)
				priority_announce("The NAP is now in full effect.", null, SSstation.announcer.get_rand_report_sound())
			else
				priority_announce("The NAP has been revoked.", null, SSstation.announcer.get_rand_report_sound())
		if("blackout")
			if(!is_funmin)
				return
			SSblackbox.record_feedback("nested tally", "admin_secrets_fun_used", 1, list("Break All Lights"))
			message_admins("[key_name_admin(holder)] broke all lights")
			for(var/obj/machinery/light/L as anything in SSmachines.get_machines_by_type_and_subtypes(/obj/machinery/light))
				L.break_light_tube()
				CHECK_TICK
		if("whiteout")
			if(!is_funmin)
				return
			SSblackbox.record_feedback("nested tally", "admin_secrets_fun_used", 1, list("Fix All Lights"))
			message_admins("[key_name_admin(holder)] fixed all lights")
			for(var/obj/machinery/light/L as anything in SSmachines.get_machines_by_type_and_subtypes(/obj/machinery/light))
				L.fix()
				CHECK_TICK
		if("customportal")
			if(!is_funmin)
				return

			var/list/settings = list(
				"mainsettings" = list(
					"typepath" = list("desc" = "Path to spawn", "type" = "datum", "path" = "/mob/living", "subtypesonly" = TRUE, "value" = /mob/living/basic/bee),
					"humanoutfit" = list("desc" = "Outfit if human", "type" = "datum", "path" = "/datum/outfit", "subtypesonly" = TRUE, "value" = /datum/outfit),
					"amount" = list("desc" = "Number per portal", "type" = "number", "value" = 1),
					"portalnum" = list("desc" = "Number of total portals", "type" = "number", "value" = 10),
					"offerghosts" = list("desc" = "Get ghosts to play mobs", "type" = "boolean", "value" = "No"),
					"minplayers" = list("desc" = "Minimum number of ghosts", "type" = "number", "value" = 1),
					"playersonly" = list("desc" = "Only spawn ghost-controlled mobs", "type" = "boolean", "value" = "No"),
					"ghostpoll" = list("desc" = "Ghost poll question", "type" = "string", "value" = "Do you want to play as %TYPE% portal invader?"),
					"delay" = list("desc" = "Time between portals, in deciseconds", "type" = "number", "value" = 50),
					"color" = list("desc" = "Portal color", "type" = "color", "value" = "#00FF00"),
					"playlightning" = list("desc" = "Play lightning sounds on announcement", "type" = "boolean", "value" = "Yes"),
					"announce_players" = list("desc" = "Make an announcement", "type" = "boolean", "value" = "Yes"),
					"announcement" = list("desc" = "Announcement", "type" = "string", "value" = "Massive bluespace anomaly detected en route to %STATION%. Brace for impact."),
				)
			)

			message_admins("[key_name(holder)] is creating a custom portal storm...")
			var/list/prefreturn = presentpreflikepicker(holder,"Customize Portal Storm", "Customize Portal Storm", Button1="Ok", width = 600, StealFocus = 1,Timeout = 0, settings=settings)

			if (prefreturn["button"] == 1)
				var/list/prefs = settings["mainsettings"]

				if (prefs["amount"]["value"] < 1 || prefs["portalnum"]["value"] < 1)
					to_chat(holder, span_warning("Number of portals and mobs to spawn must be at least 1."), confidential = TRUE)
					return

				var/mob/pathToSpawn = prefs["typepath"]["value"]
				if (!ispath(pathToSpawn))
					pathToSpawn = text2path(pathToSpawn)

				if (!ispath(pathToSpawn))
					to_chat(holder, span_notice("Invalid path [pathToSpawn]."), confidential = TRUE)
					return

				var/list/candidates = list()

				if (prefs["offerghosts"]["value"] == "Yes")
					candidates = poll_ghost_candidates(replacetext(prefs["ghostpoll"]["value"], "%TYPE%", initial(pathToSpawn.name)), ROLE_TRAITOR)

				if (prefs["playersonly"]["value"] == "Yes" && length(candidates) < prefs["minplayers"]["value"])
					message_admins("Not enough players signed up to create a portal storm, the minimum was [prefs["minplayers"]["value"]] and the number of signups [length(candidates)]")
					return

				if (prefs["announce_players"]["value"] == "Yes")
					portalAnnounce(prefs["announcement"]["value"], (prefs["playlightning"]["value"] == "Yes" ? TRUE : FALSE))

				var/list/storm_appearances = list()
				for(var/offset in 0 to SSmapping.max_plane_offset)
					var/mutable_appearance/storm = mutable_appearance('icons/obj/machines/engine/energy_ball.dmi', "energy_ball_fast", FLY_LAYER)
					SET_PLANE_W_SCALAR(storm, ABOVE_GAME_PLANE, offset)
					storm.color = prefs["color"]["value"]
					storm_appearances += storm

				message_admins("[key_name_admin(holder)] has created a customized portal storm that will spawn [prefs["portalnum"]["value"]] portals, each of them spawning [prefs["amount"]["value"]] of [pathToSpawn]")
				log_admin("[key_name(holder)] has created a customized portal storm that will spawn [prefs["portalnum"]["value"]] portals, each of them spawning [prefs["amount"]["value"]] of [pathToSpawn]")

				var/outfit = prefs["humanoutfit"]["value"]
				if (!ispath(outfit))
					outfit = text2path(outfit)

				for (var/i in 1 to prefs["portalnum"]["value"])
					if (length(candidates)) // if we're spawning players, gotta be a little tricky and also not spawn players on top of NPCs
						var/ghostcandidates = list()
						for (var/j in 1 to min(prefs["amount"]["value"], length(candidates)))
							ghostcandidates += pick_n_take(candidates)
							addtimer(CALLBACK(GLOBAL_PROC, GLOBAL_PROC_REF(doPortalSpawn), get_random_station_turf(), pathToSpawn, length(ghostcandidates), storm_appearances, ghostcandidates, outfit), i*prefs["delay"]["value"])
					else if (prefs["playersonly"]["value"] != "Yes")
						addtimer(CALLBACK(GLOBAL_PROC, GLOBAL_PROC_REF(doPortalSpawn), get_random_station_turf(), pathToSpawn, prefs["amount"]["value"], storm_appearances, null, outfit), i*prefs["delay"]["value"])
		if("changebombcap")
			if(!is_funmin)
				return
			SSblackbox.record_feedback("nested tally", "admin_secrets_fun_used", 1, list("Bomb Cap"))

			var/newBombCap = input(holder,"What would you like the new bomb cap to be. (entered as the light damage range (the 3rd number in common (1,2,3) notation)) Must be above 4)", "New Bomb Cap", GLOB.MAX_EX_LIGHT_RANGE) as num|null
			if (!CONFIG_SET(number/bombcap, newBombCap))
				return

			message_admins(span_boldannounce("[key_name_admin(holder)] changed the bomb cap to [GLOB.MAX_EX_DEVESTATION_RANGE], [GLOB.MAX_EX_HEAVY_RANGE], [GLOB.MAX_EX_LIGHT_RANGE]"))
			log_admin("[key_name(holder)] changed the bomb cap to [GLOB.MAX_EX_DEVESTATION_RANGE], [GLOB.MAX_EX_HEAVY_RANGE], [GLOB.MAX_EX_LIGHT_RANGE]")
		//buttons that are fun for exactly you and nobody else.
		if("monkey")
			if(!is_funmin)
				return
			SSblackbox.record_feedback("nested tally", "admin_secrets_fun_used", 1, list("Monkeyize All Humans"))
			message_admins("[key_name_admin(holder)] made everyone into monkeys.")
			log_admin("[key_name_admin(holder)] made everyone into monkeys.")
			for(var/i in GLOB.human_list)
				var/mob/living/carbon/human/H = i
				INVOKE_ASYNC(H, TYPE_PROC_REF(/mob/living/carbon, monkeyize))
		if("traitor_all")
			if(!is_funmin)
				return
			if(!SSticker.HasRoundStarted())
				tgui_alert(usr,"The game hasn't started yet!")
				return
			if(GLOB.everyone_a_traitor)
				tgui_alert(usr, "The everyone is a traitor secret has already been triggered")
				return
			var/objective = tgui_input_text(holder, "Enter an objective", "Objective")
			if(!objective)
				return
			GLOB.everyone_a_traitor = new /datum/everyone_is_a_traitor_controller(objective)
			SSblackbox.record_feedback("nested tally", "admin_secrets_fun_used", 1, list("Traitor All", "[objective]"))
			for(var/mob/living/player in GLOB.player_list)
				GLOB.everyone_a_traitor.make_traitor(null, player)
			message_admins(span_adminnotice("[key_name_admin(holder)] used everyone is a traitor secret. Objective is [objective]"))
			log_admin("[key_name(holder)] used everyone is a traitor secret. Objective is [objective]")
		if("massbraindamage")
			if(!is_funmin)
				return
			SSblackbox.record_feedback("nested tally", "admin_secrets_fun_used", 1, list("Mass Braindamage"))
			for(var/mob/living/carbon/human/H in GLOB.player_list)
				to_chat(H, span_boldannounce("You suddenly feel stupid."), confidential = TRUE)
				H.adjustOrganLoss(ORGAN_SLOT_BRAIN, 60, 80)
			message_admins("[key_name_admin(holder)] made everybody brain damaged")
		if("floorlava")
			SSweather.run_weather(/datum/weather/floor_is_lava)
		if("anime")
			if(!is_funmin)
				return
			var/animetype = tgui_alert(usr,"Would you like to have the clothes be changed?",,list("Yes","No","Cancel"))

			var/droptype
			if(animetype == "Yes")
				droptype = tgui_alert(usr,"Make the uniforms Nodrop?",,list("Yes","No","Cancel"))

			if(animetype == "Cancel" || droptype == "Cancel")
				return
			SSblackbox.record_feedback("nested tally", "admin_secrets_fun_used", 1, list("Chinese Cartoons"))
			message_admins("[key_name_admin(holder)] made everything kawaii.")
			for(var/i in GLOB.human_list)
				var/mob/living/carbon/human/H = i
				SEND_SOUND(H, sound(SSstation.announcer.event_sounds[ANNOUNCER_ANIMES]))

				if(H.dna.species.id == SPECIES_HUMAN)
					if(H.dna.features["tail_human"] == "None" || H.dna.features["ears"] == "None")
						var/obj/item/organ/internal/ears/cat/ears = new
						var/obj/item/organ/external/tail/cat/tail = new
						ears.Insert(H, drop_if_replaced=FALSE)
						tail.Insert(H, drop_if_replaced=FALSE)
					var/list/honorifics = list("[MALE]" = list("kun"), "[FEMALE]" = list("chan","tan"), "[NEUTER]" = list("san"), "[PLURAL]" = list("san")) //John Robust -> Robust-kun
					var/list/names = splittext(H.real_name," ")
					var/forename = names.len > 1 ? names[2] : names[1]
					var/newname = "[forename]-[pick(honorifics["[H.gender]"])]"
					H.fully_replace_character_name(H.real_name,newname)
					H.update_mutant_bodyparts()
					if(animetype == "Yes")
						var/seifuku = pick(typesof(/obj/item/clothing/under/costume/schoolgirl))
						var/obj/item/clothing/under/costume/schoolgirl/I = new seifuku
						var/olduniform = H.w_uniform
						H.temporarilyRemoveItemFromInventory(H.w_uniform, TRUE, FALSE)
						H.equip_to_slot_or_del(I, ITEM_SLOT_ICLOTHING)
						qdel(olduniform)
						if(droptype == "Yes")
							ADD_TRAIT(I, TRAIT_NODROP, ADMIN_TRAIT)
				else
					to_chat(H, span_warning("You're not kawaii enough for this!"), confidential = TRUE)
		if("masspurrbation")
			if(!is_funmin)
				return
			mass_purrbation()
			message_admins("[key_name_admin(holder)] has put everyone on \
				purrbation!")
			log_admin("[key_name(holder)] has put everyone on purrbation.")
		if("massremovepurrbation")
			if(!is_funmin)
				return
			mass_remove_purrbation()
			message_admins("[key_name_admin(holder)] has removed everyone from \
				purrbation.")
			log_admin("[key_name(holder)] has removed everyone from purrbation.")
		if("massimmerse")
			if(!is_funmin)
				return
			mass_immerse()
			message_admins("[key_name_admin(holder)] has Fully Immersed \
				everyone!")
			log_admin("[key_name(holder)] has Fully Immersed everyone.")
		if("unmassimmerse")
			if(!is_funmin)
				return
			mass_immerse(remove=TRUE)
			message_admins("[key_name_admin(holder)] has Un-Fully Immersed \
				everyone!")
			log_admin("[key_name(holder)] has Un-Fully Immersed everyone.")
		if("makeNerd")
			var/spawnpoint = pick(GLOB.blobstart)
			var/list/mob/dead/observer/candidates
			var/mob/dead/observer/chosen_candidate
			var/mob/living/basic/drone/nerd
			var/teamsize

			teamsize = input(usr, "How many drones?", "N.E.R.D. team size", 2) as num|null

			if(teamsize <= 0)
				return FALSE

			candidates = poll_ghost_candidates("Do you wish to be considered for a Nanotrasen emergency response drone?", "Drone")

			if(length(candidates) == 0)
				return FALSE

			while(length(candidates) && teamsize)
				chosen_candidate = pick(candidates)
				candidates -= chosen_candidate
				nerd = new /mob/living/basic/drone/classic(spawnpoint)
				nerd.key = chosen_candidate.key
				nerd.log_message("has been selected as a Nanotrasen emergency response drone.", LOG_GAME)
				teamsize--

			return TRUE
		if("ctf_instagib")
			if(!is_funmin)
				return
			if(GLOB.ctf_games.len <= 0)
				tgui_alert(usr, "No CTF games are set up.")
				return
			var/selected_game = tgui_input_list(usr, "Select a CTF game to ruin.", "Instagib Mode", GLOB.ctf_games)
			if(isnull(selected_game))
				return
			var/datum/ctf_controller/ctf_controller = GLOB.ctf_games[selected_game]
			var/choice = tgui_alert(usr, "[ctf_controller.instagib_mode ? "Return to standard" : "Enable instagib"] mode?", "Instagib Mode", list("Yes", "No"))
			if(choice != "Yes")
				return
			ctf_controller.toggle_instagib_mode()
			message_admins("[key_name_admin(holder)] [ctf_controller.instagib_mode ? "enabled" : "disabled"] instagib mode in CTF game: [selected_game]")
			log_admin("[key_name_admin(holder)] [ctf_controller.instagib_mode ? "enabled" : "disabled"] instagib mode in CTF game: [selected_game]")

	if(E)
		E.processing = FALSE
		if(E.announce_when>0)
			switch(tgui_alert(holder, "Would you like to alert the crew?", "Alert", list("Yes", "No", "Cancel")))
				if("Yes")
					E.announce_chance = 100
				if("Cancel")
					E.kill()
					return
				if("No")
					E.announce_chance = 0
		E.processing = TRUE
	if(holder)
		log_admin("[key_name(holder)] used secret [action]")
#undef THUNDERDOME_TEMPLATE_FILE
#undef HIGHLANDER_DELAY_TEXT

/proc/portalAnnounce(announcement, playlightning)
	set waitfor = FALSE
	if (playlightning)
		sound_to_playing_players('sound/magic/lightning_chargeup.ogg')
		sleep(8 SECONDS)
	priority_announce(replacetext(announcement, "%STATION%", station_name()))
	if (playlightning)
		sleep(2 SECONDS)
		sound_to_playing_players('sound/magic/lightningbolt.ogg')

/// Spawns a portal storm that spawns in sentient/non sentient mobs
/// portal_appearance is a list in the form (turf's plane offset + 1) -> appearance to use
/proc/doPortalSpawn(turf/loc, mobtype, numtospawn, list/portal_appearance, players, humanoutfit)
	for (var/i in 1 to numtospawn)
		var/mob/spawnedMob = new mobtype(loc)
		if (length(players))
			var/mob/chosen = players[1]
			if (chosen.client)
				chosen.client.prefs.safe_transfer_prefs_to(spawnedMob, is_antag = TRUE)
				spawnedMob.key = chosen.key
			players -= chosen
		if (ishuman(spawnedMob) && ispath(humanoutfit, /datum/outfit))
			var/mob/living/carbon/human/H = spawnedMob
			H.equipOutfit(humanoutfit)
	var/turf/T = get_step(loc, SOUTHWEST)
	T.flick_overlay_static(portal_appearance[GET_TURF_PLANE_OFFSET(T) + 1], 15)
	playsound(T, 'sound/magic/lightningbolt.ogg', rand(80, 100), TRUE)

///Makes sure latejoining crewmembers also become traitors.
/datum/everyone_is_a_traitor_controller
	var/objective = ""

/datum/everyone_is_a_traitor_controller/New(objective)
	src.objective = objective
	RegisterSignal(SSdcs, COMSIG_GLOB_CREWMEMBER_JOINED, PROC_REF(make_traitor))

/datum/everyone_is_a_traitor_controller/Destroy()
	UnregisterSignal(SSdcs, COMSIG_GLOB_CREWMEMBER_JOINED)
	return ..()

/datum/everyone_is_a_traitor_controller/proc/make_traitor(datum/source, mob/living/player)
	SIGNAL_HANDLER
	if(player.stat == DEAD || !player.mind)
		return
	if(is_special_character(player))
		return
	if(ishuman(player))
		var/datum/antagonist/traitor/traitor_datum = new(give_objectives = FALSE)
		var/datum/objective/new_objective = new
		new_objective.owner = player
		new_objective.explanation_text = objective
		traitor_datum.objectives += new_objective
		player.mind.add_antag_datum(traitor_datum)
		var/datum/uplink_handler/uplink = traitor_datum.uplink_handler
		uplink.has_progression = FALSE
		uplink.has_objectives = FALSE
	else if(isAI(player))
		var/datum/antagonist/malf_ai/malfunction_datum = new(give_objectives = FALSE)
		var/datum/objective/new_objective = new
		new_objective.owner = player
		new_objective.explanation_text = objective
		malfunction_datum.objectives += new_objective
		player.mind.add_antag_datum(malfunction_datum)
