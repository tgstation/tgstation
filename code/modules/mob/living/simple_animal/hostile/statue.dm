// A mob which only moves when it isn't being watched by living beings.

/mob/living/simple_animal/hostile/netherworld/statue
	name = "statue" // matches the name of the statue with the flesh-to-stone spell
	desc = "An incredibly lifelike marble carving. Its eyes seem to follow you..." // same as an ordinary statue with the added "eye following you" description
	icon = 'icons/obj/statue.dmi'
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
	var/obj/effect/proc_holder/spell/aoe_turf/flicker_lights/flicker = new(src)
	var/obj/effect/proc_holder/spell/aoe_turf/blindness/blind = new(src)
	var/obj/effect/proc_holder/spell/targeted/night_vision/night_vision = new(src)
	AddSpell(flicker)
	AddSpell(blind)
	AddSpell(night_vision)

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

/mob/living/simple_animal/hostile/netherworld/statue/IsVocal() //we're a statue, of course we can't talk.
	return FALSE

// Cannot talk

/mob/living/simple_animal/hostile/netherworld/statue/say(message, bubble_type, list/spans = list(), sanitize = TRUE, datum/language/language = null, ignore_spam = FALSE, forced = null, filterproof = null)
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

// Statue powers

// Flicker lights
/obj/effect/proc_holder/spell/aoe_turf/flicker_lights
	name = "Flicker Lights"
	desc = "You will trigger a large amount of lights around you to flicker."

	charge_max = 300
	clothes_req = 0
	range = 14

/obj/effect/proc_holder/spell/aoe_turf/flicker_lights/cast(list/targets,mob/user = usr)
	for(var/turf/T in targets)
		for(var/obj/machinery/light/L in T)
			L.flicker()
	return

//Blind AOE
/obj/effect/proc_holder/spell/aoe_turf/blindness
	name = "Blindness"
	desc = "Your prey will be momentarily blind for you to advance on them."

	message = "<span class='notice'>You glare your eyes.</span>"
	charge_max = 600
	clothes_req = 0
	range = 10

/obj/effect/proc_holder/spell/aoe_turf/blindness/cast(list/targets,mob/user = usr)
	for(var/mob/living/L in GLOB.alive_mob_list)
		var/turf/T = get_turf(L.loc)
		if(T && (T in targets))
			L.blind_eyes(4)
	return

//Toggle Night Vision
/obj/effect/proc_holder/spell/targeted/night_vision
	name = "Toggle Nightvision \[ON\]"
	desc = "Toggle your nightvision mode."

	charge_max = 10
	clothes_req = 0

	message = "<span class='notice'>You toggle your night vision!</span>"
	range = -1
	include_user = 1

/obj/effect/proc_holder/spell/targeted/night_vision/cast(list/targets, mob/user = usr)
	for(var/mob/living/target in targets)
		switch(target.lighting_alpha)
			if (LIGHTING_PLANE_ALPHA_VISIBLE)
				target.lighting_alpha = LIGHTING_PLANE_ALPHA_MOSTLY_VISIBLE
				name = "Toggle Nightvision \[More]"
			if (LIGHTING_PLANE_ALPHA_MOSTLY_VISIBLE)
				target.lighting_alpha = LIGHTING_PLANE_ALPHA_MOSTLY_INVISIBLE
				name = "Toggle Nightvision \[Full]"
			if (LIGHTING_PLANE_ALPHA_MOSTLY_INVISIBLE)
				target.lighting_alpha = LIGHTING_PLANE_ALPHA_INVISIBLE
				name = "Toggle Nightvision \[OFF]"
			else
				target.lighting_alpha = LIGHTING_PLANE_ALPHA_VISIBLE
				name = "Toggle Nightvision \[ON]"
		target.update_sight()

/mob/living/simple_animal/hostile/netherworld/statue/sentience_act()
	faction -= "neutral"
