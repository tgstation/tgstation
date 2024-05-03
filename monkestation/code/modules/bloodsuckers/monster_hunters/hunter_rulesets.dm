///List of antagonists that are considered 'Monsters' and their chance of being selected.
GLOBAL_LIST_INIT(monster_antagonist_types, list(
	/datum/antagonist/bloodsucker,
	/datum/antagonist/heretic,
	/datum/antagonist/changeling,
))

#define MINIMUM_MONSTERS_REQUIRED 2

//gives monsterhunters an icon in the antag selection panel
/datum/dynamic_ruleset/midround/monsterhunter
	name = "Monster Hunter"
	antag_datum = /datum/antagonist/monsterhunter
	midround_ruleset_style = MIDROUND_RULESET_STYLE_LIGHT
	antag_flag = ROLE_MONSTERHUNTER
	weight = 8
	cost = 5
	protected_roles = list(
		JOB_CAPTAIN,
		JOB_DETECTIVE,
		JOB_HEAD_OF_PERSONNEL,
		JOB_HEAD_OF_SECURITY,
		JOB_PRISONER,
		JOB_SECURITY_OFFICER,
		JOB_SECURITY_ASSISTANT,
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


/datum/dynamic_ruleset/midround/monsterhunter/trim_candidates()
	..()
	for(var/mob/living/player in living_players)
		if(issilicon(player))
			living_players -= player
		if(is_centcom_level(player.z))
			living_players -= player
		if((player.mind?.special_role || player.mind?.antag_datums?.len))
			living_players -= player

/datum/dynamic_ruleset/midround/monsterhunter/ready(forced = FALSE)
	if(required_candidates > living_players.len)
		return FALSE
	var/count = 0
	for(var/datum/antagonist/monster as anything in GLOB.antagonists)
		if(!monster.owner)
			continue
		if(!monster.owner.current)
			continue
		if(monster.owner.current.stat == DEAD)
			continue
		if(GLOB.monster_antagonist_types.Find(monster.type))
			count++

	if(MINIMUM_MONSTERS_REQUIRED > count)
		message_admins("[name] ruleset has attempted to run, but there were not enough monsters!")
		log_game("DYNAMIC: [name] ruleset has attempted to run, but there were not enough monsters!")
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

#undef MINIMUM_MONSTERS_REQUIRED
