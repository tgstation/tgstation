/mob/living/simple_animal/hostile/alien_larva
	name = "alien larva"
	real_name = "alien larva"
	icon_state = "larva0"
	pass_flags = PASSTABLE | PASSMOB
	mob_size = MOB_SIZE_SMALL
	density = FALSE
	melee_damage_lower = 1
	melee_damage_upper = 3
	maxHealth = 25
	health = 25

	default_num_legs = 1
	num_legs = 1 //Alien larvas always have a movable apendage.
	usable_legs = 1 //Alien larvas always have a movable apendage.

	///Amount of time spent alive already
	var/amount_grown = 0
	///Max amount you can grow
	var/max_grown = 100

//This is fine right now, if we're adding organ specific damage this needs to be updated
/mob/living/simple_animal/hostile/alien_larva/Initialize(mapload)

	AddAbility(new /obj/effect/proc_holder/alien/hide)
	AddAbility(new /obj/effect/proc_holder/alien/larva_evolve)
	apply_status_effect(/datum/status_effect/agent_pinpointer/xeno_queen)
	. = ..()

/mob/living/simple_animal/hostile/alien_larva/Life(delta_time = SSMOBS_DT, times_fired)
	if(notransform)
		return
	if(!..() || IS_IN_STASIS(src) || (amount_grown >= max_grown))
		return // We're dead, in stasis, or already grown.
	// GROW!
	amount_grown = min(amount_grown + (0.5 * delta_time), max_grown)
	update_icons()


/mob/living/simple_animal/hostile/alien_larva/update_stat()
	if(status_flags & GODMODE)
		return
	if(stat != DEAD)
		if(health<= -maxHealth || !getorgan(/obj/item/organ/brain))
			death()
			return
		if((HAS_TRAIT(src, TRAIT_KNOCKEDOUT)))
			set_stat(UNCONSCIOUS)
		else
			if(stat == UNCONSCIOUS)
				set_resting(FALSE)
			set_stat(CONSCIOUS)
	update_damage_hud()
	update_health_hud()

//This needs to be fixed
/mob/living/simple_animal/hostile/alien_larva/get_status_tab_items()
	. = ..()
	. += "Progress: [amount_grown]/[max_grown]"

/mob/living/simple_animal/hostile/alien_larva/Login()
	. = ..()
	if(!. || !client)
		return FALSE
	to_chat(src, "<b>You are an alien larva. Hide from danger until you can evolve.<br>Use say :a to communicate with the hivemind.</b>")

// new damage icon system
// now constructs damage icon for each organ from mask * damage field

/mob/living/simple_animal/hostile/alien_larva/start_pulling(atom/movable/AM, state, force = move_force, supress_message = FALSE)
	return

/mob/living/simple_animal/hostile/alien_larva/death(gibbed)
	if(stat == DEAD)
		return

	. = ..()
	update_icons()

/mob/living/simple_animal/hostile/alien_larva/spawn_gibs(with_bodyparts)
	if(with_bodyparts)
		new /obj/effect/gibspawner/larva(drop_location(), src)
	else
		new /obj/effect/gibspawner/larva/bodypartless(drop_location(), src)

/mob/living/simple_animal/hostile/alien_larva/gib_animation()
	new /obj/effect/temp_visual/gib_animation(loc, "gibbed-l")

/mob/living/simple_animal/hostile/alien_larva/spawn_dust()
	new /obj/effect/decal/remains/xeno(loc)

/mob/living/simple_animal/hostile/alien_larva/dust_animation()
	new /obj/effect/temp_visual/dust_animation(loc, "dust-l")
