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
	move_resist = INFINITY // This mob doesn't have legs
	var/datum/action/cooldown/ground_spikes/spikes

/mob/living/basic/meteor_heart/Initialize(mapload)
	. = ..()
	spikes = new(src)
	spikes.Grant(src)
	ai_controller.blackboard[BB_METEOR_HEART_GROUND_SPIKES] = WEAKREF(spikes)

/mob/living/basic/meteor_heart/Destroy()
	QDEL_NULL(spikes)
	return ..()
