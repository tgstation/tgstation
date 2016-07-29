<<<<<<< HEAD
//This file was auto-corrected by findeclaration.exe on 25.5.2012 20:42:33

var/list/preferences_datums = list()



/datum/preferences
	//doohickeys for savefiles
	var/path
	var/default_slot = 1				//Holder so it doesn't default to slot 1, rather the last one used
	var/max_save_slots = 3

	//non-preference stuff
	var/muted = 0
	var/last_ip
	var/last_id

	//game-preferences
	var/lastchangelog = ""				//Saved changlog filesize to detect if there was a change
	var/ooccolor = null

	//Antag preferences
	var/list/be_special = list()		//Special role selection
	var/tmp/old_be_special = 0			//Bitflag version of be_special, used to update old savefiles and nothing more
										//If it's 0, that's good, if it's anything but 0, the owner of this prefs file's antag choices were,
										//autocorrected this round, not that you'd need to check that.


	var/UI_style = "Midnight"
	var/hotkeys = FALSE
	var/tgui_fancy = TRUE
	var/tgui_lock = TRUE
	var/toggles = TOGGLES_DEFAULT
	var/chat_toggles = TOGGLES_DEFAULT_CHAT
	var/ghost_form = "ghost"
	var/ghost_orbit = GHOST_ORBIT_CIRCLE
	var/ghost_accs = GHOST_ACCS_DEFAULT_OPTION
	var/ghost_others = GHOST_OTHERS_DEFAULT_OPTION
	var/ghost_hud = 1
	var/inquisitive_ghost = 1
	var/allow_midround_antag = 1
	var/preferred_map = null

	//character preferences
	var/real_name						//our character's name
	var/be_random_name = 0				//whether we'll have a random name every round
	var/be_random_body = 0				//whether we'll have a random body every round
	var/gender = MALE					//gender of character (well duh)
	var/age = 30						//age of character
	var/underwear = "Nude"				//underwear type
	var/undershirt = "Nude"				//undershirt type
	var/socks = "Nude"					//socks type
	var/backbag = DBACKPACK				//backpack type
	var/hair_style = "Bald"				//Hair type
	var/hair_color = "000"				//Hair color
	var/facial_hair_style = "Shaved"	//Face hair type
	var/facial_hair_color = "000"		//Facial hair color
	var/skin_tone = "caucasian1"		//Skin color
	var/eye_color = "000"				//Eye color
	var/datum/species/pref_species = new /datum/species/human()	//Mutant race
	var/list/features = list("mcolor" = "FFF", "tail_lizard" = "Smooth", "tail_human" = "None", "snout" = "Round", "horns" = "None", "ears" = "None", "wings" = "None", "frills" = "None", "spines" = "None", "body_markings" = "None")

	var/list/custom_names = list("clown", "mime", "ai", "cyborg", "religion", "deity")
		//Mob preview
	var/icon/preview_icon = null

		//Jobs, uses bitflags
	var/job_civilian_high = 0
	var/job_civilian_med = 0
	var/job_civilian_low = 0

	var/job_medsci_high = 0
	var/job_medsci_med = 0
	var/job_medsci_low = 0

	var/job_engsec_high = 0
	var/job_engsec_med = 0
	var/job_engsec_low = 0

		// Want randomjob if preferences already filled - Donkie
	var/joblessrole = BERANDOMJOB  //defaults to 1 for fewer assistants

	// 0 = character settings, 1 = game preferences
	var/current_tab = 0

		// OOC Metadata:
	var/metadata = ""

	var/unlock_content = 0

	var/list/ignoring = list()

/datum/preferences/New(client/C)
	custom_names["ai"] = pick(ai_names)
	custom_names["cyborg"] = pick(ai_names)
	custom_names["clown"] = pick(clown_names)
	custom_names["mime"] = pick(mime_names)
	if(istype(C))
		if(!IsGuestKey(C.key))
			load_path(C.ckey)
			unlock_content = C.IsByondMember()
			if(unlock_content)
				max_save_slots = 8
	var/loaded_preferences_successfully = load_preferences()
	if(loaded_preferences_successfully)
		if(load_character())
			return
	//we couldn't load character data so just randomize the character appearance + name
	random_character()		//let's create a random character then - rather than a fat, bald and naked man.
	real_name = pref_species.random_name(gender,1)
	if(!loaded_preferences_successfully)
		save_preferences()
	save_character()		//let's save this new random character so it doesn't keep generating new ones.
	return


/datum/preferences/proc/ShowChoices(mob/user)
	if(!user || !user.client)
		return
	update_preview_icon()
	user << browse_rsc(preview_icon, "previewicon.png")
	var/dat = "<center>"

	dat += "<a href='?_src_=prefs;preference=tab;tab=0' [current_tab == 0 ? "class='linkOn'" : ""]>Character Settings</a> "
	dat += "<a href='?_src_=prefs;preference=tab;tab=1' [current_tab == 1 ? "class='linkOn'" : ""]>Game Preferences</a>"

	if(!path)
		dat += "<div class='notice'>Please create an account to save your preferences</div>"

	dat += "</center>"

	dat += "<HR>"

	switch(current_tab)
		if (0) // Character Settings#
			if(path)
				var/savefile/S = new /savefile(path)
				if(S)
					dat += "<center>"
					var/name
					for(var/i=1, i<=max_save_slots, i++)
						S.cd = "/character[i]"
						S["real_name"] >> name
						if(!name)
							name = "Character[i]"
						//if(i!=1) dat += " | "
						dat += "<a style='white-space:nowrap;' href='?_src_=prefs;preference=changeslot;num=[i];' [i == default_slot ? "class='linkOn'" : ""]>[name]</a> "
					dat += "</center>"

			dat += "<center><h2>Occupation Choices</h2>"
			dat += "<a href='?_src_=prefs;preference=job;task=menu'>Set Occupation Preferences</a><br></center>"
			dat += "<h2>Identity</h2>"
			dat += "<table width='100%'><tr><td width='75%' valign='top'>"
			if(appearance_isbanned(user))
				dat += "<b>You are banned from using custom names and appearances. You can continue to adjust your characters, but you will be randomised once you join the game.</b><br>"
			dat += "<a href='?_src_=prefs;preference=name;task=random'>Random Name</A> "
			dat += "<a href='?_src_=prefs;preference=name'>Always Random Name: [be_random_name ? "Yes" : "No"]</a><BR>"

			dat += "<b>Name:</b> "
			dat += "<a href='?_src_=prefs;preference=name;task=input'>[real_name]</a><BR>"

			dat += "<b>Gender:</b> <a href='?_src_=prefs;preference=gender'>[gender == MALE ? "Male" : "Female"]</a><BR>"
			dat += "<b>Age:</b> <a href='?_src_=prefs;preference=age;task=input'>[age]</a><BR>"

			dat += "<b>Special Names:</b><BR>"
			dat += "<a href ='?_src_=prefs;preference=clown_name;task=input'><b>Clown:</b> [custom_names["clown"]]</a> "
			dat += "<a href ='?_src_=prefs;preference=mime_name;task=input'><b>Mime:</b>[custom_names["mime"]]</a><BR>"
			dat += "<a href ='?_src_=prefs;preference=ai_name;task=input'><b>AI:</b> [custom_names["ai"]]</a> "
			dat += "<a href ='?_src_=prefs;preference=cyborg_name;task=input'><b>Cyborg:</b> [custom_names["cyborg"]]</a><BR>"
			dat += "<a href ='?_src_=prefs;preference=religion_name;task=input'><b>Chaplain religion:</b> [custom_names["religion"]] </a>"
			dat += "<a href ='?_src_=prefs;preference=deity_name;task=input'><b>Chaplain deity:</b> [custom_names["deity"]]</a><BR></td>"


			dat += "<td valign='center'>"

			dat += "<div class='statusDisplay'><center><img src=previewicon.png width=[preview_icon.Width()] height=[preview_icon.Height()]></center></div>"

			dat += "</td></tr></table>"

			dat += "<h2>Body</h2>"
			dat += "<a href='?_src_=prefs;preference=all;task=random'>Random Body</A> "
			dat += "<a href='?_src_=prefs;preference=all'>Always Random Body: [be_random_body ? "Yes" : "No"]</A><br>"

			dat += "<table width='100%'><tr><td width='24%' valign='top'>"

			if(config.mutant_races)
				dat += "<b>Species:</b><BR><a href='?_src_=prefs;preference=species;task=input'>[pref_species.name]</a><BR>"
			else
				dat += "<b>Species:</b> Human<BR>"

			dat += "<b>Underwear:</b><BR><a href ='?_src_=prefs;preference=underwear;task=input'>[underwear]</a><BR>"
			dat += "<b>Undershirt:</b><BR><a href ='?_src_=prefs;preference=undershirt;task=input'>[undershirt]</a><BR>"
			dat += "<b>Socks:</b><BR><a href ='?_src_=prefs;preference=socks;task=input'>[socks]</a><BR>"
			dat += "<b>Backpack:</b><BR><a href ='?_src_=prefs;preference=bag;task=input'>[backbag]</a><BR></td>"

			if(pref_species.use_skintones)

				dat += "<td valign='top' width='21%'>"

				dat += "<h3>Skin Tone</h3>"

				dat += "<a href='?_src_=prefs;preference=s_tone;task=input'>[skin_tone]</a><BR>"

				dat += "</td>"

			if(HAIR in pref_species.specflags)

				dat += "<td valign='top' width='21%'>"

				dat += "<h3>Hair Style</h3>"

				dat += "<a href='?_src_=prefs;preference=hair_style;task=input'>[hair_style]</a><BR>"
				dat += "<a href='?_src_=prefs;preference=previous_hair_style;task=input'>&lt;</a> <a href='?_src_=prefs;preference=next_hair_style;task=input'>&gt;</a><BR>"
				dat += "<span style='border:1px solid #161616; background-color: #[hair_color];'>&nbsp;&nbsp;&nbsp;</span> <a href='?_src_=prefs;preference=hair;task=input'>Change</a><BR>"


				dat += "</td><td valign='top' width='21%'>"

				dat += "<h3>Facial Hair Style</h3>"

				dat += "<a href='?_src_=prefs;preference=facial_hair_style;task=input'>[facial_hair_style]</a><BR>"
				dat += "<a href='?_src_=prefs;preference=previous_facehair_style;task=input'>&lt;</a> <a href='?_src_=prefs;preference=next_facehair_style;task=input'>&gt;</a><BR>"
				dat += "<span style='border: 1px solid #161616; background-color: #[facial_hair_color];'>&nbsp;&nbsp;&nbsp;</span> <a href='?_src_=prefs;preference=facial;task=input'>Change</a><BR>"

				dat += "</td>"

			if(EYECOLOR in pref_species.specflags)

				dat += "<td valign='top' width='21%'>"

				dat += "<h3>Eye Color</h3>"

				dat += "<span style='border: 1px solid #161616; background-color: #[eye_color];'>&nbsp;&nbsp;&nbsp;</span> <a href='?_src_=prefs;preference=eyes;task=input'>Change</a><BR>"

				dat += "</td>"

			if(config.mutant_races) //We don't allow mutant bodyparts for humans either unless this is true.

				if((MUTCOLORS in pref_species.specflags) || (MUTCOLORS_PARTSONLY in pref_species.specflags))

					dat += "<td valign='top' width='21%'>"

					dat += "<h3>Alien/Mutant Color</h3>"

					dat += "<span style='border: 1px solid #161616; background-color: #[features["mcolor"]];'>&nbsp;&nbsp;&nbsp;</span> <a href='?_src_=prefs;preference=mutant_color;task=input'>Change</a><BR>"

					dat += "</td>"

				if("tail_lizard" in pref_species.mutant_bodyparts)
					dat += "<td valign='top' width='7%'>"

					dat += "<h3>Tail</h3>"

					dat += "<a href='?_src_=prefs;preference=tail_lizard;task=input'>[features["tail_lizard"]]</a><BR>"

					dat += "</td>"

				if("snout" in pref_species.mutant_bodyparts)
					dat += "<td valign='top' width='7%'>"

					dat += "<h3>Snout</h3>"

					dat += "<a href='?_src_=prefs;preference=snout;task=input'>[features["snout"]]</a><BR>"

					dat += "</td>"

				if("horns" in pref_species.mutant_bodyparts)
					dat += "<td valign='top' width='7%'>"

					dat += "<h3>Horns</h3>"

					dat += "<a href='?_src_=prefs;preference=horns;task=input'>[features["horns"]]</a><BR>"

					dat += "</td>"

				if("frills" in pref_species.mutant_bodyparts)
					dat += "<td valign='top' width='7%'>"

					dat += "<h3>Frills</h3>"

					dat += "<a href='?_src_=prefs;preference=frills;task=input'>[features["frills"]]</a><BR>"

					dat += "</td>"

				if("spines" in pref_species.mutant_bodyparts)
					dat += "<td valign='top' width='7%'>"

					dat += "<h3>Spines</h3>"

					dat += "<a href='?_src_=prefs;preference=spines;task=input'>[features["spines"]]</a><BR>"

					dat += "</td>"

				if("body_markings" in pref_species.mutant_bodyparts)
					dat += "<td valign='top' width='7%'>"

					dat += "<h3>Body Markings</h3>"

					dat += "<a href='?_src_=prefs;preference=body_markings;task=input'>[features["body_markings"]]</a><BR>"

					dat += "</td>"

			if(config.mutant_humans)

				if("tail_human" in pref_species.mutant_bodyparts)
					dat += "<td valign='top' width='7%'>"

					dat += "<h3>Tail</h3>"

					dat += "<a href='?_src_=prefs;preference=tail_human;task=input'>[features["tail_human"]]</a><BR>"

					dat += "</td>"

				if("ears" in pref_species.mutant_bodyparts)
					dat += "<td valign='top' width='7%'>"

					dat += "<h3>Ears</h3>"

					dat += "<a href='?_src_=prefs;preference=ears;task=input'>[features["ears"]]</a><BR>"

					dat += "</td>"

				if("wings" in pref_species.mutant_bodyparts && r_wings_list.len >1)
					dat += "<td valign='top' width='7%'>"

					dat += "<h3>Wings</h3>"

					dat += "<a href='?_src_=prefs;preference=wings;task=input'>[features["wings"]]</a><BR>"

					dat += "</td>"

			dat += "</tr></table>"


		if (1) // Game Preferences
			dat += "<table><tr><td width='340px' height='300px' valign='top'>"
			dat += "<h2>General Settings</h2>"
			dat += "<b>UI Style:</b> <a href='?_src_=prefs;preference=ui'>[UI_style]</a><br>"
			dat += "<b>Keybindings:</b> <a href='?_src_=prefs;preference=hotkeys'>[(hotkeys) ? "Hotkeys" : "Default"]</a><br>"
			dat += "<b>tgui Style:</b> <a href='?_src_=prefs;preference=tgui_fancy'>[(tgui_fancy) ? "Fancy" : "No Frills"]</a><br>"
			dat += "<b>tgui Monitors:</b> <a href='?_src_=prefs;preference=tgui_lock'>[(tgui_lock) ? "Primary" : "All"]</a><br>"
			dat += "<b>Play admin midis:</b> <a href='?_src_=prefs;preference=hear_midis'>[(toggles & SOUND_MIDI) ? "Yes" : "No"]</a><br>"
			dat += "<b>Play lobby music:</b> <a href='?_src_=prefs;preference=lobby_music'>[(toggles & SOUND_LOBBY) ? "Yes" : "No"]</a><br>"
			dat += "<b>Ghost ears:</b> <a href='?_src_=prefs;preference=ghost_ears'>[(chat_toggles & CHAT_GHOSTEARS) ? "All Speech" : "Nearest Creatures"]</a><br>"
			dat += "<b>Ghost sight:</b> <a href='?_src_=prefs;preference=ghost_sight'>[(chat_toggles & CHAT_GHOSTSIGHT) ? "All Emotes" : "Nearest Creatures"]</a><br>"
			dat += "<b>Ghost whispers:</b> <a href='?_src_=prefs;preference=ghost_whispers'>[(chat_toggles & CHAT_GHOSTWHISPER) ? "All Speech" : "Nearest Creatures"]</a><br>"
			dat += "<b>Ghost radio:</b> <a href='?_src=prefs;preference=ghost_radio'>[(chat_toggles & CHAT_GHOSTRADIO) ? "Yes" : "No"]</a><br>"
			dat += "<b>Ghost pda:</b> <a href='?_src=prefs;preference=ghost_pda'>[(chat_toggles & CHAT_GHOSTPDA) ? "All Messages" : "Nearest Creatures"]</a><br>"
			dat += "<b>Pull requests:</b> <a href='?_src_=prefs;preference=pull_requests'>[(chat_toggles & CHAT_PULLR) ? "Yes" : "No"]</a><br>"
			dat += "<b>Midround Antagonist:</b> <a href='?_src_=prefs;preference=allow_midround_antag'>[(toggles & MIDROUND_ANTAG) ? "Yes" : "No"]</a><br>"
			if(config.allow_Metadata)
				dat += "<b>OOC Notes:</b> <a href='?_src_=prefs;preference=metadata;task=input'>Edit </a><br>"

			if(user.client)
				if(user.client.holder)
					dat += "<b>Adminhelp Sound:</b> <a href='?_src_=prefs;preference=hear_adminhelps'>[(toggles & SOUND_ADMINHELP)?"On":"Off"]</a><br>"
					dat += "<b>Announce Login:</b> <a href='?_src_=prefs;preference=announce_login'>[(toggles & ANNOUNCE_LOGIN)?"On":"Off"]</a><br>"

				if(unlock_content || check_rights_for(user.client, R_ADMIN))
					dat += "<b>OOC:</b> <span style='border: 1px solid #161616; background-color: [ooccolor ? ooccolor : normal_ooc_colour];'>&nbsp;&nbsp;&nbsp;</span> <a href='?_src_=prefs;preference=ooccolor;task=input'>Change</a><br>"

				if(unlock_content)
					dat += "<b>BYOND Membership Publicity:</b> <a href='?_src_=prefs;preference=publicity'>[(toggles & MEMBER_PUBLIC) ? "Public" : "Hidden"]</a><br>"
					dat += "<b>Ghost Form:</b> <a href='?_src_=prefs;task=input;preference=ghostform'>[ghost_form]</a><br>"
					dat += "<B>Ghost Orbit: </B> <a href='?_src_=prefs;task=input;preference=ghostorbit'>[ghost_orbit]</a><br>"

			var/button_name = "If you see this something went wrong."
			switch(ghost_accs)
				if(GHOST_ACCS_FULL)
					button_name = GHOST_ACCS_FULL_NAME
				if(GHOST_ACCS_DIR)
					button_name = GHOST_ACCS_DIR_NAME
				if(GHOST_ACCS_NONE)
					button_name = GHOST_ACCS_NONE_NAME

			dat += "<b>Ghost Accessories:</b> <a href='?_src_=prefs;task=input;preference=ghostaccs'>[button_name]</a><br>"

			switch(ghost_others)
				if(GHOST_OTHERS_THEIR_SETTING)
					button_name = GHOST_OTHERS_THEIR_SETTING_NAME
				if(GHOST_OTHERS_DEFAULT_SPRITE)
					button_name = GHOST_OTHERS_DEFAULT_SPRITE_NAME
				if(GHOST_OTHERS_SIMPLE)
					button_name = GHOST_OTHERS_SIMPLE_NAME

			dat += "<b>Ghosts of Others:</b> <a href='?_src_=prefs;task=input;preference=ghostothers'>[button_name]</a><br>"

			if (SERVERTOOLS && config.maprotation)
				var/p_map = preferred_map
				if (!p_map)
					p_map = "Default"
					if (config.defaultmap)
						p_map += " ([config.defaultmap.friendlyname])"
				else
					if (p_map in config.maplist)
						var/datum/votablemap/VM = config.maplist[p_map]
						if (!VM)
							p_map += " (No longer exists)"
						else
							p_map = VM.friendlyname
					else
						p_map += " (No longer exists)"
				dat += "<b>Preferred Map:</b> <a href='?_src_=prefs;preference=preferred_map;task=input'>[p_map]</a>"

			dat += "</td><td width='300px' height='300px' valign='top'>"

			dat += "<h2>Special Role Settings</h2>"

			if(jobban_isbanned(user, "Syndicate"))
				dat += "<font color=red><b>You are banned from antagonist roles.</b></font>"
				src.be_special = list()


			for (var/i in special_roles)
				if(jobban_isbanned(user, i))
					dat += "<b>Be [capitalize(i)]:</b> <a href='?_src_=prefs;jobbancheck=[i]'>BANNED</a><br>"
				else
					var/days_remaining = null
					if(config.use_age_restriction_for_jobs && ispath(special_roles[i])) //If it's a game mode antag, check if the player meets the minimum age
						var/mode_path = special_roles[i]
						var/datum/game_mode/temp_mode = new mode_path
						days_remaining = temp_mode.get_remaining_days(user.client)

					if(days_remaining)
						dat += "<b>Be [capitalize(i)]:</b> <font color=red> \[IN [days_remaining] DAYS]</font><br>"
					else
						dat += "<b>Be [capitalize(i)]:</b> <a href='?_src_=prefs;preference=be_special;be_special_type=[i]'>[(i in be_special) ? "Yes" : "No"]</a><br>"

			dat += "</td></tr></table>"

	dat += "<hr><center>"

	if(!IsGuestKey(user.key))
		dat += "<a href='?_src_=prefs;preference=load'>Undo</a> "
		dat += "<a href='?_src_=prefs;preference=save'>Save Setup</a> "

	dat += "<a href='?_src_=prefs;preference=reset_all'>Reset Setup</a>"
	dat += "</center>"

	//user << browse(dat, "window=preferences;size=560x560")
	var/datum/browser/popup = new(user, "preferences", "<div align='center'>Character Setup</div>", 640, 750)
	popup.set_content(dat)
	popup.open(0)

/datum/preferences/proc/SetChoices(mob/user, limit = 17, list/splitJobs = list("Chief Engineer"), widthPerColumn = 295, height = 620)
	if(!SSjob)
		return

	//limit - The amount of jobs allowed per column. Defaults to 17 to make it look nice.
	//splitJobs - Allows you split the table by job. You can make different tables for each department by including their heads. Defaults to CE to make it look nice.
	//widthPerColumn - Screen's width for every column.
	//height - Screen's height.

	var/width = widthPerColumn

	var/HTML = "<center>"
	HTML += "<b>Choose occupation chances</b><br>"
	HTML += "<div align='center'>Left-click to raise an occupation preference, right-click to lower it.<br></div>"
	HTML += "<center><a href='?_src_=prefs;preference=job;task=close'>Done</a></center><br>" // Easier to press up here.
	HTML += "<script type='text/javascript'>function setJobPrefRedirect(level, rank) { window.location.href='?_src_=prefs;preference=job;task=setJobLevel;level=' + level + ';text=' + encodeURIComponent(rank); return false; }</script>"
	HTML += "<table width='100%' cellpadding='1' cellspacing='0'><tr><td width='20%'>" // Table within a table for alignment, also allows you to easily add more colomns.
	HTML += "<table width='100%' cellpadding='1' cellspacing='0'>"
	var/index = -1

	//The job before the current job. I only use this to get the previous jobs color when I'm filling in blank rows.
	var/datum/job/lastJob

	for(var/datum/job/job in SSjob.occupations)

		index += 1
		if((index >= limit) || (job.title in splitJobs))
			width += widthPerColumn
			if((index < limit) && (lastJob != null))
				//If the cells were broken up by a job in the splitJob list then it will fill in the rest of the cells with
				//the last job's selection color. Creating a rather nice effect.
				for(var/i = 0, i < (limit - index), i += 1)
					HTML += "<tr bgcolor='[lastJob.selection_color]'><td width='60%' align='right'>&nbsp</td><td>&nbsp</td></tr>"
			HTML += "</table></td><td width='20%'><table width='100%' cellpadding='1' cellspacing='0'>"
			index = 0

		HTML += "<tr bgcolor='[job.selection_color]'><td width='60%' align='right'>"
		var/rank = job.title
		lastJob = job
		if(jobban_isbanned(user, rank))
			HTML += "<font color=red>[rank]</font></td><td><a href='?_src_=prefs;jobbancheck=[rank]'> BANNED</a></td></tr>"
			continue
		if(!job.player_old_enough(user.client))
			var/available_in_days = job.available_in_days(user.client)
			HTML += "<font color=red>[rank]</font></td><td><font color=red> \[IN [(available_in_days)] DAYS\]</font></td></tr>"
			continue
		if((job_civilian_low & ASSISTANT) && (rank != "Assistant") && !jobban_isbanned(user, "Assistant"))
			HTML += "<font color=orange>[rank]</font></td><td></td></tr>"
			continue
		if(config.enforce_human_authority && !user.client.prefs.pref_species.qualifies_for_rank(rank, user.client.prefs.features))
			if(user.client.prefs.pref_species.id == "human")
				HTML += "<font color=red>[rank]</font></td><td><font color=red><b> \[MUTANT\]</b></font></td></tr>"
			else
				HTML += "<font color=red>[rank]</font></td><td><font color=red><b> \[NON-HUMAN\]</b></font></td></tr>"
			continue
		if((rank in command_positions) || (rank == "AI"))//Bold head jobs
			HTML += "<b><span class='dark'>[rank]</span></b>"
		else
			HTML += "<span class='dark'>[rank]</span>"

		HTML += "</td><td width='40%'>"

		var/prefLevelLabel = "ERROR"
		var/prefLevelColor = "pink"
		var/prefUpperLevel = -1 // level to assign on left click
		var/prefLowerLevel = -1 // level to assign on right click

		if(GetJobDepartment(job, 1) & job.flag)
			prefLevelLabel = "High"
			prefLevelColor = "slateblue"
			prefUpperLevel = 4
			prefLowerLevel = 2
		else if(GetJobDepartment(job, 2) & job.flag)
			prefLevelLabel = "Medium"
			prefLevelColor = "green"
			prefUpperLevel = 1
			prefLowerLevel = 3
		else if(GetJobDepartment(job, 3) & job.flag)
			prefLevelLabel = "Low"
			prefLevelColor = "orange"
			prefUpperLevel = 2
			prefLowerLevel = 4
		else
			prefLevelLabel = "NEVER"
			prefLevelColor = "red"
			prefUpperLevel = 3
			prefLowerLevel = 1


		HTML += "<a class='white' href='?_src_=prefs;preference=job;task=setJobLevel;level=[prefUpperLevel];text=[rank]' oncontextmenu='javascript:return setJobPrefRedirect([prefLowerLevel], \"[rank]\");'>"

		if(rank == "Assistant")//Assistant is special
			if(job_civilian_low & ASSISTANT)
				HTML += "<font color=green>Yes</font>"
			else
				HTML += "<font color=red>No</font>"
			HTML += "</a></td></tr>"
			continue

		HTML += "<font color=[prefLevelColor]>[prefLevelLabel]</font>"
		HTML += "</a></td></tr>"

	for(var/i = 1, i < (limit - index), i += 1) // Finish the column so it is even
		HTML += "<tr bgcolor='[lastJob.selection_color]'><td width='60%' align='right'>&nbsp</td><td>&nbsp</td></tr>"

	HTML += "</td'></tr></table>"

	HTML += "</center></table>"

	var/message = "Be an Assistant if preferences unavailable"
	if(joblessrole == BERANDOMJOB)
		message = "Get random job if preferences unavailable"
	else if(joblessrole == RETURNTOLOBBY)
		message = "Return to lobby if preferences unavailable"
	HTML += "<center><br><a href='?_src_=prefs;preference=job;task=random'>[message]</a></center>"
	HTML += "<center><a href='?_src_=prefs;preference=job;task=reset'>Reset Preferences</a></center>"

	user << browse(null, "window=preferences")
	//user << browse(HTML, "window=mob_occupation;size=[width]x[height]")
	var/datum/browser/popup = new(user, "mob_occupation", "<div align='center'>Occupation Preferences</div>", width, height)
	popup.set_window_options("can_close=0")
	popup.set_content(HTML)
	popup.open(0)
	return

/datum/preferences/proc/SetJobPreferenceLevel(datum/job/job, level)
	if (!job)
		return 0

	if (level == 1) // to high
		// remove any other job(s) set to high
		job_civilian_med |= job_civilian_high
		job_engsec_med |= job_engsec_high
		job_medsci_med |= job_medsci_high
		job_civilian_high = 0
		job_engsec_high = 0
		job_medsci_high = 0

	if (job.department_flag == CIVILIAN)
		job_civilian_low &= ~job.flag
		job_civilian_med &= ~job.flag
		job_civilian_high &= ~job.flag

		switch(level)
			if (1)
				job_civilian_high |= job.flag
			if (2)
				job_civilian_med |= job.flag
			if (3)
				job_civilian_low |= job.flag

		return 1
	else if (job.department_flag == ENGSEC)
		job_engsec_low &= ~job.flag
		job_engsec_med &= ~job.flag
		job_engsec_high &= ~job.flag

		switch(level)
			if (1)
				job_engsec_high |= job.flag
			if (2)
				job_engsec_med |= job.flag
			if (3)
				job_engsec_low |= job.flag

		return 1
	else if (job.department_flag == MEDSCI)
		job_medsci_low &= ~job.flag
		job_medsci_med &= ~job.flag
		job_medsci_high &= ~job.flag

		switch(level)
			if (1)
				job_medsci_high |= job.flag
			if (2)
				job_medsci_med |= job.flag
			if (3)
				job_medsci_low |= job.flag

		return 1

	return 0

/datum/preferences/proc/UpdateJobPreference(mob/user, role, desiredLvl)
	if(!SSjob)
		return
	var/datum/job/job = SSjob.GetJob(role)

	if(!job)
		user << browse(null, "window=mob_occupation")
		ShowChoices(user)
		return

	if (!isnum(desiredLvl))
		user << "<span class='danger'>UpdateJobPreference - desired level was not a number. Please notify coders!</span>"
		ShowChoices(user)
		return

	if(role == "Assistant")
		if(job_civilian_low & job.flag)
			job_civilian_low &= ~job.flag
		else
			job_civilian_low |= job.flag
		SetChoices(user)
		return 1

	SetJobPreferenceLevel(job, desiredLvl)
	SetChoices(user)

	return 1


/datum/preferences/proc/ResetJobs()

	job_civilian_high = 0
	job_civilian_med = 0
	job_civilian_low = 0

	job_medsci_high = 0
	job_medsci_med = 0
	job_medsci_low = 0

	job_engsec_high = 0
	job_engsec_med = 0
	job_engsec_low = 0


/datum/preferences/proc/GetJobDepartment(datum/job/job, level)
	if(!job || !level)
		return 0
	switch(job.department_flag)
		if(CIVILIAN)
			switch(level)
				if(1)
					return job_civilian_high
				if(2)
					return job_civilian_med
				if(3)
					return job_civilian_low
		if(MEDSCI)
			switch(level)
				if(1)
					return job_medsci_high
				if(2)
					return job_medsci_med
				if(3)
					return job_medsci_low
		if(ENGSEC)
			switch(level)
				if(1)
					return job_engsec_high
				if(2)
					return job_engsec_med
				if(3)
					return job_engsec_low
	return 0

/datum/preferences/proc/process_link(mob/user, list/href_list)
	if(href_list["jobbancheck"])
		var/job = sanitizeSQL(href_list["jobbancheck"])
		var/sql_ckey = sanitizeSQL(user.ckey)
		var/DBQuery/query_get_jobban = dbcon.NewQuery("SELECT reason, bantime, duration, expiration_time, a_ckey FROM [format_table_name("ban")] WHERE ckey = '[sql_ckey]' AND job = '[job]' AND (bantype = 'JOB_PERMABAN'  OR (bantype = 'JOB_TEMPBAN' AND expiration_time > Now())) AND isnull(unbanned)")
		if(!query_get_jobban.Execute())
			var/err = query_get_jobban.ErrorMsg()
			log_game("SQL ERROR obtaining reason from ban table. Error : \[[err]\]\n")
			return
		if(query_get_jobban.NextRow())
			var/reason = query_get_jobban.item[1]
			var/bantime = query_get_jobban.item[2]
			var/duration = query_get_jobban.item[3]
			var/expiration_time = query_get_jobban.item[4]
			var/a_ckey = query_get_jobban.item[5]
			var/text
			text = "<span class='redtext'>You, or another user of this computer, ([user.ckey]) is banned from playing [job]. The ban reason is:<br>[reason]<br>This ban was applied by [a_ckey] on [bantime]"
			if(text2num(duration) > 0)
				text += ". The ban is for [duration] minutes and expires on [expiration_time] (server time)"
			text += ".</span>"
			user << text
		return

	if(href_list["preference"] == "job")
		switch(href_list["task"])
			if("close")
				user << browse(null, "window=mob_occupation")
				ShowChoices(user)
			if("reset")
				ResetJobs()
				SetChoices(user)
			if("random")
				switch(joblessrole)
					if(RETURNTOLOBBY)
						if(jobban_isbanned(user, "Assistant"))
							joblessrole = BERANDOMJOB
						else
							joblessrole = BEASSISTANT
					if(BEASSISTANT)
						joblessrole = BERANDOMJOB
					if(BERANDOMJOB)
						joblessrole = RETURNTOLOBBY
				SetChoices(user)
			if("setJobLevel")
				UpdateJobPreference(user, href_list["text"], text2num(href_list["level"]))
			else
				SetChoices(user)
		return 1

	switch(href_list["task"])
		if("random")
			switch(href_list["preference"])
				if("name")
					real_name = pref_species.random_name(gender,1)
				if("age")
					age = rand(AGE_MIN, AGE_MAX)
				if("hair")
					hair_color = random_short_color()
				if("hair_style")
					hair_style = random_hair_style(gender)
				if("facial")
					facial_hair_color = random_short_color()
				if("facial_hair_style")
					facial_hair_style = random_facial_hair_style(gender)
				if("underwear")
					underwear = random_underwear(gender)
				if("undershirt")
					undershirt = random_undershirt(gender)
				if("socks")
					socks = random_socks()
				if("eyes")
					eye_color = random_eye_color()
				if("s_tone")
					skin_tone = random_skin_tone()
				if("bag")
					backbag = pick(backbaglist)
				if("all")
					random_character()

		if("input")
			switch(href_list["preference"])
				if("ghostform")
					if(unlock_content)
						var/new_form = input(user, "Thanks for supporting BYOND - Choose your ghostly form:","Thanks for supporting BYOND",null) as null|anything in ghost_forms
						if(new_form)
							ghost_form = new_form
				if("ghostorbit")
					if(unlock_content)
						var/new_orbit = input(user, "Thanks for supporting BYOND - Choose your ghostly orbit:","Thanks for supporting BYOND", null) as null|anything in ghost_orbits
						if(new_orbit)
							ghost_orbit = new_orbit

				if("ghostaccs")
					var/new_ghost_accs = alert("Do you want your ghost to show full accessories where possible, hide accessories but still use the directional sprites where possible, or also ignore the directions and stick to the default sprites?",,GHOST_ACCS_FULL_NAME, GHOST_ACCS_DIR_NAME, GHOST_ACCS_NONE_NAME)
					switch(new_ghost_accs)
						if(GHOST_ACCS_FULL_NAME)
							ghost_accs = GHOST_ACCS_FULL
						if(GHOST_ACCS_DIR_NAME)
							ghost_accs = GHOST_ACCS_DIR
						if(GHOST_ACCS_NONE_NAME)
							ghost_accs = GHOST_ACCS_NONE

				if("ghostothers")
					var/new_ghost_others = alert("Do you want the ghosts of others to show up as their own setting, as their default sprites or always as the default white ghost?",,GHOST_OTHERS_THEIR_SETTING_NAME, GHOST_OTHERS_DEFAULT_SPRITE_NAME, GHOST_OTHERS_SIMPLE_NAME)
					switch(new_ghost_others)
						if(GHOST_OTHERS_THEIR_SETTING_NAME)
							ghost_others = GHOST_OTHERS_THEIR_SETTING
						if(GHOST_OTHERS_DEFAULT_SPRITE_NAME)
							ghost_others = GHOST_OTHERS_DEFAULT_SPRITE
						if(GHOST_OTHERS_SIMPLE_NAME)
							ghost_others = GHOST_OTHERS_SIMPLE

				if("name")
					var/new_name = reject_bad_name( input(user, "Choose your character's name:", "Character Preference")  as text|null )
					if(new_name)
						real_name = new_name
					else
						user << "<font color='red'>Invalid name. Your name should be at least 2 and at most [MAX_NAME_LEN] characters long. It may only contain the characters A-Z, a-z, -, ' and .</font>"

				if("age")
					var/new_age = input(user, "Choose your character's age:\n([AGE_MIN]-[AGE_MAX])", "Character Preference") as num|null
					if(new_age)
						age = max(min( round(text2num(new_age)), AGE_MAX),AGE_MIN)

				if("metadata")
					var/new_metadata = input(user, "Enter any information you'd like others to see, such as Roleplay-preferences:", "Game Preference" , metadata)  as message|null
					if(new_metadata)
						metadata = sanitize(copytext(new_metadata,1,MAX_MESSAGE_LEN))

				if("hair")
					var/new_hair = input(user, "Choose your character's hair colour:", "Character Preference") as null|color
					if(new_hair)
						hair_color = sanitize_hexcolor(new_hair)


				if("hair_style")
					var/new_hair_style
					if(gender == MALE)
						new_hair_style = input(user, "Choose your character's hair style:", "Character Preference")  as null|anything in hair_styles_male_list
					else
						new_hair_style = input(user, "Choose your character's hair style:", "Character Preference")  as null|anything in hair_styles_female_list
					if(new_hair_style)
						hair_style = new_hair_style

				if("next_hair_style")
					if (gender == MALE)
						hair_style = next_list_item(hair_style, hair_styles_male_list)
					else
						hair_style = next_list_item(hair_style, hair_styles_female_list)

				if("previous_hair_style")
					if (gender == MALE)
						hair_style = previous_list_item(hair_style, hair_styles_male_list)
					else
						hair_style = previous_list_item(hair_style, hair_styles_female_list)

				if("facial")
					var/new_facial = input(user, "Choose your character's facial-hair colour:", "Character Preference") as null|color
					if(new_facial)
						facial_hair_color = sanitize_hexcolor(new_facial)

				if("facial_hair_style")
					var/new_facial_hair_style
					if(gender == MALE)
						new_facial_hair_style = input(user, "Choose your character's facial-hair style:", "Character Preference")  as null|anything in facial_hair_styles_male_list
					else
						new_facial_hair_style = input(user, "Choose your character's facial-hair style:", "Character Preference")  as null|anything in facial_hair_styles_female_list
					if(new_facial_hair_style)
						facial_hair_style = new_facial_hair_style

				if("next_facehair_style")
					if (gender == MALE)
						facial_hair_style = next_list_item(facial_hair_style, facial_hair_styles_male_list)
					else
						facial_hair_style = next_list_item(facial_hair_style, facial_hair_styles_female_list)

				if("previous_facehair_style")
					if (gender == MALE)
						facial_hair_style = previous_list_item(facial_hair_style, facial_hair_styles_male_list)
					else
						facial_hair_style = previous_list_item(facial_hair_style, facial_hair_styles_female_list)

				if("underwear")
					var/new_underwear
					if(gender == MALE)
						new_underwear = input(user, "Choose your character's underwear:", "Character Preference")  as null|anything in underwear_m
					else
						new_underwear = input(user, "Choose your character's underwear:", "Character Preference")  as null|anything in underwear_f
					if(new_underwear)
						underwear = new_underwear

				if("undershirt")
					var/new_undershirt
					if(gender == MALE)
						new_undershirt = input(user, "Choose your character's undershirt:", "Character Preference") as null|anything in undershirt_m
					else
						new_undershirt = input(user, "Choose your character's undershirt:", "Character Preference") as null|anything in undershirt_f
					if(new_undershirt)
						undershirt = new_undershirt

				if("socks")
					var/new_socks
					new_socks = input(user, "Choose your character's socks:", "Character Preference") as null|anything in socks_list
					if(new_socks)
						socks = new_socks

				if("eyes")
					var/new_eyes = input(user, "Choose your character's eye colour:", "Character Preference") as color|null
					if(new_eyes)
						eye_color = sanitize_hexcolor(new_eyes)

				if("species")

					var/result = input(user, "Select a species", "Species Selection") as null|anything in roundstart_species

					if(result)
						var/newtype = roundstart_species[result]
						pref_species = new newtype()
						//Now that we changed our species, we must verify that the mutant colour is still allowed.
						var/temp_hsv = RGBtoHSV(features["mcolor"])
						if(features["mcolor"] == "#000" || (!(MUTCOLORS_PARTSONLY in pref_species.specflags) && ReadHSV(temp_hsv)[3] < ReadHSV("#7F7F7F")[3]))
							features["mcolor"] = pref_species.default_color
				if("mutant_color")
					var/new_mutantcolor = input(user, "Choose your character's alien/mutant color:", "Character Preference") as color|null
					if(new_mutantcolor)
						var/temp_hsv = RGBtoHSV(new_mutantcolor)
						if(new_mutantcolor == "#000000")
							features["mcolor"] = pref_species.default_color
						else if((MUTCOLORS_PARTSONLY in pref_species.specflags) || ReadHSV(temp_hsv)[3] >= ReadHSV("#7F7F7F")[3]) // mutantcolors must be bright, but only if they affect the skin
							features["mcolor"] = sanitize_hexcolor(new_mutantcolor)
						else
							user << "<span class='danger'>Invalid color. Your color is not bright enough.</span>"

				if("tail_lizard")
					var/new_tail
					new_tail = input(user, "Choose your character's tail:", "Character Preference") as null|anything in tails_list_lizard
					if(new_tail)
						features["tail_lizard"] = new_tail

				if("tail_human")
					var/new_tail
					new_tail = input(user, "Choose your character's tail:", "Character Preference") as null|anything in tails_list_human
					if(new_tail)
						features["tail_human"] = new_tail

				if("snout")
					var/new_snout
					new_snout = input(user, "Choose your character's snout:", "Character Preference") as null|anything in snouts_list
					if(new_snout)
						features["snout"] = new_snout

				if("horns")
					var/new_horns
					new_horns = input(user, "Choose your character's horns:", "Character Preference") as null|anything in horns_list
					if(new_horns)
						features["horns"] = new_horns

				if("ears")
					var/new_ears
					new_ears = input(user, "Choose your character's ears:", "Character Preference") as null|anything in ears_list
					if(new_ears)
						features["ears"] = new_ears

				if("wings")
					var/new_wings
					new_wings = input(user, "Choose your character's wings:", "Character Preference") as null|anything in r_wings_list
					if(new_wings)
						features["wings"] = new_wings

				if("frills")
					var/new_frills
					new_frills = input(user, "Choose your character's frills:", "Character Preference") as null|anything in frills_list
					if(new_frills)
						features["frills"] = new_frills

				if("spines")
					var/new_spines
					new_spines = input(user, "Choose your character's spines:", "Character Preference") as null|anything in spines_list
					if(new_spines)
						features["spines"] = new_spines

				if("body_markings")
					var/new_body_markings
					new_body_markings = input(user, "Choose your character's body markings:", "Character Preference") as null|anything in body_markings_list
					if(new_body_markings)
						features["body_markings"] = new_body_markings

				if("s_tone")
					var/new_s_tone = input(user, "Choose your character's skin-tone:", "Character Preference")  as null|anything in skin_tones
					if(new_s_tone)
						skin_tone = new_s_tone

				if("ooccolor")
					var/new_ooccolor = input(user, "Choose your OOC colour:", "Game Preference") as color|null
					if(new_ooccolor)
						ooccolor = sanitize_ooccolor(new_ooccolor)

				if("bag")
					var/new_backbag = input(user, "Choose your character's style of bag:", "Character Preference")  as null|anything in backbaglist
					if(new_backbag)
						backbag = new_backbag

				if("clown_name")
					var/new_clown_name = reject_bad_name( input(user, "Choose your character's clown name:", "Character Preference")  as text|null )
					if(new_clown_name)
						custom_names["clown"] = new_clown_name
					else
						user << "<font color='red'>Invalid name. Your name should be at least 2 and at most [MAX_NAME_LEN] characters long. It may only contain the characters A-Z, a-z, -, ' and .</font>"

				if("mime_name")
					var/new_mime_name = reject_bad_name( input(user, "Choose your character's mime name:", "Character Preference")  as text|null )
					if(new_mime_name)
						custom_names["mime"] = new_mime_name
					else
						user << "<font color='red'>Invalid name. Your name should be at least 2 and at most [MAX_NAME_LEN] characters long. It may only contain the characters A-Z, a-z, -, ' and .</font>"

				if("ai_name")
					var/new_ai_name = reject_bad_name( input(user, "Choose your character's AI name:", "Character Preference")  as text|null, 1 )
					if(new_ai_name)
						custom_names["ai"] = new_ai_name
					else
						user << "<font color='red'>Invalid name. Your name should be at least 2 and at most [MAX_NAME_LEN] characters long. It may only contain the characters A-Z, a-z, 0-9, -, ' and .</font>"

				if("cyborg_name")
					var/new_cyborg_name = reject_bad_name( input(user, "Choose your character's cyborg name:", "Character Preference")  as text|null, 1 )
					if(new_cyborg_name)
						custom_names["cyborg"] = new_cyborg_name
					else
						user << "<font color='red'>Invalid name. Your name should be at least 2 and at most [MAX_NAME_LEN] characters long. It may only contain the characters A-Z, a-z, 0-9, -, ' and .</font>"

				if("religion_name")
					var/new_religion_name = reject_bad_name( input(user, "Choose your character's religion:", "Character Preference")  as text|null )
					if(new_religion_name)
						custom_names["religion"] = new_religion_name
					else
						user << "<font color='red'>Invalid name. Your name should be at least 2 and at most [MAX_NAME_LEN] characters long. It may only contain the characters A-Z, a-z, -, ' and .</font>"

				if("deity_name")
					var/new_deity_name = reject_bad_name( input(user, "Choose your character's deity:", "Character Preference")  as text|null )
					if(new_deity_name)
						custom_names["deity"] = new_deity_name
					else
						user << "<font color='red'>Invalid name. Your name should be at least 2 and at most [MAX_NAME_LEN] characters long. It may only contain the characters A-Z, a-z, -, ' and .</font>"
				if ("preferred_map")
					var/maplist = list()
					var/default = "Default"
					if (config.defaultmap)
						default += " ([config.defaultmap.friendlyname])"
					for (var/M in config.maplist)
						var/datum/votablemap/VM = config.maplist[M]
						var/friendlyname = "[VM.friendlyname] "
						if (VM.voteweight <= 0)
							friendlyname += " (disabled)"
						maplist[friendlyname] = VM.name
					maplist[default] = null
					var/pickedmap = input(user, "Choose your preferred map. This will be used to help weight random map selection.", "Character Preference")  as null|anything in maplist
					if (pickedmap)
						preferred_map = maplist[pickedmap]


		else
			switch(href_list["preference"])
				if("publicity")
					if(unlock_content)
						toggles ^= MEMBER_PUBLIC
				if("gender")
					if(gender == MALE)
						gender = FEMALE
					else
						gender = MALE
					underwear = random_underwear(gender)
					undershirt = random_undershirt(gender)
					socks = random_socks()
					facial_hair_style = random_facial_hair_style(gender)
					hair_style = random_hair_style(gender)

				if("ui")
					switch(UI_style)
						if("Midnight")
							UI_style = "Plasmafire"
						if("Plasmafire")
							UI_style = "Retro"
						if("Retro")
							UI_style = "Slimecore"
						if("Slimecore")
							UI_style = "Operative"
						else
							UI_style = "Midnight"

				if("hotkeys")
					hotkeys = !hotkeys

				if("tgui_fancy")
					tgui_fancy = !tgui_fancy
				if("tgui_lock")
					tgui_lock = !tgui_lock

				if("hear_adminhelps")
					toggles ^= SOUND_ADMINHELP
				if("announce_login")
					toggles ^= ANNOUNCE_LOGIN

				if("be_special")
					var/be_special_type = href_list["be_special_type"]
					if(be_special_type in be_special)
						be_special -= be_special_type
					else
						be_special += be_special_type

				if("name")
					be_random_name = !be_random_name

				if("all")
					be_random_body = !be_random_body

				if("hear_midis")
					toggles ^= SOUND_MIDI

				if("lobby_music")
					toggles ^= SOUND_LOBBY
					if(toggles & SOUND_LOBBY)
						user << sound(ticker.login_music, repeat = 0, wait = 0, volume = 85, channel = 1)
					else
						user.stopLobbySound()

				if("ghost_ears")
					chat_toggles ^= CHAT_GHOSTEARS

				if("ghost_sight")
					chat_toggles ^= CHAT_GHOSTSIGHT

				if("ghost_whispers")
					chat_toggles ^= CHAT_GHOSTWHISPER

				if("ghost_radio")
					chat_toggles ^= CHAT_GHOSTRADIO

				if("ghost_pda")
					chat_toggles ^= CHAT_GHOSTPDA

				if("pull_requests")
					chat_toggles ^= CHAT_PULLR

				if("allow_midround_antag")
					toggles ^= MIDROUND_ANTAG

				if("save")
					save_preferences()
					save_character()

				if("load")
					load_preferences()
					load_character()

				if("changeslot")
					if(!load_character(text2num(href_list["num"])))
						random_character()
						real_name = random_unique_name(gender)
						save_character()

				if("tab")
					if (href_list["tab"])
						current_tab = text2num(href_list["tab"])

	ShowChoices(user)
	return 1

/datum/preferences/proc/copy_to(mob/living/carbon/human/character, icon_updates = 1)
	if(be_random_name)
		real_name = pref_species.random_name(gender)

	if(be_random_body)
		random_character(gender)

	if(config.humans_need_surnames)
		var/firstspace = findtext(real_name, " ")
		var/name_length = length(real_name)
		if(!firstspace)	//we need a surname
			real_name += " [pick(last_names)]"
		else if(firstspace == name_length)
			real_name += "[pick(last_names)]"

	character.real_name = real_name
	character.name = character.real_name

	character.gender = gender
	character.age = age

	character.eye_color = eye_color
	character.hair_color = hair_color
	character.facial_hair_color = facial_hair_color

	character.skin_tone = skin_tone
	character.hair_style = hair_style
	character.facial_hair_style = facial_hair_style
	character.underwear = underwear
	character.undershirt = undershirt
	character.socks = socks

	character.backbag = backbag

	character.dna.features = features.Copy()
	character.dna.real_name = character.real_name
	var/datum/species/chosen_species
	if(pref_species != /datum/species/human && config.mutant_races)
		chosen_species = pref_species.type
	else
		chosen_species = /datum/species/human
	character.set_species(chosen_species, icon_update=0)

	if(icon_updates)
		character.update_body()
		character.update_hair()
		character.update_body_parts()
=======
//This file was auto-corrected by findeclaration.exe on 25.5.2012 20:42:33

var/list/preferences_datums = list()

var/global/list/special_roles = list(
	ROLE_ALIEN        = 1, //always show
	ROLE_BLOB         = 1,
	ROLE_BORER        = 1,
	ROLE_CHANGELING   = IS_MODE_COMPILED("changeling"),
	ROLE_CULTIST      = IS_MODE_COMPILED("cult"),
	ROLE_PLANT        = 1,
	"infested monkey" = IS_MODE_COMPILED("monkey"),
	ROLE_MALF         = IS_MODE_COMPILED("malfunction"),
	//ROLE_NINJA        = 1,
	ROLE_OPERATIVE    = IS_MODE_COMPILED("nuclear"),
	ROLE_PAI          = 1, // -- TLE
	ROLE_POSIBRAIN    = 1,
	ROLE_REV          = IS_MODE_COMPILED("revolution"),
	ROLE_TRAITOR      = IS_MODE_COMPILED("traitor"),
	ROLE_VAMPIRE      = IS_MODE_COMPILED("vampire"),
	ROLE_VOXRAIDER    = IS_MODE_COMPILED("heist"),
	ROLE_WIZARD       = 1,
)

var/list/antag_roles = list(
	ROLE_ALIEN        = 1,
	ROLE_BLOB         = 1,
	ROLE_CHANGELING   = IS_MODE_COMPILED("changeling"),
	ROLE_CULTIST      = IS_MODE_COMPILED("cult"),
	ROLE_MALF         = IS_MODE_COMPILED("malfunction"),
	ROLE_OPERATIVE    = IS_MODE_COMPILED("nuclear"),
	ROLE_REV          = IS_MODE_COMPILED("revolution"),
	ROLE_TRAITOR      = IS_MODE_COMPILED("traitor"),
	ROLE_VAMPIRE      = IS_MODE_COMPILED("vampire"),
	ROLE_VOXRAIDER    = IS_MODE_COMPILED("heist"),
	ROLE_WIZARD       = 1,
)

var/list/nonantag_roles = list(
	ROLE_BORER        = 1,
	ROLE_PLANT        = 1,
	ROLE_PAI          = 1,
	ROLE_POSIBRAIN    = 1,
)

var/list/role_wiki=list(
	ROLE_ALIEN		= "Xenomorph",
	ROLE_BLOB		= "Blob",
	ROLE_BORER		= "Cortical_Borer",
	ROLE_CHANGELING	= "Changeling",
	ROLE_CULTIST	= "Cult",
	ROLE_PLANT		= "Dionaea",
	ROLE_MALF		= "Guide_to_Malfunction",
	ROLE_OPERATIVE	= "Nuclear_Agent",
	ROLE_PAI		= "Personal_AI",
	ROLE_POSIBRAIN	= "Guide_to_Silicon_Laws",
	ROLE_REV		= "Revolution",
	ROLE_TRAITOR	= "Traitor",
	ROLE_VAMPIRE	= "Vampire",
	ROLE_VOXRAIDER	= "Vox_Raider",
	ROLE_WIZARD		= "Wizard",
)

var/const/MAX_SAVE_SLOTS = 8

//used for alternate_option
#define GET_RANDOM_JOB 0
#define BE_ASSISTANT 1
#define RETURN_TO_LOBBY 2
#define POLLED_LIMIT	300

/datum/preferences
	//doohickeys for savefiles
	var/database/db = ("players2.sqlite")
	var/path
	var/default_slot = 1				//Holder so it doesn't default to slot 1, rather the last one used
	var/slot = 1
	var/list/slot_names = new
	var/lastPolled = 0

	var/savefile_version = 0

	//non-preference stuff
	var/warns = 0
	var/warnbans = 0
	var/muted = 0
	var/last_ip
	var/last_id

	//game-preferences
	var/lastchangelog = ""				//Saved changlog filesize to detect if there was a change
	var/ooccolor = "#b82e00"
	var/UI_style = "Midnight"
	var/toggles = TOGGLES_DEFAULT
	var/UI_style_color = "#ffffff"
	var/UI_style_alpha = 255
	var/space_parallax = 1
	var/space_dust = 1
	var/parallax_speed = 2
	var/special_popup = 0

	//character preferences
	var/real_name						//our character's name
	var/be_random_name = 0				//whether we are a random name every round
	var/be_random_body = 0				//whether we'll have a random body every round
	var/gender = MALE					//gender of character (well duh)
	var/age = 30						//age of character
	var/underwear = 1					//underwear type
	var/backbag = 2						//backpack type
	var/h_style = "Bald"				//Hair type
	var/r_hair = 0						//Hair color
	var/g_hair = 0						//Hair color
	var/b_hair = 0						//Hair color
	var/f_style = "Shaved"				//Face hair type
	var/r_facial = 0					//Face hair color
	var/g_facial = 0					//Face hair color
	var/b_facial = 0					//Face hair color
	var/s_tone = 0						//Skin color
	var/r_eyes = 0						//Eye color
	var/g_eyes = 0						//Eye color
	var/b_eyes = 0						//Eye color
	var/species = "Human"
	var/language = "None"				//Secondary language

		//Mob preview
	var/icon/preview_icon = null
	var/icon/preview_icon_front = null
	var/icon/preview_icon_side = null

		//Jobs, uses bitflags
	var/job_civilian_high = 0
	var/job_civilian_med = 0
	var/job_civilian_low = 0

	var/job_medsci_high = 0
	var/job_medsci_med = 0
	var/job_medsci_low = 0

	var/job_engsec_high = 0
	var/job_engsec_med = 0
	var/job_engsec_low = 0

	//Keeps track of preferrence for not getting any wanted jobs
	var/alternate_option = 0

	var/used_skillpoints = 0
	var/skill_specialization = null
	var/list/skills = list() // skills can range from 0 to 3

	// maps each organ to either null(intact), "cyborg" or "amputated"
	// will probably not be able to do this for head and torso ;)
	var/list/organ_data = list()

	var/list/player_alt_titles = new()		// the default name of a job like "Medical Doctor"

	var/flavor_text = ""
	var/med_record = ""
	var/sec_record = ""
	var/gen_record = ""
	var/disabilities = 0 // NOW A BITFIELD, SEE ABOVE

	var/nanotrasen_relation = "Neutral"

	// 0 = character settings, 1 = game preferences
	var/current_tab = 0

		// OOC Metadata:
	var/metadata = ""
	var/slot_name = ""

	// Whether or not to use randomized character slots
	var/randomslot = 0

	// jukebox volume
	var/volume = 100
	var/usewmp = 0 //whether to use WMP or VLC

	var/list/roles=list() // "role" => ROLEPREF_*

	var/usenanoui = 1 //Whether or not this client will use nanoUI, this doesn't do anything other than objects being able to check this.

	var/progress_bars = 1 //Whether to show progress bars when doing delayed actions.
	var/client/client
	var/saveloaded = 0

/datum/preferences/New(client/C)
	client=C
	if(istype(C))
		var/theckey = C.ckey
		var/thekey = C.key
		spawn()
			if(!IsGuestKey(thekey))
				var/load_pref = load_preferences_sqlite(theckey)
				if(load_pref)
					while(!speciesinit)
						sleep(1)
					try_load_save_sqlite(theckey, C, default_slot)
					return

			while(!speciesinit)
				sleep(1)
			randomize_appearance_for()
			real_name = random_name(gender)
			save_character_sqlite(theckey, C, default_slot)
			saveloaded = 1

/datum/preferences/proc/try_load_save_sqlite(var/theckey, var/theclient, var/theslot)
	var/attempts = 0
	while(!load_save_sqlite(theckey, theclient, theslot) && attempts < 5)
		sleep(15)
		attempts++
	if(attempts >= 5)//failsafe so people don't get locked out of the round forever
		randomize_appearance_for()
		real_name = random_name(gender)
		log_debug("Player [theckey] FAILED to load save 5 times and has been randomized.")
		log_admin("Player [theckey] FAILED to load save 5 times and has been randomized.")
		if(theclient)
			alert(theclient, "For some reason you've failed to load your save slot 5 times now, so you've been generated a random character. Don't worry, it didn't overwrite your old one.","Randomized Character", "OK")
	saveloaded = 1

/datum/preferences/proc/setup_character_options(var/dat, var/user)


	dat += {"<center><h2>Occupation Choices</h2>
	<a href='?_src_=prefs;preference=job;task=menu'>Set Occupation Preferences</a><br></center>
	<h2>Identity</h2>
	<table width='100%'><tr><td width='75%' valign='top'>
	<a href='?_src_=prefs;preference=name;task=random'>Random Name</a>
	<a href='?_src_=prefs;preference=name'>Always Random Name: [be_random_name ? "Yes" : "No"]</a><br>
	<b>Name:</b> <a href='?_src_=prefs;preference=name;task=input'>[real_name]</a><BR>
	<b>Gender:</b> <a href='?_src_=prefs;preference=gender'>[gender == MALE ? "Male" : "Female"]</a><BR>
	<b>Age:</b> <a href='?_src_=prefs;preference=age;task=input'>[age]</a>
	</td><td valign='center'>
	<div class='statusDisplay'><center><img src=previewicon.png class="charPreview"><img src=previewicon2.png class="charPreview"></center></div>
	</td></tr></table>
	<h2>Body</h2>
	<a href='?_src_=prefs;preference=all;task=random'>Random Body</A>
	<a href='?_src_=prefs;preference=all'>Always Random Body: [be_random_body ? "Yes" : "No"]</A><br>
	<table width='100%'><tr><td width='24%' valign='top'>
	<b>Species:</b> <a href='?_src_=prefs;preference=species;task=input'>[species]</a><BR>
	<b>Secondary Language:</b> <a href='byond://?src=\ref[user];preference=language;task=input'>[language]</a><br>
	<b>Skin Tone:</b> <a href='?_src_=prefs;preference=s_tone;task=input'>[species == "Human" ? "[-s_tone + 35]/220" : "[s_tone]"]</a><br><BR>
	<b>Handicaps:</b> <a href='byond://?src=\ref[user];task=input;preference=disabilities'><b>Set</a></b><br>
	<b>Limbs:</b> <a href='byond://?src=\ref[user];preference=limbs;task=input'>Set</a><br>
	<b>Organs:</b> <a href='byond://?src=\ref[user];preference=organs;task=input'>Set</a><br>
	<b>Underwear:</b> [gender == MALE ? "<a href ='?_src_=prefs;preference=underwear;task=input'><b>[underwear_m[underwear]]</a>" : "<a href ='?_src_=prefs;preference=underwear;task=input'><b>[underwear_f[underwear]]</a>"]<br>
	<b>Backpack:</b> <a href ='?_src_=prefs;preference=bag;task=input'><b>[backbaglist[backbag]]</a><br>
	<b>Nanotrasen Relation</b>:<br><a href ='?_src_=prefs;preference=nt_relation;task=input'><b>[nanotrasen_relation]</b></a>
	</td><td valign='top' width='21%'>
	<h3>Hair Style</h3>
	<a href='?_src_=prefs;preference=h_style;task=input'>[h_style]</a><BR>
	<a href='?_src_=prefs;preference=previous_hair_style;task=input'>&lt;</a> <a href='?_src_=prefs;preference=next_hair_style;task=input'>&gt;</a><BR>
	<span style='border:1px solid #161616; background-color: #[num2hex(r_hair, 2)][num2hex(g_hair, 2)][num2hex(b_hair, 2)];'>&nbsp;&nbsp;&nbsp;</span> <a href='?_src_=prefs;preference=hair;task=input'>Change</a><BR>
	</td><td valign='top' width='21%'>
	<h3>Facial Hair Style</h3>
	<a href='?_src_=prefs;preference=f_style;task=input'>[f_style]</a><BR>
	<a href='?_src_=prefs;preference=previous_facehair_style;task=input'>&lt;</a> <a href='?_src_=prefs;preference=next_facehair_style;task=input'>&gt;</a><BR>
	<span style='border: 1px solid #161616; background-color: #[num2hex(r_facial, 2)][num2hex(g_facial, 2)][num2hex(b_facial, 2)];'>&nbsp;&nbsp;&nbsp;</span> <a href='?_src_=prefs;preference=facial;task=input'>Change</a><BR>
	</td><td valign='top' width='21%'>
	<h3>Eye Color</h3>
	<span style='border: 1px solid #161616; background-color: #[num2hex(r_eyes, 2)][num2hex(g_eyes, 2)][num2hex(b_eyes, 2)];'>&nbsp;&nbsp;&nbsp;</span> <a href='?_src_=prefs;preference=eyes;task=input'>Change</a><BR>
	</tr></td></table>
	"}

	return dat

/datum/preferences/proc/setup_UI(var/dat, var/user)


	dat += {"<b>UI Style:</b> <a href='?_src_=prefs;preference=ui'><b>[UI_style]</b></a><br>
	<b>Custom UI</b>(recommended for White UI): <span style='border:1px solid #161616; background-color: #[UI_style_color];'>&nbsp;&nbsp;&nbsp;</span><br>Color: <a href='?_src_=prefs;preference=UIcolor'><b>[UI_style_color]</b></a><br>
	Alpha(transparency): <a href='?_src_=prefs;preference=UIalpha'><b>[UI_style_alpha]</b></a><br>
	"}

	return dat

/datum/preferences/proc/setup_special(var/dat, var/user)
	dat += {"<table><tr><td width='340px' height='300px' valign='top'>
	<h2>General Settings</h2>
	<b>Space Parallax:</b> <a href='?_src_=prefs;preference=parallax'><b>[space_parallax ? "Enabled" : "Disabled"]</b></a><br>
	<b>Parallax Speed:</b> <a href='?_src_=prefs;preference=p_speed'><b>[parallax_speed]</b></a><br>
	<b>Space Dust:</b> <a href='?_src_=prefs;preference=dust'><b>[space_dust ? "Yes" : "No"]</b></a><br>
	<b>Play admin midis:</b> <a href='?_src_=prefs;preference=hear_midis'><b>[(toggles & SOUND_MIDI) ? "Yes" : "No"]</b></a><br>
	<b>Play lobby music:</b> <a href='?_src_=prefs;preference=lobby_music'><b>[(toggles & SOUND_LOBBY) ? "Yes" : "No"]</b></a><br>
	<b>Hear streamed media:</b> <a href='?_src_=prefs;preference=jukebox'><b>[(toggles & SOUND_STREAMING) ? "Yes" : "No"]</b></a><br>
	<b>Use WMP:</b> <a href='?_src_=prefs;preference=wmp'><b>[(usewmp) ? "Yes" : "No"]</b></a><br>
	<b>Use NanoUI:</b> <a href='?_src_=prefs;preference=nanoui'><b>[(usenanoui) ? "Yes" : "No"]</b></a><br>
	<b>Progress Bars:</b> <a href='?_src_=prefs;preference=progbar'><b>[(progress_bars) ? "Yes" : "No"]</b></a><br>
	<b>Randomized Character Slot:</b> <a href='?_src_=prefs;preference=randomslot'><b>[randomslot ? "Yes" : "No"]</b></a><br>
	<b>Ghost ears:</b> <a href='?_src_=prefs;preference=ghost_ears'><b>[(toggles & CHAT_GHOSTEARS) ? "All Speech" : "Nearby Speech"]</b></a><br>
	<b>Ghost sight:</b> <a href='?_src_=prefs;preference=ghost_sight'><b>[(toggles & CHAT_GHOSTSIGHT) ? "All Emotes" : "Nearby Emotes"]</b></a><br>
	<b>Ghost radio:</b> <a href='?_src_=prefs;preference=ghost_radio'><b>[(toggles & CHAT_GHOSTRADIO) ? "All Chatter" : "Nearby Speakers"]</b></a><br>
	<b>Ghost PDA:</b> <a href='?_src_=prefs;preference=ghost_pda'><b>[(toggles & CHAT_GHOSTPDA) ? "All PDA Messages" : "No PDA Messages"]</b></a><br>
	<b>Special Windows: </b><a href='?_src_=prefs;preference=special_popup'><b>[special_popup ? "Yes" : "No"]</b></a><br>
	<b>Character Records:<b> [jobban_isbanned(user, "Records") ? "Banned" : "<a href=\"byond://?src=\ref[user];preference=records;record=1\">Set</a></b><br>"]
	<b>Flavor Text:</b><a href='byond://?src=\ref[user];preference=flavor_text;task=input'>Set</a><br>
	"}

	if(config.allow_Metadata)
		dat += "<b>OOC Notes:</b> <a href='?_src_=prefs;preference=metadata;task=input'> Edit </a><br>"

	dat += "</td><td width='300px' height='300px' valign='top'><h2>Antagonist Settings</h2>"

	if(jobban_isbanned(user, "Syndicate"))
		dat += "<b>You are banned from antagonist roles.</b>"
	else
		for (var/i in antag_roles)
			if(antag_roles[i]) //if mode is available on the server
				if(jobban_isbanned(user, i))
					dat += "<b>Be [i]:</b> <font color=red><b> \[BANNED]</b></font><br>"
				else if(i == "pai candidate")
					if(jobban_isbanned(user, "pAI"))
						dat += "<b>Be [i]:</b> <font color=red><b> \[BANNED]</b></font><br>"
				else
					var/wikiroute = role_wiki[i]
					dat += "<b>Be [i]:</b> <a href='?_src_=prefs;preference=toggle_role;role_id=[i]'><b>[roles[i] & ROLEPREF_ENABLE ? "Yes" : "No"]</b></a> [wikiroute ? "<a HREF='?src=\ref[user];getwiki=[wikiroute]'>wiki</a>" : ""]<br>"

	dat += "</td><td width='300px' height='300px' valign='top'><h2>Special Roles Settings</h2>"

	for (var/i in nonantag_roles)
		if(nonantag_roles[i]) //if mode is available on the server
			if(jobban_isbanned(user, i))
				dat += "<b>Be [i]:</b> <font color=red><b> \[BANNED]</b></font><br>"
			else if(i == "pai candidate")
				if(jobban_isbanned(user, "pAI"))
					dat += "<b>Be [i]:</b> <font color=red><b> \[BANNED]</b></font><br>"
			else
				var/wikiroute = role_wiki[i]
				dat += "<b>Be [i]:</b> <a href='?_src_=prefs;preference=toggle_role;role_id=[i]'><b>[roles[i] & ROLEPREF_ENABLE ? "Yes" : "No"]</b></a> [wikiroute ? "<a HREF='?src=\ref[user];getwiki=[wikiroute]'>wiki</a>" : ""]<br>"

	dat += "</td></tr></table>"
	return dat
/datum/preferences/proc/getPrefLevelText(var/datum/job/job)
	if(GetJobDepartment(job, 1) & job.flag)
		return "High"
	else if(GetJobDepartment(job, 2) & job.flag)
		return "Medium"
	else if(GetJobDepartment(job, 3) & job.flag)
		return "Low"
	else
		return "NEVER"
/datum/preferences/proc/getPrefLevelUpOrDown(var/datum/job/job, var/inc)
	if(GetJobDepartment(job, 1) & job.flag)
		if(inc)
			return "NEVER"
		else
			return "Medium"
	else if(GetJobDepartment(job, 2) & job.flag)
		if(inc)
			return "High"
		else
			return "Low"
	else if(GetJobDepartment(job, 3) & job.flag)
		if(inc)
			return "Medium"
		else
			return "NEVER"
	else
		if(inc)
			return "Low"
		else
			return "High"

/datum/preferences/proc/SetChoices(mob/user, limit = 17, list/splitJobs = list("Chief Engineer", "AI"), widthPerColumn = 295, height = 620)
	if(!job_master)
		return

	//limit 	 - The amount of jobs allowed per column. Defaults to 17 to make it look nice.
	//splitJobs - Allows you split the table by job. You can make different tables for each department by including their heads. Defaults to CE to make it look nice.
	//width	 - Screen' width. Defaults to 550 to make it look nice.
	//height 	 - Screen's height. Defaults to 500 to make it look nice.
	var/width = widthPerColumn


	var/HTML = "<link href='./common.css' rel='stylesheet' type='text/css'><body>"
	HTML += {"<script type='text/javascript'>function setJobPrefRedirect(level, rank) { window.location.href='?_src_=prefs;preference=job;task=input;level=' + level + ';text=' + encodeURIComponent(rank); return false; }
			function mouseDown(event,levelup,leveldown,rank){
				return false;
				}

			function mouseUp(event,levelup,leveldown,rank){
				if(event.button == 0){
					//alert("left click " + levelup + " " + rank);
					setJobPrefRedirect(1, rank);
					return false;
					}
				if(event.button == 2){
					//alert("right click " + leveldown + " " + rank);
					setJobPrefRedirect(0, rank);
					return false;
					}

				return true;
				}
			</script>"}


	HTML += {"<center>
		<b>Choose occupation chances</b><br>
		<div align='center'>Left-click to raise an occupation preference, right-click to lower it.<br><div>
		<a href='?_src_=prefs;preference=job;task=close'>Done</a></center><br>
		<table width='100%' cellpadding='1' cellspacing='0'><tr><td width='20%'>
		<table width='100%' cellpadding='1' cellspacing='0'>"}


	var/index = -1

	//The job before the current job. I only use this to get the previous jobs color when I'm filling in blank rows.
	var/datum/job/lastJob
	if (!job_master)		return
	for(var/datum/job/job in job_master.occupations)
		index += 1
		if((index >= limit) || (job.title in splitJobs))
			width += widthPerColumn
			if((index < limit) && (lastJob != null))
				//If the cells were broken up by a job in the splitJob list then it will fill in the rest of the cells with
				//the last job's selection color. Creating a rather nice effect.
				for(var/i = 0, i < (limit - index), i += 1)
					HTML += "<tr bgcolor='[lastJob.selection_color]'><td width='60%' align='right'>&nbsp</td><td>&nbsp</td></tr>"
			HTML += "</table></td><td width='20%'><table width='100%' cellpadding='1' cellspacing='0'>"
			index = 0

		HTML += "<tr bgcolor='[job.selection_color]'><td width='60%' align='right'>"
		var/rank = job.title
		lastJob = job
		if(jobban_isbanned(user, rank))
			HTML += "<font color=red>[rank]</font></td><td><font color=red><b> \[BANNED]</b></font></td></tr>"
			continue
		if(!job.player_old_enough(user.client))
			var/available_in_days = job.available_in_days(user.client)
			HTML += "<font color=red>[rank]</font></td><td><font color=red> \[IN [(available_in_days)] DAYS]</font></td></tr>"
			continue
		if((job_civilian_low & ASSISTANT) && (rank != "Assistant"))
			HTML += "<font color=orange>[rank]</font></td><td></td></tr>"
			continue
		if((rank in command_positions) || (rank == "AI"))//Bold head jobs
			if(job.alt_titles)
				HTML += "<b><span class='dark'><a href=\"byond://?src=\ref[user];preference=job;task=alt_title;job=\ref[job]\">[GetPlayerAltTitle(job)]</a></span></b>"
			else
				HTML += "<b><span class='dark'>[rank]</span></b>"
		else
			if(job.alt_titles)
				HTML += "<span class='dark'><a href=\"byond://?src=\ref[user];preference=job;task=alt_title;job=\ref[job]\">[GetPlayerAltTitle(job)]</a></span>"
			else
				HTML += "<span class='dark'>[rank]</span>"


		HTML += "</td><td width='40%'>"



		var/prefLevelLabel = "ERROR"
		var/prefLevelColor = "pink"
		var/prefUpperLevel = -1
		var/prefLowerLevel = -1

		if(GetJobDepartment(job, 1) & job.flag)
			prefLevelLabel = "High"
			prefLevelColor = "slateblue"
			prefUpperLevel = 4
			prefLowerLevel = 2
		else if(GetJobDepartment(job, 2) & job.flag)
			prefLevelLabel = "Medium"
			prefLevelColor = "green"
			prefUpperLevel = 1
			prefLowerLevel = 3
		else if(GetJobDepartment(job, 3) & job.flag)
			prefLevelLabel = "Low"
			prefLevelColor = "orange"
			prefUpperLevel = 2
			prefLowerLevel = 4
		else
			prefLevelLabel = "NEVER"
			prefLevelColor = "red"
			prefUpperLevel = 3
			prefLowerLevel = 1

		if(job.species_whitelist.len)
			if(!job.species_whitelist.Find(src.species))
				prefLevelLabel = "Unavailable"
				prefLevelColor = "gray"
				prefUpperLevel = 0
				prefLowerLevel = 0
		else if(job.species_blacklist.len)
			if(job.species_blacklist.Find(src.species))
				prefLevelLabel = "Unavailable"
				prefLevelColor = "gray"
				prefUpperLevel = 0
				prefLowerLevel = 0

		HTML += "<a class='white' onmouseup='javascript:return mouseUp(event,[prefUpperLevel],[prefLowerLevel], \"[rank]\");' oncontextmenu='javascript:return mouseDown(event,[prefUpperLevel],[prefLowerLevel], \"[rank]\");'>"


		if(rank == "Assistant")//Assistant is special
			if(job_civilian_low & ASSISTANT)
				HTML += " <font color=green>Yes</font>"
			else
				HTML += " <font color=red>No</font>"
			HTML += "</a></td></tr>"
			continue
		//if(job.alt_titles)
			//HTML += "</a></td></tr><tr bgcolor='[lastJob.selection_color]'><td width='60%' align='center'><a>&nbsp</a></td><td><a href=\"byond://?src=\ref[user];preference=job;task=alt_title;job=\ref[job]\">\[[GetPlayerAltTitle(job)]\]</a></td></tr>"
		HTML += "<font color=[prefLevelColor]>[prefLevelLabel]</font>"
		HTML += "</a></td></tr>"


	for(var/i = 1, i < (limit - index), i += 1)
		HTML += "<tr bgcolor='[lastJob.selection_color]'><td width='60%' align='right'>&nbsp</td><td>&nbsp</td></tr>"
	HTML += {"</td'></tr></table>
		</center></table>"}
	switch(alternate_option)
		if(GET_RANDOM_JOB)
			HTML += "<center><br><a href='?_src_=prefs;preference=job;task=random'>Get random job if preferences unavailable</a></center><br>"
		if(BE_ASSISTANT)
			HTML += "<center><br><a href='?_src_=prefs;preference=job;task=random'>Be assistant if preference unavailable</a></center><br>"
		if(RETURN_TO_LOBBY)
			HTML += "<center><br><a href='?_src_=prefs;preference=job;task=random'>Return to lobby if preference unavailable</a></center><br>"


	HTML += {"<center><a href='?_src_=prefs;preference=job;task=reset'>Reset</a></center>
		</tt>"}
	user << browse(null, "window=preferences")
	//user << browse(HTML, "window=mob_occupation;size=[width]x[height]")
	var/datum/browser/popup = new(user, "mob_occupation", "<div align='center'>Occupation Preferences</div>", width, height)
	popup.set_content(HTML)
	popup.open(0)
	return

/datum/preferences/proc/ShowChoices(mob/user)
	if(!user || !user.client)	return
	update_preview_icon()
	var/preview_front = fcopy_rsc(preview_icon_front)
	var/preview_side = fcopy_rsc(preview_icon_side)
	user << browse_rsc(preview_front, "previewicon.png")
	user << browse_rsc(preview_side, "previewicon2.png")
	var/dat = "<html><link href='./common.css' rel='stylesheet' type='text/css'><body>"

	if(!IsGuestKey(user.key))

		dat += {"<center>
			Slot <b>[slot_name]</b> -
			<a href=\"byond://?src=\ref[user];preference=open_load_dialog\">Load slot</a> -
			<a href=\"byond://?src=\ref[user];preference=save\">Save slot</a> -
			<a href=\"byond://?src=\ref[user];preference=reload\">Reload slot</a>
			</center><hr>"}
	else
		dat += "Please create an account to save your preferences."

	dat += "<center><a href='?_src_=prefs;preference=tab;tab=0' [current_tab == 0 ? "class='linkOn'" : ""]>Character Settings</a> | "
	dat += "<a href='?_src_=prefs;preference=tab;tab=1' [current_tab == 1 ? "class='linkOn'" : ""]>UI Settings</a> | "
	dat += "<a href='?_src_=prefs;preference=tab;tab=2' [current_tab == 2 ? "class='linkOn'" : ""]>General Settings</a></center><br>"

	if(appearance_isbanned(user))
		dat += "<b>You are banned from using custom names and appearances. You can continue to adjust your characters, but you will be randomised once you join the game.</b><br>"

	switch(current_tab)
		if(0)
			dat = setup_character_options(dat, user)
		if(1)
			dat = setup_UI(dat, user)
		if(2)
			dat = setup_special(dat, user)

	dat += "<br><hr>"

	if(!IsGuestKey(user.key))
		dat += {"<center><a href='?_src_=prefs;preference=load'>Undo</a> |
			<a href='?_src_=prefs;preference=save'>Save Setup</a> | "}

	dat += {"<a href='?_src_=prefs;preference=reset_all'>Reset Setup</a>
		</center></body></html>"}

	//user << browse(dat, "window=preferences;size=560x580")
	var/datum/browser/popup = new(user, "preferences", "<div align='center'>Character Setup</div>", 680, 640)
	popup.set_content(dat)
	popup.open(0)

/datum/preferences/proc/ShowDisabilityState(mob/user,flag,label)
	if(flag==DISABILITY_FLAG_FAT && species!="Human")
		return "<li><i>[species] cannot be fat.</i></li>"
	return "<li><b>[label]:</b> <a href=\"?_src_=prefs;task=input;preference=disabilities;disability=[flag]\">[disabilities & flag ? "Yes" : "No"]</a></li>"

/datum/preferences/proc/SetDisabilities(mob/user)
	var/HTML = "<body>"

	HTML += {"<tt><center>
		<b>Choose disabilities</b><ul>"}
	HTML += ShowDisabilityState(user,DISABILITY_FLAG_NEARSIGHTED,"Needs Glasses")
	HTML += ShowDisabilityState(user,DISABILITY_FLAG_FAT,        "Obese")
	HTML += ShowDisabilityState(user,DISABILITY_FLAG_EPILEPTIC,  "Seizures")
	HTML += ShowDisabilityState(user,DISABILITY_FLAG_DEAF,       "Deaf")
	HTML += ShowDisabilityState(user,DISABILITY_FLAG_BLIND,      "Blind")
	/*HTML += ShowDisabilityState(user,DISABILITY_FLAG_COUGHING,   "Coughing")
	HTML += ShowDisabilityState(user,DISABILITY_FLAG_TOURETTES,   "Tourettes") Still working on it! -Angelite*/


	HTML += {"</ul>
		<a href=\"?_src_=prefs;task=close;preference=disabilities\">\[Done\]</a>
		<a href=\"?_src_=prefs;task=reset;preference=disabilities\">\[Reset\]</a>
		</center></tt>"}
	user << browse(null, "window=preferences")
	user << browse(HTML, "window=disabil;size=350x300")
	return

/datum/preferences/proc/SetRecords(mob/user)
	var/HTML = "<body>"

	HTML += {"<tt><center>
		<b>Set Character Records</b><br>
		<a href=\"byond://?src=\ref[user];preference=records;task=med_record\">Medical Records</a><br>"}
	if(length(med_record) <= 40)
		HTML += "[med_record]"
	else
		HTML += "[copytext(med_record, 1, 37)]..."

	HTML += "<br><br><a href=\"byond://?src=\ref[user];preference=records;task=gen_record\">Employment Records</a><br>"

	if(length(gen_record) <= 40)
		HTML += "[gen_record]"
	else
		HTML += "[copytext(gen_record, 1, 37)]..."

	HTML += "<br><br><a href=\"byond://?src=\ref[user];preference=records;task=sec_record\">Security Records</a><br>"

	if(length(sec_record) <= 40)
		HTML += "[sec_record]<br>"
	else
		HTML += "[copytext(sec_record, 1, 37)]...<br>"


	HTML += {"<br>
		<a href=\"byond://?src=\ref[user];preference=records;records=-1\">\[Done\]</a>
		</center></tt>"}
	user << browse(null, "window=preferences")
	user << browse(HTML, "window=records;size=350x300")
	return


/datum/preferences/proc/GetPlayerAltTitle(datum/job/job)
	return player_alt_titles.Find(job.title) > 0 \
		? player_alt_titles[job.title] \
		: job.title

/datum/preferences/proc/SetPlayerAltTitle(datum/job/job, new_title)
	// remove existing entry
	if(player_alt_titles.Find(job.title))
		player_alt_titles -= job.title
	// add one if it's not default
	if(job.title != new_title)
		player_alt_titles[job.title] = new_title

/datum/preferences/proc/SetJob(mob/user, role, inc)
	var/datum/job/job = job_master.GetJob(role)
	if(!job)
		user << browse(null, "window=mob_occupation")
		ShowChoices(user)
		return

	if(role == "Assistant")
		if(job_civilian_low & job.flag)
			job_civilian_low &= ~job.flag
		else
			job_civilian_low |= job.flag
		SetChoices(user)
		return 1

	if(job.species_blacklist.Find(src.species)) //Check if our species is in the blacklist
		to_chat(user, "<span class='notice'>Your species ("+src.species+") can't have this job!</span>")
		return

	if(job.species_whitelist.len) //Whitelist isn't empty - check if our species is in the whitelist
		if(!job.species_whitelist.Find(src.species))
			var/allowed_species = ""
			for(var/S in job.species_whitelist)
				allowed_species += "[S]"

				if(job.species_whitelist.Find(S) != job.species_whitelist.len)
					allowed_species += ", "

			to_chat(user, "<span class='notice'>Only the following species can have this job: [allowed_species]. Your species is ([src.species]).</span>")
			return

	if(inc == null)
		if(GetJobDepartment(job, 1) & job.flag)
			SetJobDepartment(job, 1)
		else if(GetJobDepartment(job, 2) & job.flag)
			SetJobDepartment(job, 2)
		else if(GetJobDepartment(job, 3) & job.flag)
			SetJobDepartment(job, 3)
		else//job = Never
			SetJobDepartment(job, 4)
	else
		inc = text2num(inc)
		var/desiredLevel = getPrefLevelUpOrDown(job,inc)
		while(getPrefLevelText(job) != desiredLevel)
			if(GetJobDepartment(job, 1) & job.flag)
				SetJobDepartment(job, 1)
			else if(GetJobDepartment(job, 2) & job.flag)
				SetJobDepartment(job, 2)
			else if(GetJobDepartment(job, 3) & job.flag)
				SetJobDepartment(job, 3)
			else//job = Never
				SetJobDepartment(job, 4)

		/*if(level < 4)
			to_chat(world,"setting [job] to [level+1]")
			SetJobDepartment(job,level+1)
		else
			to_chat(world,"setting [job] to 1");SetJobDepartment(job,1)
*/
	SetChoices(user)
	return 1
/datum/preferences/proc/ResetJobs()
	job_civilian_high = 0
	job_civilian_med = 0
	job_civilian_low = 0

	job_medsci_high = 0
	job_medsci_med = 0
	job_medsci_low = 0

	job_engsec_high = 0
	job_engsec_med = 0
	job_engsec_low = 0

/datum/preferences/proc/GetJobDepartment(var/datum/job/job, var/level)
	if(!job || !level)	return 0
	switch(job.department_flag)
		if(CIVILIAN)
			switch(level)
				if(1)
					return job_civilian_high
				if(2)
					return job_civilian_med
				if(3)
					return job_civilian_low
		if(MEDSCI)
			switch(level)
				if(1)
					return job_medsci_high
				if(2)
					return job_medsci_med
				if(3)
					return job_medsci_low
		if(ENGSEC)
			switch(level)
				if(1)
					return job_engsec_high
				if(2)
					return job_engsec_med
				if(3)
					return job_engsec_low
	return 0

/datum/preferences/proc/SetJobDepartment(var/datum/job/job, var/level)
	if(!job || !level)	return 0
	switch(level)
		if(1)//Only one of these should ever be active at once so clear them all here
			job_civilian_high = 0
			job_medsci_high = 0
			job_engsec_high = 0
			return 1
		if(2)//Set current highs to med, then reset them
			job_civilian_med |= job_civilian_high
			job_medsci_med |= job_medsci_high
			job_engsec_med |= job_engsec_high

			job_civilian_high = 0
			job_medsci_high = 0
			job_engsec_high = 0

	switch(job.department_flag)
		if(CIVILIAN)
			switch(level)
				if(2)
					job_civilian_high = job.flag
					job_civilian_med &= ~job.flag
				if(3)
					job_civilian_med |= job.flag
					job_civilian_low &= ~job.flag
				else
					job_civilian_low |= job.flag
		if(MEDSCI)
			switch(level)
				if(2)
					job_medsci_high = job.flag
					job_medsci_med &= ~job.flag
				if(3)
					job_medsci_med |= job.flag
					job_medsci_low &= ~job.flag
				else
					job_medsci_low |= job.flag
		if(ENGSEC)
			switch(level)
				if(2)
					job_engsec_high = job.flag
					job_engsec_med &= ~job.flag
				if(3)
					job_engsec_med |= job.flag
					job_engsec_low &= ~job.flag
				else
					job_engsec_low |= job.flag
	return 1


/datum/preferences/proc/SetDepartmentFlags(datum/job/job, level, new_flags)	//Sets a department's preference flags (job_medsci_high, job_engsec_med - those variables) to 'new_flags'.
																		//First argument can either be a job, or the department's flag (ENGSEC, MISC, ...)
																		//Second argument can be either text ("high", "MEDIUM", "LoW") or number (1-high, 2-med, 3-low)

																		//NOTE: If you're not sure what you're doing, be careful when using this proc.

	//Determine department flag
	var/d_flag
	if(istype(job))
		d_flag = job.department_flag
	else
		d_flag = job

	//Determine department level
	var/d_level
	if(istext(level))
		switch(lowertext(level))
			if("high")
				d_level = 1
			if("med", "medium")
				d_level = 2
			if("low")
				d_level = 3
	else
		d_level = level

	switch(d_flag)
		if(CIVILIAN)
			switch(d_level)
				if(1) //high
					job_civilian_high = new_flags
				if(2) //med
					job_civilian_med = new_flags
				if(3) //low
					job_civilian_low = new_flags
		if(MEDSCI)
			switch(d_level)
				if(1) //high
					job_medsci_high = new_flags
				if(2) //med
					job_medsci_med = new_flags
				if(3) //low
					job_medsci_low = new_flags
		if(ENGSEC)
			switch(d_level)
				if(1) //high
					job_engsec_high = new_flags
				if(2) //med
					job_engsec_med = new_flags
				if(3) //low
					job_engsec_low = new_flags

/datum/preferences/proc/SetRoles(var/mob/user, var/list/href_list)
	// We just grab the role from the POST(?) data.
	for(var/role_id in special_roles)
		if(!(role_id in href_list))
			to_chat(user, "<span class='danger'>BUG: Unable to find role [role_id].</span>")
			continue
		var/oldval=text2num(roles[role_id])
		roles[role_id] = text2num(href_list[role_id])
		if(oldval!=roles[role_id])
			to_chat(user, "<span class='info'>Set role [role_id] to [get_role_desire_str(user.client.prefs.roles[role_id])]!</span>")

	save_preferences_sqlite(user, user.ckey)
	save_character_sqlite(user.ckey, user, default_slot)
	return 1

/datum/preferences/proc/ToggleRole(var/mob/user, var/list/href_list)
	var/role_id = href_list["role_id"]
//	to_chat(user, "<span class='info'>Toggling role [role_id] (currently at [roles[role_id]])...</span>")
	if(!(role_id in special_roles))
		to_chat(user, "<span class='danger'>BUG: Unable to find role [role_id].</span>")
		return 0

	if(roles[role_id] == null || roles[role_id] == "")
		roles[role_id] = 0
	// Always set persist.
	roles[role_id] |= ROLEPREF_PERSIST
	// Toggle role enable
	roles[role_id] ^= ROLEPREF_ENABLE
	return 1

/datum/preferences/proc/SetRole(var/mob/user, var/list/href_list)
	var/role_id = href_list["role_id"]
//	to_chat(user, "<span class='info'>Toggling role [role_id] (currently at [roles[role_id]])...</span>")
	if(!(role_id in special_roles))
		to_chat(user, "<span class='danger'>BUG: Unable to find role [role_id].</span>")
		return 0

	if(roles[role_id] == null || roles[role_id] == "")
		roles[role_id] = 0

	var/question={"Would you like to be \a [role_id] this round?

No/Yes:  Only affects this round.
Never/Always: Saved for later rounds.

NOTE:  The change will take effect AFTER any current recruiting periods."}
	var/answer = alert(question,"Role Preference", "Never", "No", "Yes", "Always")
	var/newval=0
	switch(answer)
		if("Never")
			newval = ROLEPREF_NEVER
		if("No")
			newval = ROLEPREF_NO
		if("Yes")
			newval = ROLEPREF_YES
		if("Always")
			newval = ROLEPREF_ALWAYS
	roles[role_id] = (roles[role_id] & ~ROLEPREF_VALMASK) | newval // We only set the lower 2 bits, leaving polled and friends untouched.

	save_preferences_sqlite(user, user.ckey)
	save_character_sqlite(user.ckey, user, default_slot)

	return 1
/datum/preferences/proc/process_link(mob/user, list/href_list)
	if(!user)
		return

	if(!istype(user, /mob/new_player))
		return

	if(href_list["preference"] == "job")
		switch(href_list["task"])
			if("close")
				user << browse(null, "window=mob_occupation")
				ShowChoices(user)
			if("reset")
				ResetJobs()
				SetChoices(user)
			if("random")
				if(alternate_option == GET_RANDOM_JOB || alternate_option == BE_ASSISTANT)
					alternate_option += 1
				else if(alternate_option == RETURN_TO_LOBBY)
					alternate_option = 0
				else
					return 0
				SetChoices(user)
			if ("alt_title")
				var/datum/job/job = locate(href_list["job"])
				if (job)
					var/choices = list(job.title) + job.alt_titles
					var/choice = input("Pick a title for [job.title].", "Character Generation", GetPlayerAltTitle(job)) as anything in choices | null
					if(choice)
						SetPlayerAltTitle(job, choice)
						SetChoices(user)
			if("input")
				SetJob(user, href_list["text"], href_list["level"])
			else
				SetChoices(user)
		return 1
	else if(href_list["preference"] == "disabilities")

		switch(href_list["task"])
			if("close")
				user << browse(null, "window=disabil")
				ShowChoices(user)
			if("reset")
				disabilities=0
				SetDisabilities(user)
			if("input")
				var/dflag=text2num(href_list["disability"])
				if(dflag >= 0)
					if(!(dflag==DISABILITY_FLAG_FAT && species!="Human"))
						disabilities ^= text2num(href_list["disability"]) //MAGIC
				SetDisabilities(user)
			else
				SetDisabilities(user)
		return 1

	else if(href_list["preference"] == "records")
		if(text2num(href_list["record"]) >= 1)
			SetRecords(user)
			return
		else
			user << browse(null, "window=records")
		if(href_list["task"] == "med_record")
			var/medmsg = input(usr,"Set your medical notes here.","Medical Records",html_decode(med_record)) as message

			if(medmsg != null)
				medmsg = copytext(medmsg, 1, MAX_PAPER_MESSAGE_LEN)
				medmsg = html_encode(medmsg)

				med_record = medmsg
				SetRecords(user)

		if(href_list["task"] == "sec_record")
			var/secmsg = input(usr,"Set your security notes here.","Security Records",html_decode(sec_record)) as message

			if(secmsg != null)
				secmsg = copytext(secmsg, 1, MAX_PAPER_MESSAGE_LEN)
				secmsg = html_encode(secmsg)

				sec_record = secmsg
				SetRecords(user)
		if(href_list["task"] == "gen_record")
			var/genmsg = input(usr,"Set your employment notes here.","Employment Records",html_decode(gen_record)) as message

			if(genmsg != null)
				genmsg = copytext(genmsg, 1, MAX_PAPER_MESSAGE_LEN)
				genmsg = html_encode(genmsg)

				gen_record = genmsg
				SetRecords(user)

	else if(href_list["preference"] == "set_roles")
		return SetRoles(user,href_list)

	else if(href_list["preference"] == "toggle_role")
		ToggleRole(user,href_list)

	switch(href_list["task"])
		if("random")
			switch(href_list["preference"])
				if("name")
					real_name = random_name(gender,species)
				if("age")
					age = rand(AGE_MIN, AGE_MAX)
				if("hair")
					r_hair = rand(0,255)
					g_hair = rand(0,255)
					b_hair = rand(0,255)
				if("h_style")
					h_style = random_hair_style(gender, species)
				if("facial")
					r_facial = rand(0,255)
					g_facial = rand(0,255)
					b_facial = rand(0,255)
				if("f_style")
					f_style = random_facial_hair_style(gender, species)
				if("underwear")
					underwear = rand(1,underwear_m.len)
					ShowChoices(user)
				if("eyes")
					r_eyes = rand(0,255)
					g_eyes = rand(0,255)
					b_eyes = rand(0,255)
				if("s_tone")
					s_tone = random_skin_tone(species)
				if("bag")
					backbag = rand(1,4)
				/*if("skin_style")
					h_style = random_skin_style(gender)*/
				if("all")
					randomize_appearance_for()	//no params needed
		if("input")
			switch(href_list["preference"])
				if("name")
					var/new_name = reject_bad_name( input(user, "Choose your character's name:", "Character Preference")  as text|null )
					if(new_name)
						real_name = new_name
					else
						to_chat(user, "<font color='red'>Invalid name. Your name should be at least 2 and at most [MAX_NAME_LEN] characters long. It may only contain the characters A-Z, a-z, -, ' and .</font>")
				if("next_hair_style")
					if (gender == MALE)
						h_style = next_list_item(h_style, hair_styles_male_list)
					else
						h_style = next_list_item(h_style, hair_styles_female_list)
				if("previous_hair_style")
					if (gender == MALE)
						h_style = previous_list_item(h_style, hair_styles_male_list)
					else
						h_style = previous_list_item(h_style, hair_styles_female_list)
				if("next_facehair_style")
					if (gender == MALE)
						f_style = next_list_item(f_style, facial_hair_styles_male_list)
					else
						f_style = next_list_item(f_style, facial_hair_styles_female_list)
				if("previous_facehair_style")
					if (gender == MALE)
						f_style = previous_list_item(f_style, facial_hair_styles_male_list)
					else
						f_style = previous_list_item(f_style, facial_hair_styles_female_list)
				if("age")
					var/new_age = input(user, "Choose your character's age:\n([AGE_MIN]-[AGE_MAX])", "Character Preference") as num|null
					if(new_age)
						age = max(min( round(text2num(new_age)), AGE_MAX),AGE_MIN)
				if("species")

					var/list/new_species = list("Human")
					var/prev_species = species
					var/whitelisted = 0

					if(config.usealienwhitelist) //If we're using the whitelist, make sure to check it!
						for(var/S in whitelisted_species)
							if(is_alien_whitelisted(user,S))
								new_species += S
								whitelisted = 1
						if(!whitelisted)
							alert(user, "You cannot change your species as you need to be whitelisted. If you wish to be whitelisted contact an admin in-game, on the forums, or on IRC.")
					else //Not using the whitelist? Aliens for everyone!
						new_species = whitelisted_species

					species = input("Please select a species", "Character Generation", null) in new_species

					if(prev_species != species)
						//grab one of the valid hair styles for the newly chosen species
						var/list/valid_hairstyles = list()
						for(var/hairstyle in hair_styles_list)
							var/datum/sprite_accessory/S = hair_styles_list[hairstyle]
							if(gender == MALE && S.gender == FEMALE)
								continue
							if(gender == FEMALE && S.gender == MALE)
								continue
							if( !(species in S.species_allowed))
								continue
							valid_hairstyles[hairstyle] = hair_styles_list[hairstyle]

						if(valid_hairstyles.len)
							h_style = pick(valid_hairstyles)
						else
							//this shouldn't happen
							h_style = hair_styles_list["Bald"]

						//grab one of the valid facial hair styles for the newly chosen species
						var/list/valid_facialhairstyles = list()
						for(var/facialhairstyle in facial_hair_styles_list)
							var/datum/sprite_accessory/S = facial_hair_styles_list[facialhairstyle]
							if(gender == MALE && S.gender == FEMALE)
								continue
							if(gender == FEMALE && S.gender == MALE)
								continue
							if( !(species in S.species_allowed))
								continue

							valid_facialhairstyles[facialhairstyle] = facial_hair_styles_list[facialhairstyle]

						if(valid_facialhairstyles.len)
							f_style = pick(valid_facialhairstyles)
						else
							//this shouldn't happen
							f_style = facial_hair_styles_list["Shaved"]

						//reset hair colour and skin colour
						r_hair = 0//hex2num(copytext(new_hair, 2, 4))
						g_hair = 0//hex2num(copytext(new_hair, 4, 6))
						b_hair = 0//hex2num(copytext(new_hair, 6, 8))

						s_tone = 0

					for(var/datum/job/job in job_master.occupations)
						if(job.species_blacklist.Find(species)) //If new species is in a job's blacklist
							for(var/i = 1 to 3)
								var/F = GetJobDepartment(job, i)

								F &= ~job.flag //Disable that job in our preferences
								SetDepartmentFlags(job, i, F)

							to_chat(usr, "<span class='info'>Your new species ([species]) is blacklisted from [job.title].</span>")

						if(job.species_whitelist.len) //If the job has a species whitelist
							if(!job.species_whitelist.Find(species)) //And it doesn't include our new species
								for(var/i = 1 to 3)
									var/F = GetJobDepartment(job, i)

									if(F & job.flag)
										to_chat(usr, "<span class='info'>Your new species ([species]) can't be [job.title]. Your preferences have been adjusted.</span>")

									F &= ~job.flag //Disable that job in our preferences
									SetDepartmentFlags(job, i, F)

				if("language")
					var/languages_available
					var/list/new_languages = list("None")

					if(config.usealienwhitelist)
						for(var/L in all_languages)
							var/datum/language/lang = all_languages[L]
							if((!(lang.flags & RESTRICTED)) && (is_alien_whitelisted(user, L)||(!( lang.flags & WHITELISTED ))))
								new_languages += lang.name

								languages_available = 1

						if(!(languages_available))
							alert(user, "There are not currently any available secondary languages.")
					else
						for(var/L in all_languages)
							var/datum/language/lang = all_languages[L]
							if(!(lang.flags & RESTRICTED))
								new_languages += lang.name

					language = input("Please select a secondary language", "Character Generation", null) in new_languages

				if("metadata")
					var/new_metadata = input(user, "Enter any information you'd like others to see, such as Roleplay-preferences:", "Game Preference" , metadata)  as message|null
					if(new_metadata)
						metadata = sanitize(copytext(new_metadata,1,MAX_MESSAGE_LEN))

				if("hair")
					if(species == "Human" || species == "Unathi")
						var/new_hair = input(user, "Choose your character's hair colour:", "Character Preference") as color|null
						if(new_hair)
							r_hair = hex2num(copytext(new_hair, 2, 4))
							g_hair = hex2num(copytext(new_hair, 4, 6))
							b_hair = hex2num(copytext(new_hair, 6, 8))

				if("h_style")
					var/list/valid_hairstyles = list()
					for(var/hairstyle in hair_styles_list)
						var/datum/sprite_accessory/S = hair_styles_list[hairstyle]
						if( !(species in S.species_allowed))
							continue

						valid_hairstyles[hairstyle] = hair_styles_list[hairstyle]

					var/new_h_style = input(user, "Choose your character's hair style:", "Character Preference")  as null|anything in valid_hairstyles
					if(new_h_style)
						h_style = new_h_style

				if("facial")
					if(species == "Human" || species == "Unathi")
						var/new_facial = input(user, "Choose your character's facial-hair colour:", "Character Preference") as color|null
						if(new_facial)
							r_facial = hex2num(copytext(new_facial, 2, 4))
							g_facial = hex2num(copytext(new_facial, 4, 6))
							b_facial = hex2num(copytext(new_facial, 6, 8))

				if("f_style")
					var/list/valid_facialhairstyles = list()
					for(var/facialhairstyle in facial_hair_styles_list)
						var/datum/sprite_accessory/S = facial_hair_styles_list[facialhairstyle]
						if(gender == MALE && S.gender == FEMALE)
							continue
						if(gender == FEMALE && S.gender == MALE)
							continue
						if( !(species in S.species_allowed))
							continue

						valid_facialhairstyles[facialhairstyle] = facial_hair_styles_list[facialhairstyle]

					var/new_f_style = input(user, "Choose your character's facial-hair style:", "Character Preference")  as null|anything in valid_facialhairstyles
					if(new_f_style)
						f_style = new_f_style

				if("underwear")
					var/list/underwear_options
					if(gender == MALE)
						underwear_options = underwear_m
					else
						underwear_options = underwear_f

					var/new_underwear = input(user, "Choose your character's underwear:", "Character Preference")  as null|anything in underwear_options
					if(new_underwear)
						underwear = underwear_options.Find(new_underwear)
					ShowChoices(user)

				if("eyes")
					var/new_eyes = input(user, "Choose your character's eye colour:", "Character Preference") as color|null
					if(new_eyes)
						r_eyes = hex2num(copytext(new_eyes, 2, 4))
						g_eyes = hex2num(copytext(new_eyes, 4, 6))
						b_eyes = hex2num(copytext(new_eyes, 6, 8))

				if("s_tone")
					if(species == "Human")
						var/new_s_tone = input(user, "Choose your character's skin-tone:\n(Light 1 - 220 Dark)", "Character Preference")  as num|null
						if(new_s_tone)
							s_tone = 35 - max(min(round(new_s_tone),220),1)
					else if(species == "Vox")//Can't reference species flags here, sorry.
						var/skin_c = input(user, "Choose your Vox's skin color:\n(1 = Green, 2 = Brown, 3 = Gray)", "Character Preference") as num|null
						if(skin_c)
							s_tone = max(min(round(skin_c),3),1)
							switch(s_tone)
								if(3)
									to_chat(user,"Your vox will now be gray.")
								if(2)
									to_chat(user,"Your vox will now be brown.")
								else
									to_chat(user,"Your vox will now be green.")
					else
						to_chat(user,"Your species doesn't have different skin tones. Yet?")
						return

				if("ooccolor")
					var/new_ooccolor = input(user, "Choose your OOC colour:", "Game Preference") as color|null
					if(new_ooccolor)
						ooccolor = new_ooccolor

				if("bag")
					var/new_backbag = input(user, "Choose your character's style of bag:", "Character Preference")  as null|anything in backbaglist
					if(new_backbag)
						backbag = backbaglist.Find(new_backbag)

				if("nt_relation")
					var/new_relation = input(user, "Choose your relation to NT. Note that this represents what others can find out about your character by researching your background, not what your character actually thinks.", "Character Preference")  as null|anything in list("Loyal", "Supportive", "Neutral", "Skeptical", "Opposed")
					if(new_relation)
						nanotrasen_relation = new_relation

				if("flavor_text")
					var/msg = input(usr,"Set the flavor text in your 'examine' verb. This can also be used for OOC notes and preferences!","Flavor Text",html_decode(flavor_text)) as message
					if(msg != null)
						msg = copytext(msg, 1, MAX_MESSAGE_LEN)
						msg = html_encode(msg)

						flavor_text = msg

				if("limbs")
					var/list/limb_input = list(
						"Left Leg [organ_data[LIMB_LEFT_LEG]]" = LIMB_LEFT_LEG,
						"Right Leg [organ_data[LIMB_RIGHT_LEG]]" = LIMB_RIGHT_LEG,
						"Left Arm [organ_data[LIMB_LEFT_ARM]]" = LIMB_LEFT_ARM,
						"Right Arm [organ_data[LIMB_RIGHT_ARM]]" = LIMB_RIGHT_ARM,
						"Left Foot [organ_data[LIMB_LEFT_FOOT]]" = LIMB_LEFT_FOOT,
						"Right Foot [organ_data[LIMB_RIGHT_FOOT]]" = LIMB_RIGHT_FOOT,
						"Left Hand [organ_data[LIMB_LEFT_HAND]]" = LIMB_LEFT_HAND,
						"Right Hand [organ_data[LIMB_RIGHT_HAND]]" = LIMB_RIGHT_HAND
						)

					var/limb_name = input(user, "Which limb do you want to change?") as null|anything in limb_input
					if(!limb_name) return

					var/limb = null
					var/second_limb = null // if you try to change the arm, the hand should also change
					var/third_limb = null  // if you try to unchange the hand, the arm should also change
					var/valid_limb_states=list("Normal","Amputated","Prothesis")
					switch(limb_input[limb_name])
						if(LIMB_LEFT_LEG)
							limb = LIMB_LEFT_LEG
							second_limb = LIMB_LEFT_FOOT
							valid_limb_states += "Peg Leg"
						if(LIMB_RIGHT_LEG)
							limb = LIMB_RIGHT_LEG
							second_limb = LIMB_RIGHT_FOOT
							valid_limb_states += "Peg Leg"
						if(LIMB_LEFT_ARM)
							limb = LIMB_LEFT_ARM
							second_limb = LIMB_LEFT_HAND
							valid_limb_states += "Wooden Prosthesis"
						if(LIMB_RIGHT_ARM)
							limb = LIMB_RIGHT_ARM
							second_limb = LIMB_RIGHT_HAND
							valid_limb_states += "Wooden Prosthesis"
						if(LIMB_LEFT_FOOT)
							limb = LIMB_LEFT_FOOT
							third_limb = LIMB_LEFT_LEG
						if(LIMB_RIGHT_FOOT)
							limb = LIMB_RIGHT_FOOT
							third_limb = LIMB_RIGHT_LEG
						if(LIMB_LEFT_HAND)
							limb = LIMB_LEFT_HAND
							third_limb = LIMB_LEFT_ARM
							valid_limb_states += "Hook Prosthesis"
						if(LIMB_RIGHT_HAND)
							limb = LIMB_RIGHT_HAND
							third_limb = LIMB_RIGHT_ARM
							valid_limb_states += "Hook Prosthesis"

					var/new_state = input(user, "What state do you wish the limb to be in?") as null|anything in valid_limb_states
					if(!new_state) return

					switch(new_state)
						if("Normal")
							organ_data[limb] = null
							if(third_limb)
								organ_data[third_limb] = null
						if("Amputated")
							organ_data[limb] = "amputated"
							if(second_limb)
								organ_data[second_limb] = "amputated"
						if("Prothesis")
							organ_data[limb] = "cyborg"
							if(second_limb)
								organ_data[second_limb] = "cyborg"
						if("Peg Leg","Wooden Prosthesis","Hook Prosthesis")
							organ_data[limb] = "peg"
							if(second_limb)
								if(limb == LIMB_LEFT_ARM || limb == LIMB_RIGHT_ARM)
									organ_data[second_limb] = "peg"
								else
									organ_data[second_limb] = "amputated"

				if("organs")
					var/organ_name = input(user, "Which internal function do you want to change?") as null|anything in list("Heart", "Eyes", "Lungs", "Liver", "Kidneys")
					if(!organ_name) return

					var/organ = null
					switch(organ_name)
						if("Heart")
							organ = "heart"
						if("Eyes")
							organ = "eyes"
						if("Lungs")
							organ = "lungs"
						if("Liver")
							organ = "liver"
						if("Kidneys")
							organ = "kidneys"

					var/new_state = input(user, "What state do you wish the organ to be in?") as null|anything in list("Normal","Assisted","Mechanical")
					if(!new_state) return

					switch(new_state)
						if("Normal")
							organ_data[organ] = null
						if("Assisted")
							organ_data[organ] = "assisted"
						if("Mechanical")
							organ_data[organ] = "mechanical"

				if("skin_style")
					var/skin_style_name = input(user, "Select a new skin style") as null|anything in list("default1", "default2", "default3")
					if(!skin_style_name) return

		else
			switch(href_list["preference"])
				if("gender")
					if(gender == MALE)
						gender = FEMALE
					else
						gender = MALE
					f_style = random_facial_hair_style(gender)
					h_style = random_hair_style(gender)

				if("hear_adminhelps")
					toggles ^= SOUND_ADMINHELP

				if("ui")
					switch(UI_style)
						if("Midnight")
							UI_style = "Orange"
						if("Orange")
							UI_style = "old"
						if("old")
							UI_style = "White"
						else
							UI_style = "Midnight"

				if("UIcolor")
					var/UI_style_color_new = input(user, "Choose your UI colour, dark colours are not recommended!") as color|null
					if(!UI_style_color_new) return
					UI_style_color = UI_style_color_new

				if("UIalpha")
					var/UI_style_alpha_new = input(user, "Select a new alpha(transparency) parameter for UI, between 50 and 255") as num
					if(!UI_style_alpha_new | !(UI_style_alpha_new <= 255 && UI_style_alpha_new >= 50)) return
					UI_style_alpha = UI_style_alpha_new

				if("parallax")
					space_parallax = !space_parallax

				if("dust")
					space_dust = !space_dust

				if("p_speed")
					parallax_speed = min(max(input(user, "Enter a number between 0 and 5 included (default=2)","Parallax Speed Preferences",parallax_speed),0),5)

				if("name")
					be_random_name = !be_random_name

				if("all")
					be_random_body = !be_random_body

				if("special_popup")
					special_popup = !special_popup

				if("randomslot")
					randomslot = !randomslot

				if("hear_midis")
					toggles ^= SOUND_MIDI

				if("lobby_music")
					toggles ^= SOUND_LOBBY
					if(toggles & SOUND_LOBBY)
						user << sound(ticker.login_music, repeat = 0, wait = 0, volume = 85, channel = 1)
					else
						user << sound(null, repeat = 0, wait = 0, volume = 85, channel = 1)

				if("jukebox")
					toggles ^= SOUND_STREAMING

				if("wmp")
					usewmp = !usewmp
				if("nanoui")
					usenanoui = !usenanoui
				if("progbar")
					progress_bars = !progress_bars
				if("ghost_ears")
					toggles ^= CHAT_GHOSTEARS

				if("ghost_sight")
					toggles ^= CHAT_GHOSTSIGHT

				if("ghost_radio")
					toggles ^= CHAT_GHOSTRADIO

				if("ghost_pda")
					toggles ^= CHAT_GHOSTPDA

				if("save")
					if(world.timeofday >= (lastPolled + POLLED_LIMIT))
						save_preferences_sqlite(user, user.ckey)
						save_character_sqlite(user.ckey, user, default_slot)
						lastPolled = world.timeofday
					else
						to_chat(user, "You need to wait [round((((lastPolled + POLLED_LIMIT) - world.timeofday) / 10))] seconds before you can save again.")
					//random_character_sqlite(user, user.ckey)

				if("reload")
					load_preferences_sqlite(user.ckey)
					load_save_sqlite(user.ckey, user, default_slot)

				if("open_load_dialog")
					if(!IsGuestKey(user.key))
						open_load_dialog(user)

				if("close_load_dialog")
					close_load_dialog(user)

				if("changeslot")
					var/num = text2num(href_list["num"])
					load_save_sqlite(user.ckey, user, num)
					default_slot = num
					close_load_dialog(user)
				if("tab")
					if(href_list["tab"])
						current_tab = text2num(href_list["tab"])
	ShowChoices(user)
	return 1

/datum/preferences/proc/copy_to(mob/living/carbon/human/character, safety = 0)
	if(be_random_name)
		real_name = random_name(gender,species)

	if(config.humans_need_surnames && species == "Human")
		var/firstspace = findtext(real_name, " ")
		var/name_length = length(real_name)
		if(!firstspace)	//we need a surname
			real_name += " [pick(last_names)]"
		else if(firstspace == name_length)
			real_name += "[pick(last_names)]"

	character.real_name = real_name
	character.name = character.real_name
	if(character.dna)
		character.dna.real_name = character.real_name

	character.flavor_text = flavor_text
	character.med_record = med_record
	character.sec_record = sec_record
	character.gen_record = gen_record

	character.setGender(gender)
	character.age = age

	character.r_eyes = r_eyes
	character.g_eyes = g_eyes
	character.b_eyes = b_eyes

	character.r_hair = r_hair
	character.g_hair = g_hair
	character.b_hair = b_hair

	character.r_facial = r_facial
	character.g_facial = g_facial
	character.b_facial = b_facial

	character.s_tone = s_tone

	character.h_style = h_style
	character.f_style = f_style


	character.skills = skills

	// Destroy/cyborgize organs

	for(var/name in organ_data)
		var/datum/organ/external/O = character.organs_by_name[name]
		var/datum/organ/internal/I = character.internal_organs_by_name[name]
		var/status = organ_data[name]

		if(status == "amputated")
			O.status &= ~ORGAN_ROBOT
			O.status &= ~ORGAN_PEG
			O.amputated = 1
			O.status |= ORGAN_DESTROYED
			O.destspawn = 1
		else if(status == "cyborg")
			O.status &= ~ORGAN_PEG
			O.status |= ORGAN_ROBOT
		else if(status == "peg")
			O.status &= ~ORGAN_ROBOT
			O.status |= ORGAN_PEG
		else if(status == "assisted")
			I.mechassist()
		else if(status == "mechanical")
			I.mechanize()
		else continue
	var/datum/species/chosen_species = all_species[species]
	if( (disabilities & DISABILITY_FLAG_FAT) && (chosen_species.flags & CAN_BE_FAT) )
		character.mutations += M_FAT
		character.mutations += M_OBESITY
	if(disabilities & DISABILITY_FLAG_NEARSIGHTED)
		character.disabilities|=NEARSIGHTED
	if(disabilities & DISABILITY_FLAG_EPILEPTIC)
		character.disabilities|=EPILEPSY
	if(disabilities & DISABILITY_FLAG_DEAF)
		character.sdisabilities|=DEAF
	if(disabilities & DISABILITY_FLAG_BLIND)
		character.sdisabilities|=BLIND
	/*if(disabilities & DISABILITY_FLAG_COUGHING)
		character.sdisabilities|=COUGHING
	if(disabilities & DISABILITY_FLAG_TOURETTES)
		character.sdisabilities|=TOURETTES Still working on it. - Angelite */

	if(underwear > underwear_m.len || underwear < 1)
		underwear = 0 //I'm sure this is 100% unnecessary, but I'm paranoid... sue me. //HAH NOW NO MORE MAGIC CLONING UNDIES
	character.underwear = underwear

	if(backbag > 4 || backbag < 1)
		backbag = 1 //Same as above
	character.backbag = backbag

	//Debugging report to track down a bug, which randomly assigned the plural gender to people.
	if(character.gender in list(PLURAL, NEUTER))
		if(isliving(character)) //Ghosts get neuter by default
			message_admins("[character] ([character.ckey]) has spawned with their gender as plural or neuter. Please notify coders.")
			character.setGender(MALE)

/datum/preferences/proc/open_load_dialog(mob/user)


	var/database/query/q = new
	var/list/name_list[MAX_SAVE_SLOTS]

	q.Add("select real_name, player_slot from players where player_ckey=?", user.ckey)
	if(q.Execute(db))
		while(q.NextRow())
			name_list[q.GetColumn(2)] = q.GetColumn(1)
	else
		message_admins("Error #: [q.Error()] - [q.ErrorMsg()]")
		warning("Error #:[q.Error()] - [q.ErrorMsg()]")
		return 0
	var/dat = {"<body><tt><center>"}
	dat += "<b>Select a character slot to load</b><hr>"
	var/counter = 1
	while(counter <= MAX_SAVE_SLOTS)
		if(counter==default_slot)
			dat += "<a href='?_src_=prefs;preference=changeslot;num=[counter];'><b>[name_list[counter]]</b></a><br>"
		else
			if(!name_list[counter])
				dat += "<a href='?_src_=prefs;preference=changeslot;num=[counter];'>Character[counter]</a><br>"
			else
				dat += "<a href='?_src_=prefs;preference=changeslot;num=[counter];'>[name_list[counter]]</a><br>"
		counter++

	dat += {"<hr>
		<a href='byond://?src=\ref[user];preference=close_load_dialog'>Close</a><br>
		</center></tt>"}
	user << browse(dat, "window=saves;size=300x390")

/datum/preferences/proc/close_load_dialog(mob/user)
	user << browse(null, "window=saves")

/datum/preferences/proc/configure_special_roles(var/mob/user)
	var/html={"<form method="get">
	<input type="hidden" name="src" value="\ref[src]" />
	<input type="hidden" name="preference" value="set_roles" />
	<h1>Special Role Preferences</h1>
	<p>Please note that this also handles in-round polling for things like Raging Mages and Borers.</p>
	<fieldset>
		<legend>Legend</legend>
		<dl>
			<dt>Never:</dt>
			<dd>Always answer no to this role.</dd>
			<dt>No:</dt>
			<dd>Answer no for this round. (Default)</dd>
			<dt>Yes:</dt>
			<dd>Answer yes for this round.</dd>
			<dt>Always:</dt>
			<dd>Always answer yes to this role.</dd>
		</dl>
	</fieldset>
	<table border=\"0\">
		<thead>
			<tr>
				<th>Role</th>
				<th class="clmNever">Never</th>
				<th class="clmNo">No</th>
				<th class="clmYes">Yes</th>
				<th class="clmAlways">Always</th>
			</tr>
		</thead>
		<tbody>"}
	for(var/role_id in special_roles)
		var/desire = get_role_desire_str(roles[role_id])
		html += {"<tr>
			<th>[role_id]</th>
			<td class='column clmNever'><input type="radio" name="[role_id]" value="[ROLEPREF_PERSIST]" title="Never"[desire=="Never"?" checked='checked'":""]/></td>
			<td class='column clmNo'><input type="radio" name="[role_id]" value="0" title="No"[desire=="No"?" checked='checked'":""] /></td>
			<td class='column clmYes'><input type="radio" name="[role_id]" value="[ROLEPREF_ENABLE]" title="Yes"[desire=="Yes"?" checked='checked'":""] /></td>
			<td class='column clmAlways'><input type="radio" name="[role_id]" value="[ROLEPREF_ENABLE|ROLEPREF_PERSIST]" title="Always"[desire=="Always"?" checked='checked'":""] /></td>
		</tr>"}
	html += {"</tbody>
		</table>
		<input type="submit" value="Submit" />
		<input type="reset" value="Reset" />
		</form>"}
	var/datum/browser/B = new /datum/browser/clean(user, "roles", "Role Selections", 300, 390)
	B.set_content(html)
	B.add_stylesheet("specialroles", 'html/browser/config_roles.css')
	B.open()

/datum/preferences/Topic(href, href_list)
	if(!usr || !client)
		return
	if(client.mob!=usr)
		to_chat(usr, "YOU AREN'T ME GO AWAY")
		return
	switch(href_list["preference"])
		if("set_roles")
			return SetRoles(usr, href_list)
		if("set_role")
			return SetRole(usr, href_list)
>>>>>>> ccb55b121a3fd5338fc56a602424016009566488
