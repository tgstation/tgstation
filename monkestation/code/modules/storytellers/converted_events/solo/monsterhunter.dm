#define MINIMUM_MONSTERS_REQUIRED 2

/datum/round_event_control/antagonist/solo/monsterhunter
	name = "Monster Hunters"
	track = EVENT_TRACK_MAJOR
	antag_flag = ROLE_MONSTERHUNTER
	tags = list(TAG_MAGICAL, TAG_TARGETED, TAG_COMBAT, TAG_CREW_ANTAG, TAG_DESTRUCTIVE)
	antag_datum = /datum/antagonist/monsterhunter
	protected_roles = list(
		JOB_CAPTAIN,
		JOB_HEAD_OF_PERSONNEL,
		JOB_CHIEF_ENGINEER,
		JOB_CHIEF_MEDICAL_OFFICER,
		JOB_RESEARCH_DIRECTOR,
		JOB_DETECTIVE,
		JOB_HEAD_OF_SECURITY,
		JOB_SECURITY_ASSISTANT,
		JOB_PRISONER,
		JOB_SECURITY_OFFICER,
		JOB_WARDEN,
		JOB_BRIG_PHYSICIAN,
	)
	restricted_roles = list(
		JOB_AI,
		JOB_CYBORG,
	)
	min_players = 10 //no required enemies due to instead needing enemy antags
	weight = 25 // high weight as its a threat
	maximum_antags = 1
	prompted_picking = TRUE
	max_occurrences = 1

/datum/round_event_control/antagonist/solo/monsterhunter/can_spawn_event(players_amt, allow_magic = FALSE, fake_check = FALSE)
	. = ..()
	if(!.)
		return

	var/count = 0
	for(var/datum/antagonist/monster as anything in GLOB.antagonists)
		if(QDELETED(monster?.owner?.current) || monster.owner.current.stat == DEAD)
			continue

		if(is_type_in_typecache(monster, GLOB.monster_hunter_prey_antags))
			count++

	if(MINIMUM_MONSTERS_REQUIRED > count)
		return FALSE

	return ..()

#undef MINIMUM_MONSTERS_REQUIRED
