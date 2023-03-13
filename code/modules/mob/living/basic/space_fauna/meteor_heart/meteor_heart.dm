/mob/living/basic/meteor_heart
	name = "meteor heart"
	desc = "A ferocious, fang-bearing creature that resembles a fish."
	icon = 'icons/mob/nonhuman-player/blob.dmi'
	icon_state = "blob_core_overlay"
	icon_living = "blob_core_overlay"
	mob_biotypes = MOB_ORGANIC
	basic_mob_flags = DEL_ON_DEATH
	mob_size = MOB_SIZE_HUGE
	health = 25
	maxHealth = 25
	pressure_resistance = 200
	response_help_continuous = "pets"
	response_help_simple = "pet"
	response_disarm_continuous = "gently pushes"
	response_disarm_simple = "gently push"
	faction = list()
	ai_controller = /datum/ai_controller/basic_controller/meteor_heart
	habitable_atmos = list("min_oxy" = 0, "max_oxy" = 0, "min_plas" = 0, "max_plas" = 0, "min_co2" = 0, "max_co2" = 0, "min_n2" = 0, "max_n2" = 0)
	minimum_survivable_temperature = 0
	maximum_survivable_temperature = 1500
	combat_mode = TRUE
	move_resist = INFINITY // This mob IS the floor
	var/datum/action/cooldown/chasing_spikes/spikes
	var/datum/action/cooldown/spine_traps/traps

/mob/living/basic/meteor_heart/Initialize(mapload)
	. = ..()
	ADD_TRAIT(src, TRAIT_IMMOBILIZED, INNATE_TRAIT)
	spikes = new(src)
	spikes.Grant(src)
	ai_controller.blackboard[BB_METEOR_HEART_GROUND_SPIKES] = WEAKREF(spikes)
	RegisterSignal(spikes, COMSIG_MOB_ABILITY_FINISHED, PROC_REF(summoned_spikes))

	traps = new(src)
	traps.Grant(src)
	ai_controller.blackboard[BB_METEOR_HEART_SPINE_TRAPS] = WEAKREF(traps)

/// Do a little animation whenever we summon spikes
/mob/living/basic/meteor_heart/proc/summoned_spikes()
	Shake(1, 1, 0.5 SECONDS)

/mob/living/basic/meteor_heart/Destroy()
	QDEL_NULL(spikes)
	return ..()
