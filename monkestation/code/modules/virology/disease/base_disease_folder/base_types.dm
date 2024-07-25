/datum/disease/advanced/virus
	form = "Virus"
	max_stages = 4
	infectionchance = 20
	infectionchance_base = 20
	stageprob = 10
	stage_variance = -1
	can_kill = list("Bacteria")
	disease_flags = parent_type::disease_flags | DISEASE_COPYSTAGE

/datum/disease/advanced/bacteria//faster spread_flags and progression, but only 3 stages max, and reset to stage 1 on every spread_flags
	form = "Bacteria"
	max_stages = 3
	infectionchance = 30
	infectionchance_base = 30
	stageprob = 30
	stage_variance = -4
	can_kill = list("Parasite")

/datum/disease/advanced/parasite//slower spread_flags. stage preserved on spread_flags
	form = "Parasite"
	infectionchance = 15
	infectionchance_base = 15
	stageprob = 10
	stage_variance = 0
	can_kill = list("Virus")
	disease_flags = parent_type::disease_flags | DISEASE_COPYSTAGE

/datum/disease/advanced/prion//very fast progression, but very slow spread_flags and resets to stage 1.
	form = "Prion"
	infectionchance = 3
	infectionchance_base = 3
	stageprob = 80
	stage_variance = -10
	can_kill = list()
