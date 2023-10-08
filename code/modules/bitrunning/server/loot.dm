/// Handles calculating rewards based on number of players, parts, threats, etc
/obj/machinery/quantum_server/proc/calculate_rewards()
	var/rewards_base = 0.8

	if(domain_randomized)
		rewards_base += 0.2

	rewards_base += servo_bonus

	rewards_base += (domain_threats * 2)

	for(var/index in 2 to length(avatar_connection_refs))
		rewards_base += multiplayer_bonus

	return rewards_base

/// Generates a reward based on the given domain
/obj/machinery/quantum_server/proc/generate_loot()
	var/list/obj/machinery/byteforge/nearby_forges = get_nearby_forges()
	if(isnull(nearby_forges))
		say(src, "No nearby byteforges detected.")
		return FALSE

	points += generated_domain.reward_points
	playsound(src, 'sound/machines/terminal_success.ogg', 30, 2)

	var/obj/machinery/byteforge/chosen_forge = pick(nearby_forges)
	if(isnull(chosen_forge))
		stack_trace("Failed to find a turf to spawn loot crate on.")
		return FALSE

	var/bonus = calculate_rewards()

	var/obj/item/paper/certificate = new()
	certificate.add_raw_text(get_completion_certificate())
	certificate.name = "certificate of domain completion"
	certificate.update_appearance()

	var/obj/structure/closet/crate/secure/bitrunning/decrypted/reward_crate = new(src, generated_domain, bonus)
	reward_crate.manifest = certificate
	reward_crate.update_appearance()

	chosen_forge.start_to_spawn(reward_crate)
	return TRUE

/// Returns the markdown text containing domain completion information
/obj/machinery/quantum_server/proc/get_completion_certificate()
	var/base_points = generated_domain.reward_points
	if(domain_randomized)
		base_points -= 1

	var/bonuses = calculate_rewards()

	var/time_difference = world.time - generated_domain.start_time

	var/completion_time = "### Completion Time: [DisplayTimeText(time_difference)]\n"

	var/grade = "\n---\n\n# Rating: [grade_completion(generated_domain.difficulty, domain_threats, base_points, domain_randomized, time_difference)]"

	var/text = "# Certificate of Domain Completion\n\n---\n\n"

	text += "### [generated_domain.name][domain_randomized ? " (Randomized)" : ""]\n"
	text += "- **Difficulty:** [generated_domain.difficulty]\n"
	text += "- **Threats:** [domain_threats]\n"
	text += "- **Base Points:** [base_points][domain_randomized ? " +1" : ""]\n\n"
	text += "- **Total Bonus:** [bonuses]x\n\n"

	if(bonuses <= 1)
		text += completion_time
		text += grade
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
	text += grade

	return text

/// Grades the player's run based on several factors
/obj/machinery/quantum_server/proc/grade_completion(difficulty, threats, points, randomized, completion_time)
	var/score = threats * 5
	score += points
	score += randomized ? 1 : 0

	var/base = difficulty + 1
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

	switch(score)
		if(1 to 4)
			return "D"
		if(5 to 7)
			return "C"
		if(8 to 10)
			return "B"
		if(11 to 13)
			return "A"
		else
			return "S"
