// A mob which only moves when it isn't being watched by living beings.

/mob/living/basic/statue
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
	obj_damage = 100
	melee_damage_lower = 68
	melee_damage_upper = 83
	attack_verb_continuous = "claws"
	attack_verb_simple = "claw"
	attack_sound = 'sound/hallucinations/growl1.ogg'
	attack_vis_effect = ATTACK_EFFECT_CLAW

	faction = list("statue")
	speak_emote = list("screams")
	death_message = "falls apart into a fine dust."
	unsuitable_atmos_damage = 0
	unsuitable_cold_damage = 0
	unsuitable_heat_damage = 0

	animate_movement = NO_STEPS // Do not animate movement, you jump around as you're a scary statue.
	hud_possible = list(ANTAG_HUD)

	see_in_dark = 13
	lighting_alpha = LIGHTING_PLANE_ALPHA_MOSTLY_VISIBLE

	sight = SEE_SELF|SEE_MOBS|SEE_OBJS|SEE_TURFS

	move_force = MOVE_FORCE_EXTREMELY_STRONG
	move_resist = MOVE_FORCE_EXTREMELY_STRONG
	pull_force = MOVE_FORCE_EXTREMELY_STRONG

	ai_controller = /datum/ai_controller/basic_controller/statue
	/// Loot this mob drops on death.
	var/loot
	/// Stores the creator in here if it has one.
	var/mob/living/creator = null

// No movement while seen code.

/mob/living/basic/statue/Initialize(mapload, mob/living/creator)
	. = ..()
	if(LAZYLEN(loot))
		AddElement(/datum/element/death_drops, loot)

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

/mob/living/basic/statue/med_hud_set_health()
	return //we're a statue we're invincible

/mob/living/basic/statue/med_hud_set_status()
	return //we're a statue we're invincible

/mob/living/basic/statue/Move(turf/NewLoc)
	if(can_be_seen(NewLoc))
		if(client)
			to_chat(src, span_warning("You cannot move, there are eyes on you!"))
		return
	return ..()

/mob/living/basic/statue/face_atom()
	if(!can_be_seen(get_turf(loc)))
		..()

/mob/living/basic/statue/can_speak(allow_mimes = FALSE)
	return FALSE // We're a statue, of course we can't talk.

// Cannot talk

/mob/living/basic/statue/say(message, bubble_type, list/spans = list(), sanitize = TRUE, datum/language/language = null, ignore_spam = FALSE, forced = null, filterproof = null, message_range = 7, datum/saymode/saymode = null)
	return

// Turn to dust when gibbed

/mob/living/basic/statue/gib()
	dust()

/mob/living/basic/statue/proc/can_be_seen(turf/location)
	// Check for darkness
	if(location?.lighting_object)
		if(location.get_lumcount() < 0.1) // No one can see us in the darkness, right?
			return null

	// We aren't in darkness, loop for viewers.
	var/list/check_list = list(src)
	if(location)
		check_list += location

	// This loop will, at most, loop twice.
	for(var/atom/check in check_list)
		for(var/mob/living/mob_target in oview(src, 7)) // They probably cannot see us if we cannot see them... can they?
			if(mob_target.client && !mob_target.is_blind() && !mob_target.has_unlimited_silicon_privilege)
				if(!istype(mob_target, /mob/living/basic/statue))
					return mob_target
		for(var/obj/vehicle/sealed/mecha/mecha_mob_target in oview(src, 7))
			for(var/mob/mechamob_target as anything in mecha_mob_target.occupants)
				if(mechamob_target.client && !mechamob_target.is_blind())
					return mechamob_target
	return null

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

/datum/ai_controller/basic_controller/statue
	blackboard = list(
		BB_TARGETTING_DATUM = new /datum/targetting_datum/basic(),
		BB_LOW_PRIORITY_HUNTING_TARGET = null, // lights
	)

	ai_movement = /datum/ai_movement/basic_avoidance
	planning_subtrees = list(
		/datum/ai_planning_subtree/simple_find_target,
		/datum/ai_planning_subtree/basic_melee_attack_subtree/statue,
		/datum/ai_planning_subtree/find_and_hunt_target/look_for_light_fixtures,
	)

/datum/ai_planning_subtree/basic_melee_attack_subtree/statue
	melee_attack_behavior = /datum/ai_behavior/basic_melee_attack/statue

/datum/ai_behavior/basic_melee_attack/statue
	action_cooldown = 1 SECONDS

/datum/ai_behavior/basic_melee_attack/statue/setup(datum/ai_controller/controller, target_key, targetting_datum_key, hiding_location_key)
	. = ..()
	var/mob/living/basic/statue/statue_mob = controller.pawn
	if(statue_mob.can_be_seen(get_turf(statue_mob)))
		return FALSE
