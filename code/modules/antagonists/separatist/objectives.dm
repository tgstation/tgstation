/datum/objective/destroy_nation
	name = "nation destruction"
	explanation_text = "Make sure no member of the enemy nation escapes alive!"
	team_explanation_text = "Make sure no member of the enemy nation escapes alive!"
	var/datum/team/nation/target_team

/datum/objective/destroy_nation/New(text, target_department)
	. = ..()
	target_team = target_department
	update_explanation_text()

/datum/objective/destroy_nation/Destroy()
	target_team = null
	. = ..()


/datum/objective/destroy_nation/update_explanation_text()
	. = ..()
	if(target_team)
		explanation_text = "Make sure no member of [target_team] ([target_team.department.department_name]) nation escapes alive!"
	else
		explanation_text = "Free Objective"

/datum/objective/destroy_nation/check_completion()
	if(!target_team)
		return TRUE

	for(var/datum/antagonist/separatist/separatist_datum in GLOB.antagonists)
		if(separatist_datum.nation.department != target_team.department) //a separatist, but not one part of the department we need to destroy
			continue
		var/datum/mind/target = separatist_datum.owner
		if(target && considered_alive(target) && (target.current.onCentCom() || target.current.onSyndieBase()))
			return FALSE //at least one member got away
	return TRUE

/datum/objective/separatist_fluff

/datum/objective/separatist_fluff/New(text, nation_name)
	explanation_text = pick(list(
		"The rest of the station must be taxed for their use of [nation_name]'s services.",
		"Make statues everywhere of your glorious leader of [nation_name]. If you have nobody, crown one amongst yourselves!",
		"[nation_name] must be absolutely blinged out.",
		"Damage as much of the station as you can, keep it in disrepair. [nation_name] must be the untouched paragon!",
		"Heavily reinforce [nation_name] against the dangers of the outside world.",
		"Make sure [nation_name] is fully off the grid, not requiring power or any other services from other departments!",
		"Use a misaligned teleporter to make you and your fellow citizens of [nation_name] flypeople. Bring toxin medication!",
		"Save the station when it needs you most. [nation_name] will be remembered as the protectors.",
		"Arm up. The citizens of [nation_name] have a right to bear arms.",
	))
	..()

/datum/objective/separatist_fluff/check_completion()
	return TRUE
