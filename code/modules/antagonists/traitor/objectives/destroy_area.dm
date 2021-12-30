/datum/traitor_objective_category/destroy_area
	name="Destroy Area"
	objectives = list(
		/datum/traitor_objective/destroy_area = 1,
	)

/datum/traitor_objective/destroy_area
	name = "Destroy the following things in %AREA% to show nanotrasen we mean business."
	description = "Your objective requires you to destroy the following things in %AREA%:"

	progression_minimum = 0 MINUTES
	progression_maximum = 0 MINUTES
	progression_reward = list(0 MINUTES, 0 MINUTES)
	telecrystal_reward = 0

	/// List of things that need destroying before this objective completes.
	var/list/things_to_destroy = list()
	/// The target area
	var/area/target_area
	/// The areas that can be chosen
	var/list/possible_area_targets = list(
		/area/service/cafeteria,
		/area/service/bar,
		/area/service/theater,
		/area/service/chapel,
	)

/datum/traitor_objective/destroy_area/generate_objective(datum/mind/generating_for, list/possible_duplicates)
