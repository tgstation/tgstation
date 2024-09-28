
/datum/corpse_damage_class/station
	area_lore = "I was working in a space station"
	weight = 10
	possible_character_types = list(/datum/corpse_character/roundstart = 1)
	possible_causes_of_death = list(
		/datum/corpse_damage/cause_of_death/melee_weapon/esword = 1,
		/datum/corpse_damage/cause_of_death/melee_weapon/changeling = 1,
		/datum/corpse_damage/cause_of_death/melee_weapon/toolbox = 1,
		/datum/corpse_damage/cause_of_death/melee_weapon/heretic = 1,
		/datum/corpse_damage/cause_of_death/explosion = 1,
		/datum/corpse_damage/cause_of_death/plasmafire = 1,
		)

	post_mortem_effects = list(
		/datum/corpse_damage/post_mortem/limb_loss = 1,
		/datum/corpse_damage/post_mortem/organ_loss = 1,
		null = 2,
		)

	decays = list(
		/datum/corpse_damage/post_mortem/organ_decay = 3,
		/datum/corpse_damage/post_mortem/organ_decay/light = 1,
		/datum/corpse_damage/post_mortem/organ_decay/heavy = 1,
		)

/datum/corpse_damage_class/station/spaced
	weight = 3
	possible_causes_of_death = list(/datum/corpse_damage/cause_of_death/spaced = 1)
	decays = list(/datum/corpse_damage/post_mortem/organ_decay/light = 1)


