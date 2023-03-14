
//gives monsterhunters an icon in the antag selection panel
/datum/dynamic_ruleset/midround/monsterhunter
	name = "Monster Hunter"
	antag_datum = /datum/antagonist/monsterhunter
	midround_ruleset_style = MIDROUND_RULESET_STYLE_HEAVY
	antag_flag = ROLE_MONSTERHUNTER
	weight = 5
	cost = 15
	protected_roles = list(
		JOB_CAPTAIN,
		JOB_DETECTIVE,
		JOB_HEAD_OF_PERSONNEL,
		JOB_HEAD_OF_SECURITY,
		JOB_PRISONER,
		JOB_SECURITY_OFFICER,
		JOB_WARDEN,
		JOB_CHIEF_ENGINEER,
		JOB_CHIEF_MEDICAL_OFFICER,
		JOB_HEAD_OF_PERSONNEL,
		JOB_QUARTERMASTER,
		JOB_RESEARCH_DIRECTOR
	)
	restricted_roles = list(
		JOB_AI,
		JOB_CYBORG,
		ROLE_POSITRONIC_BRAIN,
	)
	required_candidates = 1
	requirements = list(10,10,10,10,10,10,10,10,10,10)
	var/minimum_monsters_required = 3


/datum/dynamic_ruleset/midround/monsterhunter/trim_candidates()
	..()
	for(var/mob/living/player in living_players)
		if(issilicon(player))
			living_players -= player
		if(is_centcom_level(player.z))
			living_players -= player
		if((player.mind?.special_role || player.mind?.antag_datums?.len))
			living_players -= player

/datum/dynamic_ruleset/midround/monsterhunter/proc/generate_monsters(amount)
	var/list/possible_monsters = list(/datum/antagonist/bloodsucker,
	/datum/antagonist/heretic,
	/datum/antagonist/changeling)
	for(var/i in 1 to amount)
		var/mob/living/monster = pick(living_players)
		assigned += monster
		living_players -= monster
		var/datum/antagonist/profession = pick(possible_monsters)
		monster.mind.add_antag_datum(profession)
		message_admins("[ADMIN_LOOKUPFLW(monster)] was selected by the [name] ruleset and has been made into a Monster.")
		log_game("DYNAMIC: [key_name(monster)] was selected by the [name] ruleset and has been made into a Monster.")

/datum/dynamic_ruleset/midround/monsterhunter/ready(forced = FALSE)
	var/count = 0
	for(var/datum/antagonist/monster in GLOB.antagonists)
		var/datum/mind/candidate = monster.owner
		if(!candidate)
			continue
		if(IS_BLOODSUCKER(candidate.current) || candidate.has_antag_datum(/datum/antagonist/changeling))
			count++
	if(count < minimum_monsters_required)
		var/needed_monsters = minimum_monsters_required - count
		generate_monsters(needed_monsters)
		message_admins("MONSTERHUNTER NOTICE: Monster Hunters did not find enough monsters, generating monsters...")
	if (required_candidates > living_players.len)
		return FALSE
	return ..()

/datum/dynamic_ruleset/midround/monsterhunter/execute()
	var/mob/player = pick(living_players)
	assigned += player
	living_players -= player
	player.mind.add_antag_datum(/datum/antagonist/monsterhunter)
	message_admins("[ADMIN_LOOKUPFLW(player)] was selected by the [name] ruleset and has been made into a Monsterhunter.")
	log_game("DYNAMIC: [key_name(player)] was selected by the [name] ruleset and has been made into a Monsterhunter.")
	return TRUE
