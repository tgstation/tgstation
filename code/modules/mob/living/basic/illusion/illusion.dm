#define ATTACK_MODE_ATTACK "attack_mode"
#define ATTACK_MODE_SHOVE "shove_mode"

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
	del_on_death = TRUE
	death_message = "vanishes into thin air! It was a fake!"
	/// Weakref to what we're copying
	var/datum/weakref/parent_mob_ref
	/// Prob of getting a clone on attack
	var/multiply_chance = 0
	/// Decides how the clones attack people
	var/attack_mode = ATTACK_MODE_ATTACK

/mob/living/basic/illusion/Initialize(mapload)
	. = ..()
	RegisterSignal(src, COMSIG_HOSTILE_PRE_ATTACKINGTARGET, PROC_REF(check_mode))

/mob/living/basic/illusion/examine(mob/user)
	var/mob/living/parent_mob = parent_mob_ref?.resolve()
	if(parent_mob)
		return parent_mob.examine(user)
	return ..()

/// Called before trying to attack something
/mob/living/basic/illusion/proc/check_mode(mob/living/source, atom/attacked_target)
	SIGNAL_HANDLER
	if(attack_mode != ATTACK_MODE_SHOVE)
		return
	if(disarm(attacked_target))
		return COMPONENT_HOSTILE_NO_ATTACK

/mob/living/basic/illusion/proc/mock_as(mob/living/original, life = 5 SECONDS, hp = 100, damage = 0, replicate = 0, attack_mode = ATTACK_MODE_ATTACK)
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

	src.attack_mode = attack_mode
	addtimer(CALLBACK(src, TYPE_PROC_REF(/mob/living, death)), life)

/mob/living/basic/illusion/proc/replicate()
	var/mob/living/basic/illusion/new_clone = new(loc)
	new_clone.mock_as(parent_mob, 8 SECONDS, health / 2, melee_damage_upper, multiply_chance / 2)
	new_clone.faction = faction.Copy()
	new_clone.GiveTarget(target)

///////Actual Types/////////


#undef ATTACK_MODE_ATTACK
#undef ATTACK_MODE_SHOVE
