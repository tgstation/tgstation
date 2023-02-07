///Simple animals 2.0, This time, let's really try to keep it simple. This basetype should purely be used as a base-level for implementing simplified behaviours for things such as damage and attacks. Everything else should be in components or AI behaviours.
/mob/living/basic
	name = "basic mob"
	icon = 'icons/mob/simple/animal.dmi'
	health = 20
	maxHealth = 20
	gender = PLURAL
	living_flags = MOVES_ON_ITS_OWN
	status_flags = CANPUSH

	var/basic_mob_flags = NONE

	///Defines how fast the basic mob can move. This is a multiplier
	var/speed = 1
	///How much stamina the mob recovers per second
	var/stamina_recovery = 5

	///how much damage this basic mob does to objects, if any.
	var/obj_damage = 0
	///How much armour they ignore, as a flat reduction from the targets armour value.
	var/armour_penetration = 0
	///Damage type of a simple mob's melee attack, should it do damage.
	var/melee_damage_type = BRUTE
	///How much wounding power it has
	var/wound_bonus = CANT_WOUND
	///How much bare wounding power it has
	var/bare_wound_bonus = 0
	///If the attacks from this are sharp
	var/sharpness = NONE

	/// Sound played when the critter attacks.
	var/attack_sound
	/// Override for the visual attack effect shown on 'do_attack_animation()'.
	var/attack_vis_effect
	///Played when someone punches the creature.
	var/attacked_sound = SFX_PUNCH //This should be an element

	///What kind of objects this mob can smash.
	var/environment_smash = ENVIRONMENT_SMASH_NONE

	/// 1 for full damage, 0 for none, -1 for 1:1 heal from that source.
	var/list/damage_coeff = list(BRUTE = 1, BURN = 1, TOX = 1, CLONE = 1, STAMINA = 0, OXY = 1)
	///Minimum force required to deal any damage.
	var/force_threshold = 0

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
	var/minimum_survivable_temperature = 250
	///Maximal body temperature without receiving damage
	var/maximum_survivable_temperature = 350
	///This damage is taken when the body temp is too cold. Set both this and unsuitable_heat_damage to 0 to avoid adding the basic_body_temp_sensitive element.
	var/unsuitable_cold_damage = 1
	///This damage is taken when the body temp is too hot. Set both this and unsuitable_cold_damage to 0 to avoid adding the basic_body_temp_sensitive element.
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

	if(speak_emote)
		speak_emote = string_list(speak_emote)

	if(unsuitable_atmos_damage != 0)
		//String assoc list returns a cached list, so this is like a static list to pass into the element below.
		habitable_atmos = string_assoc_list(habitable_atmos)
		AddElement(/datum/element/atmos_requirements, habitable_atmos, unsuitable_atmos_damage)

	if(unsuitable_cold_damage != 0 && unsuitable_heat_damage != 0)
		AddElement(/datum/element/basic_body_temp_sensitive, minimum_survivable_temperature, maximum_survivable_temperature, unsuitable_cold_damage, unsuitable_heat_damage)

/mob/living/basic/Life(delta_time = SSMOBS_DT, times_fired)
	. = ..()
	///Automatic stamina re-gain
	if(staminaloss > 0)
		adjustStaminaLoss(-stamina_recovery * delta_time, FALSE, TRUE)

/mob/living/basic/say_mod(input, list/message_mods = list())
	if(length(speak_emote))
		verb_say = pick(speak_emote)
	return ..()

/mob/living/basic/death(gibbed)
	. = ..()
	if(basic_mob_flags & DEL_ON_DEATH)
		qdel(src)
	else
		health = 0
		look_dead()

/**
 * Apply the appearance and properties this mob has when it dies
 * This is called by the mob pretending to be dead too so don't put loot drops in here or something
 */
/mob/living/basic/proc/look_dead()
	icon_state = icon_dead
	if(basic_mob_flags & FLIP_ON_DEATH)
		transform = transform.Turn(180)
	if(!(basic_mob_flags & REMAIN_DENSE_WHILE_DEAD))
		set_density(FALSE)

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
		set_density(initial(density))

/mob/living/basic/proc/melee_attack(atom/target, list/modifiers)
	face_atom(target)
	if(SEND_SIGNAL(src, COMSIG_HOSTILE_PRE_ATTACKINGTARGET, target) & COMPONENT_HOSTILE_NO_ATTACK)
		return FALSE //but more importantly return before attack_animal called
	var/result = target.attack_basic_mob(src, modifiers)
	SEND_SIGNAL(src, COMSIG_HOSTILE_POST_ATTACKINGTARGET, target, result)
	return result

/mob/living/basic/resolve_unarmed_attack(atom/attack_target, list/modifiers)
	melee_attack(attack_target, modifiers)

/mob/living/basic/vv_edit_var(vname, vval)
	. = ..()
	if(vname == NAMEOF(src, speed))
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

/mob/living/basic/relaymove(mob/living/user, direction)
	if(user.incapacitated())
		return
	return relaydrive(user, direction)

/mob/living/basic/get_status_tab_items()
	. = ..()
	. += "Health: [round((health / maxHealth) * 100)]%"
	. += "Combat Mode: [combat_mode ? "On" : "Off"]"

/mob/living/basic/compare_sentience_type(compare_type)
	return sentience_type == compare_type
