/datum/dynamic_ruleset/midround/from_living/opfor_candidate
	name = "OPFOR Candidate Reroll"
	midround_ruleset_style = MIDROUND_RULESET_STYLE_LIGHT
	antag_datum = /datum/antagonist/opfor_candidate
	antag_flag = ROLE_OPFOR_CANDIDATE
	antag_flag_override = BAN_OPFOR
	required_candidates = 1
	weight = 0
	cost = 5
	repeatable = TRUE


/datum/dynamic_ruleset/midround/from_living/opfor_candidate/trim_candidates()
	..()
	candidates = living_players
	for(var/mob/player as anything in candidates)
		if(player?.ckey in GLOB.opfor_passed_ckeys)
			candidates -= player


/datum/dynamic_ruleset/midround/from_living/opfor_candidate/execute()
	var/mob/picked = pick(candidates)
	assigned += picked
	candidates -= picked
	var/datum/antagonist/opfor_candidate/candidate = new
	picked.mind.add_antag_datum(candidate)
	message_admins("[ADMIN_LOOKUPFLW(picked)] had OPFOR candidacy passed onto them.")
	log_dynamic("[key_name(picked)] had OPFOR candidacy passed onto them.")
	return TRUE

/datum/dynamic_ruleset/midround/from_living/opfor_candidate/trim_list(list/list_to_trim = list())
	var/list/trimmed_list = list_to_trim.Copy()

	for(var/mob/mob_candidate in trimmed_list)
		if (!istype(mob_candidate, required_type))
			trimmed_list.Remove(mob_candidate)
			continue

		if (!mob_candidate.client) // Are they connected?
			trimmed_list.Remove(mob_candidate)
			continue

		if (mob_candidate.client.get_remaining_days(minimum_required_age) > 0)
			trimmed_list.Remove(mob_candidate)
			continue

		if (is_banned_from(mob_candidate.ckey, BAN_OPFOR))
			trimmed_list.Remove(mob_candidate)
			continue

		if (mob_candidate.mind)
			if (restrict_ghost_roles && (mob_candidate.mind.assigned_role.title in GLOB.exp_specialmap[EXP_TYPE_SPECIAL])) // Are they playing a ghost role?
				trimmed_list.Remove(mob_candidate)
				continue

	return trimmed_list
