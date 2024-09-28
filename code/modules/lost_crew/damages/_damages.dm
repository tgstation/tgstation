#define CORPSE_DAMAGE_ORGAN_DECAY "organ decay"
#define CORPSE_DAMAGE_ORGAN_LOSS "organ loss"
#define CORPSE_DAMAGE_LIMB_LOSS "limb loss"

/datum/corpse_damage_class
	var/area_lore = "I was doing something"
	var/weight
	var/list/possible_character_types = list(/datum/corpse_character = 1)
	var/list/possible_causes_of_death
	var/list/post_mortem_effects
	var/list/decays = list(/datum/corpse_damage/post_mortem/organ_decay)

/datum/corpse_damage_class/proc/apply_character(mob/living/carbon/human/fashion_corpse, list/saved_objects)
	var/datum/corpse_character/character = pick_damage_type(possible_character_types)
	character.apply_character(fashion_corpse, saved_objects)

/datum/corpse_damage_class/proc/apply_injuries(mob/living/carbon/human/victim, list/saved_objects)
	var/datum/corpse_damage/cause_of_death = pick_damage_type(possible_causes_of_death)
	cause_of_death.apply_to_body(victim, rand(0, 1), saved_objects)

	var/datum/corpse_damage/post_mortem = pick_damage_type(post_mortem_effects)
	post_mortem?.apply_to_body(victim, rand(0, 1), saved_objects)

	var/datum/corpse_damage/decay = pick_damage_type(decays)
	decay?.apply_to_body(victim, rand(0, 1), saved_objects)

/datum/corpse_damage_class/proc/pick_damage_type(list/damages, list/used_damage_types)
	var/list/possible_damages = list()

	for(var/datum/corpse_damage/damage as anything in damages)
		if(damage.damage_type && (damage.damage_type in used_damage_types))
			continue
		possible_damages[damage] = damages[damage]

	var/datum/corpse_damage/chosen = pick_weight(possible_damages)
	if(chosen.damage_type)
		used_damage_types += chosen.damage_type
	return chosen

/datum/corpse_damage
	var/damage_type

/datum/corpse_damage/proc/apply_to_body(mob/living/carbon/human/body, severity, list/storage)
	return

/datum/corpse_damage/cause_of_death
	/// I was in x, [when I ....]
	var/cause_of_death = "when I tripped and died."

/datum/corpse_damage/post_mortem
