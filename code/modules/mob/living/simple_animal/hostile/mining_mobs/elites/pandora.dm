#define SINGULAR_SHOT 1
#define MAGIC_BOX 2
#define PANDORA_TELEPORT 3
#define AOE_SQUARES 4

/**
 * # Pandora
 *
 * A box with a similar design to the Hierophant which trades large, single attacks for more frequent smaller ones.
 * As its health gets lower, the time between its attacks decrease.
 * Its attacks are as follows:
 * - Fires hierophant blasts in a straight line.  Can only fire in a straight line in 8 directions, being the diagonals and cardinals.
 * - Creates a box of hierophant blasts around the target.  If they try to run away to avoid it, they'll very likely get hit.
 * - Teleports the pandora from one location to another, almost identical to Hierophant.
 * - Spawns a 7x7 AOE at the location of choice, spreading out from the center.
 * Pandora's fight mirrors Hierophant's closely, but has stark differences in attack effects.  Instead of long-winded dodge times and long cooldowns, Pandora constantly attacks the opponent, but leaves itself open for attack.
 */

/mob/living/simple_animal/hostile/asteroid/elite/pandora
	name = "pandora"
	desc = "A large magic box with similar power and design to the Hierophant.  Once it opens, it's not easy to close it."
	icon_state = "pandora"
	icon_living = "pandora"
	icon_aggro = "pandora"
	icon_dead = "pandora_dead"
	icon_gib = "syndicate_gib"
	health_doll_icon = "pandora"
	maxHealth = 1000
	health = 1000
	melee_damage_lower = 15
	melee_damage_upper = 15
	attack_verb_continuous = "smashes into the side of"
	attack_verb_simple = "smash into the side of"
	attack_sound = 'sound/items/weapons/sonic_jackhammer.ogg'
	throw_message = "merely dinks off of the"
	speed = 3
	move_to_delay = 10
	mouse_opacity = MOUSE_OPACITY_ICON
	mob_biotypes = MOB_ROBOTIC|MOB_MINING
	death_sound = 'sound/effects/magic/repulse.ogg'
	death_message = "'s lights flicker, before its top part falls down."
	loot_drop = /obj/item/clothing/accessory/pandora_hope

	attack_action_types = list(/datum/action/innate/elite_attack/singular_shot,
								/datum/action/innate/elite_attack/magic_box,
								/datum/action/innate/elite_attack/pandora_teleport,
								/datum/action/innate/elite_attack/aoe_squares)

	var/sing_shot_length = 8
	var/cooldown_time = 2 SECONDS

/datum/action/innate/elite_attack/singular_shot
	name = "Singular Shot"
	button_icon_state = "singular_shot"
	chosen_message = span_boldwarning("You are now creating a single linear magic square.")
	chosen_attack_num = SINGULAR_SHOT

/datum/action/innate/elite_attack/magic_box
	name = "Magic Box"
	button_icon_state = "magic_box"
	chosen_message = span_boldwarning("You are now attacking with a box of magic squares.")
	chosen_attack_num = MAGIC_BOX

/datum/action/innate/elite_attack/pandora_teleport
	name = "Line Teleport"
	button_icon_state = "pandora_teleport"
	chosen_message = span_boldwarning("You will now teleport to your target.")
	chosen_attack_num = PANDORA_TELEPORT

/datum/action/innate/elite_attack/aoe_squares
	name = "AOE Blast"
	button_icon_state = "aoe_squares"
	chosen_message = span_boldwarning("Your attacks will spawn an AOE blast at your target location.")
	chosen_attack_num = AOE_SQUARES

/mob/living/simple_animal/hostile/asteroid/elite/pandora/OpenFire()
	if(client)
		switch(chosen_attack)
			if(SINGULAR_SHOT)
				singular_shot(target)
			if(MAGIC_BOX)
				magic_box(target)
			if(PANDORA_TELEPORT)
				pandora_teleport(target)
			if(AOE_SQUARES)
				aoe_squares(target)
		return
	var/aiattack = rand(1,4)
	switch(aiattack)
		if(SINGULAR_SHOT)
			singular_shot(target)
		if(MAGIC_BOX)
			magic_box(target)
		if(PANDORA_TELEPORT)
			pandora_teleport(target)
		if(AOE_SQUARES)
			aoe_squares(target)

/mob/living/simple_animal/hostile/asteroid/elite/pandora/Life(seconds_per_tick = SSMOBS_DT, times_fired)
	. = ..()
	if(health >= maxHealth * 0.5)
		cooldown_time = 2 SECONDS
		return
	if(health < maxHealth * 0.5 && health > maxHealth * 0.25)
		cooldown_time = 1.5 SECONDS
		return
	else
		cooldown_time = 1 SECONDS

/mob/living/simple_animal/hostile/asteroid/elite/pandora/proc/singular_shot(target)
	ranged_cooldown = world.time + (cooldown_time * 0.5)
	var/dir_to_target = get_dir(get_turf(src), get_turf(target))
	var/turf/T = get_step(get_turf(src), dir_to_target)
	singular_shot_line(sing_shot_length, dir_to_target, T)

/mob/living/simple_animal/hostile/asteroid/elite/pandora/proc/singular_shot_line(procsleft, angleused, turf/T)
	if(procsleft <= 0)
		return
	new /obj/effect/temp_visual/hierophant/blast/damaging/pandora(T, src)
	T = get_step(T, angleused)
	procsleft = procsleft - 1
	addtimer(CALLBACK(src, PROC_REF(singular_shot_line), procsleft, angleused, T), cooldown_time * 0.1)

/mob/living/simple_animal/hostile/asteroid/elite/pandora/proc/magic_box(target)
	ranged_cooldown = world.time + cooldown_time
	var/turf/T = get_turf(target)
	for(var/t in spiral_range_turfs(3, T))
		if(get_dist(t, T) > 1)
			new /obj/effect/temp_visual/hierophant/blast/damaging/pandora(t, src)

/mob/living/simple_animal/hostile/asteroid/elite/pandora/proc/pandora_teleport(target)
	var/turf/turf_target = get_turf(target)
	if(!(turf_target in view(12, src)))
		return
	ranged_cooldown = world.time + (cooldown_time * 2)
	var/turf/source = get_turf(src)
	new /obj/effect/temp_visual/hierophant/telegraph(turf_target, src)
	new /obj/effect/temp_visual/hierophant/telegraph(source, src)
	playsound(source,'sound/machines/airlock/airlockopen.ogg', 200, 1)
	addtimer(CALLBACK(src, PROC_REF(pandora_teleport_2), turf_target, source), 0.2 SECONDS)

/mob/living/simple_animal/hostile/asteroid/elite/pandora/proc/pandora_teleport_2(turf/T, turf/source)
	new /obj/effect/temp_visual/hierophant/telegraph/teleport(T, src)
	new /obj/effect/temp_visual/hierophant/telegraph/teleport(source, src)
	for(var/t in RANGE_TURFS(1, T))
		new /obj/effect/temp_visual/hierophant/blast/damaging/pandora(t, src)
	for(var/t in RANGE_TURFS(1, source))
		new /obj/effect/temp_visual/hierophant/blast/damaging/pandora(t, src)
	animate(src, alpha = 0, time = 2, easing = SINE_EASING|EASE_OUT) //fade out
	visible_message(span_hierophant_warning("[src] fades out!"))
	ADD_TRAIT(src, TRAIT_UNDENSE, VANISHING_TRAIT)
	addtimer(CALLBACK(src, PROC_REF(pandora_teleport_3), T), 0.2 SECONDS)

/mob/living/simple_animal/hostile/asteroid/elite/pandora/proc/pandora_teleport_3(turf/T)
	forceMove(T)
	animate(src, alpha = 255, time = 2, easing = CIRCULAR_EASING|EASE_IN) //fade IN
	REMOVE_TRAIT(src, TRAIT_UNDENSE, VANISHING_TRAIT)
	visible_message(span_hierophant_warning("[src] fades in!"))

/mob/living/simple_animal/hostile/asteroid/elite/pandora/proc/aoe_squares(target)
	ranged_cooldown = world.time + cooldown_time
	var/turf/T = get_turf(target)
	new /obj/effect/temp_visual/hierophant/blast/damaging/pandora(T, src)
	var/max_size = 3
	addtimer(CALLBACK(src, PROC_REF(aoe_squares_2), T, 0, max_size), 0.2 SECONDS)

/mob/living/simple_animal/hostile/asteroid/elite/pandora/proc/aoe_squares_2(turf/T, ring, max_size)
	if(ring > max_size)
		return
	for(var/t in spiral_range_turfs(ring, T))
		if(get_dist(t, T) == ring)
			new /obj/effect/temp_visual/hierophant/blast/damaging/pandora(t, src)
	addtimer(CALLBACK(src, PROC_REF(aoe_squares_2), T, (ring + 1), max_size), cooldown_time * 0.1)

//The specific version of hiero's squares pandora uses
/obj/effect/temp_visual/hierophant/blast/damaging/pandora
	damage = 30
	monster_damage_boost = FALSE

//Pandora's loot: Hope
/obj/item/clothing/accessory/pandora_hope
	name = "Hope"
	desc = "Found at the bottom of Pandora. After all the evil was released, this was the only thing left inside."
	icon = 'icons/obj/mining_zones/elite_trophies.dmi'
	icon_state = "hope"
	resistance_flags = FIRE_PROOF

/obj/item/clothing/accessory/pandora_hope/accessory_equipped(obj/item/clothing/under/clothes, mob/living/user)
	user.add_mood_event("hope_lavaland", /datum/mood_event/hope_lavaland)

/obj/item/clothing/accessory/pandora_hope/accessory_dropped(obj/item/clothing/under/clothes, mob/living/user)
	user.clear_mood_event("hope_lavaland")

#undef SINGULAR_SHOT
#undef MAGIC_BOX
#undef PANDORA_TELEPORT
#undef AOE_SQUARES
