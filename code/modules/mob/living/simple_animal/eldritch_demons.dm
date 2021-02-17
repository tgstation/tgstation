/mob/living/simple_animal/hostile/eldritch
	name = "Demon"
	real_name = "Demon"
	desc = ""
	gender = NEUTER
	mob_biotypes = NONE
	speak_emote = list("screams")
	response_help_continuous = "thinks better of touching"
	response_help_simple = "think better of touching"
	response_disarm_continuous = "flails at"
	response_disarm_simple = "flail at"
	response_harm_continuous = "reaps"
	response_harm_simple = "tears"
	speak_chance = 1
	icon = 'icons/mob/eldritch_mobs.dmi'
	speed = 0
	combat_mode = TRUE
	stop_automated_movement = 1
	AIStatus = AI_OFF
	attack_sound = 'sound/weapons/punch1.ogg'
	see_in_dark = 7
	lighting_alpha = LIGHTING_PLANE_ALPHA_MOSTLY_INVISIBLE
	damage_coeff = list(BRUTE = 1, BURN = 1, TOX = 0, CLONE = 0, STAMINA = 0, OXY = 0)
	atmos_requirements = list("min_oxy" = 0, "max_oxy" = 0, "min_tox" = 0, "max_tox" = 0, "min_co2" = 0, "max_co2" = 0, "min_n2" = 0, "max_n2" = 0)
	minbodytemp = 0
	maxbodytemp = INFINITY
	healable = 0
	movement_type = GROUND
	pressure_resistance = 100
	del_on_death = TRUE
	deathmessage = "implodes into itself"
	faction = list("heretics")
	simple_mob_flags = SILENCE_RANGED_MESSAGE
	///Innate spells that are supposed to be added when a beast is created
	var/list/spells_to_add

/mob/living/simple_animal/hostile/eldritch/Initialize()
	. = ..()
	add_spells()

/**
 * Add_spells
 *
 * Goes through spells_to_add and adds each spell to the mind.
 */
/mob/living/simple_animal/hostile/eldritch/proc/add_spells()
	for(var/spell in spells_to_add)
		AddSpell(new spell())

/mob/living/simple_animal/hostile/eldritch/raw_prophet
	name = "Raw Prophet"
	real_name = "Raw Prophet"
	desc = "Abomination made from severed limbs."
	icon_state = "raw_prophet"
	status_flags = CANPUSH
	icon_living = "raw_prophet"
	melee_damage_lower = 5
	melee_damage_upper = 10
	maxHealth = 50
	health = 50
	sight = SEE_MOBS|SEE_OBJS|SEE_TURFS
	spells_to_add = list(/obj/effect/proc_holder/spell/targeted/ethereal_jaunt/shift/ash/long,/obj/effect/proc_holder/spell/pointed/manse_link,/obj/effect/proc_holder/spell/targeted/telepathy/eldritch,/obj/effect/proc_holder/spell/pointed/trigger/blind/eldritch)

	var/list/linked_mobs = list()

/mob/living/simple_animal/hostile/eldritch/raw_prophet/Initialize()
	. = ..()
	link_mob(src)

/mob/living/simple_animal/hostile/eldritch/raw_prophet/Login()
	. = ..()
	client?.view_size.setTo(10)

/mob/living/simple_animal/hostile/eldritch/raw_prophet/proc/link_mob(mob/living/mob_linked)
	if(QDELETED(mob_linked) || mob_linked.stat == DEAD)
		return FALSE
	if(HAS_TRAIT(mob_linked, TRAIT_MINDSHIELD)) //mindshield implant, no dice
		return FALSE
	if(mob_linked.anti_magic_check(FALSE, FALSE, TRUE, 0))
		return FALSE
	if(linked_mobs[mob_linked])
		return FALSE

	to_chat(mob_linked, "<span class='notice'>You feel something new enter your sphere of mind, you hear whispers of people far away, screeches of horror and a huming of welcome to [src]'s Mansus Link.</span>")
	var/datum/action/innate/mansus_speech/action = new(src)
	linked_mobs[mob_linked] = action
	action.Grant(mob_linked)
	RegisterSignal(mob_linked, list(COMSIG_LIVING_DEATH, COMSIG_PARENT_QDELETING), .proc/unlink_mob)
	return TRUE

/mob/living/simple_animal/hostile/eldritch/raw_prophet/proc/unlink_mob(mob/living/mob_linked)
	SIGNAL_HANDLER

	if(!linked_mobs[mob_linked])
		return
	UnregisterSignal(mob_linked, list(COMSIG_LIVING_DEATH, COMSIG_PARENT_QDELETING))
	var/datum/action/innate/mansus_speech/action = linked_mobs[mob_linked]
	action.Remove(mob_linked)
	qdel(action)
	to_chat(mob_linked, "<span class='notice'>Your mind shatters as the [src]'s Mansus Link leaves your mind.</span>")
	INVOKE_ASYNC(mob_linked, /mob.proc/emote, "scream")
	//micro stun
	mob_linked.AdjustParalyzed(0.5 SECONDS)
	linked_mobs -= mob_linked

/mob/living/simple_animal/hostile/eldritch/raw_prophet/death(gibbed)
	for(var/linked_mob in linked_mobs)
		unlink_mob(linked_mob)
	return ..()

/mob/living/simple_animal/hostile/eldritch/armsy
	name = "Terror of the night"
	real_name = "Armsy"
	desc = "Abomination made from severed limbs."
	icon_state = "armsy_start"
	icon_living = "armsy_start"
	maxHealth = 200
	health = 200
	melee_damage_lower = 10
	melee_damage_upper = 15
	move_resist = MOVE_FORCE_OVERPOWERING+1
	movement_type = GROUND
	spells_to_add = list(/obj/effect/proc_holder/spell/targeted/worm_contract)
	ranged_cooldown_time = 5
	ranged = TRUE
	rapid = 1
	///Previous segment in the chain
	var/mob/living/simple_animal/hostile/eldritch/armsy/back
	///Next segment in the chain
	var/mob/living/simple_animal/hostile/eldritch/armsy/front
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

//I tried Initalize but it didnt work, like at all. This proc just wouldnt fire if it was Initalize instead of New
/mob/living/simple_animal/hostile/eldritch/armsy/Initialize(mapload,spawn_more = TRUE,len = 6)
	. = ..()
	if(len < 3)
		stack_trace("Eldritch Armsy created with invalid len ([len]). Reverting to 3.")
		len = 3 //code breaks below 3, let's just not allow it.
	oldloc = loc
	RegisterSignal(src,COMSIG_MOVABLE_MOVED,.proc/update_chain_links)
	if(!spawn_more)
		return
	allow_pulling = TRUE
	///sets the hp of the head to be exactly the length times hp, so the head is de facto the hardest to destroy.
	maxHealth = len * maxHealth
	health = maxHealth
	///previous link
	var/mob/living/simple_animal/hostile/eldritch/armsy/prev = src
	///current link
	var/mob/living/simple_animal/hostile/eldritch/armsy/current
	for(var/i in 1 to len)
		current = new type(drop_location(),FALSE)
		current.icon_state = "armsy_mid"
		current.icon_living = "armsy_mid"
		current.AIStatus = AI_OFF
		current.front = prev
		prev.back = current
		prev = current
	prev.icon_state = "armsy_end"
	prev.icon_living = "armsy_end"

/mob/living/simple_animal/hostile/eldritch/armsy/adjustBruteLoss(amount, updating_health, forced)
	if(back)
		back.adjustBruteLoss(amount, updating_health, forced)
	else
		return ..()

/mob/living/simple_animal/hostile/eldritch/armsy/adjustFireLoss(amount, updating_health, forced)
	if(back)
		back.adjustFireLoss(amount, updating_health, forced)
	else
		return ..()

//we are literally a vessel of otherworldly destruction, we bring our own gravity unto this plane
/mob/living/simple_animal/hostile/eldritch/armsy/has_gravity(turf/T)
	return TRUE


/mob/living/simple_animal/hostile/eldritch/armsy/can_be_pulled()
	return FALSE

///Updates chain links to force move onto a single tile
/mob/living/simple_animal/hostile/eldritch/armsy/proc/contract_next_chain_into_single_tile()
	if(back)
		back.forceMove(loc)
		back.contract_next_chain_into_single_tile()
	return

/mob/living/simple_animal/hostile/eldritch/armsy/proc/get_length()
	. += 1
	if(back)
		. += back.get_length()

///Updates the next mob in the chain to move to our last location, fixed the worm if somehow broken.
/mob/living/simple_animal/hostile/eldritch/armsy/proc/update_chain_links()
	if(!follow)
		return
	gib_trail()
	if(back && back.loc != oldloc)
		back.Move(oldloc)
	// self fixing properties if somehow broken
	if(front && loc != front.oldloc)
		forceMove(front.oldloc)
	oldloc = loc

/mob/living/simple_animal/hostile/eldritch/armsy/proc/gib_trail()
	if(front) // head makes gibs
		return
	var/chosen_decal = pick(typesof(/obj/effect/decal/cleanable/blood/tracks))
	var/obj/effect/decal/cleanable/blood/gibs/decal = new chosen_decal(drop_location())
	decal.setDir(dir)

/mob/living/simple_animal/hostile/eldritch/armsy/Destroy()
	if(front)
		front.icon_state = "armsy_end"
		front.icon_living = "armsy_end"
		front.back = null
	if(back)
		QDEL_NULL(back) // chain destruction baby
	return ..()

/mob/living/simple_animal/hostile/eldritch/armsy/proc/heal()
	if(back)
		back.heal()

	adjustBruteLoss(-maxHealth * 0.5, FALSE)
	adjustFireLoss(-maxHealth * 0.5 ,FALSE)

	if(health == maxHealth)
		current_stacks++
		if(current_stacks >= stacks_to_grow)
			var/mob/living/simple_animal/hostile/eldritch/armsy/prev = new type(drop_location(),spawn_more = FALSE)
			icon_state = "armsy_mid"
			icon_living =  "armsy_mid"
			back = prev
			prev.icon_state = "armsy_end"
			prev.icon_living = "armsy_end"
			prev.front = src
			prev.AIStatus = AI_OFF
			current_stacks = 0
			return

/mob/living/simple_animal/hostile/eldritch/armsy/Shoot(atom/targeted_atom)
	target = targeted_atom
	AttackingTarget()

/mob/living/simple_animal/hostile/eldritch/armsy/AttackingTarget()
	if(istype(target,/obj/item/bodypart/r_arm) || istype(target,/obj/item/bodypart/l_arm))
		qdel(target)
		heal()
		return
	if(target == back || target == front)
		return
	if(back)
		back.target = target
		back.AttackingTarget()
	if(!Adjacent(target))
		return
	do_attack_animation(target)
	//have fun
	if(istype(target,/turf/closed/wall))
		var/turf/closed/wall = target
		wall.ScrapeAway()

	if(iscarbon(target))
		var/mob/living/carbon/C = target
		if(HAS_TRAIT(C, TRAIT_NODISMEMBER))
			return
		var/list/parts = list()
		for(var/X in C.bodyparts)
			var/obj/item/bodypart/bodypart = X
			if(bodypart.body_part != HEAD && bodypart.body_part != CHEST && bodypart.body_part != LEG_LEFT && bodypart.body_part != LEG_RIGHT)
				if(bodypart.dismemberable)
					parts += bodypart
		if(length(parts) && prob(10))
			var/obj/item/bodypart/bodypart = pick(parts)
			bodypart.dismember()

	return ..()

/mob/living/simple_animal/hostile/eldritch/armsy/prime
	name = "Lord of the Night"
	real_name = "Master of Decay"
	maxHealth = 400
	health = 400
	melee_damage_lower = 30
	melee_damage_upper = 50

/mob/living/simple_animal/hostile/eldritch/armsy/prime/Initialize(mapload,spawn_more = TRUE,len = 9)
	. = ..()
	var/matrix/matrix_transformation = matrix()
	matrix_transformation.Scale(1.4,1.4)
	transform = matrix_transformation

/mob/living/simple_animal/hostile/eldritch/rust_spirit
	name = "Rust Walker"
	real_name = "Rusty"
	desc = "Incomprehensible abomination actively seeping life out of it's surrounding."
	icon_state = "rust_walker_s"
	status_flags = CANPUSH
	icon_living = "rust_walker_s"
	maxHealth = 75
	health = 75
	melee_damage_lower = 15
	melee_damage_upper = 20
	sight = SEE_TURFS
	spells_to_add = list(/obj/effect/proc_holder/spell/aoe_turf/rust_conversion/small,/obj/effect/proc_holder/spell/targeted/projectile/dumbfire/rust_wave/short)

/mob/living/simple_animal/hostile/eldritch/rust_spirit/setDir(newdir)
	. = ..()
	if(newdir == NORTH)
		icon_state = "rust_walker_n"
	else if(newdir == SOUTH)
		icon_state = "rust_walker_s"
	update_icon()

/mob/living/simple_animal/hostile/eldritch/rust_spirit/Moved()
	. = ..()
	playsound(src, 'sound/effects/footstep/rustystep1.ogg', 100, TRUE)

/mob/living/simple_animal/hostile/eldritch/rust_spirit/Life()
	if(stat == DEAD)
		return ..()
	var/turf/T = get_turf(src)
	if(istype(T,/turf/open/floor/plating/rust))
		adjustBruteLoss(-3, FALSE)
		adjustFireLoss(-3, FALSE)
	return ..()

/mob/living/simple_animal/hostile/eldritch/ash_spirit
	name = "Ash Man"
	real_name = "Ashy"
	desc = "Incomprehensible abomination actively seeping life out of it's surrounding."
	icon_state = "ash_walker"
	status_flags = CANPUSH
	icon_living = "ash_walker"
	maxHealth = 75
	health = 75
	melee_damage_lower = 15
	melee_damage_upper = 20
	sight = SEE_TURFS
	spells_to_add = list(/obj/effect/proc_holder/spell/targeted/ethereal_jaunt/shift/ash,/obj/effect/proc_holder/spell/pointed/cleave,/obj/effect/proc_holder/spell/targeted/fire_sworn)

/mob/living/simple_animal/hostile/eldritch/stalker
	name = "Flesh Stalker"
	real_name = "Flesh Stalker"
	desc = "Abomination made from severed limbs."
	icon_state = "stalker"
	status_flags = CANPUSH
	icon_living = "stalker"
	maxHealth = 150
	health = 150
	melee_damage_lower = 15
	melee_damage_upper = 20
	sight = SEE_MOBS
	spells_to_add = list(/obj/effect/proc_holder/spell/targeted/ethereal_jaunt/shift/ash,/obj/effect/proc_holder/spell/targeted/shapeshift/eldritch,/obj/effect/proc_holder/spell/targeted/emplosion/eldritch)
