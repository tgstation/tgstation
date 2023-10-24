/datum/lazy_template/virtual_domain/starfront_saloon
	name = "Starfront Saloon"
	cost = BITRUNNER_COST_MEDIUM
	desc = "Looks like you stepped onto the wrong street, partner. Hope you brought your gunslinging skills."
	difficulty = BITRUNNER_DIFFICULTY_HIGH
	help_text = "One of these rooms has the cache we're looking for. Find it and get out."
	is_modular = TRUE
	key = "starfront_saloon"
	map_name = "starfront_saloon"
	mob_modules = list(
		/datum/modular_mob_segment/syndicate_team,
		/datum/modular_mob_segment/syndicate_elite,
	)
	reward_points = BITRUNNER_REWARD_HIGH
