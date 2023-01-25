// A mob which only moves when it isn't being watched by living beings.

/mob/living/simple_animal/hostile/netherworld/statue
	name = "statue" // matches the name of the statue with the flesh-to-stone spell
	desc = "An incredibly lifelike marble carving. Its eyes seem to follow you..." // same as an ordinary statue with the added "eye following you" description
	icon = 'icons/obj/art/statue.dmi'
	icon_state = "human_male"
	icon_living = "human_male"
	icon_dead = "human_male"
	gender = NEUTER
	combat_mode = TRUE
	mob_biotypes = MOB_HUMANOID
	gold_core_spawnable = NO_SPAWN

	response_help_continuous = "touches"
	response_help_simple = "touch"
	response_disarm_continuous = "pushes"
	response_disarm_simple = "push"

	speed = -1
	maxHealth = 50000
	health = 50000
	healable = 0
	harm_intent_damage = 10
	obj_damage = 100
	melee_damage_lower = 68
	melee_damage_upper = 83
	attack_verb_continuous = "claws"
	attack_verb_simple = "claw"
	attack_sound = 'sound/hallucinations/growl1.ogg'
	attack_vis_effect = ATTACK_EFFECT_CLAW

	atmos_requirements = list("min_oxy" = 0, "max_oxy" = 0, "min_plas" = 0, "max_plas" = 0, "min_co2" = 0, "max_co2" = 0, "min_n2" = 0, "max_n2" = 0)
	minbodytemp = 0

	faction = list("statue")
	move_to_delay = 0 // Very fast

	animate_movement = NO_STEPS // Do not animate movement, you jump around as you're a scary statue.
	hud_possible = list(ANTAG_HUD)

	see_in_dark = 13
	lighting_alpha = LIGHTING_PLANE_ALPHA_MOSTLY_VISIBLE
	vision_range = 12
	aggro_vision_range = 12

	search_objects = 1 // So that it can see through walls

	sight = SEE_SELF|SEE_MOBS|SEE_OBJS|SEE_TURFS

	move_force = MOVE_FORCE_EXTREMELY_STRONG
	move_resist = MOVE_FORCE_EXTREMELY_STRONG
	pull_force = MOVE_FORCE_EXTREMELY_STRONG

	var/cannot_be_seen = 1
	var/mob/living/creator = null

// No movement while seen code.

/mob/living/simple_animal/hostile/netherworld/statue/Initialize(mapload, mob/living/creator)
	. = ..()
	// Give spells

	var/datum/action/cooldown/spell/aoe/flicker_lights/flicker = new(src)
	flicker.Grant(src)
	var/datum/action/cooldown/spell/aoe/blindness/blind = new(src)
	blind.Grant(src)
	var/datum/action/cooldown/spell/night_vision/night_vision = new(src)
	night_vision.Grant(src)

	// Set creator
	if(creator)
		src.creator = creator

/mob/living/simple_animal/hostile/netherworld/statue/add_cell_sample()
	return

/mob/living/simple_animal/hostile/netherworld/statue/med_hud_set_health()
	return //we're a statue we're invincible

/mob/living/simple_animal/hostile/netherworld/statue/med_hud_set_status()
	return //we're a statue we're invincible

/mob/living/simple_animal/hostile/netherworld/statue/Move(turf/NewLoc)
	if(can_be_seen(NewLoc))
		if(client)
			to_chat(src, span_warning("You cannot move, there are eyes on you!"))
		return
	return ..()

/mob/living/simple_animal/hostile/netherworld/statue/Life(delta_time = SSMOBS_DT, times_fired)
	..()
	if(!client && target) // If we have a target and we're AI controlled
		var/mob/watching = can_be_seen()
		// If they're not our target
		if(watching && watching != target)
			// This one is closer.
			if(get_dist(watching, src) > get_dist(target, src))
				LoseTarget()
				GiveTarget(watching)

/mob/living/simple_animal/hostile/netherworld/statue/AttackingTarget()
	if(can_be_seen(get_turf(loc)))
		if(client)
			to_chat(src, span_warning("You cannot attack, there are eyes on you!"))
		return FALSE
	else
		return ..()

/mob/living/simple_animal/hostile/netherworld/statue/DestroyPathToTarget()
	if(!can_be_seen(get_turf(loc)))
		..()

/mob/living/simple_animal/hostile/netherworld/statue/face_atom()
	if(!can_be_seen(get_turf(loc)))
		..()

/mob/living/simple_animal/hostile/netherworld/statue/can_speak(allow_mimes = FALSE)
	return FALSE // We're a statue, of course we can't talk.

// Cannot talk

/mob/living/simple_animal/hostile/netherworld/statue/say(message, bubble_type, list/spans = list(), sanitize = TRUE, datum/language/language = null, ignore_spam = FALSE, forced = null, filterproof = null, message_range = 7, datum/saymode/saymode = null)
	return

// Turn to dust when gibbed

/mob/living/simple_animal/hostile/netherworld/statue/gib()
	dust()


// Stop attacking clientless mobs

/mob/living/simple_animal/hostile/netherworld/statue/CanAttack(atom/the_target)
	if(isliving(the_target))
		var/mob/living/L = the_target
		if(!L.client && !L.ckey)
			return FALSE
	return ..()

// Don't attack your creator if there is one

/mob/living/simple_animal/hostile/netherworld/statue/ListTargets()
	. = ..()
	return . - creator

/mob/living/simple_animal/hostile/netherworld/statue/sentience_act()
	faction -= FACTION_NEUTRAL

// Statue powers

// Flicker lights
/datum/action/cooldown/spell/aoe/flicker_lights
	name = "Flicker Lights"
	desc = "You will trigger a large amount of lights around you to flicker."

	cooldown_time = 30 SECONDS
	spell_requirements = NONE
	aoe_radius = 14

/datum/action/cooldown/spell/aoe/flicker_lights/get_things_to_cast_on(atom/center)
	var/list/things = list()
	for(var/obj/machinery/light/nearby_light in range(aoe_radius, center))
		if(!nearby_light.on)
			continue

		things += nearby_light

	return things

/datum/action/cooldown/spell/aoe/flicker_lights/cast_on_thing_in_aoe(obj/machinery/light/victim, atom/caster)
	victim.flicker()

//Blind AOE
/datum/action/cooldown/spell/aoe/blindness
	name = "Blindness"
	desc = "Your prey will be momentarily blind for you to advance on them."

	cooldown_time = 1 MINUTES
	spell_requirements = NONE
	aoe_radius = 14

/datum/action/cooldown/spell/aoe/blindness/cast(atom/cast_on)
	cast_on.visible_message(span_danger("[cast_on] glares their eyes."))
	return ..()

/datum/action/cooldown/spell/aoe/blindness/get_things_to_cast_on(atom/center)
	var/list/things = list()
	for(var/mob/living/nearby_mob in range(aoe_radius, center))
		if(nearby_mob == owner || nearby_mob == center)
			continue

		things += nearby_mob

	return things

/datum/action/cooldown/spell/aoe/blindness/cast_on_thing_in_aoe(mob/living/victim, atom/caster)
	victim.adjust_temp_blindness(8 SECONDS)
