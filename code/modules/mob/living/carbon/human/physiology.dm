//Stores several modifiers in a way that isn't cleared by changing species

/datum/physiology
	var/brute_mod = 1   	// % of brute damage taken from all sources
	var/burn_mod = 1    	// % of burn damage taken from all sources
	var/tox_mod = 1     	// % of toxin damage taken from all sources
	var/oxy_mod = 1     	// % of oxygen damage taken from all sources
	var/clone_mod = 1   	// % of clone damage taken from all sources
	var/stamina_mod = 1 	// % of stamina damage taken from all sources
	var/brain_mod = 1   	// % of brain damage taken from all sources

	var/pressure_mod = 1	// % of brute damage taken from low or high pressure (stacks with brute_mod)
	var/heat_mod = 1    	// % of burn damage taken from heat (stacks with burn_mod)
	var/cold_mod = 1    	// % of burn damage taken from cold (stacks with burn_mod)

	var/damage_resistance = 0 // %damage reduction from all sources

	var/siemens_coeff = 1 	// resistance to shocks

	var/stun_mod = 1      	// % stun modifier
	var/bleed_mod = 1     	// % bleeding modifier
	var/datum/armor/armor 	// internal armor datum

	var/hunger_mod = 1		//% of hunger rate taken per tick.

	var/do_after_speed = 1 //Speed mod for do_after. Lower is better. If temporarily adjusting, please only modify using *= and /=, so you don't interrupt other calculations.

	///Static ssoc list of levels (ints) - strings
	var/list/static/level_names = list("Novice", "Apprentice", "Journeyman", "Expert", "Master", "Legendary")//This list is already in the right order, due to indexing
	///Assoc list of skills - level
	var/list/skills = list()
	///Assoc list of skills - exp
	var/list/skill_experience = list()

/datum/physiology/New()
	armor = new

///Adjust experience of a specific skill
/datum/physiology/proc/adjust_experience(skill, amt)
	skill_experience[skill] = max(0, skill_experience[skill] + amt) //Prevent going below 0
	switch(skill_experience[skill])
		if(SKILL_EXP_LEGENDARY to INFINITY)
			skills[skill] = SKILL_LEVEL_LEGENDARY
		if(SKILL_EXP_MASTER to SKILL_EXP_LEGENDARY)
			skills[skill] = SKILL_LEVEL_MASTER
		if(SKILL_EXP_EXPERT to SKILL_EXP_MASTER)
			skills[skill] = SKILL_LEVEL_EXPERT
		if(SKILL_EXP_JOURNEYMAN to SKILL_EXP_EXPERT)
			skills[skill] = SKILL_LEVEL_JOURNEYMAN
		if(SKILL_EXP_APPRENTICE to SKILL_EXP_JOURNEYMAN)
			skills[skill] = SKILL_LEVEL_APPRENTICE
		if(SKILL_EXP_NOVICE to SKILL_EXP_APPRENTICE)
			skills[skill] = SKILL_LEVEL_NOVICE
		if(0 to SKILL_EXP_NOVICE)
			skills[skill] = SKILL_LEVEL_NONE	

/datum/physiology/proc/get_skill_speed_modifier(skill)
	switch(skills[skill])
		if(SKILL_LEVEL_NONE)
			return 0.7
		if(SKILL_LEVEL_NOVICE)
			return 0.8
		if(SKILL_LEVEL_APPRENTICE)
			return 0.9
		if(SKILL_LEVEL_JOURNEYMAN)
			return 1
		if(SKILL_LEVEL_EXPERT)
			return 1.10
		if(SKILL_LEVEL_MASTER)
			return 1.25
		if(SKILL_LEVEL_LEGENDARY)
			return 1.5
			

/datum/physiology/proc/get_skill_level(skill)
	return skills[skill]

/datum/physiology/proc/print_levels(user)
	var/msg

	var/list/shown_skills = list()
	for(var/i in skills)
		if(skills[i])
			shown_skills += i
	if(!shown_skills.len)
		msg += "<span class='notice'>You don't seem to have any particularly outstanding skills.</span>"
		to_chat(user, msg)

	msg += "<span class='info'>*---------*\n<EM>Your skills</EM>\n"
	for(var/i in shown_skills)
		msg += "<span class='notice'>[i] - [level_names[skills[i]]]</span>"
