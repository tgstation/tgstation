/datum/antagonist/hivemind
	name = "Hivemind Host"
	roundend_category = "hiveminds"
	antagpanel_category = "Hivemind Host"
	job_rank = ROLE_HIVE
	antag_moodlet = /datum/mood_event/focused
	var/special_role = ROLE_HIVE
	var/list/hivemembers = list()
	var/hive_size = 0

	var/list/upgrade_tiers = list(
		//Tier 1
		/obj/effect/proc_holder/spell/target_hive/hive_add = 0,
		/obj/effect/proc_holder/spell/target_hive/hive_remove = 0,
		/obj/effect/proc_holder/spell/target_hive/hive_see = 0,
		/obj/effect/proc_holder/spell/target_hive/hive_shock = 0,
		/obj/effect/proc_holder/spell/self/hive_drain = 4,
		//Tier 2
		/obj/effect/proc_holder/spell/targeted/induce_panic = 10,
		/obj/effect/proc_holder/spell/targeted/hive_hack = 12,
		/obj/effect/proc_holder/spell/target_hive/hive_control = 15,
		//Tier 3
		/obj/effect/proc_holder/spell/targeted/hive_loyal = 20,
		/obj/effect/proc_holder/spell/targeted/forcewall/hive = 20,
		/obj/effect/proc_holder/spell/targeted/hive_assim = 25,
		/obj/effect/proc_holder/spell/target_hive/hive_attack = 30)

/datum/antagonist/hivemind/proc/calc_size()
	listclearnulls(hivemembers)
	var/old_size = hive_size
	hive_size = hivemembers.len
	if(hive_size != old_size)
		check_powers()

/datum/antagonist/hivemind/proc/check_powers()
	for(var/power in upgrade_tiers)
		var/level = upgrade_tiers[power]
		if(hive_size >= level && !(locate(power) in owner.spell_list))
			owner.AddSpell(new power(null))
		else if(hive_size < level && (locate(power) in owner.spell_list))
			owner.RemoveSpell(power)


/datum/antagonist/hivemind/proc/add_to_hive(var/mob/living/carbon/human/H)
	var/warning = "<span class='userdanger'>We have detected an enemy hivemind via [H.real_name], we can remove them from the hive to protect our identity or probe them to discover those of our enemies!</span>"
	var/user_warning = "<span class='userdanger'>We have detected an enemy hivemind using our physical form as a vessel! We will eject them, but this may take some time!</span>"
	var/enemies = FALSE
	for(var/datum/antagonist/hivemind/enemy_hive in GLOB.antagonists)
		if(enemy_hive.owner == owner)
			continue
		if(enemy_hive.hivemembers.Find(H))
			addtimer(CALLBACK(GLOBAL_PROC, /proc/to_chat, enemy_hive.owner, warning), rand(500,700)) //Warn opposing hivehosts that a vessel has been assimilated
			enemies = TRUE
		if(H.mind == enemy_hive.owner)
			addtimer(CALLBACK(GLOBAL_PROC, /proc/to_chat, H, user_warning), rand(500,700)) // If the host has assimilated an enemy hive host, alert the enemy before booting them from the hive after a short while
			addtimer(CALLBACK(GLOBAL_PROC, /proc/remove_hivemember, H), rand(1000,1400))
	if(enemies)
		addtimer(CALLBACK(GLOBAL_PROC, /proc/to_chat, owner, warning), rand(500,700)) //As well as the host who just added them
	hivemembers |= H
	calc_size()

/datum/antagonist/hivemind/proc/remove_from_hive(var/mob/living/carbon/human/H)
	hivemembers -= H
	calc_size()

/datum/antagonist/hivemind/antag_panel_data()
	return "Vessels Assimilated: [hive_size]"

/datum/antagonist/hivemind/on_gain()

//	SSticker.mode.hivemind |= owner
	owner.special_role = special_role
	apply_innate_effects()
//	grant_powers()
	check_powers()
	forge_objectives()
	..()
/*
/datum/antagonist/hivemind/proc/grant_powers()
	owner.AddSpell(new /obj/effect/proc_holder/spell/target_hive/hive_add(null))
	owner.AddSpell(new /obj/effect/proc_holder/spell/target_hive/hive_remove(null))
	owner.AddSpell(new /obj/effect/proc_holder/spell/target_hive/hive_see(null))
	owner.AddSpell(new /obj/effect/proc_holder/spell/target_hive/hive_shock(null))
	owner.AddSpell(new /obj/effect/proc_holder/spell/self/hive_drain(null))
	//Tier 2
	owner.AddSpell(new /obj/effect/proc_holder/spell/target_hive/hive_force(null))
	owner.AddSpell(new /obj/effect/proc_holder/spell/targeted/induce_panic(null))
	//Tier 3
	owner.AddSpell(new /obj/effect/proc_holder/spell/targeted/hive_assim(null))
	owner.AddSpell(new /obj/effect/proc_holder/spell/targeted/hive_loyal(null))
	owner.AddSpell(new /obj/effect/proc_holder/spell/targeted/forcewall/hive(null))
	owner.AddSpell(new /obj/effect/proc_holder/spell/target_hive/hive_attack(null))
*/

/datum/antagonist/hivemind/apply_innate_effects()
	if(owner.assigned_role == "Clown")
		var/mob/living/carbon/human/traitor_mob = owner.current
		if(traitor_mob && istype(traitor_mob))
			if(!silent)
				to_chat(traitor_mob, "The great psionic powers of the Hive lets you overcome your clownish nature, allowing you to wield weapons with impunity.")
			traitor_mob.dna.remove_mutation(CLOWNMUT)
	var/datum/atom_hud/antag/hud = GLOB.huds[ANTAG_HUD_HIVE]
	hud.join_hud(owner.current)
	set_antag_hud(owner.current, "hivemind")

/datum/antagonist/hivemind/remove_innate_effects()
	if(owner.assigned_role == "Clown")
		var/mob/living/carbon/human/traitor_mob = owner.current
		if(traitor_mob && istype(traitor_mob))
			traitor_mob.dna.add_mutation(CLOWNMUT)
	var/datum/atom_hud/antag/hud = GLOB.huds[ANTAG_HUD_HIVE]
	hud.leave_hud(owner.current)
	set_antag_hud(owner.current, null)



/datum/antagonist/hivemind/on_removal()

	//Remove all hive powers here
	hive_size = -1
	check_powers()

//	SSticker.mode.hivemind -= owner
	remove_innate_effects()
	if(!silent && owner.current)
		to_chat(owner.current,"<span class='userdanger'> Your psionic powers fade, you are no longer the hivemind's host! </span>")
	owner.special_role = null
	..()

/datum/antagonist/hivemind/proc/add_objective(var/datum/objective/O)
	objectives += O

/datum/antagonist/hivemind/proc/remove_objective(var/datum/objective/O)
	objectives -= O

/datum/antagonist/hivemind/proc/forge_objectives()
	if(prob(65))
		var/datum/objective/hivemind/hivesize/size_objective = new
		size_objective.owner = owner
		add_objective(size_objective)
	else
		var/datum/objective/hivemind/hiveescape/hive_escape_objective = new
		hive_escape_objective.owner = owner
		add_objective(hive_escape_objective)
	if(prob(50))
		var/datum/objective/hivemind/assimilate/assim_objective = new
		assim_objective.owner = owner
		if(prob(25)) //Decently high chance to have to assimilate an implanted crew member
			assim_objective.find_target_by_role(pick("Captain","Head of Security","Security Officer","Detective","Warden"))
		if(!assim_objective.target) //If the prob doesn't happen or there are no implanted crew, find any target
			assim_objective.find_target()
		assim_objective.update_explanation_text()
		add_objective(assim_objective)
	else if(prob(70))
		var/datum/objective/assassinate/kill_objective = new
		kill_objective.owner = owner
		kill_objective.find_target()
		add_objective(kill_objective)
	else
		var/datum/objective/maroon/maroon_objective = new
		maroon_objective.owner = owner
		maroon_objective.find_target()
		add_objective(maroon_objective)

	var/datum/objective/escape/escape_objective = new
	escape_objective.owner = owner
	add_objective(escape_objective)

	return

/datum/antagonist/hivemind/greet()
	to_chat(owner.current, "<B><font size=3 color=red>You are the host of a powerful Hivemind.</font></B>")
	to_chat(owner.current, "<b>Your psionic powers will grow by assimilating the crew into your hive. Use the Assimilate Vessel spell on a stationary \
		target, and after ten seconds he will be one of the hive. This is completely silent and safe to use, and failing will reset the cooldown. As \
		you assimilate the crew, you will gain more powers to use. Most are silent and won't help you in a fight, but grant you great power over your \
		vessels. There are other hiveminds onboard the station, collaboration is possible, but a strong enough hivemind can reap many rewards from a \
		well planned betrayal.</b>")
	owner.current.playsound_local(get_turf(owner.current), 'sound/ambience/antag/tatoralert.ogg', 100, FALSE, pressure_affected = FALSE)

	owner.announce_objectives()

/datum/antagonist/hivemind/roundend_report()
	var/list/result = list()

	var/greentext = TRUE

	result += printplayer(owner)
	result += "<b>Hive Size:</b> [hive_size]"

	var/objectives_text = ""
	if(objectives.len)
		var/count = 1
		for(var/datum/objective/objective in objectives)
			if(objective.check_completion())
				objectives_text += "<br><B>Objective #[count]</B>: [objective.explanation_text] <span class='greentext'>Success!</span>"
			else
				objectives_text += "<br><B>Objective #[count]</B>: [objective.explanation_text] <span class='redtext'>Fail.</span>"
				greentext = FALSE
			count++

	result += objectives_text

	var/special_role_text = lowertext(name)

	if(greentext)
		result += "<span class='greentext'>The [special_role_text] was successful!</span>"
	else
		result += "<span class='redtext'>The [special_role_text] has failed!</span>"
		SEND_SOUND(owner.current, 'sound/ambience/ambifailure.ogg')

	return result.Join("<br>")

/datum/antagonist/hivemind/is_gamemode_hero()
	return SSticker.mode.name == "hivemind"
