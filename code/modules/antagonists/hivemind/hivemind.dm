/datum/antagonist/hivemind
	name = "Hivemind Host"
	roundend_category = "hiveminds"
	antagpanel_category = "Hivemind Host"
	job_rank = ROLE_HIVE
	antag_moodlet = /datum/mood_event/focused
	var/special_role = ROLE_HIVE
	var/list/hivemembers = list()
	var/hive_size = 0
	var/threat_level = 0 // Part of what determines how strong the radar is, on a scale of 0 to 10
	var/static/datum/objective/hivemind/assimilate_common/common_assimilation_obj //Make it static since we want a common target for all the antags

	var/list/upgrade_tiers = list(
		//Tier 1
		/obj/effect/proc_holder/spell/target_hive/hive_add = 0,
		/obj/effect/proc_holder/spell/target_hive/hive_remove = 0,
		/obj/effect/proc_holder/spell/target_hive/hive_see = 0,
		/obj/effect/proc_holder/spell/target_hive/hive_shock = 2,
		/obj/effect/proc_holder/spell/self/hive_drain = 4,
		//Tier 2
		/obj/effect/proc_holder/spell/target_hive/hive_warp = 6,
		/obj/effect/proc_holder/spell/targeted/hive_hack = 8,
		/obj/effect/proc_holder/spell/target_hive/hive_control = 10,
		/obj/effect/proc_holder/spell/targeted/induce_panic = 12,
		//Tier 3
		/obj/effect/proc_holder/spell/self/hive_loyal = 15,
		/obj/effect/proc_holder/spell/targeted/hive_assim = 18,
		/obj/effect/proc_holder/spell/targeted/forcewall/hive = 20,
		/obj/effect/proc_holder/spell/target_hive/hive_attack = 25)

/datum/antagonist/hivemind/proc/calc_size()
	listclearnulls(hivemembers)
	var/old_size = hive_size
	hive_size = hivemembers.len
	if(hive_size != old_size)
		check_powers()

/datum/antagonist/hivemind/proc/get_threat_multiplier()
	calc_size()
	return min(hive_size/50 + threat_level/20, 1)

/datum/antagonist/hivemind/proc/check_powers()
	for(var/power in upgrade_tiers)
		var/level = upgrade_tiers[power]
		if(hive_size >= level && !(locate(power) in owner.spell_list))
			var/obj/effect/proc_holder/spell/the_spell = new power(null)
			owner.AddSpell(the_spell)
			if(hive_size > 0)
				to_chat(owner, "<span class='assimilator'>We have unlocked [the_spell.name].</span><span class='bold'> [the_spell.desc]</span>")

/datum/antagonist/hivemind/proc/add_to_hive(var/mob/living/carbon/human/H)
	var/user_warning = "<span class='userdanger'>We have detected an enemy hivemind using our physical form as a vessel and have begun ejecting their mind! They will be alerted of our disappearance once we succeed!</span>"
	for(var/datum/antagonist/hivemind/enemy_hive in GLOB.antagonists)
		if(is_real_hivehost(H))
			var/eject_time = rand(1400,1600) //2.5 minutes +- 10 seconds
			addtimer(CALLBACK(GLOBAL_PROC, /proc/to_chat, H, user_warning), rand(500,1300)) // If the host has assimilated an enemy hive host, alert the enemy before booting them from the hive after a short while
			addtimer(CALLBACK(src, .proc/handle_ejection, H), eject_time)
	hivemembers |= H
	calc_size()

/datum/antagonist/hivemind/proc/remove_from_hive(var/mob/living/carbon/human/H)
	hivemembers -= H
	calc_size()

/datum/antagonist/hivemind/proc/handle_ejection(mob/living/carbon/human/H)
	var/user_warning = "The enemy host has been ejected from our mind"

	if(!H || !owner)
		return

	var/mob/living/carbon/human/H2 = owner.current
	if(!H2)
		return

	var/mob/living/real_H = H.get_real_hivehost()
	var/mob/living/real_H2 = H2.get_real_hivehost()

	if(is_real_hivehost(H))
		real_H2.apply_status_effect(STATUS_EFFECT_HIVE_TRACKER, real_H)
		real_H.apply_status_effect(STATUS_EFFECT_HIVE_RADAR)
		to_chat(real_H, "<span class='userdanger'>We detect a surge of psionic energy from a far away vessel before they disappear from the hive. Whatever happened, there's a good chance they're after us now.</span>")
	if(is_real_hivehost(H2))
		real_H.apply_status_effect(STATUS_EFFECT_HIVE_TRACKER, real_H2)
		real_H2.apply_status_effect(STATUS_EFFECT_HIVE_RADAR)
		user_warning = " and we've managed to pinpoint their location"

	to_chat(H2, "<span class='userdanger'>[user_warning]!</span>")

/datum/antagonist/hivemind/proc/destroy_hive()
	hivemembers = list()
	calc_size()

/datum/antagonist/hivemind/antag_panel_data()
	return "Vessels Assimilated: [hive_size]"

/datum/antagonist/hivemind/on_gain()

	owner.special_role = special_role
	check_powers()
	forge_objectives()
	..()

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
	for(var/power in upgrade_tiers)
		owner.RemoveSpell(power)

	if(!silent && owner.current)
		to_chat(owner.current,"<span class='userdanger'> Your psionic powers fade, you are no longer the hivemind's host! </span>")
	owner.special_role = null
	..()

/datum/antagonist/hivemind/proc/forge_objectives()
	if(prob(65))
		var/datum/objective/hivemind/hivesize/size_objective = new
		size_objective.owner = owner
		objectives += size_objective
	else
		var/datum/objective/hivemind/hiveescape/hive_escape_objective = new
		hive_escape_objective.owner = owner
		objectives += hive_escape_objective

	if(prob(85))
		var/datum/objective/hivemind/assimilate/assim_objective = new
		assim_objective.owner = owner
		if(prob(25)) //Decently high chance to have to assimilate an implanted crew member
			assim_objective.find_target_by_role(pick("Captain","Head of Security","Security Officer","Detective","Warden"))
		if(!assim_objective.target) //If the prob doesn't happen or there are no implanted crew, find any target that isn't a hivemmind host
			assim_objective.find_target_by_role(role = ROLE_HIVE, role_type = TRUE, invert = TRUE)
		assim_objective.update_explanation_text()
		objectives += assim_objective
	else
		var/datum/objective/hivemind/biggest/biggest_objective = new
		biggest_objective.owner = owner
		objectives += biggest_objective

	if(prob(85) && common_assimilation_obj) //If the mode rolled the versus objective IE common_assimilation_obj is not null, add a very high chance to get this
		var/datum/objective/hivemind/assimilate_common/versus_objective = new
		versus_objective.owner = owner
		versus_objective.target = common_assimilation_obj.target
		versus_objective.update_explanation_text()
		objectives += versus_objective
	else if(prob(70))
		var/giveit = TRUE
		var/datum/objective/assassinate/kill_objective = new
		kill_objective.owner = owner
		kill_objective.find_target()
		for(var/datum/objective/hivemind/assimilate/ass_obj in objectives)
			if(ass_obj.target == kill_objective.target)
				giveit = FALSE
				break
		if(giveit)
			objectives += kill_objective
	else
		var/datum/objective/maroon/maroon_objective = new
		maroon_objective.owner = owner
		maroon_objective.find_target()
		objectives += maroon_objective

	var/datum/objective/escape/escape_objective = new
	escape_objective.owner = owner
	objectives += escape_objective

	return

/datum/antagonist/hivemind/greet()
	to_chat(owner.current, "<B><font size=3 color=red>You are the host of a powerful Hivemind.</font></B>")
	to_chat(owner.current, "<b>Your psionic powers will grow by assimilating the crew into your hive. Use the Assimilate Vessel spell on a stationary \
		target, and after ten seconds he will be one of the hive. This is completely silent and safe to use, and failing will reset the cooldown. As \
		you assimilate the crew, you will gain more powers to use. Most are silent and won't help you in a fight, but grant you great power over your \
		vessels. Hover your mouse over a power's action icon for an extended description on what it does. There are other hiveminds onboard the station, \
		collaboration is possible, but a strong enough hivemind can reap many rewards from a well planned betrayal.</b>")
	owner.current.playsound_local(get_turf(owner.current), 'sound/ambience/antag/assimilation.ogg', 100, FALSE, pressure_affected = FALSE)

	owner.announce_objectives()

/datum/antagonist/hivemind/roundend_report()
	var/list/result = list()

	result += printplayer(owner)
	result += "<b>Hive Size:</b> [hive_size]"
	var/greentext = TRUE
	if(objectives)
		result += printobjectives(objectives)
		for(var/datum/objective/objective in objectives)
			if(!objective.check_completion())
				greentext = FALSE
				break

	if(objectives.len == 0 || greentext)
		result += "<span class='greentext big'>The [name] was successful!</span>"
	else
		result += "<span class='redtext big'>The [name] has failed!</span>"

	return result.Join("<br>")

/datum/antagonist/hivemind/is_gamemode_hero()
	return SSticker.mode.name == "Assimilation"
