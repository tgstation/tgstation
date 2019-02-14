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
	var/track_bonus = 0 // Bonus time to your tracking abilities
	var/size_mod = 0 // Bonus size for using reclaim
	var/list/individual_track_bonus = list() // Bonus time to tracking individual targets
	var/unlocked_one_mind = FALSE
	var/datum/team/hivemind/active_one_mind
	var/mutable_appearance/glow

	var/list/upgrade_tiers = list(
		//Tier 1 - Roundstart powers
		/obj/effect/proc_holder/spell/target_hive/hive_add = 0,
		/obj/effect/proc_holder/spell/target_hive/hive_remove = 0,
		/obj/effect/proc_holder/spell/target_hive/hive_see = 0,
		/obj/effect/proc_holder/spell/target_hive/hive_shock = 0,
		/obj/effect/proc_holder/spell/target_hive/hive_warp = 0,
		//Tier 2 - Tracking related powers
		/obj/effect/proc_holder/spell/self/hive_scan = 5,
		/obj/effect/proc_holder/spell/targeted/hive_reclaim = 5,
		/obj/effect/proc_holder/spell/targeted/hive_hack = 5,
		//Tier 3 - Combat related powers
		/obj/effect/proc_holder/spell/self/hive_drain = 10,
		/obj/effect/proc_holder/spell/targeted/induce_panic = 10,
		/obj/effect/proc_holder/spell/targeted/forcewall/hive = 10,
		//Tier 4 - Chaos-spreading powers
		/obj/effect/proc_holder/spell/self/hive_wake = 15,
		/obj/effect/proc_holder/spell/self/hive_loyal = 15,
		/obj/effect/proc_holder/spell/target_hive/hive_control = 15,
		//Tier 5 - Deadly powers
		/obj/effect/proc_holder/spell/targeted/induce_sleep = 20,
		/obj/effect/proc_holder/spell/target_hive/hive_attack = 20
	)


/datum/antagonist/hivemind/proc/calc_size()
	listclearnulls(hivemembers)
	var/temp = 0
	for(var/datum/mind/M in hivemembers)
		if(M.current && M.current.stat != DEAD)
			temp++
	if(hive_size != temp)
		hive_size = temp
		check_powers()

/datum/antagonist/hivemind/proc/get_threat_multiplier()
	calc_size()
	return min((hive_size+size_mod*2)/50 + threat_level/20, 1)

/datum/antagonist/hivemind/proc/get_carbon_members()
	var/list/carbon_members = list()
	for(var/datum/mind/M in hivemembers)
		if(!M.current || !iscarbon(M.current))
			continue
		carbon_members += M.current
	return carbon_members

/datum/antagonist/hivemind/proc/check_powers()
	for(var/power in upgrade_tiers)
		var/level = upgrade_tiers[power]
		if(hive_size+size_mod >= level && !(locate(power) in owner.spell_list))
			var/obj/effect/proc_holder/spell/the_spell = new power(null)
			owner.AddSpell(the_spell)
			if(hive_size > 0)
				to_chat(owner, "<span class='assimilator'>We have unlocked [the_spell.name].</span><span class='bold'> [the_spell.desc]</span>")

	if(!unlocked_one_mind && hive_size >= 15)
		var/lead = TRUE
		for(var/datum/antagonist/hivemind/enemy in GLOB.antagonists)
			if(enemy == src)
				continue
			if(!enemy.active_one_mind && enemy.hive_size <= hive_size + size_mod - 20)
				continue
			lead = FALSE
			break
		if(lead)
			unlocked_one_mind = TRUE
			owner.AddSpell(new/obj/effect/proc_holder/spell/self/one_mind)
			to_chat(owner, "<big><span class='assimilator'>Our true power, the One Mind, is finally within reach.</span></big>")

/datum/antagonist/hivemind/proc/add_track_bonus(datum/antagonist/hivemind/enemy, bonus)
	if(individual_track_bonus[enemy])
		individual_track_bonus[enemy] = bonus
	else
		individual_track_bonus[enemy] += bonus

/datum/antagonist/hivemind/proc/get_track_bonus(datum/antagonist/hivemind/enemy)
	if(individual_track_bonus[enemy])
		. = 0
	else
		. = individual_track_bonus[enemy]
	. += (TRACKER_DEFAULT_TIME + track_bonus)

/datum/antagonist/hivemind/proc/add_to_hive(mob/living/carbon/C)
	if(!C)
		return
	var/datum/mind/M = C.mind
	if(M)
		hivemembers |= M
		calc_size()

	var/user_warning = "<span class='userdanger'>We have detected an enemy hivemind using our physical form as a vessel and have begun ejecting their mind! They will be alerted of our disappearance once we succeed!</span>"
	if(C.is_real_hivehost())
		var/eject_time = rand(1400,1600) //2.5 minutes +- 10 seconds
		addtimer(CALLBACK(GLOBAL_PROC, /proc/to_chat, C, user_warning), rand(500,1300)) // If the host has assimilated an enemy hive host, alert the enemy before booting them from the hive after a short while
		addtimer(CALLBACK(src, .proc/handle_ejection, C), eject_time)
	else if(active_one_mind)
		C.hive_awaken(final_form=active_one_mind)

/datum/antagonist/hivemind/proc/is_carbon_member(mob/living/carbon/C)
	if(!hivemembers || !C || !iscarbon(C))
		return FALSE
	var/datum/mind/M = C.mind
	if(!M || !hivemembers.Find(M))
		return FALSE
	return TRUE

/datum/antagonist/hivemind/proc/remove_from_hive(mob/living/carbon/C)
	var/datum/mind/M = C.mind
	if(M)
		hivemembers -= M
		calc_size()

/datum/antagonist/hivemind/proc/handle_ejection(mob/living/carbon/C)
	var/user_warning = "The enemy host has been ejected from our mind"
	if(!C || !owner)
		return
	var/mob/living/carbon/C2 = owner.current
	if(!C2)
		return

	var/mob/living/real_C = C.get_real_hivehost()
	var/mob/living/real_C2 = C2.get_real_hivehost()
	var/datum/antagonist/hivemind/hive_C
	var/datum/antagonist/hivemind/hive_C2
	if(real_C.mind)
		hive_C = real_C.mind.has_antag_datum(/datum/antagonist/hivemind)
	if(real_C2.mind)
		hive_C2 = real_C2.mind.has_antag_datum(/datum/antagonist/hivemind)
	if(!hive_C || !hive_C2)
		return
	if(C == real_C) //Mind control check
		real_C2.apply_status_effect(STATUS_EFFECT_HIVE_TRACKER, real_C, hive_C.get_track_bonus(hive_C2))
		real_C.apply_status_effect(STATUS_EFFECT_HIVE_RADAR)
		to_chat(real_C, "<span class='assimilator'>We detect a surge of psionic energy from a far away vessel before they disappear from the hive. Whatever happened, there's a good chance they're after us now.</span>")
	if(C2 == real_C2)
		real_C.apply_status_effect(STATUS_EFFECT_HIVE_TRACKER, real_C2, hive_C2.get_track_bonus(hive_C))
		real_C2.apply_status_effect(STATUS_EFFECT_HIVE_RADAR)
		user_warning += " and we've managed to pinpoint their location"
	to_chat(C2, "<span class='userdanger'>[user_warning]!</span>")

/datum/antagonist/hivemind/proc/destroy_hive()
	hivemembers = list()
	calc_size()

/datum/antagonist/hivemind/antag_panel_data()
	return "Vessels Assimilated: [hive_size]"

/datum/antagonist/hivemind/proc/awaken()
	if(!owner?.current)
		return
	var/mob/living/carbon/C = owner.current.get_real_hivehost()
	if(!C)
		return
	owner.AddSpell(new/obj/effect/proc_holder/spell/self/hive_comms)
	C.add_trait(TRAIT_STUNIMMUNE, HIVEMIND_ONE_MIND_TRAIT)
	C.add_trait(TRAIT_SLEEPIMMUNE, HIVEMIND_ONE_MIND_TRAIT)
	C.add_trait(TRAIT_VIRUSIMMUNE, HIVEMIND_ONE_MIND_TRAIT)
	C.add_trait(TRAIT_NOLIMBDISABLE, HIVEMIND_ONE_MIND_TRAIT)
	C.add_trait(TRAIT_NOHUNGER, HIVEMIND_ONE_MIND_TRAIT)
	C.add_trait(TRAIT_NODISMEMBER, HIVEMIND_ONE_MIND_TRAIT)

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
	if(prob(50))
		var/datum/objective/hivemind/hivesize/size_objective = new
		size_objective.owner = owner
		objectives += size_objective
	else if(prob(70))
		var/datum/objective/hivemind/hiveescape/hive_escape_objective = new
		hive_escape_objective.owner = owner
		objectives += hive_escape_objective
	else
		var/datum/objective/hivemind/biggest/biggest_objective = new
		biggest_objective.owner = owner
		objectives += biggest_objective

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
