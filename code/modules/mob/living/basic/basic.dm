///Simple animals 2.0, This time, let's really try to keep it simple. This basetype should purely be used as a base-level for implementing simplified behaviours for things such as damage and attacks. Everything else should be in components or AI behaviours.
/mob/living/basic
	name = "basic mob"
	icon = 'icons/mob/simple/animal.dmi'
	health = 20
	maxHealth = 20
	max_stamina = BASIC_MOB_STAMINA_MATCH_HEALTH
	gender = PLURAL
	living_flags = MOVES_ON_ITS_OWN
	status_flags = CANPUSH | CANSTUN
	fire_stack_decay_rate = -5 // Reasonably fast as NPCs will not usually actively extinguish themselves

	var/basic_mob_flags = NONE

	///Defines how fast the basic mob can move. This is not a multiplier
	var/speed = 1
	///How much stamina the mob recovers per second, if set to >0 stamina loses its normal function of resetting after a set amount of time
	var/stamina_recovery = 0
	///How slow will we get when we lose all our stamina?
	var/max_stamina_slowdown = 3
	///Percentage of max stamina loss we need to lose in order to get stunned
	var/stamina_crit_threshold = 100

	///how much damage this basic mob does to objects, if any.
	var/obj_damage = 0
	///How much armour they ignore, as a flat reduction from the targets armour value.
	var/armour_penetration = 0
	///Damage type of a simple mob's melee attack, should it do damage.
	var/melee_damage_type = BRUTE
	///How much wounding power it has
	var/wound_bonus = CANT_WOUND
	///How much bare wounding power it has
	var/exposed_wound_bonus = 0
	///If the attacks from this are sharp
	var/sharpness = NONE

	/// Sound played when the critter attacks.
	var/attack_sound
	/// Override for the visual attack effect shown on 'do_attack_animation()'.
	var/attack_vis_effect
	///Played when someone punches the creature.
	var/attacked_sound = SFX_PUNCH //This should be an element
	/// How often can you melee attack?
	var/melee_attack_cooldown = 2 SECONDS

	/// Variable maintained for compatibility with attack_animal procs until simple animals can be refactored away. Use element instead of setting manually.
	var/environment_smash = ENVIRONMENT_SMASH_STRUCTURES

	/// 1 for full damage, 0 for none, -1 for 1:1 heal from that source.
	var/list/damage_coeff = list(BRUTE = 1, BURN = 1, TOX = 1, STAMINA = 1, OXY = 1)

	///Verbs used for speaking e.g. "Says" or "Chitters". This can be elementized
	var/list/speak_emote = list()

	///When someone interacts with the simple animal.
	///Help-intent verb in present continuous tense.
	var/response_help_continuous = "pokes"
	///Help-intent verb in present simple tense.
	var/response_help_simple = "poke"
	///Disarm-intent verb in present continuous tense.
	var/response_disarm_continuous = "shoves"
	///Disarm-intent verb in present simple tense.
	var/response_disarm_simple = "shove"
	///Harm-intent verb in present continuous tense.
	var/response_harm_continuous = "hits"
	///Harm-intent verb in present simple tense.
	var/response_harm_simple = "hit"

	///Basic mob's own attacks verbs,
	///Attacking verb in present continuous tense.
	var/attack_verb_continuous = "attacks"
	///Attacking verb in present simple tense.
	var/attack_verb_simple = "attack"
	///Attacking, but without damage, verb in present continuous tense.
	var/friendly_verb_continuous = "nuzzles"
	///Attacking, but without damage, verb in present simple tense.
	var/friendly_verb_simple = "nuzzle"

	////////THIS SECTION COULD BE ITS OWN ELEMENT
	///Icon to use
	var/icon_living = ""
	///Icon when the animal is dead. Don't use animated icons for this.
	var/icon_dead = ""
	///We only try to show a gibbing animation if this exists.
	var/icon_gib = null

	///If the mob can be spawned with a gold slime core. HOSTILE_SPAWN are spawned with plasma, FRIENDLY_SPAWN are spawned with blood.
	var/gold_core_spawnable = NO_SPAWN
	///Sentience type, for slime potions. SHOULD BE AN ELEMENT BUT I DONT CARE ABOUT IT FOR NOW
	var/sentience_type = SENTIENCE_ORGANIC

	///Leaving something at 0 means it's off - has no maximum.
	var/list/habitable_atmos = list("min_oxy" = 5, "max_oxy" = 0, "min_plas" = 0, "max_plas" = 1, "min_co2" = 0, "max_co2" = 5, "min_n2" = 0, "max_n2" = 0)
	///This damage is taken when atmos doesn't fit all the requirements above. Set to 0 to avoid adding the atmos_requirements element.
	var/unsuitable_atmos_damage = 1

	///Minimal body temperature without receiving damage
	var/minimum_survivable_temperature = NPC_DEFAULT_MIN_TEMP
	///Maximal body temperature without receiving damage
	var/maximum_survivable_temperature = NPC_DEFAULT_MAX_TEMP
	///This damage is taken when the body temp is too cold. Set both this and unsuitable_heat_damage to 0 to avoid adding the body_temp_sensitive element.
	var/unsuitable_cold_damage = 1
	///This damage is taken when the body temp is too hot. Set both this and unsuitable_cold_damage to 0 to avoid adding the body_temp_sensitive element.
	var/unsuitable_heat_damage = 1

/mob/living/basic/Initialize(mapload)
	. = ..()

	if(gender == PLURAL)
		gender = pick(MALE,FEMALE)

	if(!real_name)
		real_name = name

	if(!loc)
		stack_trace("Basic mob being instantiated in nullspace")

	update_basic_mob_varspeed()
	apply_target_randomisation()
	make_stamina_slowable()

	if(speak_emote)
		speak_emote = string_list(speak_emote)

	///We need to wait for SSair to be initialized before we can check atmos/temp requirements.
	if(PERFORM_ALL_TESTS(focus_only/atmos_and_temp_requirements) && mapload && !SSair.initialized)
		RegisterSignal(SSair, COMSIG_SUBSYSTEM_POST_INITIALIZE, PROC_REF(on_ssair_init))
		return
	apply_atmos_requirements(mapload)
	apply_temperature_requirements(mapload)

/mob/living/basic/proc/on_ssair_init(datum/source)
	SIGNAL_HANDLER
	UnregisterSignal(SSair, COMSIG_SUBSYSTEM_POST_INITIALIZE)
	apply_atmos_requirements(TRUE)
	apply_temperature_requirements(TRUE)

/// Ensures this mob can take atmospheric damage if it's supposed to
/mob/living/basic/proc/apply_atmos_requirements(mapload)
	if(unsuitable_atmos_damage == 0 || isnull(habitable_atmos))
		return
	//String assoc list returns a cached list, so this is like a static list to pass into the element below.
	habitable_atmos = string_assoc_list(habitable_atmos)
	AddElement(/datum/element/atmos_requirements, habitable_atmos, unsuitable_atmos_damage, mapload)

/// Ensures this mob can take temperature damage if it's supposed to
/mob/living/basic/proc/apply_temperature_requirements(mapload)
	if((unsuitable_cold_damage == 0 && unsuitable_heat_damage == 0) || (minimum_survivable_temperature <= 0 && maximum_survivable_temperature >= INFINITY))
		return
	AddElement(/datum/element/body_temp_sensitive, minimum_survivable_temperature, maximum_survivable_temperature, unsuitable_cold_damage, unsuitable_heat_damage, mapload)

/// Ensures that this mob can be slowed from taking stamina damage
/mob/living/basic/proc/make_stamina_slowable()
	if (max_stamina == BASIC_MOB_STAMINA_MATCH_HEALTH)
		max_stamina = maxHealth
	if (damage_coeff[STAMINA] <= 0 || max_stamina <= 0 || max_stamina_slowdown <= 0)
		return
	AddElement(/datum/element/basic_stamina_slowdown, minium_stamina_threshold = max_stamina / 3, maximum_stamina = max_stamina, maximum_slowdown = max_stamina_slowdown)

/mob/living/basic/proc/apply_target_randomisation()
	if (basic_mob_flags & PRECISE_ATTACK_ZONES)
		return
	AddElement(/datum/element/attack_zone_randomiser)

/mob/living/basic/Life(seconds_per_tick = SSMOBS_DT, times_fired)
	. = ..()
	if(staminaloss > 0)
		adjustStaminaLoss(-stamina_recovery * seconds_per_tick, forced = TRUE)

/mob/living/basic/get_default_say_verb()
	return length(speak_emote) ? pick(speak_emote) : ..()

/mob/living/basic/death(gibbed)
	. = ..()
	if(basic_mob_flags & DEL_ON_DEATH)
		ghostize(can_reenter_corpse = FALSE)
		qdel(src)
	else
		health = 0
		look_dead()

/mob/living/basic/gib()
	if(butcher_results || guaranteed_butcher_results)
		var/list/butcher_loot = list()
		if(butcher_results)
			butcher_loot += butcher_results
		if(guaranteed_butcher_results)
			butcher_loot += guaranteed_butcher_results
		var/atom/loot_destination = drop_location()
		for(var/path in butcher_loot)
			for(var/i in 1 to butcher_loot[path])
				new path(loot_destination)
	return ..()

/**
 * Apply the appearance and properties this mob has when it dies
 * This is called by the mob pretending to be dead too so don't put loot drops in here or something
 */
/mob/living/basic/proc/look_dead()
	icon_state = icon_dead
	if(basic_mob_flags & FLIP_ON_DEATH)
		transform = transform.Turn(180)
	if(!(basic_mob_flags & REMAIN_DENSE_WHILE_DEAD))
		ADD_TRAIT(src, TRAIT_UNDENSE, BASIC_MOB_DEATH_TRAIT)
	SEND_SIGNAL(src, COMSIG_BASICMOB_LOOK_DEAD)

/mob/living/basic/revive(full_heal_flags = NONE, excess_healing = 0, force_grab_ghost = FALSE)
	. = ..()
	if(!.)
		return
	look_alive()

/// Apply the appearance and properties this mob has when it is alive
/mob/living/basic/proc/look_alive()
	icon_state = icon_living
	if(basic_mob_flags & FLIP_ON_DEATH)
		transform = transform.Turn(180)
	if(!(basic_mob_flags & REMAIN_DENSE_WHILE_DEAD))
		REMOVE_TRAIT(src, TRAIT_UNDENSE, BASIC_MOB_DEATH_TRAIT)
	SEND_SIGNAL(src, COMSIG_BASICMOB_LOOK_ALIVE)

/mob/living/basic/update_sight()
	lighting_color_cutoffs = list(lighting_cutoff_red, lighting_cutoff_green, lighting_cutoff_blue)
	return ..()

/mob/living/basic/examine(mob/user)
	. = ..()
	if(stat != DEAD)
		return
	. += span_deadsay("Upon closer examination, [p_they()] appear[p_s()] to be [HAS_MIND_TRAIT(user, TRAIT_NAIVE) ? "asleep" : "dead"].")

/mob/living/basic/proc/melee_attack(atom/target, list/modifiers, ignore_cooldown = FALSE)
	if(!early_melee_attack(target, modifiers, ignore_cooldown))
		return FALSE
	var/result = target.attack_basic_mob(src, modifiers)
	SEND_SIGNAL(src, COMSIG_HOSTILE_POST_ATTACKINGTARGET, target, result)
	if(!ignore_cooldown)
		changeNext_move(melee_attack_cooldown) // Set it again because objects like to fuck with it in attack_basic_mob
	return result

/mob/living/basic/proc/early_melee_attack(atom/target, list/modifiers, ignore_cooldown = FALSE)
	face_atom(target)
	if(!ignore_cooldown)
		changeNext_move(melee_attack_cooldown) // Set cooldown early in case it is cancelled
	if(SEND_SIGNAL(src, COMSIG_HOSTILE_PRE_ATTACKINGTARGET, target, Adjacent(target), modifiers) & COMPONENT_HOSTILE_NO_ATTACK)
		return FALSE //but more importantly return before attack_animal called
	return TRUE

/mob/living/basic/resolve_unarmed_attack(atom/attack_target, list/modifiers)
	melee_attack(attack_target, modifiers)

/mob/living/basic/vv_edit_var(vname, vval)
	switch(vname)
		if(NAMEOF(src, habitable_atmos), NAMEOF(src, unsuitable_atmos_damage))
			RemoveElement(/datum/element/atmos_requirements, habitable_atmos, unsuitable_atmos_damage)
			. = TRUE
		if(NAMEOF(src, minimum_survivable_temperature), NAMEOF(src, maximum_survivable_temperature), NAMEOF(src, unsuitable_cold_damage), NAMEOF(src, unsuitable_heat_damage))
			RemoveElement(/datum/element/body_temp_sensitive, minimum_survivable_temperature, maximum_survivable_temperature, unsuitable_cold_damage, unsuitable_heat_damage)
			. = TRUE

	. = ..()

	switch(vname)
		if(NAMEOF(src, habitable_atmos), NAMEOF(src, unsuitable_atmos_damage))
			apply_atmos_requirements()
		if(NAMEOF(src, minimum_survivable_temperature), NAMEOF(src, maximum_survivable_temperature), NAMEOF(src, unsuitable_cold_damage), NAMEOF(src, unsuitable_heat_damage))
			apply_temperature_requirements()
		if(NAMEOF(src, speed))
			datum_flags |= DF_VAR_EDITED
			set_varspeed(vval)

/mob/living/basic/proc/set_varspeed(var_value)
	speed = var_value
	update_basic_mob_varspeed()

/mob/living/basic/proc/update_basic_mob_varspeed()
	if(speed == 0)
		remove_movespeed_modifier(/datum/movespeed_modifier/simplemob_varspeed)
	add_or_update_variable_movespeed_modifier(/datum/movespeed_modifier/simplemob_varspeed, multiplicative_slowdown = speed)
	SEND_SIGNAL(src, POST_BASIC_MOB_UPDATE_VARSPEED)

/mob/living/basic/update_movespeed()
	. = ..()
	if (cached_multiplicative_slowdown > END_GLIDE_SPEED)
		ADD_TRAIT(src, TRAIT_NO_GLIDE, SPEED_TRAIT)
	else
		REMOVE_TRAIT(src, TRAIT_NO_GLIDE, SPEED_TRAIT)

/mob/living/basic/relaymove(mob/living/user, direction)
	if(user.incapacitated)
		return
	return relaydrive(user, direction)

/mob/living/basic/get_status_tab_items()
	. = ..()
	. += "Health: [round((health / maxHealth) * 100)]%"
	. += "Combat Mode: [combat_mode ? "On" : "Off"]"

/mob/living/basic/compare_sentience_type(compare_type)
	return sentience_type == compare_type

/mob/living/basic/on_fire_stack(seconds_per_tick, datum/status_effect/fire_handler/fire_stacks/fire_handler)
	adjust_bodytemperature((maximum_survivable_temperature + (fire_handler.stacks * 12)) * 0.5 * seconds_per_tick)

/mob/living/basic/get_fire_overlay(stacks, on_fire)
	var/fire_icon = "generic_fire"
	if(!GLOB.fire_appearances[fire_icon])
		GLOB.fire_appearances[fire_icon] = mutable_appearance(
			'icons/mob/effects/onfire.dmi',
			fire_icon,
			-HIGHEST_LAYER,
			appearance_flags = RESET_COLOR|KEEP_APART,
		)

	return GLOB.fire_appearances[fire_icon]

/mob/living/basic/put_in_hands(obj/item/I, del_on_fail = FALSE, merge_stacks = TRUE, ignore_animation = TRUE)
	. = ..()
	if (.)
		update_held_items()

/mob/living/basic/update_held_items()
	. = ..()
	if(isnull(client) || isnull(hud_used) || hud_used.hud_version == HUD_STYLE_NOHUD)
		return
	var/turf/our_turf = get_turf(src)
	for(var/obj/item/held in held_items)
		var/index = get_held_index_of_item(held)
		SET_PLANE(held, ABOVE_HUD_PLANE, our_turf)
		held.screen_loc = ui_hand_position(index)
		client.screen |= held

/mob/living/basic/get_body_temp_heat_damage_limit()
	return maximum_survivable_temperature

/mob/living/basic/get_body_temp_cold_damage_limit()
	return minimum_survivable_temperature

/mob/living/basic/proc/hop_on_nearby_turf()
	var/dir = pick(GLOB.cardinals)
	Move(get_step(src, dir), dir)
	animate(src, pixel_y = 18, time = 0.4 SECONDS, flags = ANIMATION_RELATIVE, easing = CUBIC_EASING|EASE_OUT)
	animate(pixel_y = -18, time = 0.4 SECONDS, flags = ANIMATION_RELATIVE, easing = CUBIC_EASING|EASE_IN)

///ovverride to add mob specific cytology mutation effects, returns TRUE if we added a mob specific mutation
/mob/living/basic/proc/mutate()
	if(SEND_SIGNAL(src, COMSIG_BASICMOB_MUTATED) & MUTATED_NO_FURTHER_MUTATIONS)
		//Tells the vat our mob has been mutated by another source and we don't want to add potentially incompatible mutations such as shiny mutation.
		return TRUE
	else
		return FALSE

