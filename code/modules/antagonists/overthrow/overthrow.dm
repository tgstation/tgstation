/datum/antagonist/overthrow
	name = "Syndicate mutineer"
	roundend_category = "syndicate mutineers"
	antagpanel_category = "Syndicate Mutineers"
	job_rank = ROLE_TRAITOR
	var/datum/team/overthrow/team

/datum/antagonist/overthrow/on_gain()
	create_team()
	objectives += team.objectives
	owner.objectives += objectives
	equip_
	..()

/datum/antagonist/overthrow/create_team()
	if(!team)
		team = new()
		team.add_member(owner)
		team.create_objectives()
		var/team_name = stripped_input(owner, "Name your team:", "Team name", , MAX_NAME_LEN)
		if(!team_name)
			to_chat(owner, "<span class='danger'>You must give a name to your team!</span>")
			create_team()
			return
		team.name = team_name
	else
		team.add_member(owner)

/datum/antagonist/overthrow/apply_innate_effects()
	..()
	if(owner.assigned_role == "Clown")
		var/mob/living/carbon/human/traitor_mob = owner.current
		if(traitor_mob && istype(traitor_mob))
			if(!silent)
				to_chat(traitor_mob, "Your training has allowed you to overcome your clownish nature, allowing you to wield weapons without harming yourself.")
			traitor_mob.dna.remove_mutation(CLOWNMUT)
	update_overthrow_icons_added()

/datum/antagonist/overthrow/remove_innate_effects()
	update_overthrow_icons_removed()
	if(owner.assigned_role == "Clown")
		var/mob/living/carbon/human/traitor_mob = owner.current
		if(traitor_mob && istype(traitor_mob))
			traitor_mob.dna.add_mutation(CLOWNMUT)
	..()

/datum/antagonist/overthrow/proc/update_overthrow_icons_added(datum/mind/traitor_mind)
	var/datum/atom_hud/antag/overthrowhud = GLOB.huds[team.hud_entry_num]
	if(!overthrowhud)
		overthrowhud = new()
		team.hud_entry_num = GLOB.huds.len + 1 // the index of the hud inside huds list
		GLOB.huds += overthrowhud
	overthrowhud.join_hud(owner.current)
	set_antag_hud(owner.current, "traitor")

/datum/antagonist/overthrow/proc/update_overthrow_icons_removed(datum/mind/traitor_mind)
	var/datum/atom_hud/antag/overthrowhud = GLOB.huds[team.hud_entry_num]
	if(overthrowhud)
		overthrowhud.leave_hud(owner.current)
		set_antag_hud(owner.current, null)

/datum/antagonist/overthrow/get_team()
	return team

/datum/antagonist/overthrow/greet()
	to_chat(owner.current, "<B><font size=3 color=red>You are a syndicate sleeping agent. Your job is to stage a swift, fairly bloodless coup. </font></B>")
