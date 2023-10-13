// Sidepaths for knowledge between Knock and Moon.

/datum/heretic_knowledge/spell/mind_gate
	name = "Mind Gate"
	desc = "Grants you Mind Gate, a spell \
		which deals you 20 brain damage but the target suffers a hallucination, is left confused for 10 seconds and takes 30 brain damage."
	gain_text = "My mind swings open like a gate, and its insight will let me percieve the truth."
	next_knowledge = list(
		/datum/heretic_knowledge/key_ring,
		/datum/heretic_knowledge/spell/moon_smile,
	)
	spell_to_add = /datum/action/cooldown/spell/pointed/mind_gate
	cost = 1
	route = PATH_SIDE

/datum/heretic_knowledge/unfathomable_curio
	name = "Unfathomable Curio"
	desc = "Grants you Apetra Vulnera, a spell \
		which causes heavy bleeding on all bodyparts of the victim that have more than 15 brute damage. \
		Wounds a random limb if no limb is sufficiently damaged."
	gain_text = "Flesh opens, and blood spills. My master seeks sacrifice, and I shall appease."
	next_knowledge = list(
		/datum/heretic_knowledge/spell/burglar_finesse,
		/datum/heretic_knowledge/moon_amulette,
	)
	required_atoms = list(
		/obj/item/organ/internal/brain = 1,
		/obj/item/stack/rods = 3,
		/obj/item/storage/box = 1,
	)
	result_atoms = list(/obj/item/clothing/neck/heretic_focus/moon_amulette)
	cost = 1
	route = PATH_SIDE

/datum/heretic_knowledge/spell/opening_blast
	name = "Wave Of Desperation"
	desc = "Grants you Wave Of Desparation, a spell which can only be cast while restrained. \
		It removes your restraints, repels and knocks down adjacent people, and applies the Mansus Grasp to everything nearby."
	gain_text = "My shackles undone in dark fury, their feeble bindings crumble before my power."
	next_knowledge = list(
		/datum/heretic_knowledge/spell/burglar_finesse,
		/datum/heretic_knowledge/void_cloak,
	)
	spell_to_add = /datum/action/cooldown/spell/aoe/wave_of_desperation
	cost = 1
	route = PATH_SIDE
