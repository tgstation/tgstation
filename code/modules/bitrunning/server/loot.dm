#define GRADE_D "D"
#define GRADE_C "C"
#define GRADE_B "B"
#define GRADE_A "A"
#define GRADE_S "S"


/// Handles calculating rewards based on number of players, parts, threats, etc
/obj/machinery/quantum_server/proc/calculate_rewards()
	var/rewards_base = 0.8

	if(domain_randomized)
		rewards_base += 0.2

	rewards_base += servo_bonus

	rewards_base += (length(spawned_threat_refs) * 2)

	for(var/index in 2 to length(avatar_connection_refs))
		rewards_base += multiplayer_bonus

	return rewards_base


/// Handles spawning the (new) crate and deleting the former
/obj/machinery/quantum_server/proc/generate_loot(obj/cache, obj/machinery/byteforge/chosen_forge)
	SSblackbox.record_feedback("tally", "bitrunning_domain_primary_completed", 1, generated_domain.key)
	for(var/mob/person in cache.contents)
		SEND_SIGNAL(person, COMSIG_BITRUNNER_CACHE_SEVER)

	spark_at_location(cache) // abracadabra!
	qdel(cache) // and it's gone!
	SEND_SIGNAL(src, COMSIG_BITRUNNER_DOMAIN_COMPLETE, cache, generated_domain.reward_points)

	points += generated_domain.reward_points
	playsound(src, 'sound/machines/terminal/terminal_success.ogg', 30, vary = TRUE)

	var/bonus = calculate_rewards()

	var/time_difference = world.time - generated_domain.start_time
	var/grade = grade_completion(time_difference)

	var/obj/item/paper/certificate = new()
	certificate.add_raw_text(get_completion_certificate(time_difference, grade))
	certificate.name = "certificate of domain completion"
	certificate.update_appearance()

	var/obj/structure/closet/crate/secure/bitrunning/decrypted/reward_cache = new(src, generated_domain, bonus)
	reward_cache.manifest = certificate
	reward_cache.update_appearance()

	if(can_generate_tech_disk(grade))
		SSblackbox.record_feedback("tally", "bitrunning_bepis_rewarded", 1, generated_domain.key)
		new /obj/item/disk/design_disk/bepis/remove_tech(reward_cache)
		generated_domain.disk_reward_spawned = TRUE

	chosen_forge.start_to_spawn(reward_cache)
	return TRUE


/// Builds secondary loot if the achievements were met
/obj/machinery/quantum_server/proc/generate_secondary_loot(obj/curiosity, obj/machinery/byteforge/chosen_forge)
	SSblackbox.record_feedback("tally", "bitrunning_domain_secondary_completed", 1, generated_domain.key)
	spark_at_location(curiosity) // abracadabra!
	qdel(curiosity) // and it's gone!

	var/obj/item/storage/lockbox/bitrunning/decrypted/reward_curiosity = new(src, generated_domain)

	chosen_forge.start_to_spawn(reward_curiosity)
	return TRUE


/// Returns the markdown text containing domain completion information
/obj/machinery/quantum_server/proc/get_completion_certificate(time_difference, grade)
	var/base_points = generated_domain.reward_points
	if(domain_randomized)
		base_points -= 1

	var/bonuses = calculate_rewards()

	var/domain_threats = length(spawned_threat_refs)

	var/completion_time = "### Completion Time: [DisplayTimeText(time_difference)]\n"

	var/completion_grade = "\n---\n\n# Rating: [grade]"

	var/text = "# Certificate of Domain Completion\n\n---\n\n"

	text += "### [generated_domain.name][domain_randomized ? " (Randomized)" : ""]\n"
	text += "- **Difficulty:** [generated_domain.difficulty]\n"
	text += "- **Threats:** [domain_threats]\n"
	text += "- **Base Reward:** [base_points][domain_randomized ? " +1" : ""]\n\n"
	text += "- **Total Bonus:** [bonuses]x\n\n"

	if(bonuses <= 1)
		text += completion_time
		text += completion_grade
		return text

	text += "### Bonuses\n"
	if(domain_randomized)
		text += "- **Randomized:** + 0.2\n"

	if(length(avatar_connection_refs) > 1)
		text += "- **Multiplayer:** + [(length(avatar_connection_refs) - 1) * multiplayer_bonus]\n"

	if(domain_threats > 0)
		text += "- **Threats:** + [domain_threats * 2]\n"

	var/servo_rating = servo_bonus

	if(servo_rating > 0.2)
		text += "- **Components:** + [servo_rating]\n"

	text += completion_time
	text += completion_grade

	return text

/// Checks if the players should get a bepis reward
/obj/machinery/quantum_server/proc/can_generate_tech_disk(grade)
	if(generated_domain.disk_reward_spawned)
		return FALSE

	if(!LAZYLEN(SSresearch.techweb_nodes_experimental))
		return FALSE

	var/static/list/passing_grades = list()
	if(!passing_grades.len)
		passing_grades = list(GRADE_A,GRADE_S)

	return  generated_domain.difficulty >= BITRUNNER_DIFFICULTY_MEDIUM && (grade in passing_grades)


/// Grades the player's run based on several factors
/obj/machinery/quantum_server/proc/grade_completion(completion_time)
	var/score = length(spawned_threat_refs) * 5
	score += generated_domain.reward_points

	var/base = generated_domain.difficulty + 1
	var/time_score = 1

	if(completion_time <= 1 MINUTES)
		time_score = 10
	else if(completion_time <= 2 MINUTES)
		time_score = 5
	else if(completion_time <= 5 MINUTES)
		time_score = 3
	else if(completion_time <= 10 MINUTES)
		time_score = 2
	else
		time_score = 1

	score += time_score * base

	// Increases the chance for glitches to spawn based on how well they're doing
	threat += score

	switch(score)
		if(1 to 4)
			return GRADE_D
		if(5 to 7)
			return GRADE_C
		if(8 to 10)
			return GRADE_B
		if(11 to 13)
			return GRADE_A
		else
			return GRADE_S

#undef GRADE_D
#undef GRADE_C
#undef GRADE_B
#undef GRADE_A
#undef GRADE_S
