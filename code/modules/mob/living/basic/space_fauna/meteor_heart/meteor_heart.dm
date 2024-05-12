#define HEARTBEAT_NORMAL (1.2 SECONDS)
#define HEARTBEAT_FAST (0.6 SECONDS)
#define HEARTBEAT_FRANTIC (0.4 SECONDS)

#define SPIKES_ABILITY_TYPEPATH /datum/action/cooldown/mob_cooldown/chasing_spikes

/mob/living/basic/meteor_heart
	name = "meteor heart"
	desc = "A pulsing lump of flesh and bone growing directly out of the ground."
	icon = 'icons/mob/simple/meteor_heart.dmi'
	icon_state = "heart"
	icon_living = "heart"
	mob_biotypes = MOB_ORGANIC
	basic_mob_flags = DEL_ON_DEATH
	mob_size = MOB_SIZE_HUGE
	health = 600 // 15 PKA shots
	maxHealth = 600
	pressure_resistance = 200
	response_help_continuous = "pets"
	response_help_simple = "pet"
	response_disarm_continuous = "gently pushes"
	response_disarm_simple = "gently push"
	faction = list()
	ai_controller = /datum/ai_controller/basic_controller/meteor_heart
	habitable_atmos = null
	minimum_survivable_temperature = 0
	maximum_survivable_temperature = 1500
	combat_mode = TRUE
	move_resist = INFINITY // This mob IS the floor

	/// Looping heartbeat sound
	var/datum/looping_sound/heartbeat/soundloop

/mob/living/basic/meteor_heart/Initialize(mapload)
	. = ..()
	ADD_TRAIT(src, TRAIT_IMMOBILIZED, INNATE_TRAIT)
	var/static/list/death_loot = list(/obj/effect/temp_visual/meteor_heart_death)
	AddElement(/datum/element/death_drops, death_loot)
	AddElement(/datum/element/relay_attackers)

	var/static/list/innate_actions = list(
		SPIKES_ABILITY_TYPEPATH = BB_METEOR_HEART_GROUND_SPIKES,
		/datum/action/cooldown/mob_cooldown/spine_traps = BB_METEOR_HEART_SPINE_TRAPS,
	)
	grant_actions_by_list(innate_actions)
	ai_controller.set_ai_status(AI_STATUS_OFF)

	RegisterSignal(src, COMSIG_MOB_ABILITY_FINISHED, PROC_REF(used_ability))
	RegisterSignal(src, COMSIG_ATOM_WAS_ATTACKED, PROC_REF(aggro))

	for (var/obj/structure/meateor_fluff/body_part in view(5, src))
		RegisterSignal(body_part, COMSIG_ATOM_DESTRUCTION, PROC_REF(aggro))

	soundloop = new(src, start_immediately = FALSE)
	soundloop.mid_length = HEARTBEAT_NORMAL
	soundloop.pressure_affected = FALSE
	soundloop.start()

	AddComponent(\
		/datum/component/bloody_spreader,\
		blood_left = INFINITY,\
		blood_dna = list("meaty DNA" = "MT-"),\
		diseases = null,\
	)

/// Called when we get mad at something, either for attacking us or attacking the nearby area
/mob/living/basic/meteor_heart/proc/aggro()
	if (ai_controller.ai_status == AI_STATUS_ON)
		return
	ai_controller.reset_ai_status()
	if (!ai_controller.ai_status == AI_STATUS_ON)
		return
	icon_state = "heart_aggro"
	soundloop.set_mid_length(HEARTBEAT_FAST)

/// Called when we stop being mad
/mob/living/basic/meteor_heart/proc/deaggro()
	ai_controller.set_ai_status(AI_STATUS_OFF)
	icon_state = "heart"
	soundloop.set_mid_length(HEARTBEAT_NORMAL)

/// Animate when using certain abilities
/mob/living/basic/meteor_heart/proc/used_ability(mob/living/owner, datum/action/cooldown/mob_cooldown/ability)
	SIGNAL_HANDLER
	if(!istype(ability, SPIKES_ABILITY_TYPEPATH))
		return
	Shake(1, 0, 1.5 SECONDS)

/mob/living/basic/meteor_heart/Destroy()
	QDEL_NULL(soundloop)
	return ..()

/// Dramatic death animation for the meteor heart mob
/obj/effect/temp_visual/meteor_heart_death
	name = "meteor heart"
	icon = 'icons/mob/simple/meteor_heart.dmi'
	icon_state = "heart_dying"
	desc = "You've killed this innocent asteroid, I hope you feel happy."
	duration = 3 SECONDS
	/// Looping heartbeat sound
	var/datum/looping_sound/heartbeat/soundloop

/obj/effect/temp_visual/meteor_heart_death/Initialize(mapload)
	. = ..()
	playsound(src, 'sound/magic/demon_dies.ogg', vol = 100, vary = TRUE, pressure_affected = FALSE)
	Shake(2, 0, 3 SECONDS)
	addtimer(CALLBACK(src, PROC_REF(gib)), duration - 1, TIMER_DELETE_ME)
	soundloop = new(src, start_immediately = FALSE)
	soundloop.mid_length = HEARTBEAT_FRANTIC
	soundloop.pressure_affected = FALSE
	soundloop.start()

/obj/effect/temp_visual/meteor_heart_death/Destroy()
	QDEL_NULL(soundloop)
	return ..()

/// Make this place a mess
/obj/effect/temp_visual/meteor_heart_death/proc/gib()
	playsound(loc, 'sound/effects/attackblob.ogg', vol = 100, vary = TRUE, pressure_affected = FALSE)
	var/turf/my_turf = get_turf(src)
	new /obj/effect/gibspawner/human(my_turf)
	for (var/obj/structure/eyeball as anything in GLOB.meteor_eyeballs)
		if (eyeball.z != src.z)
			continue
		addtimer(CALLBACK(eyeball, TYPE_PROC_REF(/atom/, take_damage), eyeball.max_integrity), rand(0.5 SECONDS, 2 SECONDS)) // pop!
	for (var/mob/murderer in range(10, src))
		if (!murderer.client || isspaceturf(get_turf(murderer)))
			continue
		shake_camera(murderer, duration = 2 SECONDS, strength = 2)

#undef HEARTBEAT_NORMAL
#undef HEARTBEAT_FAST
#undef HEARTBEAT_FRANTIC

#undef SPIKES_ABILITY_TYPEPATH
