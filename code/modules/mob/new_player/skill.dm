var/global/const
	SKILL_NONE = 0
	SKILL_BASIC = 1
	SKILL_ADEPT = 2
	SKILL_EXPERT = 3

datum/skill/var
    ID = "none" // ID of the skill, used in code
    name = "None" // name of the skill
    desc = "Placeholder skill" // detailed description of the skill
    field = "Misc" // the field under which the skill will be listed
    secondary = 0 // secondary skills only have two levels and cost significantly less

var/global/list/SKILLS = null
var/list/SKILL_ENGINEER = list("field" = "Engineering", "EVA" = SKILL_BASIC, "construction" = SKILL_ADEPT, "electrical" = SKILL_BASIC, "engines" = SKILL_ADEPT)
var/list/SKILL_ORGAN_ROBOTICIST = list("field" = "Science", "devices" = SKILL_ADEPT, "electrical" = SKILL_BASIC, "computer" = SKILL_ADEPT, "anatomy" = SKILL_BASIC)
var/list/SKILL_SECURITY_OFFICER = list("field" = "Security", "combat" = SKILL_BASIC, "weapons" = SKILL_ADEPT, "law" = SKILL_ADEPT, "forensics" = SKILL_BASIC)
var/list/SKILL_CHEMIST = list("field" = "Science", "chemistry" = SKILL_ADEPT, "science" = SKILL_ADEPT, "medical" = SKILL_BASIC, "devices" = SKILL_BASIC)
var/global/list/SKILL_PRE = list("Engineer" = SKILL_ENGINEER, "Roboticist" = SKILL_ORGAN_ROBOTICIST, "Security Officer" = SKILL_SECURITY_OFFICER, "Chemist" = SKILL_CHEMIST)

datum/skill/management
    ID = "management"
    name = "Command"
    desc = "Your ability to manage and commandeer other crew members."

datum/skill/combat
	ID = "combat"
	name = "Close Combat"
	desc = "This skill describes your training in hand-to-hand combat or melee weapon usage. While expertise in this area is rare in the era of firearms, experts still exist among athletes."
	field = "Security"

datum/skill/weapons
	ID = "weapons"
	name = "Weapons Expertise"
	desc = "This skill describes your expertise with and knowledge of weapons. A low level in this skill implies knowledge of simple weapons, for example tazers and flashes. A high level in this skill implies knowledge of complex weapons, such as grenades, riot shields, pulse rifles or bombs. A low level in this skill is typical for security officers, a high level of this skill is typical for special agents and soldiers."
	field = "Security"

datum/skill/EVA
    ID = "EVA"
    name = "Extra-vehicular activity"
    desc = "This skill describes your skill and knowledge of space-suits and working in vacuum."
    field = "Engineering"
    secondary = 1

datum/skill/forensics
	ID = "forensics"
	name = "Forensics"
	desc = "Describes your skill at performing forensic examinations and identifying vital evidence. Does not cover analytical abilities, and as such isn't the only indicator for your investigation skill. Note that in order to perform autopsy, the surgery skill is also required."
	field = "Security"

datum/skill/construction
    ID = "construction"
    name = "Construction"
    desc = "Your ability to construct various buildings, such as walls, floors, tables and so on. Note that constructing devices such as APCs additionally requires the Electronics skill. A low level of this skill is typical for janitors, a high level of this skill is typical for engineers."
    field = "Engineering"

datum/skill/management
    ID = "management"
    name = "Command"
    desc = "Your ability to manage and commandeer other crew members."

datum/skill/knowledge/law
    ID = "law"
    name = "NanoTrasen Law"
    desc = "Your knowledge of NanoTrasen law and procedures. This includes space law, as well as general station rulings and procedures. A low level in this skill is typical for security officers, a high level in this skill is typical for captains."
    field = "Security"
    secondary = 1

datum/skill/devices
    ID = "devices"
    name = "Complex Devices"
    desc = "Describes the ability to assemble complex devices, such as computers, circuits, printers, robots or gas tank assemblies(bombs). Note that if a device requires electronics or programming, those skills are also required in addition to this skill."
    field = "Science"

datum/skill/electrical
    ID = "electrical"
    name = "Electrical Engineering"
    desc = "This skill describes your knowledge of electronics and the underlying physics. A low level of this skill implies you know how to lay out wiring and configure powernets, a high level of this skill is required for working complex electronic devices such as circuits or bots."
    field = "Engineering"

datum/skill/atmos
    ID = "atmos"
    name = "Atmospherics"
    desc = "Describes your knowledge of piping, air distribution and gas dynamics."
    field = "Engineering"

datum/skill/engines
	ID = "engines"
	name = "Engines"
	desc = "Describes your knowledge of the various engine types common on space stations, such as the singularity or anti-matter engine."
	field = "Engineering"
	secondary = 1

datum/skill/computer
    ID = "computer"
    name = "Information Technology"
    desc = "Describes your understanding of computers, software and communication. Not a requirement for using computers, but definitely helps. Used in telecommunications and programming of computers and AIs."
    field = "Science"

datum/skill/pilot
    ID = "pilot"
    name = "Heavy Machinery Operation"
    desc = "Describes your experience and understanding of operating heavy machinery, which includes mechs and other large exosuits. Used in piloting mechs."
    field = "Engineering"

datum/skill/medical
    ID = "medical"
    name = "Medicine"
    desc = "Covers an understanding of the human body and medicine. At a low level, this skill gives a basic understanding of applying common types of medicine, and a rough understanding of medical devices like the health analyzer. At a high level, this skill grants exact knowledge of all the medicine available on the station, as well as the ability to use complex medical devices like the body scanner or mass spectrometer."
    field = "Medical"

datum/skill/anatomy
    ID = "anatomy"
    name = "Anatomy"
    desc = "Gives you a detailed insight of the human body. A high skill in this is required to perform surgery.This skill may also help in examining alien biology."
    field = "Medical"

datum/skill/virology
    ID = "virology"
    name = "Virology"
    desc = "This skill implies an understanding of microorganisms and their effects on humans."
    field = "Medical"

datum/skill/genetics
    ID = "genetics"
    name = "Genetics"
    desc = "Implies an understanding of how DNA works and the structure of the human DNA."
    field = "Science"

datum/skill/chemistry
	ID = "chemistry"
	name = "Chemistry"
	desc = "Experience with mixing chemicals, and an understanding of what the effect will be. This doesn't cover an understanding of the effect of chemicals on the human body, as such the medical skill is also required for medical chemists."
	field = "Science"

datum/skill/botany
	ID = "botany"
	name = "Botany"
	desc = "Describes how good a character is at growing and maintaining plants."

datum/skill/cooking
	ID = "cooking"
	name = "Cooking"
	desc = "Describes a character's skill at preparing meals and other consumable goods. This includes mixing alcoholic beverages."

datum/skill/science
	ID = "science"
	name = "Science"
	desc = "Your experience and knowledge with scientific methods and processes."
	field = "Science"

datum/attribute/var
	ID = "none"
	name = "None"
	desc = "This is a placeholder"


proc/setup_skills()
	if(SKILLS == null)
		SKILLS = list()
		for(var/T in (typesof(/datum/skill)-/datum/skill))
			var/datum/skill/S = new T
			if(S.ID != "none")
				if(!SKILLS.Find(S.field))
					SKILLS[S.field] = list()
				var/list/L = SKILLS[S.field]
				L += S


mob/living/carbon/human/proc/GetSkillClass(points)
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


proc/show_skill_window(var/mob/user, var/mob/living/carbon/human/M)
	if(!istype(M)) return
	if(SKILLS == null)
		setup_skills()

	if(!M.skills || M.skills.len == 0)
		user << "There are no skills to display."
		return

	var/HTML = "<body>"
	HTML += "<b>Select your Skills</b><br>"
	HTML += "Current skill level: <b>[M.GetSkillClass(M.used_skillpoints)]</b> ([M.used_skillpoints])<br>"
	HTML += "<table>"
	for(var/V in SKILLS)
		HTML += "<tr><th colspan = 5><b>[V]</b>"
		HTML += "</th></tr>"
		for(var/datum/skill/S in SKILLS[V])
			var/level = M.skills[S.ID]
			HTML += "<tr style='text-align:left;'>"
			HTML += "<th>[S.name]</th>"
			HTML += "<th><font color=[(level == SKILL_NONE) ? "red" : "black"]>\[Untrained\]</font></th>"
			// secondary skills don't have an amateur level
			if(S.secondary)
				HTML += "<th></th>"
			else
				HTML += "<th><font color=[(level == SKILL_BASIC) ? "red" : "black"]>\[Amateur\]</font></th>"
			HTML += "<th><font color=[(level == SKILL_ADEPT) ? "red" : "black"]>\[Trained\]</font></th>"
			HTML += "<th><font color=[(level == SKILL_EXPERT) ? "red" : "black"]>\[Professional\]</font></th>"
			HTML += "</tr>"
	HTML += "</table>"

	user << browse(null, "window=preferences")
	user << browse(HTML, "window=show_skills;size=600x800")
	return

mob/living/carbon/human/verb/show_skills()
	set category = "IC"
	set name = "Show Own Skills"

	show_skill_window(src, src)