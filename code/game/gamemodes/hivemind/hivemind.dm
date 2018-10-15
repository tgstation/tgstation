/datum/game_mode/hivemind
	name = "Assimilation"
	config_tag = "hivemind"
	report_type = "hivemind"
	antag_flag = ROLE_HIVE
	false_report_weight = 5
	protected_jobs = list("Security Officer", "Warden", "Detective", "Head of Security", "Captain")
	restricted_jobs = list("Cyborg","AI")
	required_players = 25
	required_enemies = 2
	recommended_enemies = 3
	reroll_friendly = 1
	enemy_minimum_age = 0

	announce_span = "danger"
	announce_text = "The hosts of several psionic hiveminds have infiltrated the station and are looking to assimilate the crew!\n\
	<span class='danger'>Hosts</span>: Expand your hivemind and complete your objectives at all costs!\n\
	<span class='notice'>Crew</span>: Prevent the hosts from getting into your mind!"

	var/list/hosts = list()

/proc/is_hivehost(mob/living/M)
	return M && M.mind && M.mind.has_antag_datum(/datum/antagonist/hivemind)

/proc/is_hivemember(mob/living/M)
	if(!M)
		return FALSE
	for(var/datum/antagonist/hivemind/H in GLOB.antagonists)
		if(H.hivemembers.Find(M))
			return TRUE
	return FALSE

/proc/remove_hivemember(mob/living/M) //Removes somebody from all hives as opposed to the antag proc remove_from_hive()
	if(!M)
		return
	for(var/datum/antagonist/hivemind/H in GLOB.antagonists)
		if(H.hivemembers.Find(M))
			H.hivemembers -= M
			H.calc_size()

/datum/game_mode/hivemind/pre_setup()

	if(CONFIG_GET(flag/protect_roles_from_antagonist))
		restricted_jobs += protected_jobs

	if(CONFIG_GET(flag/protect_assistant_from_antagonist))
		restricted_jobs += "Assistant"

	var/num_hosts = max( 1 , rand(0,1) + min(5, round(num_players() / 15) ) ) //1 host for every 15 players up to 75, with a 50% chance of an extra

	for(var/j = 0, j < num_hosts, j++)
		if (!antag_candidates.len)
			break
		var/datum/mind/host = antag_pick(antag_candidates)
		hosts += host
		host.special_role = ROLE_HIVE
		host.restricted_roles = restricted_jobs
		log_game("[key_name(host)] has been selected as a hivemind host")
		antag_candidates.Remove(host)

	if(hosts.len < required_enemies)
		setup_error = "Not enough host candidates"
		return FALSE
	else
		return TRUE


/datum/game_mode/hivemind/post_setup()
	for(var/datum/mind/i in hosts)
		i.add_antag_datum(/datum/antagonist/hivemind)
	return ..()

/datum/game_mode/hivemind/generate_report()
	return "Reports of psychic activity have been showing up in this sector, and we believe this may have to do with a containment breach on \[REDACTED\] last month \
		when a sapient hive intelligence displaying paranormal powers escaped into the unknown. They present a very large risk as they can assimilate people into \
		the hivemind with ease, although they appear unable to affect mindshielded personnel."