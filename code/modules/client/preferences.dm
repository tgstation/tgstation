//This file was auto-corrected by findeclaration.exe on 25.5.2012 20:42:33

var/list/preferences_datums = list()

var/global/list/special_roles = list( //keep synced with the defines BE_* in setup.dm
//some autodetection here.
	"traitor" = /datum/game_mode/traitor,			//0
	"operative" = /datum/game_mode/nuclear,			//1
	"changeling" = /datum/game_mode/changeling,		//2
	"wizard" = /datum/game_mode/wizard,				//3
	"malf AI" = /datum/game_mode/malfunction,		//4
	"revolutionary" = /datum/game_mode/revolution,	//5
	"alien",										//6
	"pAI/posibrain",								//7
	"cultist" = /datum/game_mode/cult,				//8
	"blob" = /datum/game_mode/blob,					//9
	"ninja",										//10
	"monkey" = /datum/game_mode/monkey,				//11
	"gangster" = /datum/game_mode/gang,				//12
	"shadowling" = /datum/game_mode/shadowling,		//13
	"abductor" = /datum/game_mode/abduction			//14
)


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
	var/be_special = 0					//Special role selection
	var/UI_style = "Midnight"
	var/toggles = TOGGLES_DEFAULT
	var/chat_toggles = TOGGLES_DEFAULT_CHAT
	var/ghost_form = "ghost"
	var/allow_midround_antag = 1

	//character preferences
	var/real_name						//our character's name
	var/be_random_name = 0				//whether we'll have a random name every round
	var/be_random_body = 0				//whether we'll have a random body every round
	var/gender = MALE					//gender of character (well duh)
	var/age = 30						//age of character
	var/blood_type = "A+"				//blood type (not-chooseable)
	var/underwear = "Nude"				//underwear type
	var/undershirt = "Nude"				//undershirt type
	var/socks = "Nude"					//socks type
	var/backbag = 2						//backpack type
	var/hair_style = "Bald"				//Hair type
	var/hair_color = "000"				//Hair color
	var/facial_hair_style = "Shaved"	//Face hair type
	var/facial_hair_color = "000"		//Facial hair color
	var/skin_tone = "caucasian1"		//Skin color
	var/eye_color = "000"				//Eye color
	var/datum/species/pref_species = new /datum/species/human()	//Mutant race
	var/mutant_color = "FFF"			//Mutant race skin color
	var/list/custom_names = list("clown", "mime", "ai", "cyborg", "religion", "deity")

		//Mob preview
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

		// Want randomjob if preferences already filled - Donkie
	var/userandomjob = 1 //defaults to 1 for fewer assistants

	// 0 = character settings, 1 = game preferences
	var/current_tab = 0

		// OOC Metadata:
	var/metadata = ""

	var/unlock_content = 0

/datum/preferences/New(client/C)
	blood_type = random_blood_type()
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
	real_name = random_name(gender)
	if(!loaded_preferences_successfully)
		save_preferences()
	save_character()		//let's save this new random character so it doesn't keep generating new ones.
	return

/datum/preferences
	proc/ShowChoices(mob/user)
		if(!user || !user.client)	return
		update_preview_icon()
		user << browse_rsc(preview_icon_front, "previewicon.png")
		user << browse_rsc(preview_icon_side, "previewicon2.png")
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
							if(!name)	name = "Character[i]"
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

				dat += "<div class='statusDisplay'><center><img src=previewicon.png height=64 width=64><img src=previewicon2.png height=64 width=64></center></div>"

				dat += "</td></tr></table>"

				dat += "<h2>Body</h2>"
				dat += "<a href='?_src_=prefs;preference=all;task=random'>Random Body</A> "
				dat += "<a href='?_src_=prefs;preference=all'>Always Random Body: [be_random_body ? "Yes" : "No"]</A><br>"

				dat += "<table width='100%'><tr><td width='24%' valign='top'>"

				if(config.mutant_races)
					dat += "<b>Species:</b><BR><a href='?_src_=prefs;preference=species;task=input'>[pref_species.name]</a><BR>"
				else
					dat += "<b>Species:</b> Human<BR>"

				dat += "<b>Blood Type:</b> [blood_type]<BR>"
				dat += "<b>Underwear:</b><BR><a href ='?_src_=prefs;preference=underwear;task=input'>[underwear]</a><BR>"
				dat += "<b>Undershirt:</b><BR><a href ='?_src_=prefs;preference=undershirt;task=input'>[undershirt]</a><BR>"
				dat += "<b>Socks:</b><BR><a href ='?_src_=prefs;preference=socks;task=input'>[socks]</a><BR>"
				dat += "<b>Backpack:</b><BR><a href ='?_src_=prefs;preference=bag;task=input'>[backbaglist[backbag]]</a><BR></td>"

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

				if(MUTCOLORS in pref_species.specflags)

					dat += "<td valign='top' width='21%'>"

					dat += "<h3>Alien Color</h3>"

					dat += "<span style='border: 1px solid #161616; background-color: #[mutant_color];'>&nbsp;&nbsp;&nbsp;</span> <a href='?_src_=prefs;preference=mutant_color;task=input'>Change</a><BR>"

					dat += "</td>"

				dat += "</tr></table>"


			if (1) // Game Preferences
				dat += "<table><tr><td width='340px' height='300px' valign='top'>"
				dat += "<h2>General Settings</h2>"
				dat += "<b>UI Style:</b> <a href='?_src_=prefs;preference=ui'>[UI_style]</a><br>"
				dat += "<b>Play admin midis:</b> <a href='?_src_=prefs;preference=hear_midis'>[(toggles & SOUND_MIDI) ? "Yes" : "No"]</a><br>"
				dat += "<b>Play lobby music:</b> <a href='?_src_=prefs;preference=lobby_music'>[(toggles & SOUND_LOBBY) ? "Yes" : "No"]</a><br>"
				dat += "<b>Ghost ears:</b> <a href='?_src_=prefs;preference=ghost_ears'>[(chat_toggles & CHAT_GHOSTEARS) ? "Nearest Creatures" : "All Speech"]</a><br>"
				dat += "<b>Ghost sight:</b> <a href='?_src_=prefs;preference=ghost_sight'>[(chat_toggles & CHAT_GHOSTSIGHT) ? "Nearest Creatures" : "All Emotes"]</a><br>"
				dat += "<b>Ghost whispers:</b> <a href='?_src_=prefs;preference=ghost_whispers'>[(chat_toggles & CHAT_GHOSTWHISPER) ? "Nearest Creatures" : "All Speech"]</a><br>"
				dat += "<b>Ghost radio:</b> <a href='?_src=prefs;preference=ghost_radio'>[(chat_toggles & CHAT_GHOSTRADIO) ? "Yes" : "No"]</a><br>"
				dat += "<b>Ghost pda:</b> <a href='?_src=prefs;preference=ghost_pda'>[(chat_toggles & CHAT_GHOSTPDA) ? "Nearest Creatures" : "All Messages"]</a><br>"
				dat += "<b>Pull requests:</b> <a href='?_src_=prefs;preference=pull_requests'>[(chat_toggles & CHAT_PULLR) ? "Yes" : "No"]</a><br>"
				dat += "<b>Midround Antagonist:</b> <a href='?_src_=prefs;preference=allow_midround_antag'>[(toggles & MIDROUND_ANTAG) ? "Yes" : "No"]</a><br>"
				if(config.allow_Metadata)
					dat += "<b>OOC Notes:</b> <a href='?_src_=prefs;preference=metadata;task=input'> Edit </a><br>"

				if(user.client)
					if(user.client.holder)
						dat += "<b>Adminhelp Sound:</b> "
						dat += "<a href='?_src_=prefs;preference=hear_adminhelps'>[(toggles & SOUND_ADMINHELP)?"On":"Off"]</a><br>"

					if(unlock_content || check_rights_for(user.client, R_ADMIN))
						dat += "<b>OOC:</b> <span style='border: 1px solid #161616; background-color: [ooccolor ? ooccolor : normal_ooc_colour];'>&nbsp;&nbsp;&nbsp;</span> <a href='?_src_=prefs;preference=ooccolor;task=input'>Change</a><br>"

					if(unlock_content)
						dat += "<b>BYOND Membership Publicity:</b> <a href='?_src_=prefs;preference=publicity'>[(toggles & MEMBER_PUBLIC) ? "Public" : "Hidden"]</a><br>"
						dat += "<b>Ghost Form:</b> <a href='?_src_=prefs;task=input;preference=ghostform'>[ghost_form]</a><br>"


				dat += "</td><td width='300px' height='300px' valign='top'>"

				dat += "<h2>Antagonist Settings</h2>"

				if(jobban_isbanned(user, "Syndicate"))
					dat += "<font color=red><b>You are banned from antagonist roles.</b></font>"
					src.be_special = 0

				else
					var/n = 0
					for (var/i in special_roles)
						if(jobban_isbanned(user, i))
							dat += "<b>Be [i]:</b> <font color=red><b>\[BANNED]</b></font><br>"
						else
							var/days_remaining = null
							if(config.use_age_restriction_for_jobs && ispath(special_roles[i])) //If it's a game mode antag, check if the player meets the minimum age
								var/mode_path = special_roles[i]
								var/datum/game_mode/temp_mode = new mode_path
								days_remaining = temp_mode.get_remaining_days(user.client)

							if(days_remaining)
								dat += "<b>Be [i]:</b> <font color=red> \[IN [days_remaining] DAYS]</font><br>"
							else
								dat += "<b>Be [i]:</b> <a href='?_src_=prefs;preference=be_special;num=[n]'>[src.be_special&(1<<n) ? "Yes" : "No"]</a><br>"
						n++
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

	proc/SetChoices(mob/user, limit = 17, list/splitJobs = list("Chief Engineer"), widthPerColumn = 295, height = 620)
		if(!SSjob)	return

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
				HTML += "<font color=red>[rank]</font></td><td><font color=red><b> \[BANNED\]</b></font></td></tr>"
				continue
			if(!job.player_old_enough(user.client))
				var/available_in_days = job.available_in_days(user.client)
				HTML += "<font color=red>[rank]</font></td><td><font color=red> \[IN [(available_in_days)] DAYS\]</font></td></tr>"
				continue
			if((job_civilian_low & ASSISTANT) && (rank != "Assistant") && !jobban_isbanned(user, "Assistant"))
				HTML += "<font color=orange>[rank]</font></td><td></td></tr>"
				continue
			if(config.enforce_human_authority && (rank in command_positions) && user.client.prefs.pref_species.id != "human")
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

		HTML += "<center><br><a href='?_src_=prefs;preference=job;task=random'>[userandomjob ? "Get random job if preferences unavailable" : "Be an Assistant if preference unavailable"]</a></center>"
		HTML += "<center><a href='?_src_=prefs;preference=job;task=reset'>Reset Preferences</a></center>"

		user << browse(null, "window=preferences")
		//user << browse(HTML, "window=mob_occupation;size=[width]x[height]")
		var/datum/browser/popup = new(user, "mob_occupation", "<div align='center'>Occupation Preferences</div>", width, height)
		popup.set_window_options("can_close=0")
		popup.set_content(HTML)
		popup.open(0)
		return

	proc/SetJobPreferenceLevel(var/datum/job/job, var/level)
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

	proc/UpdateJobPreference(mob/user, role, desiredLvl)
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


	proc/ResetJobs()

		job_civilian_high = 0
		job_civilian_med = 0
		job_civilian_low = 0

		job_medsci_high = 0
		job_medsci_med = 0
		job_medsci_low = 0

		job_engsec_high = 0
		job_engsec_med = 0
		job_engsec_low = 0


	proc/GetJobDepartment(var/datum/job/job, var/level)
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

	proc/process_link(mob/user, list/href_list)
		if(!istype(user, /mob/new_player))	return

		if(href_list["preference"] == "job")
			switch(href_list["task"])
				if("close")
					user << browse(null, "window=mob_occupation")
					ShowChoices(user)
				if("reset")
					ResetJobs()
					SetChoices(user)
				if("random")
					if(jobban_isbanned(user, "Assistant"))
						userandomjob = 1
					else
						userandomjob = !userandomjob
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
						real_name = random_name(gender)
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
						socks = random_socks(gender)
					if("eyes")
						eye_color = random_eye_color()
					if("s_tone")
						skin_tone = random_skin_tone()
					if("bag")
						backbag = rand(1,3)
					if("all")
						random_character()

			if("input")
				switch(href_list["preference"])
					if("ghostform")
						if(unlock_content)
							var/new_form = input(user, "Thanks for supporting BYOND - Choose your ghostly form:","Thanks for supporting BYOND",null) as null|anything in ghost_forms
							if(new_form)
								ghost_form = new_form
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
						if(gender == MALE)
							new_socks = input(user, "Choose your character's socks:", "Character Preference") as null|anything in socks_m
						else
							new_socks = input(user, "Choose your character's socks:", "Character Preference") as null|anything in socks_f
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
							if(mutant_color == "#000")
								mutant_color = pref_species.default_color

					if("mutant_color")
						var/new_mutantcolor = input(user, "Choose your character's alien skin color:", "Character Preference") as color|null
						if(new_mutantcolor)
							var/temp_hsv = RGBtoHSV(new_mutantcolor)
							if(new_mutantcolor == "#000000")
								mutant_color = pref_species.default_color
							else if(ReadHSV(temp_hsv)[3] >= ReadHSV("#7F7F7F")[3]) // mutantcolors must be bright
								mutant_color = sanitize_hexcolor(new_mutantcolor)
							else
								user << "<span class='danger'>Invalid color. Your color is not bright enough.</span>"

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
							backbag = backbaglist.Find(new_backbag)

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
						socks = random_socks(gender)
						facial_hair_style = random_facial_hair_style(gender)
						hair_style = random_hair_style(gender)

					if("hear_adminhelps")
						toggles ^= SOUND_ADMINHELP

					if("ui")
						switch(UI_style)
							if("Midnight")
								UI_style = "Plasmafire"
							if("Plasmafire")
								UI_style = "Retro"
							else
								UI_style = "Midnight"

					if("be_special")
						var/num = text2num(href_list["num"])
						be_special ^= (1<<num)

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
							user << sound(null, repeat = 0, wait = 0, volume = 85, channel = 1)

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
							real_name = random_name(gender)
							save_character()

					if("tab")
						if (href_list["tab"])
							current_tab = text2num(href_list["tab"])

		ShowChoices(user)
		return 1

	proc/copy_to(mob/living/carbon/human/character)
		if(be_random_name)
			real_name = random_name(gender)

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

		if(character.dna)
			character.dna.real_name = character.real_name
			if(pref_species != /datum/species/human && config.mutant_races)
				hardset_dna(character, null, null, null, null, pref_species.type)
			else
				hardset_dna(character, null, null, null, null, /datum/species/human)
			character.dna.mutant_color = mutant_color
			character.update_mutcolor()

		character.gender = gender
		character.age = age
		character.blood_type = blood_type

		character.eye_color = eye_color
		character.hair_color = hair_color
		character.facial_hair_color = facial_hair_color

		character.skin_tone = skin_tone
		character.hair_style = hair_style
		character.facial_hair_style = facial_hair_style
		character.underwear = underwear
		character.undershirt = undershirt
		character.socks = socks

		if(backbag > 3 || backbag < 1)
			backbag = 1 //Same as above
		character.backbag = backbag

		character.update_body()
		character.update_hair()
