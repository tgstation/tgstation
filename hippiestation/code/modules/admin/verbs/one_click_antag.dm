//Shadowling
/datum/admins/proc/makeShadowling()
	var/datum/game_mode/shadowling/temp = new
	if(CONFIG_GET(flag/protect_roles_from_antagonist))
		temp.restricted_jobs += temp.protected_jobs
	if(CONFIG_GET(flag/protect_assistant_from_antagonist))
		temp.restricted_jobs += "Assistant"
	var/list/mob/living/carbon/human/candidates = list()
	var/mob/living/carbon/human/H
	for(var/mob/living/carbon/human/applicant in GLOB.player_list)
		if(ROLE_SHADOWLING in applicant.client.prefs.be_special)
			if(!applicant.stat)
				if(applicant.mind)
					if(!applicant.mind.special_role)
						if(!jobban_isbanned(applicant, "shadowling") && !jobban_isbanned(applicant, "Syndicate") && !jobban_isbanned(applicant, CLUWNEBAN) && !jobban_isbanned(applicant, CATBAN))
							if(temp.age_check(applicant.client))
								if(!(applicant.job in temp.restricted_jobs))
									if(!(is_shadow_or_thrall(applicant)))
										candidates += applicant

	if(candidates.len)
		H = pick(candidates)
		SSticker.mode.shadows += H.mind
		H.mind.special_role = "shadowling"
		to_chat(H, "<span class='shadowling'><b><i>You are a shadowling!</b></i></span>")
		to_chat(H, "<span class='shadowling'><b><i>Something stirs in the space between worlds. A red light floods your mind, and suddenly you understand. Your human disguise has served you well, but it \
		is time you cast it away. You are a shadowling, and you are to ascend at all costs.</b></i></span>")
		to_chat(H, "<span class='shadowling'>Don't know how to play Shadowling? Read the wiki at https://wiki.hippiestation.com/index.php?title=Shadowling</span>")
		SSticker.mode.finalize_shadowling(H.mind)
		H.playsound_local(get_turf(H), 'hippiestation/sound/ambience/antag/sling.ogg', 100, FALSE, pressure_affected = FALSE)
		message_admins("[H] has been made into a shadowling.")
		candidates.Remove(H)
		return 1
	return 0

/datum/admins/proc/makeVampire()
	var/datum/game_mode/vampire/temp = new
	if(CONFIG_GET(flag/protect_roles_from_antagonist))
		temp.restricted_jobs += temp.protected_jobs
	if(CONFIG_GET(flag/protect_assistant_from_antagonist))
		temp.restricted_jobs += "Assistant"
	var/list/mob/living/carbon/human/candidates = list()
	var/mob/living/carbon/human/H
	for(var/mob/living/carbon/human/applicant in GLOB.player_list)
		if((ROLE_VAMPIRE in applicant.client.prefs.be_special) && !applicant.stat && applicant.mind && !applicant.mind.special_role)
			if(!jobban_isbanned(applicant, "vampire") && !jobban_isbanned(applicant, "Syndicate") && !jobban_isbanned(applicant, CLUWNEBAN) && !jobban_isbanned(applicant, CATBAN))
				if(temp.age_check(applicant.client) && !(applicant.job in temp.restricted_jobs) && !is_vampire(applicant))
					candidates += applicant

	if(LAZYLEN(candidates))
		H = pick(candidates)
		add_vampire(H)
		return TRUE
	return FALSE
