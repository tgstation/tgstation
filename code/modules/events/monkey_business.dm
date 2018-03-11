/datum/round_event_control/monkeys
	name = "Monkey Business"
	typepath = /datum/round_event/ghost_role/monkeys
	weight = 15


/datum/round_event/ghost_role/monkeys
	minimum_required = 1
	role_name = "random monkey"
	fakeable = TRUE
	var/max_monkeys = 5

/datum/round_event/ghost_role/monkeys/announce(fake)
	if(fake || prob(45)) //55% chance of "oh god monkeys"
		var/data = pick("scans from our long-range sensors", "our sophisticated probabilistic models", "our omnipotence", "the communications traffic on your station", "energy emissions we detected", "\[REDACTED\]")
		priority_announce("Based on [data], we believe that some monkeys has developed spontaneous intelligence.","[command_name()] Medium-Priority Update")

/datum/round_event/ghost_role/monkeys/spawn_role()
	var/list/mob/dead/observer/candidates
	candidates = get_candidates(ROLE_ALIEN, null, ROLE_ALIEN)

	var/list/potential = list()
	for(var/mob/living/carbon/monkey/M in GLOB.alive_mob_list)
		var/turf/T = get_turf(M)
		if(!T || !is_station_level(M.z))
			continue
		if(!M.mind)
			potential += M

	if(!potential.len)
		return WAITING_FOR_SOMETHING
	if(!candidates.len)
		return NOT_ENOUGH_PLAYERS

	var/spawned_monkeys = 0
	while(spawned_monkeys < max_monkeys && candidates.len && potential.len)
		var/mob/living/carbon/monkey/MN  = pick_n_take(potential)
		var/mob/dead/observer/SG = pick_n_take(candidates)

		spawned_monkeys++
		spawned_mobs += MN

		MN.key = SG.key
		MN.grant_language(/datum/language/common)
		MN.fully_heal(TRUE) //just incase some assistant used this monkey as a punching bag
		MN.mind.assigned_role = "Sentient Monkey"
		MN.mind.special_role = "Sentient Monkey"

		to_chat(MN, "<span class='userdanger'>It's time for... monkey business!</span>")
		to_chat(MN, "<span class='warning'>Due to space anomalies, you are now fully sentient! Please note, <B>you are not an antag, and cannot harm or kill unless in self defense.</B></span>")

	return SUCCESSFUL_SPAWN