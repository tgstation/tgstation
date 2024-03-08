/mob/living/simple_animal/hostile/illusion
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

/mob/living/simple_animal/hostile/illusion/proc/Copy_Parent(mob/living/original, life = 5 SECONDS, hp = 100, damage = 0, replicate = 0)
	appearance = original.appearance
	parent_mob_ref = WEAKREF(original)
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

/mob/living/simple_animal/hostile/illusion/examine(mob/user)
	var/mob/living/parent_mob = parent_mob_ref?.resolve()
	if(parent_mob)
		return parent_mob.examine(user)
	return ..()

/mob/living/simple_animal/hostile/illusion/AttackingTarget()
	. = ..()
	if(!. || !isliving(target) || !prob(multiply_chance))
		return
	var/mob/living/hitting_target = target
	if(hitting_target.stat == DEAD)
		return
	var/mob/living/parent_mob = parent_mob_ref?.resolve()
	if(isnull(parent_mob))
		return
	var/mob/living/simple_animal/hostile/illusion/new_clone = new(loc)
	new_clone.Copy_Parent(parent_mob, 8 SECONDS, health / 2, melee_damage_upper, multiply_chance / 2)
	new_clone.faction = faction.Copy()
	new_clone.GiveTarget(target)

///////Actual Types/////////

/mob/living/simple_animal/hostile/illusion/escape
	retreat_distance = 10
	minimum_distance = 10
	melee_damage_lower = 0
	melee_damage_upper = 0
	speed = -1
	obj_damage = 0
	environment_smash = ENVIRONMENT_SMASH_NONE


/mob/living/simple_animal/hostile/illusion/escape/AttackingTarget()
	return FALSE

/mob/living/simple_animal/hostile/illusion/mirage
	AIStatus = AI_OFF
	density = FALSE

/mob/living/simple_animal/hostile/illusion/mirage/death(gibbed)
	do_sparks(rand(3, 6), FALSE, src)
	return ..()
