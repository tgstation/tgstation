/datum/round_event_control/sentience
	name = "Random Human-level Intelligence"
	typepath = /datum/round_event/ghost_role/sentience
	weight = 10

/datum/round_event/ghost_role/sentience
	minimum_required = 1
	role_name = "random animal"

/datum/round_event/ghost_role/sentience/start()
	var/sentience_report = "<font size=3><b>[command_name()] Medium-Priority Update</b></font>"

	var/data = pick("scans from our long-range sensors", "our sophisticated probabilistic models", "our omnipotence", "the communications traffic on your station", "energy emissions we detected", "\[REDACTED\]")
	var/pets = pick("animals/bots", "bots/animals", "pets", "simple animals", "lesser lifeforms", "\[REDACTED\]")
	var/strength = pick("human", "moderate", "lizard", "security", "command", "clown", "low", "very low", "\[REDACTED\]")

	sentience_report += "<br><br>Based on [data], we believe that one of the station's [pets] has developed [strength] level intelligence, and the ability to communicate."

	print_command_report(sentience_report, "Classified [command_name()] Update")
	priority_announce("A report has been downloaded and printed out at all communications consoles.", "Incoming Classified Message", 'sound/AI/commandreport.ogg')
	..()

/datum/round_event/ghost_role/sentience/spawn_role()
	var/list/mob/dead/observer/candidates
	candidates = get_candidates(ROLE_ALIEN, null, ROLE_ALIEN)

	// find our chosen mob to breathe life into
	// Mobs have to be simple animals, mindless and on station
	var/list/potential = list()
	for(var/mob/living/simple_animal/L in living_mob_list)
		var/turf/T = get_turf(L)
		if(T.z != ZLEVEL_STATION)
			continue
		if(!(L in player_list) && !L.mind)
			potential += L

	if(!potential.len)
		return WAITING_FOR_SOMETHING
	var/mob/living/simple_animal/SA = pick(potential)
	if(!candidates.len)
		return NOT_ENOUGH_PLAYERS
	var/mob/dead/observer/SG = pick(candidates)

	SA.key = SG.key
	SA.languages_spoken |= HUMAN
	SA.languages_understood |= HUMAN
	SA.sentience_act()

	SA.maxHealth = max(SA.maxHealth, 200)
	SA.health = SA.maxHealth
	SA.del_on_death = FALSE

	spawned_mobs += SA

	SA << "<span class='userdanger'>Hello world!</span>"
	SA << "<span class='warning'>Due to freak radiation and/or chemicals \
		and/or lucky chance, you have gained human level intelligence \
		and the ability to speak and understand human language!</span>"

	return SUCCESSFUL_SPAWN
