/mob/living/basic/illusion
	name = "illusion"
	desc = "It's a fake!"
	icon = 'icons/effects/effects.dmi'
	icon_state = "static"
	icon_living = "static"
	icon_dead = "null"
	gender = NEUTER
	mob_biotypes = NONE
	melee_damage_lower = 5
	melee_damage_upper = 5
	combat_mode = TRUE
	attack_verb_continuous = "gores"
	attack_verb_simple = "gore"
	maxHealth = 100
	health = 100
	speed = 0
	faction = list(FACTION_ILLUSION)
	basic_mob_flags = DEL_ON_DEATH
	death_message = "vanishes into thin air! It was a fake!"
	ai_controller = /datum/ai_controller/basic_controller/illusion
	/// Weakref to what we're copying
	var/datum/weakref/parent_mob_ref
	/// Prob of getting a clone on attack
	var/multiply_chance = 0
	/// The blackboard key we want to set for our target
	var/target_key = BB_BASIC_MOB_CURRENT_TARGET

/mob/living/basic/illusion/Initialize(mapload)
	. = ..()
	RegisterSignal(src, COMSIG_HOSTILE_PRE_ATTACKINGTARGET, PROC_REF(attack_override))
	RegisterSignal(src, COMSIG_LIVING_HEALTH_UPDATE, PROC_REF(on_health_changed))
	RegisterSignal(src, COMSIG_LIVING_DEATH, PROC_REF(on_death))

/mob/living/basic/illusion/examine(mob/user)
	var/mob/living/parent_mob = parent_mob_ref?.resolve()
	if(parent_mob)
		return parent_mob.examine(user)
	return ..()

/// Override the attack with custom behavior. Implemented on subtypes
/mob/living/basic/illusion/proc/attack_override(mob/living/source, atom/attacked_target)
	SIGNAL_HANDLER
	return

/// When our health changes, maybe replicate
/mob/living/basic/illusion/proc/on_health_changed(mob/living/source)
	SIGNAL_HANDLER
	if(multiply_chance <= 0)
		return

	replicate()

/// Send a small balloon alert on death since the death_message thing is a little lackluster
/mob/living/basic/illusion/proc/on_death(mob/living/source, gibbed)
	SIGNAL_HANDLER
	INVOKE_ASYNC(src, TYPE_PROC_REF(/mob/living/basic/illusion, send_death_message), get_turf(src))

/mob/living/basic/illusion/proc/send_death_message(turf/death_turf)
	balloon_alert_to_viewers(death_turf, "disappears!")

/// Gives the illusion a target to focus on. By default it's the attack key
/mob/living/basic/illusion/proc/set_target(mob/living/target_mob)
	ai_controller.set_blackboard_key(target_key, target_mob)

/// Does the actual work of setting up the illusion's appearance and some other functionality.
/mob/living/basic/illusion/proc/mock_as(mob/living/original, life = 5 SECONDS, hp = 100, damage = 0, replicate = 0)
	if(QDELETED(original))
		return

	parent_mob_ref = WEAKREF(original)
	appearance = original.appearance
	setDir(original.dir)

	maxHealth = hp
	updatehealth() // re-cap health to new value

	melee_damage_lower = damage
	melee_damage_upper = damage
	multiply_chance = replicate

	faction -= FACTION_NEUTRAL
	transform = initial(transform)
	pixel_x = base_pixel_x
	pixel_y = base_pixel_y

	addtimer(CALLBACK(src, TYPE_PROC_REF(/mob/living, death)), life)

/// Some illusions can replicate as they attack. Cool.
/mob/living/basic/illusion/proc/replicate()
	var/mob/living/parent_mob = parent_mob_ref.resolve()
	if(QDELETED(parent_mob))
		return
	var/mob/living/basic/illusion/new_clone = new(loc)
	new_clone.mock_as(parent_mob, 8 SECONDS, hp = health / 2, damage = melee_damage_upper, replicate = multiply_chance / 2)
	new_clone.faction = faction.Copy()
	new_clone.set_target(ai_controller.blackboard[target_key])

