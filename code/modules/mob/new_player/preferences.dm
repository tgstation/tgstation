//This file was auto-corrected by findeclaration.exe on 25.5.2012 20:42:33

var/global/list/special_roles = list( //keep synced with the defines BE_* in setup.dm --rastaf
//some autodetection here.
	"traitor" = IS_MODE_COMPILED("traitor"),             // 0
	"operative" = IS_MODE_COMPILED("nuclear"),           // 1
	"changeling" = IS_MODE_COMPILED("changeling"),       // 2
	"wizard" = IS_MODE_COMPILED("wizard"),               // 3
	"malf AI" = IS_MODE_COMPILED("malfunction"),         // 4
	"revolutionary" = IS_MODE_COMPILED("revolution"),    // 5
	"alien candidate" = 1, //always show                 // 6
	"pAI candidate" = 1, // -- TLE                       // 7
	"cultist" = IS_MODE_COMPILED("cult"),                // 8
	"infested monkey" = IS_MODE_COMPILED("monkey"),      // 9
)

var/global/list/underwear_m = list("White", "Grey", "Green", "Blue", "Black", "Mankini", "Love-Hearts", "Black2", "Grey2", "Stripey", "Kinky", "None") //Curse whoever made male/female underwear diffrent colours
var/global/list/underwear_f = list("Red", "White", "Yellow", "Blue", "Black", "Thong", "Babydoll", "Baby-Blue", "Green", "Pink", "Kinky", "None")
var/global/list/backbaglist = list("Nothing", "Backpack", "Satchel")

var/const/BE_TRAITOR   =(1<<0)
var/const/BE_OPERATIVE =(1<<1)
var/const/BE_CHANGELING=(1<<2)
var/const/BE_WIZARD    =(1<<3)
var/const/BE_MALF      =(1<<4)
var/const/BE_REV       =(1<<5)
var/const/BE_ALIEN     =(1<<6)
var/const/BE_PAI       =(1<<7)
var/const/BE_CULTIST   =(1<<8)
var/const/BE_MONKEY    =(1<<9)


var/const/MAX_SAVE_SLOTS = 10


datum/preferences

	var/real_name
	var/be_random_name = 0
	var/gender = MALE
	var/age = 30.0
	var/b_type = "A+"

		//Special role selection
	var/be_special = 0
		//Play admin midis
	var/midis = 1
		//Toggle ghost ears
	var/ghost_ears = 1
	var/ghost_sight = 1
		//Play pregame music
	var/pregame_music = 1
		//Saved changlog filesize to detect if there was a change
	var/lastchangelog = 0

		//Just like it sounds
	var/ooccolor = "#b82e00"
	var/underwear = 1
	var/backbag = 2

		//Hair type
	var/h_style = "Bald"
		//Hair color
	var/r_hair = 0
	var/g_hair = 0
	var/b_hair = 0

		//Face hair type
	var/f_style = "Shaved"
		//Face hair color
	var/r_facial = 0
	var/g_facial = 0
	var/b_facial = 0

		//Species
	var/species = "Human"

		//Skin color
	var/s_tone = 0

		//Eye color
	var/r_eyes = 0
	var/g_eyes = 0
	var/b_eyes = 0

	var/UI_style = "Midnight"

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
	var/userandomjob = 1 // Defaults to 1 for less assistants!
	var/default_slot = 1//Holder so it doesn't default to slot 1, rather the last one used
	var/slot_name = ""


	var/used_skillpoints = 0
	var/skill_specialization = null
	var/list/skills = list() // skills can range from 0 to 3

	// maps each organ to either null(intact), "cyborg" or "amputated"
	// will probably not be able to do this for head and torso ;)
	var/list/organ_data = list()

	var/list/job_alt_titles = new()		// the default name of a job like "Medical Doctor"

	var/flavor_text = ""
	var/med_record = ""
	var/sec_record = ""
	var/disabilities = 0

		// OOC Metadata:
	var/metadata = ""

	var/sound_adminhelp = 0
	var/lobby_music = 1//Whether or not to play the lobby music(Defaults yes)



	New()
		randomize_name()
		..()

	proc/ZeroSkills(var/forced = 0)
		for(var/V in SKILLS) for(var/datum/skill/S in SKILLS[V])
			if(!skills.Find(S.ID) || forced)
				skills[S.ID] = SKILL_NONE

	proc/CalculateSkillPoints()
		used_skillpoints = 0
		for(var/V in SKILLS) for(var/datum/skill/S in SKILLS[V])
			var/multiplier = 1
			switch(skills[S.ID])
				if(SKILL_NONE)
					used_skillpoints += 0 * multiplier
				if(SKILL_BASIC)
					used_skillpoints += 1 * multiplier
				if(SKILL_ADEPT)
					// secondary skills cost less
					if(S.secondary)
						used_skillpoints += 1 * multiplier
					else
						used_skillpoints += 3 * multiplier
				if(SKILL_EXPERT)
					// secondary skills cost less
					if(S.secondary)
						used_skillpoints += 3 * multiplier
					else
						used_skillpoints += 6 * multiplier

	proc/GetSkillClass(points)
		// skill classes describe how your character compares in total points
		var/original_points = points
		points -= min(round((age - 20) / 2.5), 4) // every 2.5 years after 20, one extra skillpoint
		if(age > 30)
			points -= round((age - 30) / 5) // every 5 years after 30, one extra skillpoint
		if(original_points > 0 && points <= 0) points = 1
		switch(points)
			if(0)
				return "Unconfigured"
			if(1 to 3)
				return "Terrifying"
			if(4 to 6)
				return "Below Average"
			if(7 to 10)
				return "Average"
			if(11 to 14)
				return "Above Average"
			if(15 to 18)
				return "Exceptional"
			if(19 to 24)
				return "Genius"
			if(24 to 1000)
				return "God"

	proc/SetSkills(mob/user)
		if(SKILLS == null)
			setup_skills()

		if(skills.len == 0)
			ZeroSkills()


		var/HTML = "<body>"
		HTML += "<b>Select your Skills</b><br>"
		HTML += "Current skill level: <b>[GetSkillClass(used_skillpoints)]</b> ([used_skillpoints])<br>"
		HTML += "<a href=\"byond://?src=\ref[user];preference=skills;preconfigured=1;\">Use preconfigured skillset</a><br>"
		HTML += "<table>"
		for(var/V in SKILLS)
			HTML += "<tr><th colspan = 5><b>[V]</b>"
			HTML += "</th></tr>"
			for(var/datum/skill/S in SKILLS[V])
				var/level = skills[S.ID]
				HTML += "<tr style='text-align:left;'>"
				HTML += "<th><a href='byond://?src=\ref[user];preference=skills;skillinfo=\ref[S]'>[S.name]</a></th>"
				HTML += "<th><a href='byond://?src=\ref[user];preference=skills;setskill=\ref[S];newvalue=[SKILL_NONE]'><font color=[(level == SKILL_NONE) ? "red" : "black"]>\[Untrained\]</font></a></th>"
				// secondary skills don't have an amateur level
				if(S.secondary)
					HTML += "<th></th>"
				else
					HTML += "<th><a href='byond://?src=\ref[user];preference=skills;setskill=\ref[S];newvalue=[SKILL_BASIC]'><font color=[(level == SKILL_BASIC) ? "red" : "black"]>\[Amateur\]</font></a></th>"
				HTML += "<th><a href='byond://?src=\ref[user];preference=skills;setskill=\ref[S];newvalue=[SKILL_ADEPT]'><font color=[(level == SKILL_ADEPT) ? "red" : "black"]>\[Trained\]</font></a></th>"
				HTML += "<th><a href='byond://?src=\ref[user];preference=skills;setskill=\ref[S];newvalue=[SKILL_EXPERT]'><font color=[(level == SKILL_EXPERT) ? "red" : "black"]>\[Professional\]</font></a></th>"
				HTML += "</tr>"
		HTML += "</table>"
		HTML += "<a href=\"byond://?src=\ref[user];preference=skills;cancel=1;\">\[Done\]</a>"

		user << browse(null, "window=preferences")
		user << browse(HTML, "window=show_skills;size=600x800")
		return

	proc/ShowChoices(mob/user)
		if(!user || !user.client)	return
		update_preview_icon()
		user << browse_rsc(preview_icon_front, "previewicon.png")
		user << browse_rsc(preview_icon_side, "previewicon2.png")
		var/dat = "<html><body><center>"

		dat += "Slot <b>[slot_name]</b> - "
		dat += "<a href=\"byond://?src=\ref[user];preference=open_load_dialog\">Load slot</a> - "
		dat += "<a href=\"byond://?src=\ref[user];preference=save\">Save slot</a> - "
		dat += "<a href=\"byond://?src=\ref[user];preference=slotname;task=input\">Rename slot</a> - "
		dat += "<a href=\"byond://?src=\ref[user];preference=reload\">Reload slot</a>"

		//column 1
		dat += "</center><hr><table><tr><td width='310px'>"

		dat += "<b>Name:</b> "
		dat += "<a href=\"byond://?src=\ref[user];preference=name;task=input\"><b>[real_name]</b></a> "
		dat += "(<a href=\"byond://?src=\ref[user];preference=name;task=random\">&reg;</A>) "
		dat += "(&reg; = <a href=\"byond://?src=\ref[user];preference=name\">[be_random_name ? "Yes" : "No"]</a>)"
		dat += "<br>"

		dat += "<b>Gender:</b> <a href=\"byond://?src=\ref[user];preference=gender\"><b>[gender == MALE ? "Male" : "Female"]</b></a><br>"
		dat += "<b>Age:</b> <a href='byond://?src=\ref[user];preference=age;task=input'>[age]</a>"

		dat += "<br>"
		dat += "<b>UI Style:</b> <a href=\"byond://?src=\ref[user];preference=ui\"><b>[UI_style]</b></a><br>"
		dat += "<b>Play admin midis:</b> <a href=\"byond://?src=\ref[user];preference=hear_midis\"><b>[midis == 1 ? "Yes" : "No"]</b></a><br>"
		dat += "<b>Play lobby music:</b> <a href=\"byond://?src=\ref[user];preference=lobby_music\"><b>[lobby_music == 1 ? "Yes" : "No"]</b></a><br>"
		dat += "<b>Ghost ears:</b> <a href=\"byond://?src=\ref[user];preference=ghost_ears\"><b>[ghost_ears == 0 ? "Nearest Creatures" : "All Speech"]</b></a><br>"
		dat += "<b>Ghost sight:</b> <a href=\"byond://?src=\ref[user];preference=ghost_sight\"><b>[ghost_sight == 0 ? "Nearest Creatures" : "All Emotes"]</b></a><br>"

		if(config.allow_Metadata)
			dat += "<b>OOC Notes:</b> <a href='byond://?src=\ref[user];preference=metadata;task=input'> Edit </a><br>"

		if((user.client) && (user.client.holder) && (user.client.holder.rank))
			dat += "<b>Adminhelp sound</b>: "
			dat += "[(sound_adminhelp)?"On":"Off"] <a href='byond://?src=\ref[user];preference=hear_adminhelps'>toggle</a><br>"

			if(user.client.holder.level >= 5)
				dat += "<br><b>OOC</b><br>"
				dat += "<a href='byond://?src=\ref[user];preference=ooccolor;task=input'>Change color</a> <font face=\"fixedsys\" size=\"3\" color=\"[ooccolor]\"><table style='display:inline;'  bgcolor=\"[ooccolor]\"><tr><td>__</td></tr></table></font><br>"

		dat += "<br><b>Occupation Choices</b><br>"
		dat += "\t<a href=\"byond://?src=\ref[user];preference=job;task=menu\"><b>Set Preferences</b></a><br><br>"

		if(jobban_isbanned(user, "Records"))
			dat += "<b>You are banned from using character records.</b><br>"
		else
			dat += "<b><a href=\"byond://?src=\ref[user];preference=records;task=input\">Character Records</a></b><br><br>"

		dat += "<b>Flavor Text</b><br>"
		dat += "<a href='byond://?src=\ref[user];preference=flavor_text;task=input'>Change</a><br>"
		if(lentext(flavor_text) <= 40)
			dat += "[flavor_text]"
		else
			dat += "[copytext(flavor_text, 1, 37)]...<br>"
		dat += "<br>"

		dat += "<b>Skill Choices</b><br>"
		dat += "\t<i>[GetSkillClass(used_skillpoints)]</i> ([used_skillpoints])<br>"
		dat += "\t<a href=\"byond://?src=\ref[user];preference=skills\"><b>Set Skills</b></a><br><br>"

		//column 2
		dat += "</td><td width='310px'>"	//height='300px'

		dat += "<table><tr><td width=100><b>Body</b> "
		dat += "(<a href=\"byond://?src=\ref[user];preference=all;task=random\">&reg;</A>)"
		dat += "<br>"
		dat += "Species: <a href='byond://?src=\ref[user];preference=species;task=input'>[species]</a><br>"
		dat += "Blood Type: <a href='byond://?src=\ref[user];preference=b_type;task=input'>[b_type]</a><br>"
		dat += "Skin Tone: <a href='byond://?src=\ref[user];preference=s_tone;task=input'>[-s_tone + 35]/220<br></a>"

		if(gender == MALE)
			dat += "Underwear: <a href =\"byond://?src=\ref[user];preference=underwear;task=input\"><b>[underwear_m[underwear]]</b></a><br>"
		else
			dat += "Underwear: <a href =\"byond://?src=\ref[user];preference=underwear;task=input\"><b>[underwear_f[underwear]]</b></a><br>"

		dat += "Backpack Type:<br><a href =\"byond://?src=\ref[user];preference=bag;task=input\"><b>[backbaglist[backbag]]</b></a><br>"

		dat += "</td><td><b>Preview</b><br><img src=previewicon.png height=64 width=64><img src=previewicon2.png height=64 width=64></td></tr></table>"

		dat += "<br><b>Hair</b><br>"
		dat += "<a href='byond://?src=\ref[user];preference=hair;task=input'>Change Color</a> <font face=\"fixedsys\" size=\"3\" color=\"#[num2hex(r_hair, 2)][num2hex(g_hair, 2)][num2hex(b_hair, 2)]\"><table style='display:inline;' bgcolor=\"#[num2hex(r_hair, 2)][num2hex(g_hair, 2)][num2hex(b_hair)]\"><tr><td>__</td></tr></table></font><br>"
		dat += "Style: <a href='byond://?src=\ref[user];preference=h_style;task=input'>[h_style]</a><br>"

		dat += "<br><b>Facial</b><br>"
		dat += "<a href='byond://?src=\ref[user];preference=facial;task=input'> Change Color</a> <font face=\"fixedsys\" size=\"3\" color=\"#[num2hex(r_facial, 2)][num2hex(g_facial, 2)][num2hex(b_facial, 2)]\"><table  style='display:inline;' bgcolor=\"#[num2hex(r_facial, 2)][num2hex(g_facial, 2)][num2hex(b_facial)]\"><tr><td>__</td></tr></table></font><br>"
		dat += "Style: <a href='byond://?src=\ref[user];preference=f_style;task=input'>[f_style]</a><br>"

		dat += "<br><b>Eyes</b><br>"
		dat += "<a href='byond://?src=\ref[user];preference=eyes;task=input'>Change Color</a> <font face=\"fixedsys\" size=\"3\" color=\"#[num2hex(r_eyes, 2)][num2hex(g_eyes, 2)][num2hex(b_eyes, 2)]\"><table  style='display:inline;' bgcolor=\"#[num2hex(r_eyes, 2)][num2hex(g_eyes, 2)][num2hex(b_eyes)]\"><tr><td>__</td></tr></table></font>"

		dat += "<br><br>"
		if(jobban_isbanned(user, "Syndicate"))
			dat += "<b>You are banned from antagonist roles.</b>"
			src.be_special = 0
		else
			var/n = 0
			for (var/i in special_roles)
				if(special_roles[i]) //if mode is available on the server
					if(jobban_isbanned(user, i))
						dat += "<b>Be [i]:</b> <font color=red><b> \[BANNED]</b></font><br>"
					else if(i == "pai candidate")
						if(jobban_isbanned(user, "pAI"))
							dat += "<b>Be [i]:</b> <font color=red><b> \[BANNED]</b></font><br>"
					else
						dat += "<b>Be [i]:</b> <a href=\"byond://?src=\ref[user];preference=be_special;num=[n]\"><b>[src.be_special&(1<<n) ? "Yes" : "No"]</b></a><br>"
				n++
		dat += "</td></tr></table><center>"

		dat += "<hr>"

		/*
		if(!IsGuestKey(user.key))
			dat += "<a href='byond://?src=\ref[user];preference=load'>Undo</a> - "
			dat += "<a href='byond://?src=\ref[user];preference=save'>Save Setup</a> - "

		dat += "<a href='byond://?src=\ref[user];preference=reset_all'>Reset Setup</a>"
		*/
		dat += "</center></body></html>"

		user << browse(dat, "window=preferences;size=570x650")

	proc/SetDisabilities(mob/user)
		var/HTML = "<body>"
		HTML += "<tt><center>"
		HTML += "<b>Choose disabilities</b><br>"

		HTML += "Need Glasses? <a href=\"byond://?src=\ref[user];preferences=1;disabilities=0\">[disabilities & (1<<0) ? "Yes" : "No"]</a><br>"
		HTML += "Seizures? <a href=\"byond://?src=\ref[user];preferences=1;disabilities=1\">[disabilities & (1<<1) ? "Yes" : "No"]</a><br>"
		HTML += "Coughing? <a href=\"byond://?src=\ref[user];preferences=1;disabilities=2\">[disabilities & (1<<2) ? "Yes" : "No"]</a><br>"
		HTML += "Tourettes/Twitching? <a href=\"byond://?src=\ref[user];preferences=1;disabilities=3\">[disabilities & (1<<3) ? "Yes" : "No"]</a><br>"
		HTML += "Nervousness? <a href=\"byond://?src=\ref[user];preferences=1;disabilities=4\">[disabilities & (1<<4) ? "Yes" : "No"]</a><br>"
		HTML += "Deafness? <a href=\"byond://?src=\ref[user];preferences=1;disabilities=5\">[disabilities & (1<<5) ? "Yes" : "No"]</a><br>"

		HTML += "<br>"
		HTML += "<a href=\"byond://?src=\ref[user];preferences=1;disabilities=-2\">\[Done\]</a>"
		HTML += "</center></tt>"

		user << browse(null, "window=preferences")
		user << browse(HTML, "window=disabil;size=350x300")
		return

	proc/SetRecords(mob/user)
		var/HTML = "<body>"
		HTML += "<tt><center>"
		HTML += "<b>Set Character Records</b><br>"

		HTML += "<a href=\"byond://?src=\ref[user];preferences=1;med_record=1\">Medical Records</a><br>"

		if(lentext(med_record) <= 40)
			HTML += "[med_record]"
		else
			HTML += "[copytext(med_record, 1, 37)]..."

		HTML += "<br><br><a href=\"byond://?src=\ref[user];preferences=1;sec_record=1\">Security Records</a><br>"

		if(lentext(sec_record) <= 40)
			HTML += "[sec_record]<br>"
		else
			HTML += "[copytext(sec_record, 1, 37)]...<br>"

		HTML += "<br>"
		HTML += "<a href=\"byond://?src=\ref[user];preferences=1;records=-1\">\[Done\]</a>"
		HTML += "</center></tt>"

		user << browse(null, "window=preferences")
		user << browse(HTML, "window=records;size=350x300")
		return

	proc/GetAltTitle(datum/job/job)
		return job_alt_titles.Find(job.title) > 0 \
			? job_alt_titles[job.title] \
			: job.title

	proc/SetAltTitle(datum/job/job, new_title)
		// remove existing entry
		if(job_alt_titles.Find(job.title))
			job_alt_titles -= job.title
		// add one if it's not default
		if(job.title != new_title)
			job_alt_titles[job.title] = new_title

	proc/SetChoices(mob/user, limit = 17, list/splitJobs = list("Chief Engineer"), width = 550, height = 500)
		 //limit 	 - The amount of jobs allowed per column. Defaults to 17 to make it look nice.
		 //splitJobs - Allows you split the table by job. You can make different tables for each department by including their heads. Defaults to CE to make it look nice.
		 //width	 - Screen' width. Defaults to 550 to make it look nice.
		 //height 	 - Screen's height. Defaults to 500 to make it look nice.


		var/HTML = "<body>"
		HTML += "<tt><center>"
		HTML += "<b>Choose occupation chances</b><br>Unavailable occupations are in red.<br><br>"
		HTML += "<a align='center' href=\"byond://?src=\ref[user];preference=job;task=close\">\[Done\]</a><br><br>" // Easier to press up here.
		HTML += "<table width='100%' cellpadding='1' cellspacing='0'><tr><td width='20%'>" // Table within a table for alignment, also allows you to easily add more colomns.
		HTML += "<table width='100%' cellpadding='1' cellspacing='0'>"
		var/index = -1

		//The job before the current job. I only use this to get the previous jobs color when I'm filling in blank rows.
		var/datum/job/lastJob

		for(var/datum/job/job in job_master.occupations)

			index += 1
			if((index >= limit) || (job.title in splitJobs))
				if((index < limit) && (lastJob != null))
					//If the cells were broken up by a job in the splitJob list then it will fill in the rest of the cells with
					//the last job's selection color. Creating a rather nice effect.
					for(var/i = 0, i < (limit - index), i += 1)
						HTML += "<tr bgcolor='[lastJob.selection_color]'><td width='60%' align='right'><a>&nbsp</a></td><td><a>&nbsp</a></td></tr>"
				HTML += "</table></td><td width='20%'><table width='100%' cellpadding='1' cellspacing='0'>"
				index = 0

			HTML += "<tr bgcolor='[job.selection_color]'><td width='60%' align='right'>"
			var/rank = job.title
			lastJob = job
			if(jobban_isbanned(user, rank))
				HTML += "<font color=red>[rank]</font></td><td><font color=red><b> \[BANNED]</b></font></td></tr>"
				continue
			if((job_civilian_low & ASSISTANT) && (rank != "Assistant"))
				HTML += "<font color=orange>[rank]</font></td><td></td></tr>"
				continue
			if((rank in command_positions) || (rank == "AI"))//Bold head jobs
				HTML += "<b>[rank]</b>"
			else
				HTML += "[rank]"

			HTML += "</td><td width='40%'>"

			HTML += "<a href=\"byond://?src=\ref[user];preference=job;task=input;text=[rank]\">"

			if(rank == "Assistant")//Assistant is special
				if(job_civilian_low & ASSISTANT)
					HTML += " <font color=green>\[Yes]</font>"
				else
					HTML += " <font color=red>\[No]</font>"
				HTML += "</a></td></tr>"
				continue

			if(GetJobDepartment(job, 1) & job.flag)
				HTML += " <font color=blue>\[High]</font>"
			else if(GetJobDepartment(job, 2) & job.flag)
				HTML += " <font color=green>\[Medium]</font>"
			else if(GetJobDepartment(job, 3) & job.flag)
				HTML += " <font color=orange>\[Low]</font>"
			else
				HTML += " <font color=red>\[NEVER]</font>"
			HTML += "</a></td></tr>"

		HTML += "</td'></tr></table>"

		HTML += "</center></table>"

		HTML += "<center><br><u><a href=\"byond://?src=\ref[user];preference=job;task=random\"><font color=[userandomjob ? "green>Get random job if preferences unavailable" : "red>Be assistant if preference unavailable"]</font></a></u></center>"

		HTML += "</tt>"

		user << browse(null, "window=preferences")
		user << browse(HTML, "window=mob_occupation;size=[width]x[height]")
		return


	proc/SetJob(mob/user, role)
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

		if(GetJobDepartment(job, 1) & job.flag)
			SetJobDepartment(job, 1)
		else if(GetJobDepartment(job, 2) & job.flag)
			SetJobDepartment(job, 2)
		else if(GetJobDepartment(job, 3) & job.flag)
			SetJobDepartment(job, 3)
		else//job = Never
			SetJobDepartment(job, 4)

		SetChoices(user)
		return 1


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


	proc/SetJobDepartment(var/datum/job/job, var/level)
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


	proc/process_link(mob/user, list/href_list)
		if(!user)	return

		if(href_list["preference"] == "job")
			switch(href_list["task"])
				if("close")
					user << browse(null, "window=mob_occupation")
					ShowChoices(user)
				if("random")
					userandomjob = !userandomjob
					SetChoices(user)
				if("input")
					SetJob(user, href_list["text"])
				else
					SetChoices(user)
			return 1
		else if(href_list["preference"] == "skills")
			if(href_list["cancel"])
				user << browse(null, "window=show_skills")
				ShowChoices(user)
			else if(href_list["skillinfo"])
				var/datum/skill/S = locate(href_list["skillinfo"])
				var/HTML = "<b>[S.name]</b><br>[S.desc]"
				user << browse(HTML, "window=\ref[user]skillinfo")
			else if(href_list["setskill"])
				var/datum/skill/S = locate(href_list["setskill"])
				var/value = text2num(href_list["newvalue"])
				skills[S.ID] = value
				CalculateSkillPoints()
				SetSkills(user)
			else if(href_list["preconfigured"])
				var/selected = input(user, "Select a skillset", "Skillset") as null|anything in SKILL_PRE
				if(!selected) return

				ZeroSkills(1)
				for(var/V in SKILL_PRE[selected])
					if(V == "field")
						skill_specialization = SKILL_PRE[selected]["field"]
						continue
					skills[V] = SKILL_PRE[selected][V]
				CalculateSkillPoints()

				SetSkills(user)
			else if(href_list["setspecialization"])
				skill_specialization = href_list["setspecialization"]
				CalculateSkillPoints()
				SetSkills(user)
			else
				SetSkills(user)
			return 1

		switch(href_list["task"])
			if("random")
				switch(href_list["preference"])
					if("name")
						randomize_name()

					if("age")
						age = rand(MIN_PLAYER_AGE, MAX_PLAYER_AGE)

					if("b_type")
						b_type = pick( 31;"A+", 7;"A-", 8;"B+", 2;"B-", 2;"AB+", 1;"AB-", 40;"O+", 9;"O-" )

					if("hair")
						randomize_hair_color("hair")

					if("h_style")
						randomize_hair(gender)

					if("facial")
						randomize_hair_color("facial")

					if("f_style")
						randomize_facial(gender)

					if("underwear")
						underwear = rand(1,12)

					if("eyes")
						randomize_eyes_color()

					if("s_tone")
						randomize_skin_tone()

					if("bag")
						backbag = rand(1,3)

					if("all")
						gender = pick(MALE,FEMALE)
						randomize_name()
						age = rand(17,45)
						underwear = rand(1,12)
						backbag = rand(1,3)
						randomize_hair_color("hair")
						randomize_hair(gender)
						randomize_hair_color("facial")
						randomize_facial(gender)
						randomize_eyes_color()
						randomize_skin_tone()
						b_type = pick( 31;"A+", 7;"A-", 8;"B+", 2;"B-", 2;"AB+", 1;"AB-", 40;"O+", 9;"O-" )

						job_civilian_high = 0
						job_civilian_med = 0
						job_civilian_low = 0
						job_medsci_high = 0
						job_medsci_med = 0
						job_medsci_low = 0
						job_engsec_high = 0
						job_engsec_med = 0
						job_engsec_low = 0
						be_special = 0
						be_random_name = 0
						UI_style = "Midnight"
						midis = 1
						ghost_ears = 1
						userandomjob = 1

			if("input")
				switch(href_list["preference"])
					if("name")
						var/new_name = reject_bad_name( input(user, "Choose your character's name:", "Character Preference")  as text|null )
						if(new_name)
							real_name = new_name
						else
							user << "<font color='red'>Invalid name. Your name should be at least 2 and at most [MAX_NAME_LEN] characters long. It may only contain the characters A-Z, a-z, -, ' and .</font>"

					if("age")
						var/new_age = input(user, "Choose your character's age:\n([MIN_PLAYER_AGE]-[MAX_PLAYER_AGE])", "Character Preference") as num|null
						if(new_age)
							age = max(min(round(text2num(new_age)), MAX_PLAYER_AGE), MIN_PLAYER_AGE)

					if("species")
						var/list/new_species = list("Human")
						var/prev_species = species
						var/whitelisted = 0
						if(config.usealienwhitelist) //If we're using the whitelist, make sure to check it!
							if(is_alien_whitelisted(user, "Soghun")) //Check for Soghun and admins
								new_species += "Soghun"
								whitelisted = 1
							if(is_alien_whitelisted(user, "Tajaran")) //Check for Tajaran and admins
								new_species += "Tajaran"
								whitelisted = 1
							if(is_alien_whitelisted(user, "Skrell")) //Check for Skrell and admins
								new_species += "Skrell"
								whitelisted = 1
						else //Not using the whitelist? Aliens for everyone!
							new_species += "Tajaran"
							new_species += "Soghun"
							new_species += "Skrell"
						if(!whitelisted && config.usealienwhitelist)
							alert(user, "You cannot change your species as you need to be whitelisted. If you wish to be whitelisted contact an admin in-game, on the forums, or on IRC.")
						species = input("Please select a species", "Character Generation", null) in new_species
						if(prev_species != species)
							//grab one of the valid hair styles for the newly chosen species
							var/list/valid_hairstyles = list()
							for(var/hairstyle in hair_styles_list)
								var/datum/sprite_accessory/S = hair_styles_list[hairstyle]
								if(gender == MALE && !S.choose_male)
									continue
								if(gender == FEMALE && !S.choose_female)
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
								if(gender == MALE && !S.choose_male)
									continue
								if(gender == FEMALE && !S.choose_female)
									continue
								if( !(species in S.species_allowed))
									continue

								valid_facialhairstyles[facialhairstyle] = facial_hair_styles_list[facialhairstyle]
							if(valid_hairstyles.len)
								f_style = pick(valid_facialhairstyles)
							else
								//this shouldn't happen
								f_style = facial_hair_styles_list["Shaved"]

							s_tone = 0


					if("metadata")
						var/new_metadata = input(user, "Enter any information you'd like others to see, such as Roleplay-preferences:", "Game Preference" , metadata)  as message|null
						if(new_metadata)
							metadata = sanitize(copytext(new_metadata,1,MAX_MESSAGE_LEN))

					if("b_type")
						var/new_b_type = input(user, "Choose your character's blood-type:", "Character Preference") as null|anything in list( "A+", "A-", "B+", "B-", "AB+", "AB-", "O+", "O-" )
						if(new_b_type)
							b_type = new_b_type

					if("hair")
						var/new_hair = input(user, "Choose your character's hair colour:", "Character Preference") as color|null
						if(new_hair)
							r_hair = hex2num(copytext(new_hair, 2, 4))
							g_hair = hex2num(copytext(new_hair, 4, 6))
							b_hair = hex2num(copytext(new_hair, 6, 8))

					if("h_style")
						var/list/valid_hairstyles = list()
						for(var/hairstyle in hair_styles_list)
							var/datum/sprite_accessory/S = hair_styles_list[hairstyle]
							if(gender == MALE && !S.choose_male)
								continue
							if(gender == FEMALE && !S.choose_female)
								continue
							if( !(species in S.species_allowed))
								continue

							valid_hairstyles[hairstyle] = hair_styles_list[hairstyle]

						var/new_h_style = input(user, "Choose your character's hair style:", "Character Preference")  as null|anything in valid_hairstyles
						if(new_h_style)
							h_style = new_h_style

					if("facial")
						var/new_facial = input(user, "Choose your character's facial-hair colour:", "Character Preference") as color|null
						if(new_facial)
							r_facial = hex2num(copytext(new_facial, 2, 4))
							g_facial = hex2num(copytext(new_facial, 4, 6))
							b_facial = hex2num(copytext(new_facial, 6, 8))

					if("f_style")
						var/list/valid_facialhairstyles = list()
						for(var/facialhairstyle in facial_hair_styles_list)
							var/datum/sprite_accessory/S = facial_hair_styles_list[facialhairstyle]
							if(gender == MALE && !S.choose_male)
								continue
							if(gender == FEMALE && !S.choose_female)
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

					if("eyes")
						var/new_eyes = input(user, "Choose your character's eye colour:", "Character Preference") as color|null
						if(new_eyes)
							r_eyes = hex2num(copytext(new_eyes, 2, 4))
							g_eyes = hex2num(copytext(new_eyes, 4, 6))
							b_eyes = hex2num(copytext(new_eyes, 6, 8))

					if("s_tone")
						if(species != "Human")
							return
						var/new_s_tone = input(user, "Choose your character's skin-tone:\n(Light 1 - 220 Dark)", "Character Preference")  as num|null
						if(new_s_tone)
							s_tone = max(min(round(new_s_tone), 220), 1)
							s_tone = -s_tone + 35

					if("ooccolor")
						var/new_ooccolor = input(user, "Choose your OOC colour:", "Game Preference") as color|null
						if(new_ooccolor)
							ooccolor = new_ooccolor

					if("bag")
						var/new_backbag = input(user, "Choose your character's style of bag:", "Character Preference")  as null|anything in backbaglist
						if(new_backbag)
							backbag = backbaglist.Find(new_backbag)

					if("slotname")
						var/new_slotname = input(user, "Please name this savefile:", "Save Slot Name")  as text|null
						if(ckey(new_slotname))//Checks to make sure there is one letter
							slot_name = strip_html_simple(new_slotname,20)
							savefile_save(user)

					if("flavor_text")
						var/msg = input(usr,"Set the flavor text in your 'examine' verb. This can also be used for OOC notes and preferences!","Flavor Text",html_decode(flavor_text)) as message

						if(msg != null)
							msg = copytext(msg, 1, MAX_MESSAGE_LEN)
							msg = html_encode(msg)

							flavor_text = msg

					if("disabilities")
						if(text2num(href_list["disabilities"]) >= -1)
							if(text2num(href_list["disabilities"]) >= 0)
								disabilities ^= (1<<text2num(href_list["disabilities"])) //MAGIC
							SetDisabilities(user)
							return
						else
							user << browse(null, "window=disabil")

					if("records")
						if(text2num(href_list["records"]) >= 1)
							SetRecords(user)
							return
						else
							user << browse(null, "window=records")

					if("med_record")
						var/medmsg = input(usr,"Set your medical notes here.","Medical Records",html_decode(med_record)) as message

						if(medmsg != null)
							medmsg = copytext(medmsg, 1, MAX_PAPER_MESSAGE_LEN)
							medmsg = html_encode(medmsg)

							med_record = medmsg
							SetRecords(user)

					if("sec_record")
						var/secmsg = input(usr,"Set your security notes here.","Security Records",html_decode(sec_record)) as message

						if(secmsg != null)
							secmsg = copytext(secmsg, 1, MAX_PAPER_MESSAGE_LEN)
							secmsg = html_encode(secmsg)

							sec_record = secmsg
							SetRecords(user)

			else
				switch(href_list["preference"])
					if("gender")
						if(gender == MALE)
							gender = FEMALE
						else
							gender = MALE
						//grab one of the valid hair styles for the newly chosen species
						var/list/valid_hairstyles = list()
						for(var/hairstyle in hair_styles_list)
							var/datum/sprite_accessory/S = hair_styles_list[hairstyle]
							if(gender == MALE && !S.choose_male)
								continue
							if(gender == FEMALE && !S.choose_female)
								continue
							if( !(species in S.species_allowed))
								continue

							valid_hairstyles[hairstyle] = hair_styles_list[hairstyle]
						if(valid_hairstyles.len)
							h_style = pick(valid_hairstyles)
						else
							h_style = hair_styles_list["Bald"]

						//grab one of the valid facial hair styles for the newly chosen species
						var/list/valid_facialhairstyles = list()
						for(var/facialhairstyle in facial_hair_styles_list)
							var/datum/sprite_accessory/S = facial_hair_styles_list[facialhairstyle]
							if(gender == MALE && !S.choose_male)
								continue
							if(gender == FEMALE && !S.choose_female)
								continue
							if( !(species in S.species_allowed))
								continue

							valid_facialhairstyles[facialhairstyle] = facial_hair_styles_list[facialhairstyle]
						if(valid_hairstyles.len)
							f_style = pick(valid_facialhairstyles)
						else
							f_style = facial_hair_styles_list["Shaved"]


					if("hear_adminhelps")
						sound_adminhelp = !sound_adminhelp

					if("ui")
						switch(UI_style)
							if("Midnight")
								UI_style = "Orange"
							if("Orange")
								UI_style = "old"
							else
								UI_style = "Midnight"

					if("be_special")
						var/num = text2num(href_list["num"])
						be_special ^= (1<<num)

					if("name")
						be_random_name = !be_random_name

					if("hear_midis")
						midis = !midis

					if("lobby_music")
						lobby_music = !lobby_music
						if(lobby_music)
							user << sound(ticker.login_music, repeat = 0, wait = 0, volume = 85, channel = 1)
						else
							user << sound(null, repeat = 0, wait = 0, volume = 85, channel = 1)

					if("ghost_ears")
						ghost_ears = !ghost_ears

					if("ghost_sight")
						ghost_sight = !ghost_sight

					if("save")
						if(!IsGuestKey(user.key))
							savefile_save(user)

					if("reload")
						if(!IsGuestKey(user.key))
							savefile_load(user)

					if("open_load_dialog")
						if(!IsGuestKey(user.key))
							open_load_dialog(user)

					if("close_load_dialog")
						close_load_dialog(user)

					if("changeslot")
						savefile_save(user)
						user.client.activeslot = min(max(text2num(href_list["num"]), 1), MAX_SAVE_SLOTS)
						savefile_load(user)
						close_load_dialog(user)

					if("newslot")
						savefile_save(user)
						var/slot_num = min(max(text2num(href_list["num"]), 1), MAX_SAVE_SLOTS)
						savefile_createslot(user, slot_num)
						close_load_dialog(user)

		ShowChoices(user)
		return 1

	proc/copy_to(mob/living/carbon/human/character, safety = 0)
		if(be_random_name)
			randomize_name()

		if(config.humans_need_surnames)
			var/firstspace = findtext(real_name, " ")
			var/name_length = length(real_name)
			if(!firstspace)	//we need a surname
				real_name += " [pick(last_names)]"
			else if(firstspace == name_length)
				real_name += "[pick(last_names)]"

		character.real_name = real_name

		if(character.dna)
			character.dna.real_name = character.real_name

		character.gender = gender

		character.age = age

		character.b_type = b_type

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

		switch(UI_style)
			if("Orange")
				character.UI = 'icons/mob/screen1_Orange.dmi'
			if("old")
				character.UI = 'icons/mob/screen1_old.dmi'
			else
				//default
				character.UI = 'icons/mob/screen1_Midnight.dmi'

		if(underwear > 12 || underwear < 1)
			underwear = 1 //I'm sure this is 100% unnecessary, but I'm paranoid... sue me.
		character.underwear = underwear

		if(backbag > 3 || backbag < 1)
			backbag = 1 //Same as above
		character.backbag = backbag

		if(!safety)//To prevent run-time errors due to null datum when using randomize_appearance_for()
			spawn(10)
				if(character&&character.client)
					setup_client(character.client)

		//Debugging report to track down a bug, which randomly assigned the plural gender to people.
		if(character.gender in list(PLURAL, NEUTER))
			if(isliving(src)) //Ghosts get neuter by default
				message_admins("[character] ([character.ckey]) has spawned with their gender as plural or neuter. Please notify coders.")
				character.gender = MALE

	proc/copy_to_observer(mob/dead/observer/character)
		spawn(10)
			if(character && character.client)
				setup_client(character.client)

	proc/setup_client(var/client/C)
		if(C)
			C.sound_adminhelp = src.sound_adminhelp
			C.midis = src.midis
			C.ooccolor = src.ooccolor
			C.be_alien = be_special & BE_ALIEN
			C.be_pai = be_special & BE_PAI
			if(isnull(src.ghost_ears)) src.ghost_ears = 1 //There were problems where the default was null before someone saved their profile.
			C.ghost_ears = src.ghost_ears
			C.ghost_sight = src.ghost_sight
