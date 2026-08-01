///prototype for mining mobs
/mob/living/basic/mining
	abstract_type = /mob/living/basic/mining
	icon = 'icons/mob/simple/lavaland/lavaland_monsters.dmi'
	combat_mode = TRUE
	status_flags = NONE //don't inherit standard basicmob flags
	mob_size = MOB_SIZE_LARGE
	mob_biotypes = MOB_ORGANIC|MOB_BEAST|MOB_MINING
	faction = list(FACTION_MINING, FACTION_ASHWALKER)
	unsuitable_atmos_damage = 0
	minimum_survivable_temperature = 0
	maximum_survivable_temperature = INFINITY
	// Pale purple, should be red enough to see stuff on lavaland
	lighting_cutoff_red = 25
	lighting_cutoff_green = 15
	lighting_cutoff_blue = 35
	damage_coeff = list(BRUTE = 1, BURN = 1, TOX = 1, STAMINA = 0, OXY = 1)
	var/previous_target
	/// Message to output if throwing damage is absorbed
	var/throw_blocked_message = "bounces off"
	/// What crusher trophy this mob drops, if any
	var/crusher_loot
	/// What is the chance the mob drops it if all their health was taken by crusher attacks
	var/crusher_drop_chance = 25
	/// Does this mob count for mining mob kills counter?
	var/kill_count = TRUE
	/// What sound do we play when we idle while activated?
	var/idle_sound
	/// What sound do we play when we get hurt?
	var/pain_sound
	/// What channel should our pain sound be on? To restart the sound if it gets hit again.
	var/pain_channel
	/// What's our chance of performing pain responses?
	var/pain_chance = 0
	/// Should we be stunned on pain? If so, for how long?
	var/pain_stun = null
	/// What sound do we play when we aggro on someone?
	var/aggro_sound


/mob/living/basic/mining/Initialize(mapload)
	. = ..()
	add_traits(list(TRAIT_LAVA_IMMUNE, TRAIT_ASHSTORM_IMMUNE, TRAIT_SNOWSTORM_IMMUNE), INNATE_TRAIT)
	if (kill_count)
		AddElement(/datum/element/mob_killed_tally, "mobs_killed_mining")
	var/static/list/vulnerable_projectiles
	if(!vulnerable_projectiles)
		vulnerable_projectiles = string_list(MINING_MOB_PROJECTILE_VULNERABILITY)
	add_ranged_armour(vulnerable_projectiles)
	if(crusher_loot)
		AddElement(\
			/datum/element/crusher_loot,\
			trophy_type = crusher_loot,\
			drop_mod = crusher_drop_chance,\
			drop_immediately = basic_mob_flags & DEL_ON_DEATH,\
		)
	RegisterSignal(src, COMSIG_ATOM_WAS_ATTACKED, PROC_REF(on_attacked))
	RegisterSignals(src, list(COMSIG_AI_BLACKBOARD_KEY_SET(BB_CURRENT_TARGET), COMSIG_AI_BLACKBOARD_KEY_CLEARED(BB_CURRENT_TARGET)), PROC_REF(on_aggro))
	// We add this to ensure that mobs will actually receive the above signal, as some will lack AI
	// handling for retaliation and attack special cases
	AddElement(/datum/element/relay_attackers)
	AddElement(/datum/element/ai_retaliate) //Used by priority behaviors

/mob/living/basic/mining/proc/on_aggro(atom/source)
	SIGNAL_HANDLER
	var/atom/new_target = source.ai_controller.blackboard[BB_CURRENT_TARGET]
	if(!new_target)
		return // we don't care there's nothing there
	if(!previous_target)
		previous_target = new_target
	else if (new_target != previous_target)
		previous_target = new_target
		UNLOCK_DO_ONCE(ai_controller, BB_AGGRO_SOUND)

/mob/living/basic/mining/Destroy()
	. = ..()
	UnregisterSignal(src, list(COMSIG_AI_BLACKBOARD_KEY_SET(BB_CURRENT_TARGET), COMSIG_AI_BLACKBOARD_KEY_CLEARED(BB_CURRENT_TARGET)))
	if(pain_channel)
		SSsounds.free_sound_channel(pain_channel)

/mob/living/basic/mining/proc/add_ranged_armour(list/vulnerable_projectiles)
	AddElement(\
		/datum/element/ranged_armour,\
		minimum_projectile_force = 30,\
		below_projectile_multiplier = 0.3,\
		vulnerable_projectile_types = vulnerable_projectiles,\
		minimum_thrown_force = 20,\
		throw_blocked_message = throw_blocked_message,\
	)

/mob/living/basic/mining/proc/on_attacked(datum/source, atom/attacker, attack_flags)
	SIGNAL_HANDLER
	if(attack_flags & ATTACKER_DAMAGING_ATTACK)
		if(pain_chance && prob(pain_chance))
			if(!pain_channel)
				pain_channel = SSsounds.reserve_sound_channel()
			playsound(src, pain_sound, 100, FALSE, channel = pain_channel) // todo: add channel specification to sound tokens, use them here
			if(pain_stun)
				Shake(2, 0, pain_stun, pain_stun * 0.5)
				Stun(pain_stun)
	if(!has_faction(FACTION_ASHWALKER) || !astype(attacker, /mob/living)?.has_faction(FACTION_ASHWALKER))
		return
	remove_faction(FACTION_ASHWALKER)


/datum/emote/living/mining
	mob_type_allowed_typecache = list(/mob/living/basic/mining)

/datum/emote/living/mining/aggro
	key = "aggro"
	key_third_person = "aggro"
	message = "screeches!"
	emote_type = EMOTE_AUDIBLE
	vary = FALSE
	use_sound_tokens = TRUE

/datum/emote/living/mining/aggro/get_sound(mob/living/basic/mining/user)
	return user.aggro_sound

/datum/emote/living/mining/idle
	key = "idle"
	key_third_person = "idle"
	message = "makes a noise."
	emote_type = EMOTE_AUDIBLE
	vary = FALSE
	use_sound_tokens = TRUE
	cooldown = 20 SECONDS

/datum/emote/living/mining/idle/get_sound(mob/living/basic/mining/user)
	return user.idle_sound
