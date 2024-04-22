/datum/material_trait
	var/name = "Generic Material Trait"
	var/desc = "Does generic material things."
	var/trait_flags = NONE
	var/reforges = 4

/datum/material_trait/proc/on_trait_add(atom/movable/parent)

/datum/material_trait/proc/on_remove(atom/movable/parent)

/datum/material_trait/proc/on_process(atom/movable/parent, datum/material_stats/host)

/datum/material_trait/proc/on_mob_attack(atom/movable/parent, datum/material_stats/host, mob/living/target, mob/living/attacker)
