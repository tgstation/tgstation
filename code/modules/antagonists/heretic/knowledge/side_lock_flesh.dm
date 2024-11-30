/datum/heretic_knowledge_tree_column/lock_to_flesh
	neighbour_type_left = /datum/heretic_knowledge_tree_column/main/lock
	neighbour_type_right = /datum/heretic_knowledge_tree_column/main/flesh

	route = PATH_SIDE

	tier1 = /datum/heretic_knowledge/dummy_lock_to_flesh
	tier2 = /datum/heretic_knowledge/spell/opening_blast
	tier3 = /datum/heretic_knowledge/spell/apetra_vulnera

/datum/heretic_knowledge/dummy_lock_to_flesh
	name = "Flesh and Lock ways"
	desc = "Research this to gain access to the other path"
	gain_text = "There are ways from feasting to wounding, the power of birth is close to the power of opening."
	cost = 1

// Sidepaths for knowledge between Knock and Flesh.
/datum/heretic_knowledge/spell/opening_blast
	name = "Wave Of Desperation"
	desc = "Grants you Wave Of Desparation, a spell which can only be cast while restrained. \
		It removes your restraints, repels and knocks down adjacent people, and applies the Mansus Grasp to everything nearby. \
		However, you will fall unconscious a short time after casting this spell."
	gain_text = "My shackles undone in dark fury, their feeble bindings crumble before my power."

	action_to_add = /datum/action/cooldown/spell/aoe/wave_of_desperation
	cost = 1

/datum/heretic_knowledge/spell/apetra_vulnera
	name = "Apetra Vulnera"
	desc = "Grants you Apetra Vulnera, a spell \
		which causes heavy bleeding on all bodyparts of the victim that have more than 15 brute damage. \
		Wounds a random limb if no limb is sufficiently damaged."
	gain_text = "Flesh opens, and blood spills. My master seeks sacrifice, and I shall appease."

	action_to_add = /datum/action/cooldown/spell/pointed/apetra_vulnera
	cost = 1


