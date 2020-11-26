/*! 
This subsystem mostly exists to populate and manage the skill singletons.
*/

SUBSYSTEM_DEF(skills)
	name = "Skills"
	flags = SS_NO_FIRE
	init_order = INIT_ORDER_SKILLS
	///Dictionary of skill.type || skill ref
	var/list/all_skills = list() 
	///List of level names with index corresponding to skill level
	var/list/level_names = list("None", "Novice", "Apprentice", "Journeyman", "Expert", "Master", "Legendary") //List of skill level names. Note that indexes can be accessed like so: level_names[SKILL_LEVEL_NOVICE]

/datum/controller/subsystem/skills/Initialize(timeofday)
	InitializeSkills()
	return ..()

///Ran on initialize, populates the skills dictionary
/datum/controller/subsystem/skills/proc/InitializeSkills(timeofday)
	for(var/type in GLOB.skill_types)
		var/datum/skill/ref = new type
		all_skills[type] = ref
