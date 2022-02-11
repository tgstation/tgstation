/mob/living/simple_animal/hostile/heretic_summon
	name = "Eldritch Demon"
	real_name = "Eldritch Demon"
	desc = "A horror from beyond this realm."
	icon = 'icons/mob/eldritch_mobs.dmi'
	gender = NEUTER
	mob_biotypes = NONE
	attack_sound = 'sound/weapons/punch1.ogg'
	response_help_continuous = "thinks better of touching"
	response_help_simple = "think better of touching"
	response_disarm_continuous = "flails at"
	response_disarm_simple = "flail at"
	response_harm_continuous = "reaps"
	response_harm_simple = "tears"
	speak_emote = list("screams")
	speak_chance = 1
	speed = 0
	combat_mode = TRUE
	stop_automated_movement = TRUE
	AIStatus = AI_OFF
	see_in_dark = 7
	lighting_alpha = LIGHTING_PLANE_ALPHA_MOSTLY_INVISIBLE
	damage_coeff = list(BRUTE = 1, BURN = 1, TOX = 0, CLONE = 0, STAMINA = 0, OXY = 0)
	atmos_requirements = list("min_oxy" = 0, "max_oxy" = 0, "min_plas" = 0, "max_plas" = 0, "min_co2" = 0, "max_co2" = 0, "min_n2" = 0, "max_n2" = 0)
	minbodytemp = 0
	maxbodytemp = INFINITY
	healable = FALSE
	movement_type = GROUND
	pressure_resistance = 100
	del_on_death = TRUE
	deathmessage = "implodes into itself."
	faction = list(FACTION_HERETIC)
	simple_mob_flags = SILENCE_RANGED_MESSAGE
	/// Innate spells that are added when a beast is created.
	var/list/spells_to_add

/mob/living/simple_animal/hostile/heretic_summon/Initialize(mapload)
	. = ..()
	add_spells()

/**
 * Add_spells
 *
 * Goes through spells_to_add and adds each spell to the mind.
 */
/mob/living/simple_animal/hostile/heretic_summon/proc/add_spells()
	for(var/spell in spells_to_add)
		AddSpell(new spell())

/mob/living/simple_animal/hostile/heretic_summon/raw_prophet
	name = "Raw Prophet"
	real_name = "Raw Prophet"
	desc = "An abomination stitched together from a few severed arms and one lost eye."
	icon_state = "raw_prophet"
	icon_living = "raw_prophet"
	status_flags = CANPUSH
	melee_damage_lower = 5
	melee_damage_upper = 10
	maxHealth = 50
	health = 50
	sight = SEE_MOBS|SEE_OBJS|SEE_TURFS
	spells_to_add = list(
		/obj/effect/proc_holder/spell/targeted/ethereal_jaunt/shift/ash/long,
		/obj/effect/proc_holder/spell/targeted/telepathy/eldritch,
		/obj/effect/proc_holder/spell/pointed/trigger/blind/eldritch,
	)

/mob/living/simple_animal/hostile/heretic_summon/raw_prophet/Initialize(mapload)
	. = ..()
	var/on_link_message = "You feel something new enter your sphere of mind... \
		You hear whispers of people far away, screeches of horror and a huming of welcome to [src]'s Mansus Link."

	var/on_unlink_message = "Your mind shatters as [src]'s Mansus Link leaves your mind."

	AddComponent(/datum/component/mind_linker, \
		network_name = "Mansus Link", \
		chat_color = "#568b00", \
		linker_action_path = /datum/action/cooldown/manse_link, \
		link_message = on_link_message, \
		unlink_message = on_unlink_message, \
		post_unlink_callback = CALLBACK(src, .proc/after_unlink), \
		speech_action_background_icon_state = "bg_ecult", \
	)

/mob/living/simple_animal/hostile/heretic_summon/raw_prophet/Login()
	. = ..()
	client?.view_size.setTo(10)

/*
 * Callback for the mind_linker component.
 * Stuns people who are ejected from the network.
 */
/mob/living/simple_animal/hostile/heretic_summon/raw_prophet/proc/after_unlink(mob/living/unlinked_mob)
	if(QDELETED(unlinked_mob) || unlinked_mob.stat == DEAD)
		return

	INVOKE_ASYNC(unlinked_mob, /mob.proc/emote, "scream")
	unlinked_mob.AdjustParalyzed(0.5 SECONDS) //micro stun

// What if we took a linked list... But made it a mob?
/// The "Terror of the Night" / Armsy, a large worm made of multiple bodyparts that occupies multiple tiles
/mob/living/simple_animal/hostile/heretic_summon/armsy
	name = "Terror of the night"
	real_name = "Armsy"
	desc = "An abomination made from dozens and dozens of severed and malformed limbs piled onto each other."
	icon_state = "armsy_start"
	icon_living = "armsy_start"
	maxHealth = 200
	health = 200
	melee_damage_lower = 10
	melee_damage_upper = 15
	move_force = MOVE_FORCE_OVERPOWERING
	move_resist = MOVE_FORCE_OVERPOWERING
	pull_force = MOVE_FORCE_OVERPOWERING
	movement_type = GROUND
	mob_size = MOB_SIZE_HUGE
	sentience_type = SENTIENCE_BOSS
	environment_smash = ENVIRONMENT_SMASH_RWALLS
	mob_biotypes = MOB_ORGANIC|MOB_EPIC
	obj_damage = 200
	ranged_cooldown_time = 5
	ranged = TRUE
	rapid = 1
	spells_to_add = list(/obj/effect/proc_holder/spell/targeted/worm_contract)
	///Previous segment in the chain
	var/mob/living/simple_animal/hostile/heretic_summon/armsy/back
	///Next segment in the chain
	var/mob/living/simple_animal/hostile/heretic_summon/armsy/front
	///Your old location
	var/oldloc
	///Allow / disallow pulling
	var/allow_pulling = FALSE
	///How many arms do we have to eat to expand?
	var/stacks_to_grow = 5
	///Currently eaten arms
	var/current_stacks = 0
	///Does this follow other pieces?
	var/follow = TRUE

/*
 * Arguments
 * * spawn_bodyparts - whether we spawn additional armsy bodies until we reach length.
 * * worm_length - the length of the worm we're creating. Below 3 doesn't work very well.
 */
/mob/living/simple_animal/hostile/heretic_summon/armsy/Initialize(mapload, spawn_bodyparts = TRUE, worm_length = 6)
	. = ..()
	if(worm_length < 3)
		stack_trace("[type] created with invalid len ([worm_length]). Reverting to 3.")
		worm_length = 3 //code breaks below 3, let's just not allow it.

	oldloc = loc
	RegisterSignal(src, COMSIG_MOVABLE_MOVED, .proc/update_chain_links)
	if(!spawn_bodyparts)
		return

	allow_pulling = TRUE
	// Sets the hp of the head to be exactly the (length * hp), so the head is de facto the hardest to destroy.
	maxHealth = worm_length * maxHealth
	health = maxHealth

	// The previous link in the chain
	var/mob/living/simple_animal/hostile/heretic_summon/armsy/prev = src
	// The current link in the chain
	var/mob/living/simple_animal/hostile/heretic_summon/armsy/current

	for(var/i in 1 to worm_length)
		current = new type(drop_location(), FALSE)
		current.icon_state = "armsy_mid"
		current.icon_living = "armsy_mid"
		current.AIStatus = AI_OFF
		current.front = prev
		prev.back = current
		prev = current

	prev.icon_state = "armsy_end"
	prev.icon_living = "armsy_end"

/mob/living/simple_animal/hostile/heretic_summon/armsy/adjustBruteLoss(amount, updating_health, forced)
	if(back)
		return back.adjustBruteLoss(amount, updating_health, forced)

	return ..()

/mob/living/simple_animal/hostile/heretic_summon/armsy/adjustFireLoss(amount, updating_health, forced)
	if(back)
		return back.adjustFireLoss(amount, updating_health, forced)

	return ..()

// We are literally a vessel of otherworldly destruction, we bring our own gravity unto this plane
/mob/living/simple_animal/hostile/heretic_summon/armsy/has_gravity(turf/T)
	return TRUE

/mob/living/simple_animal/hostile/heretic_summon/armsy/can_be_pulled()
	return FALSE

/// Updates every body in the chain to force move onto a single tile.
/mob/living/simple_animal/hostile/heretic_summon/armsy/proc/contract_next_chain_into_single_tile()
	if(!back)
		return

	back.forceMove(loc)
	back.contract_next_chain_into_single_tile()

/*
 * Recursively get the length of our chain.
 */
/mob/living/simple_animal/hostile/heretic_summon/armsy/proc/get_length()
	. = 1
	if(back)
		. += back.get_length()

/// Updates the next mob in the chain to move to our last location. Fixes the chain if somehow broken.
/mob/living/simple_animal/hostile/heretic_summon/armsy/proc/update_chain_links()
	SIGNAL_HANDLER

	if(!follow)
		return

	gib_trail()
	if(back && back.loc != oldloc)
		back.Move(oldloc)

	// self fixing properties if somehow broken
	if(front && loc != front.oldloc)
		forceMove(front.oldloc)

	oldloc = loc

/// Creates a tail of blood / gibs as we move.
/mob/living/simple_animal/hostile/heretic_summon/armsy/proc/gib_trail()
	if(front) // head makes gibs
		return
	var/chosen_decal = pick(typesof(/obj/effect/decal/cleanable/blood/tracks))
	var/obj/effect/decal/cleanable/blood/gibs/decal = new chosen_decal(drop_location())
	decal.setDir(dir)

/mob/living/simple_animal/hostile/heretic_summon/armsy/Destroy()
	if(front)
		front.icon_state = "armsy_end"
		front.icon_living = "armsy_end"
		front.back = null
	if(back)
		QDEL_NULL(back) // chain destruction baby
	return ..()

/*
 * Handle healing our chain.
 *
 * Eating arms off the ground heals us,
 * and if we eat enough arms while above
 * a certain health threshold,  we even gain back parts!
 */
/mob/living/simple_animal/hostile/heretic_summon/armsy/proc/heal()
	if(back)
		back.heal()
		return

	adjustBruteLoss(-maxHealth * 0.5, FALSE)
	adjustFireLoss(-maxHealth * 0.5, FALSE)

	if(health < maxHealth * 0.8)
		return

	if(++current_stacks < stacks_to_grow)
		return

	var/mob/living/simple_animal/hostile/heretic_summon/armsy/prev = new type(drop_location(), FALSE)
	icon_state = "armsy_mid"
	icon_living = "armsy_mid"
	back = prev
	prev.icon_state = "armsy_end"
	prev.icon_living = "armsy_end"
	prev.front = src
	prev.AIStatus = AI_OFF
	current_stacks = 0

/mob/living/simple_animal/hostile/heretic_summon/armsy/Shoot(atom/targeted_atom)
	GiveTarget(targeted_atom)
	AttackingTarget()

/mob/living/simple_animal/hostile/heretic_summon/armsy/AttackingTarget()
	if(istype(target, /obj/item/bodypart/r_arm) || istype(target, /obj/item/bodypart/l_arm))
		playsound(src, 'sound/magic/demon_consume.ogg', 50, TRUE)
		qdel(target)
		heal()
		return
	if(target == back || target == front)
		return
	if(back)
		back.GiveTarget(target)
		back.AttackingTarget()
	if(!Adjacent(target))
		return
	do_attack_animation(target)

	if(iscarbon(target))
		var/mob/living/carbon/carbon_target = target
		if(HAS_TRAIT(carbon_target, TRAIT_NODISMEMBER))
			return
		var/list/parts_to_remove = list()
		for(var/obj/item/bodypart/bodypart in carbon_target.bodyparts)
			if(bodypart.body_part != HEAD && bodypart.body_part != CHEST && bodypart.body_part != LEG_LEFT && bodypart.body_part != LEG_RIGHT)
				if(bodypart.dismemberable)
					parts_to_remove += bodypart

		if(parts_to_remove.len && prob(10))
			var/obj/item/bodypart/lost_arm = pick(parts_to_remove)
			lost_arm.dismember()

	return ..()

/mob/living/simple_animal/hostile/heretic_summon/armsy/prime
	name = "Lord of the Night"
	real_name = "Master of Decay"
	maxHealth = 400
	health = 400
	melee_damage_lower = 30
	melee_damage_upper = 50

/mob/living/simple_animal/hostile/heretic_summon/armsy/prime/Initialize(mapload, spawn_bodyparts = TRUE, worm_length = 9)
	. = ..()
	var/matrix/matrix_transformation = matrix()
	matrix_transformation.Scale(1.4, 1.4)
	transform = matrix_transformation

/mob/living/simple_animal/hostile/heretic_summon/rust_spirit
	name = "Rust Walker"
	real_name = "Rusty"
	desc = "An incomprehensible abomination. Everywhere it steps, it appears to be actively seeping life out of its surroundings."
	icon_state = "rust_walker_s"
	icon_living = "rust_walker_s"
	status_flags = CANPUSH
	maxHealth = 75
	health = 75
	melee_damage_lower = 15
	melee_damage_upper = 20
	sight = SEE_TURFS
	spells_to_add = list(
		/obj/effect/proc_holder/spell/aoe_turf/rust_conversion/small,
		/obj/effect/proc_holder/spell/targeted/projectile/dumbfire/rust_wave/short,
	)

/mob/living/simple_animal/hostile/heretic_summon/rust_spirit/setDir(newdir)
	. = ..()
	if(newdir == NORTH)
		icon_state = "rust_walker_n"
	else if(newdir == SOUTH)
		icon_state = "rust_walker_s"
	update_appearance(UPDATE_ICON_STATE)

/mob/living/simple_animal/hostile/heretic_summon/rust_spirit/Moved()
	. = ..()
	playsound(src, 'sound/effects/footstep/rustystep1.ogg', 100, TRUE)

/mob/living/simple_animal/hostile/heretic_summon/rust_spirit/Life(delta_time = SSMOBS_DT, times_fired)
	if(stat == DEAD)
		return ..()

	var/turf/our_turf = get_turf(src)
	if(HAS_TRAIT(our_turf, TRAIT_RUSTY))
		adjustBruteLoss(-1.5 * delta_time, FALSE)
		adjustFireLoss(-1.5 * delta_time, FALSE)

	return ..()

/mob/living/simple_animal/hostile/heretic_summon/ash_spirit
	name = "Ash Man"
	real_name = "Ashy"
	desc = "An incomprehensible abomination. As it moves, a thin trail of ash follows, appearing from seemingly nowhere."
	icon_state = "ash_walker"
	icon_living = "ash_walker"
	status_flags = CANPUSH
	maxHealth = 75
	health = 75
	melee_damage_lower = 15
	melee_damage_upper = 20
	sight = SEE_TURFS
	spells_to_add = list(
		/obj/effect/proc_holder/spell/targeted/ethereal_jaunt/shift/ash,
		/obj/effect/proc_holder/spell/pointed/cleave,
		/obj/effect/proc_holder/spell/targeted/fire_sworn,
	)

/mob/living/simple_animal/hostile/heretic_summon/stalker
	name = "Flesh Stalker"
	real_name = "Flesh Stalker"
	desc = "An abomination made from several limbs and organs. Every moment you stare at it, it appears to shift and change unnaturally."
	icon_state = "stalker"
	icon_living = "stalker"
	status_flags = CANPUSH
	maxHealth = 150
	health = 150
	melee_damage_lower = 15
	melee_damage_upper = 20
	sight = SEE_MOBS
	spells_to_add = list(
		/obj/effect/proc_holder/spell/targeted/ethereal_jaunt/shift/ash,
		/obj/effect/proc_holder/spell/targeted/shapeshift/eldritch,
		/obj/effect/proc_holder/spell/targeted/emplosion/eldritch,
	)
