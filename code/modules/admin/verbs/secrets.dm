

/client/proc/secrets() //Creates a verb for admins to open up the ui
	set name = "Secrets"
	set desc = "Abuse harder than you ever have before with this handy dandy semi-misc stuff menu"
	set category = "Admin.Game"
	SSblackbox.record_feedback("tally", "admin_verb", 1, "Secrets Panel") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!
	var/datum/secrets_menu/tgui  = new(usr)//create the datum
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
			for(var/l in GLOB.admin_log)
				dat += "<li>[l]</li>"
			if(!GLOB.admin_log.len)
				dat += "No-one has done anything this round!"
			holder << browse(dat, "window=admin_log")
		if("show_admins")
			var/dat = "<meta charset='UTF-8'><B>Current admins:</B><HR>"
			if(GLOB.admin_datums)
				for(var/ckey in GLOB.admin_datums)
					var/datum/admins/D = GLOB.admin_datums[ckey]
					dat += "[ckey] - [D.rank.name]<br>"
				holder << browse(dat, "window=showadmins;size=600x500")
		//Buttons for debug.
		if("maint_access_engiebrig")
			if(!is_debugger)
				return
			for(var/obj/machinery/door/airlock/maintenance/M in GLOB.machines)
				M.check_access()
				if (ACCESS_MAINT_TUNNELS in M.req_access)
					M.req_access = list()
					M.req_one_access = list(ACCESS_BRIG,ACCESS_ENGINE)
			message_admins("[key_name_admin(holder)] made all maint doors engineering and brig access-only.")
		if("maint_access_brig")
			if(!is_debugger)
				return
			for(var/obj/machinery/door/airlock/maintenance/M in GLOB.machines)
				M.check_access()
				if (ACCESS_MAINT_TUNNELS in M.req_access)
					M.req_access = list(ACCESS_BRIG)
			message_admins("[key_name_admin(holder)] made all maint doors brig access-only.")
		if("infinite_sec")
			if(!is_debugger)
				return
			var/datum/job/J = SSjob.GetJob("Security Officer")
			if(!J)
				return
			J.total_positions = -1
			J.spawn_positions = -1
			message_admins("[key_name_admin(holder)] has removed the cap on security officers.")
		//Buttons for helpful stuff. This is where people land in the tgui
		if("clear_virus")
			var/choice = input("Are you sure you want to cure all disease?") in list("Yes", "Cancel")
			if(choice == "Yes")
				message_admins("[key_name_admin(holder)] has cured all diseases.")
				for(var/thing in SSdisease.active_diseases)
					var/datum/disease/D = thing
					D.cure(0)
		if("list_bombers")
			var/dat = "<B>Bombing List</B><HR>"
			for(var/l in GLOB.bombers)
				dat += text("[l]<BR>")
			holder << browse(dat, "window=bombers")

		if("list_signalers")
			var/dat = "<B>Showing last [length(GLOB.lastsignalers)] signalers.</B><HR>"
			for(var/sig in GLOB.lastsignalers)
				dat += "[sig]<BR>"
			holder << browse(dat, "window=lastsignalers;size=800x500")
		if("list_lawchanges")
			var/dat = "<B>Showing last [length(GLOB.lawchanges)] law changes.</B><HR>"
			for(var/sig in GLOB.lawchanges)
				dat += "[sig]<BR>"
			holder << browse(dat, "window=lawchanges;size=800x500")
		if("showailaws")
			holder.holder.output_ai_laws()//huh, inconvenient var naming, huh?
		if("showgm")
			if(!SSticker.HasRoundStarted())
				alert("The game hasn't started yet!")
			else if (SSticker.mode)
				alert("The game mode is [SSticker.mode.name]")
			else
				alert("For some reason there's a SSticker, but not a game mode")
		if("manifest")
			var/dat = "<B>Showing Crew Manifest.</B><HR>"
			dat += "<table cellspacing=5><tr><th>Name</th><th>Position</th></tr>"
			for(var/datum/data/record/t in GLOB.data_core.general)
				dat += "<tr><td>[t.fields["name"]]</td><td>[t.fields["rank"]]</td></tr>"
			dat += "</table>"
			holder << browse(dat, "window=manifest;size=440x410")
		if("dna")
			var/dat = "<B>Showing DNA from blood.</B><HR>"
			dat += "<table cellspacing=5><tr><th>Name</th><th>DNA</th><th>Blood Type</th></tr>"
			for(var/i in GLOB.human_list)
				var/mob/living/carbon/human/H = i
				if(H.ckey)
					dat += "<tr><td>[H]</td><td>[H.dna.unique_enzymes]</td><td>[H.dna.blood_type]</td></tr>"
			dat += "</table>"
			holder << browse(dat, "window=DNA;size=440x410")
		if("fingerprints")
			var/dat = "<B>Showing Fingerprints.</B><HR>"
			dat += "<table cellspacing=5><tr><th>Name</th><th>Fingerprints</th></tr>"
			for(var/i in GLOB.human_list)
				var/mob/living/carbon/human/H = i
				if(H.ckey)
					dat += "<tr><td>[H]</td><td>[md5(H.dna.uni_identity)]</td></tr>"
			dat += "</table>"
			holder << browse(dat, "window=fingerprints;size=440x410")
		if("ctfbutton")
			toggle_id_ctf(holder, "centcom")
		if("tdomereset")
			var/delete_mobs = alert("Clear all mobs?","Confirm","Yes","No","Cancel")
			if(delete_mobs == "Cancel")
				return

			log_admin("[key_name(holder)] reset the thunderdome to default with delete_mobs==[delete_mobs].", 1)
			message_admins("<span class='adminnotice'>[key_name_admin(holder)] reset the thunderdome to default with delete_mobs==[delete_mobs].</span>")

			var/area/thunderdome = GLOB.areas_by_type[/area/tdome/arena]
			if(delete_mobs == "Yes")
				for(var/mob/living/mob in thunderdome)
					qdel(mob) //Clear mobs
			for(var/obj/obj in thunderdome)
				if(!istype(obj, /obj/machinery/camera) && !istype(obj, /obj/effect/abstract/proximity_checker))
					qdel(obj) //Clear objects

			var/area/template = GLOB.areas_by_type[/area/tdome/arena_source]
			template.copy_contents_to(thunderdome)
		if("set_name")
			var/new_name = input(holder, "Please input a new name for the station.", "What?", "") as text|null
			if(!new_name)
				return
			set_station_name(new_name)
			log_admin("[key_name(holder)] renamed the station to \"[new_name]\".")
			message_admins("<span class='adminnotice'>[key_name_admin(holder)] renamed the station to: [new_name].</span>")
			priority_announce("[command_name()] has renamed the station to \"[new_name]\".")
		if("reset_name")
			var/new_name = new_station_name()
			set_station_name(new_name)
			log_admin("[key_name(holder)] reset the station name.")
			message_admins("<span class='adminnotice'>[key_name_admin(holder)] reset the station name.</span>")
			priority_announce("[command_name()] has renamed the station to \"[new_name]\".")
		if("night_shift_set")
			var/val = alert(holder, "What do you want to set night shift to? This will override the automatic system until set to automatic again.", "Night Shift", "On", "Off", "Automatic")
			switch(val)
				if("Automatic")
					if(CONFIG_GET(flag/enable_night_shifts))
						SSnightshift.can_fire = TRUE
						SSnightshift.fire()
					else
						SSnightshift.update_nightshift(FALSE, TRUE)
				if("On")
					SSnightshift.can_fire = FALSE
					SSnightshift.update_nightshift(TRUE, TRUE)
				if("Off")
					SSnightshift.can_fire = FALSE
					SSnightshift.update_nightshift(FALSE, TRUE)
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
				to_chat(holder, "<span class='admin'>There is no arrivals shuttle.</span>", confidential = TRUE)
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
			switch(alert("Do you want this to be a random disease or do you have something in mind?",,"Make Your Own","Random","Choose"))
				if("Make Your Own")
					AdminCreateVirus(holder)
				if("Random")
					var/datum/round_event_control/disease_outbreak/DC = locate(/datum/round_event_control/disease_outbreak) in SSevents.control
					E = DC.runEvent()
				if("Choose")
					var/virus = input("Choose the virus to spread", "BIOHAZARD") as null|anything in sortList(typesof(/datum/disease), /proc/cmp_typepaths_asc)
					var/datum/round_event_control/disease_outbreak/DC = locate(/datum/round_event_control/disease_outbreak) in SSevents.control
					var/datum/round_event/disease_outbreak/DO = DC.runEvent()
					DO.virus_type = virus
					E = DO
		if("allspecies")
			if(!is_funmin)
				return
			var/result = input(holder, "Please choose a new species","Species") as null|anything in GLOB.species_list
			if(result)
				SSblackbox.record_feedback("nested tally", "admin_secrets_fun_used", 1, list("Mass Species Change", "[result]"))
				log_admin("[key_name(holder)] turned all humans into [result]", 1)
				message_admins("\blue [key_name_admin(holder)] turned all humans into [result]")
				var/newtype = GLOB.species_list[result]
				for(var/i in GLOB.human_list)
					var/mob/living/carbon/human/H = i
					H.set_species(newtype)
		if("power")
			if(!is_funmin)
				return
			SSblackbox.record_feedback("nested tally", "admin_secrets_fun_used", 1, list("Power All APCs"))
			log_admin("[key_name(holder)] made all areas powered", 1)
			message_admins("<span class='adminnotice'>[key_name_admin(holder)] made all areas powered</span>")
			power_restore()
		if("unpower")
			if(!is_funmin)
				return
			SSblackbox.record_feedback("nested tally", "admin_secrets_fun_used", 1, list("Depower All APCs"))
			log_admin("[key_name(holder)] made all areas unpowered", 1)
			message_admins("<span class='adminnotice'>[key_name_admin(holder)] made all areas unpowered</span>")
			power_failure()
		if("quickpower")
			if(!is_funmin)
				return
			SSblackbox.record_feedback("nested tally", "admin_secrets_fun_used", 1, list("Power All SMESs"))
			log_admin("[key_name(holder)] made all SMESs powered", 1)
			message_admins("<span class='adminnotice'>[key_name_admin(holder)] made all SMESs powered</span>")
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
			var/response = alert("Delay by 40 seconds?", "There can, in fact, only be one", "Instant!", "40 seconds (crush the hope of a normal shift)")
			if(response == "Instant!")
				holder.only_one()
			else
				holder.only_one_delayed()
			SSblackbox.record_feedback("nested tally", "admin_secrets_fun_used", 1, list("There Can Be Only One"))
		if("guns")
			if(!is_funmin)
				return
			SSblackbox.record_feedback("nested tally", "admin_secrets_fun_used", 1, list("Summon Guns"))
			var/survivor_probability = 0
			switch(alert("Do you want this to create survivors antagonists?",,"No Antags","Some Antags","All Antags!"))
				if("Some Antags")
					survivor_probability = 25
				if("All Antags!")
					survivor_probability = 100

			rightandwrong(SUMMON_GUNS, holder, survivor_probability)
		if("magic")
			if(!is_funmin)
				return
			SSblackbox.record_feedback("nested tally", "admin_secrets_fun_used", 1, list("Summon Magic"))
			var/survivor_probability = 0
			switch(alert("Do you want this to create magician antagonists?",,"No Antags","Some Antags","All Antags!"))
				if("Some Antags")
					survivor_probability = 25
				if("All Antags!")
					survivor_probability = 100

			rightandwrong(SUMMON_MAGIC, holder, survivor_probability)
		if("events")
			if(!is_funmin)
				return
			if(!SSevents.wizardmode)
				if(alert("Do you want to toggle summon events on?",,"Yes","No") == "Yes")
					summonevents()
					SSblackbox.record_feedback("nested tally", "admin_secrets_fun_used", 1, list("Summon Events", "Activate"))

			else
				switch(alert("What would you like to do?",,"Intensify Summon Events","Turn Off Summon Events","Nothing"))
					if("Intensify Summon Events")
						summonevents()
						SSblackbox.record_feedback("nested tally", "admin_secrets_fun_used", 1, list("Summon Events", "Intensify"))
					if("Turn Off Summon Events")
						SSevents.toggleWizardmode()
						SSevents.resetFrequency()
						SSblackbox.record_feedback("nested tally", "admin_secrets_fun_used", 1, list("Summon Events", "Disable"))
		if("eagles")
			if(!is_funmin)
				return
			SSblackbox.record_feedback("nested tally", "admin_secrets_fun_used", 1, list("Egalitarian Station"))
			for(var/obj/machinery/door/airlock/W in GLOB.machines)
				if(is_station_level(W.z) && !istype(get_area(W), /area/command) && !istype(get_area(W), /area/commons) && !istype(get_area(W), /area/service) && !istype(get_area(W), /area/command/heads_quarters) && !istype(get_area(W), /area/security/prison))
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
			for(var/obj/machinery/light/L in GLOB.machines)
				L.break_light_tube()
		if("whiteout")
			if(!is_funmin)
				return
			SSblackbox.record_feedback("nested tally", "admin_secrets_fun_used", 1, list("Fix All Lights"))
			message_admins("[key_name_admin(holder)] fixed all lights")
			for(var/obj/machinery/light/L in GLOB.machines)
				L.fix()
		if("customportal")
			if(!is_funmin)
				return

			var/list/settings = list(
				"mainsettings" = list(
					"typepath" = list("desc" = "Path to spawn", "type" = "datum", "path" = "/mob/living", "subtypesonly" = TRUE, "value" = /mob/living/simple_animal/hostile/poison/bees),
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
					to_chat(holder, "<span class='warning'>Number of portals and mobs to spawn must be at least 1.</span>", confidential = TRUE)
					return

				var/mob/pathToSpawn = prefs["typepath"]["value"]
				if (!ispath(pathToSpawn))
					pathToSpawn = text2path(pathToSpawn)

				if (!ispath(pathToSpawn))
					to_chat(holder, "<span class='notice'>Invalid path [pathToSpawn].</span>", confidential = TRUE)
					return

				var/list/candidates = list()

				if (prefs["offerghosts"]["value"] == "Yes")
					candidates = pollGhostCandidates(replacetext(prefs["ghostpoll"]["value"], "%TYPE%", initial(pathToSpawn.name)), ROLE_TRAITOR)

				if (prefs["playersonly"]["value"] == "Yes" && length(candidates) < prefs["minplayers"]["value"])
					message_admins("Not enough players signed up to create a portal storm, the minimum was [prefs["minplayers"]["value"]] and the number of signups [length(candidates)]")
					return

				if (prefs["announce_players"]["value"] == "Yes")
					portalAnnounce(prefs["announcement"]["value"], (prefs["playlightning"]["value"] == "Yes" ? TRUE : FALSE))

				var/mutable_appearance/storm = mutable_appearance('icons/obj/tesla_engine/energy_ball.dmi', "energy_ball_fast", FLY_LAYER)
				storm.color = prefs["color"]["value"]

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
							addtimer(CALLBACK(GLOBAL_PROC, .proc/doPortalSpawn, get_random_station_turf(), pathToSpawn, length(ghostcandidates), storm, ghostcandidates, outfit), i*prefs["delay"]["value"])
					else if (prefs["playersonly"]["value"] != "Yes")
						addtimer(CALLBACK(GLOBAL_PROC, .proc/doPortalSpawn, get_random_station_turf(), pathToSpawn, prefs["amount"]["value"], storm, null, outfit), i*prefs["delay"]["value"])
		if("changebombcap")
			if(!is_funmin)
				return
			SSblackbox.record_feedback("nested tally", "admin_secrets_fun_used", 1, list("Bomb Cap"))

			var/newBombCap = input(holder,"What would you like the new bomb cap to be. (entered as the light damage range (the 3rd number in common (1,2,3) notation)) Must be above 4)", "New Bomb Cap", GLOB.MAX_EX_LIGHT_RANGE) as num|null
			if (!CONFIG_SET(number/bombcap, newBombCap))
				return

			message_admins("<span class='boldannounce'>[key_name_admin(holder)] changed the bomb cap to [GLOB.MAX_EX_DEVESTATION_RANGE], [GLOB.MAX_EX_HEAVY_RANGE], [GLOB.MAX_EX_LIGHT_RANGE]</span>")
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
				INVOKE_ASYNC(H, /mob/living/carbon.proc/monkeyize)
		if("traitor_all")
			if(!is_funmin)
				return
			if(!SSticker.HasRoundStarted())
				alert("The game hasn't started yet!")
				return
			var/objective = stripped_input(holder, "Enter an objective")
			if(!objective)
				return
			SSblackbox.record_feedback("nested tally", "admin_secrets_fun_used", 1, list("Traitor All", "[objective]"))
			for(var/mob/living/H in GLOB.player_list)
				if(!(ishuman(H)||istype(H, /mob/living/silicon/)))
					continue
				if(H.stat == DEAD || !H.mind || ispAI(H))
					continue
				if(is_special_character(H))
					continue
				var/datum/antagonist/traitor/T = new()
				T.give_objectives = FALSE
				var/datum/objective/new_objective = new
				new_objective.owner = H
				new_objective.explanation_text = objective
				T.add_objective(new_objective)
				H.mind.add_antag_datum(T)
			message_admins("<span class='adminnotice'>[key_name_admin(holder)] used everyone is a traitor secret. Objective is [objective]</span>")
			log_admin("[key_name(holder)] used everyone is a traitor secret. Objective is [objective]")
		if("massbraindamage")
			if(!is_funmin)
				return
			SSblackbox.record_feedback("nested tally", "admin_secrets_fun_used", 1, list("Mass Braindamage"))
			for(var/mob/living/carbon/human/H in GLOB.player_list)
				to_chat(H, "<span class='boldannounce'>You suddenly feel stupid.</span>", confidential = TRUE)
				H.adjustOrganLoss(ORGAN_SLOT_BRAIN, 60, 80)
			message_admins("[key_name_admin(holder)] made everybody brain damaged")
		if("floorlava")
			SSweather.run_weather(/datum/weather/floor_is_lava)
		if("anime")
			if(!is_funmin)
				return
			var/animetype = alert("Would you like to have the clothes be changed?",,"Yes","No","Cancel")

			var/droptype
			if(animetype =="Yes")
				droptype = alert("Make the uniforms Nodrop?",,"Yes","No","Cancel")

			if(animetype == "Cancel" || droptype == "Cancel")
				return
			SSblackbox.record_feedback("nested tally", "admin_secrets_fun_used", 1, list("Chinese Cartoons"))
			message_admins("[key_name_admin(holder)] made everything kawaii.")
			for(var/i in GLOB.human_list)
				var/mob/living/carbon/human/H = i
				SEND_SOUND(H, sound(SSstation.announcer.event_sounds[ANNOUNCER_ANIMES]))

				if(H.dna.species.id == "human")
					if(H.dna.features["tail_human"] == "None" || H.dna.features["ears"] == "None")
						var/obj/item/organ/ears/cat/ears = new
						var/obj/item/organ/tail/cat/tail = new
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
					to_chat(H, "<span class='warning'>You're not kawaii enough for this!</span>", confidential = TRUE)
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
	if(E)
		E.processing = FALSE
		if(E.announceWhen>0)
			switch(alert(holder, "Would you like to alert the crew?", "Alert", "Yes", "No", "Cancel"))
				if("Yes")
					E.announceChance = 100
				if("Cancel")
					E.kill()
					return
				if("No")
					E.announceChance = 0
		E.processing = TRUE
	if(holder)
		log_admin("[key_name(holder)] used secret [action]")

/proc/portalAnnounce(announcement, playlightning)
	set waitfor = FALSE
	if (playlightning)
		sound_to_playing_players('sound/magic/lightning_chargeup.ogg')
		sleep(80)
	priority_announce(replacetext(announcement, "%STATION%", station_name()))
	if (playlightning)
		sleep(20)
		sound_to_playing_players('sound/magic/lightningbolt.ogg')

/proc/doPortalSpawn(turf/loc, mobtype, numtospawn, portal_appearance, players, humanoutfit)
	for (var/i in 1 to numtospawn)
		var/mob/spawnedMob = new mobtype(loc)
		if (length(players))
			var/mob/chosen = players[1]
			if (chosen.client)
				chosen.client.prefs.copy_to(spawnedMob)
				spawnedMob.key = chosen.key
			players -= chosen
		if (ishuman(spawnedMob) && ispath(humanoutfit, /datum/outfit))
			var/mob/living/carbon/human/H = spawnedMob
			H.equipOutfit(humanoutfit)
	var/turf/T = get_step(loc, SOUTHWEST)
	flick_overlay_static(portal_appearance, T, 15)
	playsound(T, 'sound/magic/lightningbolt.ogg', rand(80, 100), TRUE)
