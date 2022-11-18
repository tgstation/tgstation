/mob/living/basic/mouse
	name = "mouse"
	desc = "This cute little guy just loves the taste of uninsulated electrical cables. Isn't he adorable?"
	icon_state = "mouse_gray"
	icon_living = "mouse_gray"
	icon_dead = "mouse_gray_dead"
	held_state = "mouse_gray"

	maxHealth = 5
	health = 5
	see_in_dark = 6
	density = FALSE
	pass_flags = PASSTABLE|PASSGRILLE|PASSMOB
	mob_size = MOB_SIZE_TINY
	can_be_held = TRUE
	held_w_class = WEIGHT_CLASS_TINY
	mob_biotypes = MOB_ORGANIC|MOB_BEAST
	gold_core_spawnable = FRIENDLY_SPAWN
	faction = list(FACTION_RAT)
	butcher_results = list(/obj/item/food/meat/slab/mouse = 1)

	speak_emote = list("squeaks")
	response_help_continuous = "pets"
	response_help_simple = "pet"
	response_disarm_continuous = "gently pushes aside"
	response_disarm_simple = "gently push aside"
	response_harm_continuous = "splats"
	response_harm_simple = "splat"

	ai_controller = /datum/ai_controller/basic_controller/mouse

	/// What color our mouse is. Brown, gray and white - leave blank for random.
	var/body_color
	/// Does this mouse contribute to the ratcap?
	var/contributes_to_ratcap = TRUE
	/// Probability that, if we successfully bite a shocked cable, that we will die to it.
	var/cable_zap_prob = 85

/mob/living/basic/mouse/Initialize(mapload)
	. = ..()
	if(contributes_to_ratcap)
		SSmobs.cheeserats |= src
	ADD_TRAIT(src, TRAIT_VENTCRAWLER_ALWAYS, INNATE_TRAIT)

	if(isnull(body_color))
		body_color = pick("brown", "gray", "white")
		held_state = "mouse_[body_color]" // not handled by variety element
		AddElement(/datum/element/animal_variety, "mouse", body_color, FALSE)
	AddElement(/datum/element/swabable, CELL_LINE_TABLE_MOUSE, CELL_VIRUS_TABLE_GENERIC_MOB, 1, 10)
	AddComponent(/datum/component/squeak, list('sound/effects/mousesqueek.ogg' = 1), 100, extrarange = SHORT_RANGE_SOUND_EXTRARANGE) //as quiet as a mouse or whatever

	var/static/list/loc_connections = list(
		COMSIG_ATOM_ENTERED = .proc/on_entered,
	)
	AddElement(/datum/element/connect_loc, loc_connections)

/mob/living/basic/mouse/Destroy()
	SSmobs.cheeserats -= src
	return ..()

/mob/living/basic/mouse/examine(mob/user)
	. = ..()

	var/sameside = user.faction_check_mob(src, exact_match = TRUE)
	if(isregalrat(user))
		if(sameside)
			. += span_notice("This rat serves under you.")
		else
			. += span_warning("This peasant serves a different king! Strike [p_them()] down!")

	else if(user != src && ismouse(user))
		if(sameside)
			. += span_notice("You both serve the same king.")
		else
			. += span_warning("This fool serves a different king!")

/// Kills the rat and changes its icon state to be splatted (bloody).
/mob/living/basic/mouse/proc/splat()
	icon_dead = "mouse_[body_color]_splat"
	adjust_health(-maxHealth)

// On revival, re-add the mouse to the ratcap, or block it if we're at it
/mob/living/basic/mouse/revive(full_heal = FALSE, admin_revive = FALSE)
	if(!contributes_to_ratcap)
		return ..()

	var/cap = CONFIG_GET(number/ratcap)
	if(!admin_revive && !ckey && length(SSmobs.cheeserats) >= cap)
		visible_message(span_warning("[src] twitches, but does not continue moving \
			due to the overwhelming rodent population on the station!"))
		return

	. = ..()
	if(stat != DEAD)
		SSmobs.cheeserats |= src

// On death, remove the mouse from the ratcap, and turn it into an item if applicable
/mob/living/basic/mouse/death(gibbed)
	SSmobs.cheeserats -= src
	// Rats with a mind will not turn into a lizard snack on death
	if(mind)
		return ..()

	// Call parent with gibbed = TRUE, becuase we're getting rid of the body
	. = ..(TRUE)
	// Now if we were't ACTUALLY gibbed, spawn the dead mouse
	if(!gibbed)
		var/obj/item/food/deadmouse/mouse = new(loc)
		mouse.name = name
		mouse.icon_state = icon_dead
		if(HAS_TRAIT(src, TRAIT_BEING_SHOCKED))
			mouse.desc = "They're toast."
			mouse.add_atom_colour("#3A3A3A", FIXED_COLOUR_PRIORITY)
	qdel(src)

/mob/living/basic/mouse/UnarmedAttack(atom/attack_target, proximity_flag, list/modifiers)
	. = ..()
	if(!.)
		return

	if(!proximity_flag)
		return

	if(istype(attack_target, /obj/item/food/cheese))
		try_consume_cheese(attack_target)
		return TRUE

	if(istype(attack_target, /obj/structure/cable))
		try_bite_cable(attack_target)
		return TRUE

/// Signal proc for [COMSIG_ATOM_ENTERED]. Sends a lil' squeak to chat when someone walks over us.
/mob/living/basic/mouse/proc/on_entered(datum/source, atom/movable/entered)
	SIGNAL_HANDLER

	if(ishuman(entered) && stat == CONSCIOUS)
		to_chat(entered, span_notice("[icon2html(src, entered)] Squeak!"))

/// Attempts to consume a piece of cheese, causing a few effects.
/mob/living/basic/mouse/proc/try_consume_cheese(obj/item/food/cheese/cheese)
	// Royal cheese will evolve us into a regal rat
	if(istype(cheese, /obj/item/food/cheese/royal))
		visible_message(
			span_warning("[src] devours [cheese]! They morph into something... greater!"),
			span_notice("You devour [cheese], and start morphing into something... greater!"),
		)
		evolve_into_regal_rat()
		qdel(cheese)
		return

	var/cap = CONFIG_GET(number/ratcap)
	// Normal cheese will either heal us
	if(prob(90) || health < maxHealth)
		visible_message(
			span_notice("[src] nibbles [cheese]."),
			span_notice("You nibble [cheese][health < maxHealth ? ", restoring your health" : ""].")
		)
		adjust_health(-maxHealth)

	// Or, if we're at full health, there's a 10% chance that normal cheese will spawn a new mouse
	// ...if the rat cap allows us, that is
	else if(length(SSmobs.cheeserats) >= cap)
		visible_message(
			span_warning("[src] carefully eats [cheese], hiding it from the [cap] mice on the station!"),
			span_notice("You carefully nibble [cheese], hiding it from the [cap] other mice on board the station.")
		)
	else
		visible_message(
			span_notice("[src] nibbles through [cheese], attracting another mouse!"),
			span_notice("You nibble through [cheese], attracting another mouse!")
		)
		create_a_new_rat()

	qdel(cheese)

/// Evolves this rat into a regal rat
/mob/living/basic/mouse/proc/evolve_into_regal_rat()
	var/mob/living/simple_animal/hostile/regalrat/controlled/regalrat = new(loc)
	mind?.transfer_to(regalrat)
	INVOKE_ASYNC(regalrat, /atom/movable/proc/say, "RISE, MY SUBJECTS! SCREEEEEEE!")
	qdel(src)

/// Creates a new mouse based on this mouse's subtype.
/mob/living/basic/mouse/proc/create_a_new_rat()
	new /mob/living/basic/mouse(loc)

/// Biting into a cable will cause a mouse to get shocked and die if applicable. Or do nothing if they're lucky.
/mob/living/basic/mouse/proc/try_bite_cable(obj/structure/cable/cable)
	if(cable.avail() && !HAS_TRAIT(src, TRAIT_SHOCKIMMUNE) && prob(cable_zap_prob))
		visible_message(
			span_warning("[src] chews through \the [cable]. It's toast!"),
			span_userdanger("As you bite deeply into [cable], you suddenly realize this may have been a bad idea."),
			span_hear("You hear electricity crack."),
		)
		// Finely toasted
		ADD_TRAIT(src, TRAIT_BEING_SHOCKED, TRAIT_GENERIC)
		// Unfortunately we can't check the return value of electrocute_act before displaying a message,
		// as it's possible the damage from electrocution results in our hunter being deleted.
		// But what are the odds of the shock failing? Hahaha...
		electrocute_act(maxHealth * 2, cable, flags = SHOCK_SUPPRESS_MESSAGE)

	else
		visible_message(
			span_warning("[src] chews through \the [cable]."),
			span_notice("You chew through \the [cable]."),
		)

	playsound(cable, 'sound/effects/sparks2.ogg', 100, TRUE)
	cable.deconstruct()

/mob/living/basic/mouse/white
	body_color = "white"
	icon_state = "mouse_white"
	held_state = "mouse_white"

/mob/living/basic/mouse/gray
	body_color = "gray"
	icon_state = "mouse_gray"

/mob/living/basic/mouse/brown
	body_color = "brown"
	icon_state = "mouse_brown"
	held_state = "mouse_brown"

//TOM IS ALIVE! SQUEEEEEEEE~K :)
/mob/living/basic/mouse/brown/tom
	name = "Tom"
	desc = "Jerry the cat is not amused."
	response_help_continuous = "pets"
	response_help_simple = "pet"
	response_disarm_continuous = "gently pushes aside"
	response_disarm_simple = "gently push aside"
	response_harm_continuous = "splats"
	response_harm_simple = "splat"
	gold_core_spawnable = NO_SPAWN

/mob/living/basic/mouse/brown/tom/Initialize(mapload)
	. = ..()
	// Tom fears no cable.
	ADD_TRAIT(src, TRAIT_SHOCKIMMUNE, INNATE_TRAIT)
	AddElement(/datum/element/pet_bonus, "squeaks happily!")

/mob/living/basic/mouse/brown/tom/create_a_new_rat()
	new /mob/living/basic/mouse/brown(loc) // dominant gene

/mob/living/basic/mouse/rat
	name = "rat"
	desc = "They're a nasty, ugly, evil, disease-ridden rodent with anger issues."

	melee_damage_lower = 3
	melee_damage_upper = 5
	obj_damage = 5
	maxHealth = 15
	health = 15

	ai_controller = /datum/ai_controller/basic_controller/mouse/rat

/mob/living/basic/mouse/rat/create_a_new_rat()
	new /mob/living/basic/mouse/rat(loc)

/// Mice turn into food when they die
/obj/item/food/deadmouse
	name = "dead mouse"
	desc = "They look like somebody dropped the bass on it. A lizard's favorite meal."
	icon = 'icons/mob/simple/animal.dmi'
	icon_state = "mouse_gray_dead"
	bite_consumption = 3
	eatverbs = list("devour")
	food_reagents = list(/datum/reagent/consumable/nutriment = 3, /datum/reagent/consumable/nutriment/vitamin = 2)
	foodtypes = GORE | MEAT | RAW
	grind_results = list(/datum/reagent/blood = 20, /datum/reagent/liquidgibs = 5)
	decomp_req_handle = TRUE
	ant_attracting = FALSE
	decomp_type = /obj/item/food/deadmouse/moldy

/obj/item/food/deadmouse/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/swabable, CELL_LINE_TABLE_MOUSE, CELL_VIRUS_TABLE_GENERIC_MOB, 1, 10)

/obj/item/food/deadmouse/examine(mob/user)
	. = ..()
	if (reagents?.has_reagent(/datum/reagent/yuck) || reagents?.has_reagent(/datum/reagent/fuel))
		. += span_warning("[p_theyre(TRUE)] dripping with fuel and smells terrible.")

/obj/item/food/deadmouse/attackby(obj/item/attacking_item, mob/user, params)
	var/mob/living/living_user = user
	if(istype(living_user) && attacking_item.get_sharpness() && living_user.combat_mode)
		if(!isturf(loc))
			balloon_alert(user, "can't butcher here!")
			return

		balloon_alert(user, "butchering...")
		if(!do_after(user, 0.75 SECONDS, src))
			balloon_alert(user, "interrupted!")
			return

		loc.balloon_alert(user, "butchered")
		new /obj/item/food/meat/slab/mouse(loc)
		qdel(src)
		return

	return ..()

/obj/item/food/deadmouse/afterattack(obj/target, mob/living/user, proximity_flag)
	. = ..()
	if(proximity_flag && reagents && target.is_open_container())
		// is_open_container will not return truthy if target.reagents doesn't exist
		var/datum/reagents/target_reagents = target.reagents
		var/trans_amount = reagents.maximum_volume - reagents.total_volume * (4 / 3)
		if(target_reagents.has_reagent(/datum/reagent/fuel) && target_reagents.trans_to(src, trans_amount))
			to_chat(user, span_notice("You dip [src] into [target]."))
		else
			to_chat(user, span_warning("That's a terrible idea."))
		return

/obj/item/food/deadmouse/moldy
	name = "moldy dead mouse"
	desc = "A dead rodent, consumed by mold and rot. There is a slim chance that a lizard might still eat it."
	icon_state = "mouse_gray_dead"
	food_reagents = list(/datum/reagent/consumable/nutriment = 3, /datum/reagent/consumable/nutriment/vitamin = 2, /datum/reagent/consumable/mold = 10)
	foodtypes = GORE | MEAT | RAW | GROSS
	grind_results = list(/datum/reagent/blood = 20, /datum/reagent/liquidgibs = 5, /datum/reagent/consumable/mold = 10)
	preserved_food = TRUE

/// The mouse AI controller
/datum/ai_controller/basic_controller/mouse
	blackboard = list(
		BB_CURRENT_HUNTING_TARGET = null, // cheese
		BB_LOW_PRIORITY_HUNTING_TARGET = null, // cable
	)

	ai_traits = STOP_MOVING_WHEN_PULLED
	ai_movement = /datum/ai_movement/basic_avoidance
	idle_behavior = /datum/idle_behavior/idle_random_walk
	planning_subtrees = list(
		// Top priority is to look for and execute hunts for cheese
		/datum/ai_planning_subtree/find_and_hunt_target/look_for_cheese,
		// Try to speak after a cheese hunt, because it's cute
		/datum/ai_planning_subtree/random_speech/mouse,
		// Otherwise, look for and execute hunts for cabling
		/datum/ai_planning_subtree/find_and_hunt_target/look_for_cables,
	)

/// AI controller for rats, slightly more complex than mice becuase they attack people
/datum/ai_controller/basic_controller/mouse/rat
	blackboard = list(
		BB_TARGETTING_DATUM = new /datum/targetting_datum/basic/rat(),
		BB_BASIC_MOB_CURRENT_TARGET = null, // heathen
		BB_CURRENT_HUNTING_TARGET = null, // cheese
		BB_LOW_PRIORITY_HUNTING_TARGET = null, // cable
	)

	ai_traits = STOP_MOVING_WHEN_PULLED
	ai_movement = /datum/ai_movement/basic_avoidance
	idle_behavior = /datum/idle_behavior/idle_random_walk
	planning_subtrees = list(
		/datum/ai_planning_subtree/simple_find_target,
		/datum/ai_planning_subtree/basic_melee_attack_subtree/rat,
		/datum/ai_planning_subtree/find_and_hunt_target/look_for_cheese,
		/datum/ai_planning_subtree/random_speech/mouse,
		/datum/ai_planning_subtree/find_and_hunt_target/look_for_cables,
	)

/datum/ai_planning_subtree/basic_melee_attack_subtree/rat
	melee_attack_behavior = /datum/ai_behavior/basic_melee_attack/rat

/datum/ai_behavior/basic_melee_attack/rat
	action_cooldown = 2 SECONDS

/datum/targetting_datum/basic/rat
	check_factions_exactly = TRUE
