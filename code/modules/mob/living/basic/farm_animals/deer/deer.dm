/mob/living/basic/deer
	name = "doe"
	desc = "A gentle, peaceful forest animal. How did this get into space?"
	icon_state = "deer-doe"
	icon_living = "deer-doe"
	icon_dead = "deer-doe-dead"
	gender = FEMALE
	mob_biotypes = MOB_ORGANIC|MOB_BEAST
	speak_emote = list("grunts", "grunts lowly")
	butcher_results = list(/obj/item/food/meat/slab/grassfed = 3)
	response_help_continuous = "pets"
	response_help_simple = "pet"
	response_disarm_continuous = "gently nudges"
	response_disarm_simple = "gently nudges aside"
	response_harm_continuous = "kicks"
	response_harm_simple = "kick"
	attack_verb_continuous = "bucks"
	attack_verb_simple = "buck"
	attack_sound = 'sound/weapons/punch1.ogg'
	health = 75
	maxHealth = 75
	blood_volume = BLOOD_VOLUME_NORMAL
	ai_controller = /datum/ai_controller/basic_controller/deer
	/// Things that will scare us into being stationary. Vehicles are scary to deers because they might have headlights.
	var/static/list/stationary_scary_things = list(/obj/vehicle)


/mob/living/basic/deer/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/ai_retaliate)
	AddElement(/datum/element/footstep, footstep_type = FOOTSTEP_MOB_SHOE)
	var/time_to_freeze_for = (rand(5, 10) SECONDS)
	ai_controller.set_blackboard_key(BB_STATIONARY_SECONDS, time_to_freeze_for)
	ai_controller.set_blackboard_key(BB_STATIONARY_COOLDOWN, (time_to_freeze_for * (rand(3, 5))))
	ai_controller.set_blackboard_key(BB_STATIONARY_TARGETS, typecacheof(stationary_scary_things))


/// Cold resistent and doesn't need to breathe
/mob/living/basic/deer/ice
	habitable_atmos = null
	minimum_survivable_temperature = 0
