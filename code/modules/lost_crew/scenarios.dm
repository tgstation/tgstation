/// Default scenario, with normal species, assignments and damages etc
/datum/corpse_damage_class/station
	area_lore = "I was working in a space station"
	weight = 15
	possible_character_types = list(/datum/corpse_character/mostly_roundstart = 1)
	possible_character_assignments = list(
		/datum/corpse_assignment/engineer = 1,
		/datum/corpse_assignment/medical = 1,
		/datum/corpse_assignment/security = 1,
		/datum/corpse_assignment/science = 1,
		/datum/corpse_assignment/cargo = 1,
		/datum/corpse_assignment/civillian = 1,
		)
	// // BANDASTATION REMOVAL START - Feat: Augmentations
	// possible_flavor_types = list(
	// 	/datum/corpse_flavor/quirk/prosthetic_limb = 1,
	// 	null = 9,
	// )
	// // BANDASTATION REMOVAL END - Feat: Augmentations

	possible_causes_of_death = list(
		/datum/corpse_damage/cause_of_death/melee_weapon/esword = 1,
		/datum/corpse_damage/cause_of_death/melee_weapon/changeling = 1,
		/datum/corpse_damage/cause_of_death/melee_weapon/toolbox = 1,
		/datum/corpse_damage/cause_of_death/melee_weapon/heretic = 1,
		/datum/corpse_damage/cause_of_death/explosion = 1,
		/datum/corpse_damage/cause_of_death/plasmafire = 1,
		/datum/corpse_damage/cause_of_death/projectile/bullet = 1,
		/datum/corpse_damage/cause_of_death/projectile/laser = 1,
		/datum/corpse_damage/cause_of_death/poison/venom = 1,
		)

	post_mortem_effects = list(
		/datum/corpse_damage/post_mortem/limb_loss = 5,
		/datum/corpse_damage/post_mortem/organ_loss = 5,
		)

	decays = list(
		/datum/corpse_damage/post_mortem/organ_decay = 5,
		/datum/corpse_damage/post_mortem/organ_decay/light = 1,
		/datum/corpse_damage/post_mortem/organ_decay/heavy = 1,
		)

/// Less decay, spread burn and brute damage
/datum/corpse_damage_class/station/spaced
	weight = 2
	possible_causes_of_death = list(/datum/corpse_damage/cause_of_death/spaced = 1)
	decays = list(/datum/corpse_damage/post_mortem/organ_decay/light = 1)

/// Human morgue body
/datum/corpse_damage_class/station/morgue
	weight = 0
	possible_character_types = list(/datum/corpse_character/morgue = 1)
	possible_character_assignments = list()
	possible_flavor_types = list()

/// Non-roundstart species
/datum/corpse_damage_class/station/exotic_species
	possible_character_types = list(/datum/corpse_character/pod = 1)
	weight = 1
