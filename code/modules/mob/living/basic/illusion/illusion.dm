/// Pretty genericky mob that just manifests itself as any sort of input living mob, used in several ways
/// Has a basic AI that helps it attack targets that are assigned to it, but there's more flavor in the subtypes.
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
	RegisterSignal(src, COMSIG_HOSTILE_PRE_ATTACKINGTARGET, PROC_REF(on_preattack))
	RegisterSignal(src, COMSIG_MOB_AFTER_APPLY_DAMAGE, PROC_REF(on_damage_taken))

/mob/living/basic/illusion/examine(mob/user)
	var/mob/living/parent_mob = parent_mob_ref?.resolve()
	if(parent_mob)
		return parent_mob.examine(user)
	return ..()

/// Signal handler for when we attack something. Hook for replicating on standard behavior, with additional behavior on subtypes.
/mob/living/basic/illusion/proc/on_preattack(mob/living/source, atom/attacked_target)
	SIGNAL_HANDLER
	try_replicate()

/// Signal handler for when we are attacked.
/mob/living/basic/illusion/proc/on_damage_taken(mob/living/source)
	SIGNAL_HANDLER
	try_replicate()

/// Full setup for illusion mobs to lessen code duplication in the individual files.
/mob/living/basic/illusion/proc/full_setup(mob/living/original, mob/living/target_mob = null, list/faction = null, life = 5 SECONDS, hp = 100, damage = 0, replicate = 0)
	mock_as(original, life, hp, damage, replicate)
	set_faction(faction)
	set_target(target_mob)

/// Gives the illusion a target to focus on in whatever behavior it wants to engage as.
/mob/living/basic/illusion/proc/set_target(mob/living/target_mob)
	if(target_mob == null)
		return
	ai_controller.set_blackboard_key(target_key, target_mob)

/// Sets the faction of the illusion
/mob/living/basic/illusion/proc/set_faction(list/new_faction)
	if(!new_faction) // can be list with no length or null
		return
	faction = new_faction.Copy()

/// Does the actual work of setting up the illusion's appearance and some other functionality.
/mob/living/basic/illusion/proc/mock_as(mob/living/original, life, hp, damage, replicate)
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

/// See if we are able to replicate, and if so, do it.
/mob/living/basic/illusion/proc/try_replicate()
	if(prob(multiply_chance))
		replicate()

/// Actually perform the replication of this illusion.
/mob/living/basic/illusion/proc/replicate()
	var/mob/living/parent_mob = parent_mob_ref.resolve()
	if(QDELETED(parent_mob))
		return
	var/mob/living/basic/illusion/new_clone = new(loc)
	new_clone.full_setup(
		parent_mob,
		target_mob = ai_controller.blackboard[target_key],
		faction = faction,
		life = 8 SECONDS,
		hp = health / 2,
		damage = melee_damage_upper,
		replicate = multiply_chance / 2,
	)
