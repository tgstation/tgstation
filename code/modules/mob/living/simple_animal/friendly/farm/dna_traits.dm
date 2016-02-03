/datum/farm_animal_trait
	var/name = "Pornhub"
	var/description = "Sponsored By Brazzers"
	var/datum/farm_animal_trait/opposite_trait = null
	var/datum/farm_animal_dna/owner = null
	var/manifest_probability = 0
	var/continue_probability = 0
	var/random_blacklist = 0

/datum/farm_animal_trait/proc/on_apply(var/mob/living/simple_animal/farm/M)
	return

/datum/farm_animal_trait/proc/on_life(var/mob/living/simple_animal/farm/M)
	return

/datum/farm_animal_trait/proc/on_priority_life(var/mob/living/simple_animal/farm/M)
	return

/datum/farm_animal_trait/proc/on_breed(var/mob/living/simple_animal/farm/M, var/mob/living/simple_animal/farm/mate)
	return

/datum/farm_animal_trait/proc/on_create_young(var/atom/movable/young, var/mob/living/simple_animal/farm/M)
	return

/datum/farm_animal_trait/proc/on_death(var/mob/living/simple_animal/farm/M)
	return

/datum/farm_animal_trait/proc/on_remove(var/mob/living/simple_animal/farm/M)
	return

/datum/farm_animal_trait/proc/on_examine(var/mob/user, var/mob/living/simple_animal/farm/M)
	return

/datum/farm_animal_trait/proc/on_hear(message, atom/movable/speaker, message_langs, raw_message, radio_freq, list/spans)
	return

/datum/farm_animal_trait/proc/on_attack_by(var/mob/living/simple_animal/farm/M, obj/item/O, mob/living/user, params)
	return

/datum/farm_animal_trait/proc/on_attacked(var/mob/living/simple_animal/farm/M, var/mob/living/L)
	return

/datum/farm_animal_trait/proc/on_attack_mob(var/mob/living/simple_animal/farm/M, var/mob/living/L)
	return

/datum/farm_animal_trait/proc/on_move(var/mob/living/simple_animal/farm/M)
	return