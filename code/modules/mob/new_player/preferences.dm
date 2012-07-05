//This file was auto-corrected by findeclaration.exe on 25.5.2012 20:42:33

#define UI_OLD 0
#define UI_NEW 1

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
	"meme" = IS_MODE_COMPILED("meme"),                   // 10
)

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
var/const/BE_MEME		 =(1<<10)





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
	var/list/underwear_m = list("White", "Grey", "Green", "Blue", "Black", "None") //Curse whoever made male/female underwear diffrent colours
	var/list/underwear_f = list("Red", "White", "Yellow", "Blue", "Black", "None")
	var/backbag = 2
	var/list/backbaglist = list("Nothing", "Backpack", "Satchel", "Satchel Alt")

		//Hair type
	var/h_style = "Short Hair"
	var/datum/sprite_accessory/hair/hair_style
		//Hair color
	var/r_hair = 0
	var/g_hair = 0
	var/b_hair = 0

		//Face hair type
	var/f_style = "Shaved"
	var/datum/sprite_accessory/facial_hair/facial_hair_style
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

		//UI style
		//UI = UI_OLD
	var/UI_style = "Midnight"

		//Mob preview
	var/icon/preview_icon = null
	var/preview_dir = SOUTH

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

	var/list/job_alt_titles = new()		// the default name of a job like "Medical Doctor"

	var/flavor_text = ""

	var/med_record = ""
	var/sec_record = ""

		// slot stuff (Why were they var/var?  --SkyMarshal)
	var/slotname
	var/curslot = 0
	var/disabilities = 0

	var/used_skillpoints = 0
	var/skill_specialization = null
	var/list/skills = list() // skills can range from 0 to 3

	// maps each organ to either null(intact), "cyborg" or "amputated"
	// will probably not be able to do this for head and torso ;)
	var/list/organ_data = list()

		// OOC Metadata:
	var/metadata = ""


	New()
		hair_style = new/datum/sprite_accessory/hair/short
		facial_hair_style = new/datum/sprite_accessory/facial_hair/shaved
		randomize_name()
		..()
//proc for making sentences Do This As An Example. For names.
	proc/simple_titlecase(string)
		string = uppertext(copytext(string,1,2)) + copytext(string, 2)
		var/space_pos = findtext(string, " ")
		var/strlen = length(string)
		while(space_pos)
			string = copytext(string,1,space_pos+1) + \
				uppertext(copytext(string, space_pos+1, space_pos+2)) + \
				((space_pos+2 <= strlen) ? copytext(string, space_pos+2) : "")
			space_pos = findtext(string, " ", space_pos+1)
			//In case of a trailing space
			if(space_pos >= strlen) return string
		return string

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
		HTML += "<a href=\"byond://?src=\ref[user];skills=1;preferences=1;preconfigured=1;\">Use preconfigured skillset</a><br>"
		HTML += "<table>"
		for(var/V in SKILLS)
			HTML += "<tr><th colspan = 5><b>[V]</b>"
			HTML += "</th></tr>"
			for(var/datum/skill/S in SKILLS[V])
				var/level = skills[S.ID]
				HTML += "<tr style='text-align:left;'>"
				HTML += "<th><a href='byond://?src=\ref[user];preferences=1;skills=1;skillinfo=\ref[S]'>[S.name]</a></th>"
				HTML += "<th><a href='byond://?src=\ref[user];preferences=1;skills=1;setskill=\ref[S];newvalue=[SKILL_NONE]'><font color=[(level == SKILL_NONE) ? "red" : "black"]>\[Untrained\]</font></a></th>"
				// secondary skills don't have an amateur level
				if(S.secondary)
					HTML += "<th></th>"
				else
					HTML += "<th><a href='byond://?src=\ref[user];preferences=1;skills=1;setskill=\ref[S];newvalue=[SKILL_BASIC]'><font color=[(level == SKILL_BASIC) ? "red" : "black"]>\[Amateur\]</font></a></th>"
				HTML += "<th><a href='byond://?src=\ref[user];preferences=1;skills=1;setskill=\ref[S];newvalue=[SKILL_ADEPT]'><font color=[(level == SKILL_ADEPT) ? "red" : "black"]>\[Trained\]</font></a></th>"
				HTML += "<th><a href='byond://?src=\ref[user];preferences=1;skills=1;setskill=\ref[S];newvalue=[SKILL_EXPERT]'><font color=[(level == SKILL_EXPERT) ? "red" : "black"]>\[Professional\]</font></a></th>"
				HTML += "</tr>"
		HTML += "</table>"
		HTML += "<a href=\"byond://?src=\ref[user];skills=1;preferences=1;cancel=1;\">\[Done\]</a>"

		user << browse(null, "window=preferences")
		user << browse(HTML, "window=show_skills;size=600x800")
		return



	proc/ShowChoices(mob/user)
		update_preview_icon()
		user << browse_rsc(preview_icon, "previewicon.png")

		var/dat = "<html><body>"
		dat += "<b>Name:</b> "
		dat += "<a href=\"byond://?src=\ref[user];preferences=1;real_name=input\"><b>[real_name]</b></a> "
		dat += "(<a href=\"byond://?src=\ref[user];preferences=1;real_name=random\">&reg;</A>) "
		dat += "(&reg; = <a href=\"byond://?src=\ref[user];preferences=1;b_random_name=1\">[be_random_name ? "Yes" : "No"]</a>)"
		dat += "<br>"

		dat += "<b>Gender:</b> <a href=\"byond://?src=\ref[user];preferences=1;gender=input\"><b>[gender == MALE ? "Male" : "Female"]</b></a><br>"
		dat += "<b>Age:</b> <a href='byond://?src=\ref[user];preferences=1;age=input'>[age]</a>"

		dat += "<br>"
		dat += "<b>UI Style:</b> <a href=\"byond://?src=\ref[user];preferences=1;UI=input\"><b>[UI_style]</b></a><br>"
		dat += "<b>Play admin midis:</b> <a href=\"byond://?src=\ref[user];preferences=1;midis=input\"><b>[midis == 1 ? "Yes" : "No"]</b></a><br>"
		dat += "<b>Ghost ears:</b> <a href=\"byond://?src=\ref[user];preferences=1;ghost_ears=input\"><b>[ghost_ears == 0 ? "Nearest Creatures" : "All Speech"]</b></a><br>"
		dat += "<b>Ghost sight:</b> <a href=\"byond://?src=\ref[user];preferences=1;ghost_sight=input\"><b>[ghost_sight == 0 ? "Nearest Creatures" : "All Emotes"]</b></a><br>"

		if(config.allow_Metadata)
			dat += "<b>OOC Notes:</b> <a href='byond://?src=\ref[user];preferences=1;OOC=input'> Edit </a><br>"

		if((user.client) && (user.client.holder) && (user.client.holder.rank) && (user.client.holder.level >= 5))
			dat += "<hr><b>OOC</b><br>"
			dat += "<a href='byond://?src=\ref[user];preferences=1;ooccolor=input'>Change colour</a> <font face=\"fixedsys\" size=\"3\" color=\"[ooccolor]\"><table style='display:inline;'  bgcolor=\"[ooccolor]\"><tr><td>__</td></tr></table></font>"

		dat += "<hr><b>Occupation Choices</b><br>"
		dat += "\t<a href=\"byond://?src=\ref[user];preferences=1;occ=1\"><b>Set Preferences</b></a><br>"

		dat += "<hr><b>Skill Choices</b><br>"
		dat += "\t<i>[GetSkillClass(used_skillpoints)]</i> ([used_skillpoints])<br>"
		dat += "\t<a href=\"byond://?src=\ref[user];preferences=1;skills=1\"><b>Set Skills</b></a><br>"

		dat += "<hr><table><tr><td><b>Body</b> "
		dat += "(<a href=\"byond://?src=\ref[user];preferences=1;s_tone=random;underwear=random;backbag_type=random;age=random;b_type=random;hair=random;h_style=random;facial=random;f_style=random;eyes=random\">&reg;</A>)" // Random look
		dat += "<br>"
		dat += "Species: <a href='byond://?src=\ref[user];preferences=1;species=input'>[species]</a><br>"
		dat += "Blood Type: <a href='byond://?src=\ref[user];preferences=1;b_type=input'>[b_type]</a><br>"
		dat += "Skin Tone: <a href='byond://?src=\ref[user];preferences=1;s_tone=input'>[-s_tone + 35]/220<br></a>"

		dat += "Limbs: <a href='byond://?src=\ref[user];preferences=1;limbs=input'>Adjust Limbs</a><br>"
		for(var/name in organ_data)
			var/status = organ_data[name]
			var/organ_name = null
			switch(name)
				if("l_arm")
					organ_name = "left arm"
				if("r_arm")
					organ_name = "right arm"
				if("l_leg")
					organ_name = "left leg"
				if("r_leg")
					organ_name = "right leg"
				if("l_foot")
					organ_name = "left foot"
				if("r_foot")
					organ_name = "right foot"
				if("l_hand")
					organ_name = "left hand"
				if("r_hand")
					organ_name = "right hand"

			if(status == "cyborg")
				dat += "\tRobotical [organ_name] prothesis<br>"
			if(status == "amputated")
				dat += "\tAmputated [organ_name]<br>"
		dat+="<br>"

		if(gender == MALE)
			dat += "Underwear: <a href =\"byond://?src=\ref[user];preferences=1;underwear=inputmale\"><b>[underwear_m[underwear]]</b></a><br>"
		else
			dat += "Underwear: <a href =\"byond://?src=\ref[user];preferences=1;underwear=inputfemale\"><b>[underwear_f[underwear]]</b></a><br>"

		dat += "Backpack Type:<br><a href =\"byond://?src=\ref[user];preferences=1;backbag_type=input\"><b>[backbaglist[backbag]]</b></a><br>"

		dat += "</td><td style='text-align:center;padding-left:2em'><b>Preview</b><br>"
		dat += "<a href='?src=\ref[user];preferences=1;preview_dir=[turn(preview_dir,-90)]'>&lt;</a>"
		dat += "<img src=previewicon.png height=64 width=64 style='vertical-align:middle'>"
		dat += "<a href='?src=\ref[user];preferences=1;preview_dir=[turn(preview_dir,90)]'>&gt;</a>"
		dat += "</td></tr></table>"

		dat += "<hr><b>Hair</b><br>"

		dat += "<a href='byond://?src=\ref[user];preferences=1;hair=input'>Change Color</a> <font face=\"fixedsys\" size=\"3\" color=\"#[num2hex(r_hair, 2)][num2hex(g_hair, 2)][num2hex(b_hair, 2)]\"><table style='display:inline;' bgcolor=\"#[num2hex(r_hair, 2)][num2hex(g_hair, 2)][num2hex(b_hair)]\"><tr><td>__</td></tr></table></font> "

		dat += "Style: <a href='byond://?src=\ref[user];preferences=1;h_style=input'>[h_style]</a>"

		dat += "<hr><b>Facial</b><br>"

		dat += "<a href='byond://?src=\ref[user];preferences=1;facial=input'>Change Color</a> <font face=\"fixedsys\" size=\"3\" color=\"#[num2hex(r_facial, 2)][num2hex(g_facial, 2)][num2hex(b_facial, 2)]\"><table  style='display:inline;' bgcolor=\"#[num2hex(r_facial, 2)][num2hex(g_facial, 2)][num2hex(b_facial)]\"><tr><td>__</td></tr></table></font> "

		dat += "Style: <a href='byond://?src=\ref[user];preferences=1;f_style=input'>[f_style]</a>"

		dat += "<hr><b>Eyes</b><br>"
		dat += "<a href='byond://?src=\ref[user];preferences=1;eyes=input'>Change Color</a> <font face=\"fixedsys\" size=\"3\" color=\"#[num2hex(r_eyes, 2)][num2hex(g_eyes, 2)][num2hex(b_eyes, 2)]\"><table  style='display:inline;' bgcolor=\"#[num2hex(r_eyes, 2)][num2hex(g_eyes, 2)][num2hex(b_eyes)]\"><tr><td>__</td></tr></table></font>"

		dat += "<hr><b><a href=\"byond://?src=\ref[user];preferences=1;disabilities=-1\">Disabilities</a></b><br>"

		if(jobban_isbanned(user, "Records"))
			dat += "<hr><b>You are banned from using character records.</b><br>"
		else
			dat += "<hr><b><a href=\"byond://?src=\ref[user];preferences=1;records=1\">Character Records</a></b><br>"
		dat += "<hr><b>Flavor Text</b><br>"
		dat += "<a href='byond://?src=\ref[user];preferences=1;flavor_text=1'>Change</a><br>"
		if(lentext(flavor_text) <= 40)
			dat += "[flavor_text]"
		else
			dat += "[copytext(flavor_text, 1, 37)]..."

		dat += "<hr>"
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
						dat += "<b>Be [i]:</b> <a href=\"byond://?src=\ref[user];preferences=1;be_special=[n]\"><b>[src.be_special&(1<<n) ? "Yes" : "No"]</b></a><br>"
				n++
		dat += "<hr>"

		// slot options
		if (!IsGuestKey(user.key))
			if(!curslot)
				curslot = 1
				slotname = savefile_getslots(user)[1]
			dat += "<a href='byond://?src=\ref[user];preferences=1;saveslot=[curslot]'>Save Slot [curslot] ([slotname])</a><br>"
			dat += "<a href='byond://?src=\ref[user];preferences=1;loadslot2=1'>Load</a><br>"
		dat += "<a href='byond://?src=\ref[user];preferences=1;createslot=1'>Create New Slot</a><br>"

		dat += "<a href='byond://?src=\ref[user];preferences=1;reset_all=1'>Reset Setup</a><br>"
		dat += "</body></html>"

		user << browse(dat, "window=preferences;size=300x710")
	proc/loadsave(mob/user)
		var/dat = "<body>"
		dat += "<tt><center>"

		var/list/slots = savefile_getslots(user)
		for(var/slot=1, slot<=slots.len, slot++)
			dat += "<a href='byond://?src=\ref[user];preferences=1;loadslot=[slot]'>Load Slot [slot] ([slots[slot]]) </a><a href='byond://?src=\ref[user];preferences=1;removeslot=[slot]'>(R)</a><br><br>"

		dat += "<a href='byond://?src=\ref[user];preferences=1;loadslot=CLOSE'>Close</a><br>"
		dat += "</center></tt>"
		user << browse(dat, "window=saves;size=300x640")
	proc/closesave(mob/user)
		user << browse(null, "window=saves;size=300x640")

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

	proc/SetChoices(mob/user, limit = 17, list/splitJobs, width = 550, height = 500)
		 //limit 	 - The amount of jobs allowed per column. Defaults to 17 to make it look nice.
		 //splitJobs - Allows you split the table by job. You can make different tables for each department by including their heads. Defaults to CE to make it look nice.
		 //width	 - Screen' width. Defaults to 550 to make it look nice.
		 //height 	 - Screen's height. Defaults to 500 to make it look nice.

		 // Modify this if you added more jobs and it looks like a mess. Add the jobs in the splitJobs that you want to trigger and intitate a new table.

		if(splitJobs == null)
			if (ticker && ticker.current_state >= GAME_STATE_PLAYING)
				splitJobs = list()
			else
				splitJobs = list("Chief Engineer")


		var/HTML = "<body>"
		HTML += "<tt><center>"
		HTML += "<b>Choose occupation chances</b><br>Unavailable occupations are in red.<br><br>"
		HTML += "<a align='center' href=\"byond://?src=\ref[user];preferences=1;occ=0;job=cancel\">\[Done\]</a><br><br>" // Easier to press up here.
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

			HTML += "<a href=\"byond://?src=\ref[user];preferences=1;occ=1;job=[rank]\">"

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
			if(job.alt_titles)
				HTML += "</a> <a href=\"byond://?src=\ref[user];preferences=1;alt_title=1;job=\ref[job]\">\[[GetAltTitle(job)]\]</a></td></tr>"
			else
				HTML += "</a></td></tr>"

		HTML += "</center></tt>"

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


	proc/process_link(mob/user, list/link_tags)
		if(!usr)
			return
		if(link_tags["occ"])
			if(link_tags["cancel"])
				user << browse(null, "window=\ref[user]occupation")
				return
			else if(link_tags["job"])
				SetJob(user, link_tags["job"])
			else
				if(job_master)
					SetChoices(user)

			return 1

		if(link_tags["preview_dir"])
			preview_dir = text2num(link_tags["preview_dir"])

		if(link_tags["skills"])
			if(link_tags["cancel"])
				user << browse(null, "window=show_skills")
				ShowChoices(user)
				return
			else if(link_tags["skillinfo"])
				var/datum/skill/S = locate(link_tags["skillinfo"])
				var/HTML = "<b>[S.name]</b><br>[S.desc]"
				user << browse(HTML, "window=\ref[user]skillinfo")
			else if(link_tags["setskill"])
				var/datum/skill/S = locate(link_tags["setskill"])
				var/value = text2num(link_tags["newvalue"])
				skills[S.ID] = value
				CalculateSkillPoints()
				SetSkills(user)
			else if(link_tags["preconfigured"])
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
			else if(link_tags["setspecialization"])
				skill_specialization = link_tags["setspecialization"]
				CalculateSkillPoints()
				SetSkills(user)
			else
				SetSkills(user)

			return 1

		if(link_tags["alt_title"] && link_tags["job"])
			var/datum/job/job = locate(link_tags["job"])
			var/choices = list(job.title) + job.alt_titles
			var/choice = input("Pick a title for [job.title].", "Character Generation", GetAltTitle(job)) as anything in choices | null
			if(choice)
				SetAltTitle(job, choice)
				SetChoices(user)

		if(link_tags["real_name"])
			var/new_name

			switch(link_tags["real_name"])
				if("input")
					new_name = copytext( (input(user, "Please select a name:", "Character Generation")  as text) ,1,MAX_NAME_LEN)
					var/list/bad_characters = list("_", "'", "\"", "<", ">", ";", "\[", "\]", "{", "}", "|", "\\","0","1","2","3","4","5","6","7","8","9")
					for(var/c in bad_characters)
						new_name = dd_replacetext(new_name, c, "")

					if(!new_name || (new_name == "Unknown") || (new_name == "floor") || (new_name == "wall") || (new_name == "r-wall"))
						alert("Invalid name. Don't do that!")
						return

					//Make it so number one. (means you can have names like McMillian). Credit to: Jtgibson
					new_name = simple_titlecase(new_name)
/*
					//Carn: To fix BYOND text-parsing errors caused by people using dumb capitalisation in their names.
					var/tempname
					for(var/N in dd_text2list(new_name, " "))
						if(N && tempname) //if both aren't null strings
							tempname += " "
						tempname += capitalize(lowertext(N))
					new_name = tempname
*/


				if("random")
					randomize_name()

			if(new_name)
				real_name = new_name

		if(link_tags["age"])
			switch(link_tags["age"])
				if("input")
					var/new_age = input(user, "Please enter an age ([minimum_age]-[maximum_age])", "Character Generation")  as num
					if(new_age)
						age = max(min(round(text2num(new_age)), maximum_age), minimum_age)
				if("random")
					age = rand (minimum_age, maximum_age)

		if(link_tags["OOC"])
			var/tempnote = ""
			tempnote = copytext(sanitize(input(user, "Please enter your OOC Notes!:", "OOC notes" , metadata)  as text),1,MAX_MESSAGE_LEN)
			if(tempnote)
				metadata = tempnote
			return




		if(link_tags["b_type"])
			switch(link_tags["b_type"])
				if("input")
					var/new_b_type = input(user, "Please select a blood type:", "Character Generation")  as null|anything in list( "A+", "A-", "B+", "B-", "AB+", "AB-", "O+", "O-" )
					if(new_b_type)
						b_type = new_b_type
				if("random")
					b_type = pickweight ( list ("A+" = 31, "A-" = 7, "B+" = 8, "B-" = 2, "AB+" = 2, "AB-" = 1, "O+" = 40, "O-" = 9))

		if(link_tags["species"])
			switch(link_tags["species"])
				if("input")
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
					if(!whitelisted)
						alert(user, "You cannot change your species as you need to be whitelisted. If you wish to be whitelisted contact an admin in-game, on the forums, or on IRC.")
					species = input("Please select a species", "Character Generation", null) in new_species
					if(prev_species != species)
						h_style = "Bald" //Try not to carry face/head hair over.
						f_style = "Shaved"
						s_tone = 0 //Don't carry over skintone either.
						hair_style = new/datum/sprite_accessory/hair/bald
						facial_hair_style = new/datum/sprite_accessory/facial_hair/shaved
						if(species == "Skrell")
							if(gender == FEMALE)
								hair_style = new/datum/sprite_accessory/hair/alien/skrell/female/tentacle
							else
								hair_style = new/datum/sprite_accessory/hair/alien/skrell/male/tentacle

		if(link_tags["hair"])
			switch(link_tags["hair"])
				if("input")
					var/new_hair = input(user, "Please select hair color.", "Character Generation") as color
					if(new_hair)
						r_hair = hex2num(copytext(new_hair, 2, 4))
						g_hair = hex2num(copytext(new_hair, 4, 6))
						b_hair = hex2num(copytext(new_hair, 6, 8))
				if("random")
					randomize_hair_color("hair")

		if(link_tags["facial"])
			switch(link_tags["facial"])
				if("input")
					var/new_facial = input(user, "Please select facial hair color.", "Character Generation") as color
					if(new_facial)
						r_facial = hex2num(copytext(new_facial, 2, 4))
						g_facial = hex2num(copytext(new_facial, 4, 6))
						b_facial = hex2num(copytext(new_facial, 6, 8))
				if("random")
					randomize_hair_color("facial")

		if(link_tags["eyes"])
			switch(link_tags["eyes"])
				if("input")
					var/new_eyes = input(user, "Please select eye color.", "Character Generation") as color
					if(new_eyes)
						r_eyes = hex2num(copytext(new_eyes, 2, 4))
						g_eyes = hex2num(copytext(new_eyes, 4, 6))
						b_eyes = hex2num(copytext(new_eyes, 6, 8))
				if("random")
					randomize_eyes_color()

		if(link_tags["s_tone"])
			switch(link_tags["s_tone"])
				if("random")
					randomize_skin_tone()
				if("input")
					var/new_tone = input(user, "Please select skin tone level: 1-220 (1=albino, 35=caucasian, 150=black, 220='very' black) or 20-70 for other species.", "Character Generation")  as num
					if(new_tone)
						if(species != "Human")
							s_tone = max(min(round(text2num(new_tone)), 70), 20)
						else
							s_tone = max(min(round(text2num(new_tone)), 220), 1)
						s_tone = -s_tone + 35

		if(link_tags["h_style"])
			if(species == "Tajaran" || species == "Soghun")
				return
			switch(link_tags["h_style"])

				// New and improved hair selection code, by Doohl
				if("random") // random hair selection

					randomize_hair(gender) // call randomize_hair() proc with var/gender parameter
					// see preferences_setup.dm for proc

				if("input") // input hair selection

					// Generate list of hairs via typesof()
					var/list/all_hairs = typesof(/datum/sprite_accessory/hair) - /datum/sprite_accessory/hair - typesof(/datum/sprite_accessory/hair/alien)

					if(species == "Skrell")
						if(gender == FEMALE)
							all_hairs = typesof(/datum/sprite_accessory/hair/alien/skrell/female) - /datum/sprite_accessory/hair/alien/skrell/female
						else
							all_hairs = typesof(/datum/sprite_accessory/hair/alien/skrell/male) - /datum/sprite_accessory/hair/alien/skrell/male

					// List of hair names
					var/list/hairs = list()

					// loop through potential hairs
					for(var/x in all_hairs)
						var/datum/sprite_accessory/hair/H = new x // create new hair datum based on type x
						hairs.Add(H.name) // add hair name to hairs
						del(H) // delete the hair after it's all done

					// prompt the user for a hair selection, the selection being anything in list hairs
					var/new_style = input(user, "Select a hair style", "Character Generation")  as null|anything in hairs

					// if new style selected (not cancel)
					if(new_style)
						h_style = new_style

						for(var/x in all_hairs) // loop through all_hairs again. Might be slightly CPU expensive, but not significantly.
							var/datum/sprite_accessory/hair/H = new x // create new hair datum
							if(H.name == new_style)
								hair_style = H // assign the hair_style variable a new hair datum
								break
							else
								del(H) // if hair H not used, delete. BYOND can garbage collect, but better safe than sorry

		if(link_tags["ooccolor"])
			var/ooccolor = input(user, "Please select OOC colour.", "OOC colour") as color

			if(ooccolor)
				src.ooccolor = ooccolor

		if(link_tags["f_style"])
			if(species != "Human") //Non-humans don't have hair stuff yet.
				return
			switch(link_tags["f_style"])

				// see above for commentation. This is just a slight modification of the hair code for facial hairs
				if("random")

					randomize_facial(gender)

				if("input")

					var/list/all_fhairs = typesof(/datum/sprite_accessory/facial_hair) - /datum/sprite_accessory/facial_hair
					var/list/fhairs = list()
					for(var/x in all_fhairs)
						var/datum/sprite_accessory/facial_hair/H = new x
						fhairs.Add(H.name)
						del(H)

					var/new_style = input(user, "Select a facial hair style", "Character Generation")  as null|anything in fhairs
					if(new_style)
						f_style = new_style
						for(var/x in all_fhairs)
							var/datum/sprite_accessory/facial_hair/H = new x
							if(H.name == new_style)
								facial_hair_style = H
								break
							else
								del(H)

		if(link_tags["gender"])
			if(gender == MALE)
				gender = FEMALE
				if(species == "Skrell")
					hair_style = new/datum/sprite_accessory/hair/alien/skrell/female/tentacle
			else
				gender = MALE
				if(species == "Skrell")
					hair_style = new/datum/sprite_accessory/hair/alien/skrell/male/tentacle

		if(link_tags["limbs"])
			var/limb_name = input(user, "Which limb do you want to change?") as null|anything in list("Left Leg","Right Leg","Left Arm","Right Arm","Left Foot","Right Foot","Left Hand","Right Hand")
			if(!limb_name) return

			var/limb = null
			switch(limb_name)
				if("Left Leg")
					limb = "l_leg"
				if("Right Leg")
					limb = "r_leg"
				if("Left Arm")
					limb = "l_arm"
				if("Right Arm")
					limb = "r_arm"
				if("Left Foot")
					limb = "l_foot"
				if("Right Foot")
					limb = "r_foot"
				if("Left Hand")
					limb = "l_hand"
				if("Right Hand")
					limb = "r_hand"

			var/new_state = input(user, "What state do you wish the limb to be in?") as null|anything in list("Normal","Amputated","Prothesis")
			if(!new_state) return

			switch(new_state)
				if("Normal")
					organ_data[limb] = null
				if("Amputated")
					organ_data[limb] = "amputated"
				if("Prothesis")
					organ_data[limb] = "cyborg"

		if(link_tags["UI"])
			switch(UI_style)
				if("Midnight")
					UI_style = "Orange"
				if("Orange")
					UI_style = "old"
				if("old")
					UI_style = "Midnight"
				else
					UI_style = "Midnight"

		if(link_tags["midis"])
			midis = !midis

		if(link_tags["ghost_ears"])
			ghost_ears = !ghost_ears

		if(link_tags["ghost_sight"])
			ghost_sight = !ghost_sight

		if(link_tags["underwear"])
			switch(link_tags["underwear"])
				if("inputmale")
					var/tempUnderwear = input(user, "Please select your underwear colour:", "Character Generation")  as null|anything in underwear_m
					if(tempUnderwear)
						underwear = underwear_m.Find(tempUnderwear)
				if("inputfemale")
					var/tempUnderwear = input(user, "Please select your underwear colour:", "Character Generation")  as null|anything in underwear_f
					if(tempUnderwear)
						underwear = underwear_f.Find(tempUnderwear)
				if("random")
					if(prob (75))
						underwear = pick(1,2,3,4,5)
					else
						underwear = 6

		if(link_tags["backbag_type"])
			switch(link_tags["backbag_type"])
				if("input")
					var/tempBag = input(user, "Please pick a backpack type:", "Character Generation")  as null|anything in backbaglist
					if(tempBag)
						backbag = backbaglist.Find(tempBag)
				if("random")
					backbag = pick(1,2,3)


		if(link_tags["be_special"])
			src.be_special^=(1<<text2num(link_tags["be_special"])) //bitwize magic, sorry for that. --rastaf0

		if(link_tags["b_random_name"])
			be_random_name = !be_random_name

		if(link_tags["flavor_text"])
			var/msg = input(usr,"Set the flavor text in your 'examine' verb. This can also be used for OOC notes and preferences!","Flavor Text",html_decode(flavor_text)) as message

			if(msg != null)
				msg = copytext(msg, 1, MAX_MESSAGE_LEN)
				msg = html_encode(msg)

				flavor_text = msg

		// slot links
		if(!IsGuestKey(user.key))
			if(link_tags["saveslot"])
				var/slot = text2num(link_tags["saveslot"])

				savefile_save(user, slot)

			else if(link_tags["loadslot"])
				var/slot = text2num(link_tags["loadslot"])
				if(link_tags["loadslot"] == "CLOSE")
					closesave(user)
					return
				if(!savefile_load(user, slot))
					alert(user, "You do not have a savefile.")
				else
					curslot = slot
					slotname = savefile_getslots(user)[curslot]
					loadsave(user)
		if(link_tags["removeslot"])
			if(alert("Are you sure you wish to delete this slot?",,"Yes","No")=="No")
				return
			var/slot = text2num(link_tags["removeslot"])
			if(!slot)
				return

			savefile_removeslot(user, slot)

			usr << "Slot [slot] Deleted."
			curslot = 1
			slotname = savefile_getslots(user)[curslot]
			loadsave(usr)
		if(link_tags["loadslot2"])
			loadsave(user)
		if(link_tags["createslot"])
			var/list/slots = savefile_getslots(user)
			var/count = slots.len
			count++
			if(count > 10)
				usr << "You have reached the character limit."
				return
			slotname = input(usr,"Choose a name for your slot","Name","Slot "+num2text(count))

			curslot = savefile_createslot(user, slotname)

			if(!savefile_load(user, count))
				alert(user, "You do not have a savefile.")
			else
				closesave(user)

		if(link_tags["reset_all"])
			gender = MALE
			randomize_name()

			age = 30
			job_civilian_high = 0
			job_civilian_med = 0
			job_civilian_low = 0
			job_medsci_high = 0
			job_medsci_med = 0
			job_medsci_low = 0
			job_engsec_high = 0
			job_engsec_med = 0
			job_engsec_low = 0
			job_alt_titles = new()
			underwear = 1
			backbag = 2
			be_special = 0
			be_random_name = 0
			r_hair = 0.0
			g_hair = 0.0
			b_hair = 0.0
			r_facial = 0.0
			g_facial = 0.0
			b_facial = 0.0
			h_style = "Short Hair"
			f_style = "Shaved"
			r_eyes = 0.0
			g_eyes = 0.0
			b_eyes = 0.0
			s_tone = 0.0
			b_type = "A+"
			//UI = UI_OLD
			UI_style = "Midnight"
			midis = 1
			ghost_ears = 1
			disabilities = 0

		if(link_tags["disabilities"])
			if(text2num(link_tags["disabilities"]) >= -1)
				if(text2num(link_tags["disabilities"]) >= 0)
					disabilities ^= (1<<text2num(link_tags["disabilities"])) //MAGIC
				SetDisabilities(user)
				return
			else
				user << browse(null, "window=disabil")

		if(link_tags["records"])
			if(text2num(link_tags["records"]) >= 1)
				SetRecords(user)
				return
			else
				user << browse(null, "window=records")

		if(link_tags["med_record"])
			var/medmsg = input(usr,"Set your medical notes here.","Medical Records",html_decode(med_record)) as message

			if(medmsg != null)
				medmsg = copytext(medmsg, 1, MAX_PAPER_MESSAGE_LEN)
				medmsg = html_encode(medmsg)

				med_record = medmsg
				SetRecords(user)

		if(link_tags["sec_record"])
			var/secmsg = input(usr,"Set your security notes here.","Security Records",html_decode(sec_record)) as message

			if(secmsg != null)
				secmsg = copytext(secmsg, 1, MAX_PAPER_MESSAGE_LEN)
				secmsg = html_encode(secmsg)

				sec_record = secmsg
				SetRecords(user)

		ShowChoices(user)

	proc/copy_to(mob/living/carbon/human/character, safety = 0)
		if(be_random_name)
			randomize_name()
		character.real_name = real_name
		character.original_name = real_name //Original name is only used in ghost chat! It is not to be edited by anything!

		character.species = species

		character.flavor_text = flavor_text
		character.med_record = med_record
		character.sec_record = sec_record

		character.gender = gender

		character.age = age
		character.dna.b_type = b_type

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

		// Destroy/cyborgize organs
		for(var/name in organ_data)
			var/datum/organ/external/O = character.organs[name]
			if(!O) continue

			var/status = organ_data[name]
			if(status == "amputated")
				del O
			else if(status == "cyborg")
				O.status |= ROBOT

		switch(UI_style)
			if("Midnight")
				character.UI = 'screen1_Midnight.dmi'
			if("Orange")
				character.UI = 'screen1_Orange.dmi'
			if("old")
				character.UI = 'screen1_old.dmi'
			else
				character.UI = 'screen1_Midnight.dmi'

		character.hair_style = hair_style
		character.facial_hair_style = facial_hair_style

		if(underwear > 6 || underwear < 1)
			underwear = 1 //I'm sure this is 100% unnecessary, but I'm paranoid... sue me.
		character.underwear = underwear

		if(backbag > 4 || backbag < 1)
			backbag = 1 //Same as above
		character.backbag = backbag

		character.used_skillpoints = used_skillpoints
		character.skill_specialization = skill_specialization
		character.skills = skills

		character.update_face()
		character.update_body()

		if(!safety)//To prevent run-time errors due to null datum when using randomize_appearance_for()
			spawn(10)
				if(character&&character.client)
					setup_client(character.client)

	proc/copy_to_observer(mob/dead/observer/character)
		spawn(10)
			if(character && character.client)
				setup_client(character.client)

	proc/setup_client(var/client/C)
		if(C)
			C.midis = src.midis
			C.ooccolor = src.ooccolor
			C.be_alien = be_special & BE_ALIEN
			C.be_pai = be_special & BE_PAI
			C.be_syndicate = be_special
			if(isnull(src.ghost_ears)) src.ghost_ears = 1 //There were problems where the default was null before someone saved their profile.
			C.ghost_ears = src.ghost_ears
			C.ghost_sight = src.ghost_sight

	proc/copydisabilities(mob/living/carbon/human/character)
		if(disabilities & 1)
			character.dna.struc_enzymes = setblock(character.dna.struc_enzymes,GLASSESBLOCK,toggledblock(getblock(character.dna.struc_enzymes,GLASSESBLOCK,3)),3)
		if(disabilities & 2)
			character.dna.struc_enzymes = setblock(character.dna.struc_enzymes,HEADACHEBLOCK,toggledblock(getblock(character.dna.struc_enzymes,HEADACHEBLOCK,3)),3)
		if(disabilities & 4)
			character.dna.struc_enzymes = setblock(character.dna.struc_enzymes,COUGHBLOCK,toggledblock(getblock(character.dna.struc_enzymes,COUGHBLOCK,3)),3)
		if(disabilities & 8)
			character.dna.struc_enzymes = setblock(character.dna.struc_enzymes,TWITCHBLOCK,toggledblock(getblock(character.dna.struc_enzymes,TWITCHBLOCK,3)),3)
		if(disabilities & 16)
			character.dna.struc_enzymes = setblock(character.dna.struc_enzymes,NERVOUSBLOCK,toggledblock(getblock(character.dna.struc_enzymes,NERVOUSBLOCK,3)),3)
		if(disabilities & 32)
			character.dna.struc_enzymes = setblock(character.dna.struc_enzymes,DEAFBLOCK,toggledblock(getblock(character.dna.struc_enzymes,DEAFBLOCK,3)),3)
		//if(disabilities & 64)
			//mute
		//if(disabilities & 128)
			//character.dna.struc_enzymes = setblock(character.dna.struc_enzymes,BLINDBLOCK,toggledblock(getblock(character.dna.struc_enzymes,BLINDBLOCK,3)),3)
		character.disabilities = disabilities

#undef UI_OLD
#undef UI_NEW
