/mob/living/simple_animal/mouse
	name = "mouse"
	desc = "They're a nasty, ugly, evil, disease-ridden rodent."
	icon_state = "mouse_gray"
	icon_living = "mouse_gray"
	icon_dead = "mouse_gray_dead"
	speak = list("Squeak!","SQUEAK!","Squeak?")
	speak_emote = list("squeaks")
	emote_hear = list("squeaks.")
	emote_see = list("runs in a circle.", "shakes.")
	speak_chance = 1
	turns_per_move = 5
	see_in_dark = 6
	maxHealth = 5
	health = 5
	butcher_results = list(/obj/item/food/meat/slab/mouse = 1)
	response_help_continuous = "pets"
	response_help_simple = "pet"
	response_disarm_continuous = "gently pushes aside"
	response_disarm_simple = "gently push aside"
	response_harm_continuous = "splats"
	response_harm_simple = "splat"
	density = FALSE
	pass_flags = PASSTABLE | PASSGRILLE | PASSMOB
	mob_size = MOB_SIZE_TINY
	mob_biotypes = MOB_ORGANIC|MOB_BEAST
	var/body_color //brown, gray and white, leave blank for random
	gold_core_spawnable = FRIENDLY_SPAWN
	var/chew_probability = 1
	can_be_held = TRUE
	held_w_class = WEIGHT_CLASS_TINY
	held_state = "mouse_gray"
	faction = list("rat")

/mob/living/simple_animal/mouse/Initialize(mapload)
	. = ..()
	if(body_color == null)
		body_color = pick("brown","gray","white")
	AddElement(/datum/element/animal_variety, "mouse", body_color, FALSE)
	AddComponent(/datum/component/squeak, list('sound/effects/mousesqueek.ogg' = 1), 100, extrarange = SHORT_RANGE_SOUND_EXTRARANGE) //as quiet as a mouse or whatever
	add_cell_sample()

	ADD_TRAIT(src, TRAIT_VENTCRAWLER_ALWAYS, INNATE_TRAIT)
	var/static/list/loc_connections = list(
		COMSIG_ATOM_ENTERED = .proc/on_entered,
	)
	AddElement(/datum/element/connect_loc, loc_connections)

/mob/living/simple_animal/mouse/add_cell_sample()
	AddElement(/datum/element/swabable, CELL_LINE_TABLE_MOUSE, CELL_VIRUS_TABLE_GENERIC_MOB, 1, 10)

/mob/living/simple_animal/mouse/proc/splat()
	src.health = 0
	src.icon_dead = "mouse_[body_color]_splat"
	death()

/mob/living/simple_animal/mouse/death(gibbed, toast)
	if(!ckey)
		..(1)
		if(!gibbed)
			var/obj/item/food/deadmouse/M = new(loc)
			M.icon_state = icon_dead
			M.name = name
			if(toast)
				M.add_atom_colour("#3A3A3A", FIXED_COLOUR_PRIORITY)
				M.desc = "They're toast."
		qdel(src)
	else
		SSmobs.cheeserats -= src // remove play controlled mouse also
		..(gibbed)

/mob/living/simple_animal/mouse/revive(full_heal = FALSE, admin_revive = FALSE)
	var/cap = CONFIG_GET(number/ratcap)
	if(!admin_revive && !ckey && LAZYLEN(SSmobs.cheeserats) >= cap)
		visible_message(span_warning("[src] twitched but does not continue moving due to the overwhelming rodent population on the station!"))
		return FALSE
	. = ..()
	if(.)
		SSmobs.cheeserats += src

/mob/living/simple_animal/mouse/proc/on_entered(datum/source, AM as mob|obj)
	SIGNAL_HANDLER
	if(ishuman(AM))
		if(!stat)
			var/mob/M = AM
			to_chat(M, span_notice("[icon2html(src, M)] Squeak!"))
	if(istype(AM, /obj/item/food/cheese/royal))
		evolve()
		qdel(AM)

/mob/living/simple_animal/mouse/handle_automated_action()
	if(prob(chew_probability))
		var/turf/open/floor/F = get_turf(src)
		if(istype(F) && F.underfloor_accessibility >= UNDERFLOOR_INTERACTABLE)
			var/obj/structure/cable/C = locate() in F
			if(C && prob(15))
				var/powered = C.avail()
				if(powered && !HAS_TRAIT(src, TRAIT_SHOCKIMMUNE))
					visible_message(span_warning("[src] chews through the [C]. It's toast!"))
					death(toast = TRUE)
				else
					visible_message(span_warning("[src] chews through the [C]."))

				C.deconstruct()
				if(powered)
					playsound(src, 'sound/effects/sparks2.ogg', 100, TRUE)

	for(var/obj/item/food/cheese/cheese in range(1, src))
		if(prob(10))
			be_fruitful()
			qdel(cheese)
			return
	for(var/obj/item/food/cheese/royal/bigcheese in range(1, src))
		qdel(bigcheese)
		evolve()
		return

/mob/living/simple_animal/mouse/UnarmedAttack(atom/A, proximity_flag, list/modifiers)
	if(HAS_TRAIT(src, TRAIT_HANDS_BLOCKED))
		return
	. = ..()
	if(istype(A, /obj/item/food/cheese) && canUseTopic(A, BE_CLOSE, NO_DEXTERITY))
		if(health == maxHealth)
			to_chat(src,span_warning("You don't need to eat or heal."))
			return
		to_chat(src,span_green("You nibble some cheese, restoring your health."))
		adjustHealth(-(maxHealth-health))
		qdel(A)
		return
	return ..()

/**
 *Checks the mouse cap, if it's above the cap, doesn't spawn a mouse. If below, spawns a mouse and adds it to cheeserats.
 */
/mob/living/simple_animal/mouse/proc/be_fruitful()
	var/cap = CONFIG_GET(number/ratcap)
	if(LAZYLEN(SSmobs.cheeserats) >= cap)
		visible_message(span_warning("[src] carefully eats the cheese, hiding it from the [cap] mice on the station!"))
		return
	var/mob/living/newmouse = new /mob/living/simple_animal/mouse(loc)
	SSmobs.cheeserats += newmouse
	visible_message(span_notice("[src] nibbles through the cheese, attracting another mouse!"))

/**
 *Spawns a new regal rat, says some good jazz, and if sentient, transfers the relivant mind.
 */
/mob/living/simple_animal/mouse/proc/evolve()
	var/mob/living/simple_animal/hostile/regalrat/regalrat = new /mob/living/simple_animal/hostile/regalrat/controlled(loc)
	visible_message(span_warning("[src] devours the cheese! They morph into something... greater!"))
	INVOKE_ASYNC(regalrat, /atom/movable/proc/say, "RISE, MY SUBJECTS! SCREEEEEEE!")
	if(mind)
		mind.transfer_to(regalrat)
	qdel(src)

/*
 * Mouse types
 */

/mob/living/simple_animal/mouse/white
	body_color = "white"
	icon_state = "mouse_white"
	held_state = "mouse_white"

/mob/living/simple_animal/mouse/gray
	body_color = "gray"
	icon_state = "mouse_gray"

/mob/living/simple_animal/mouse/brown
	body_color = "brown"
	icon_state = "mouse_brown"
	held_state = "mouse_brown"

/mob/living/simple_animal/mouse/Destroy()
	SSmobs.cheeserats -= src
	return ..()

//TOM IS ALIVE! SQUEEEEEEEE~K :)
/mob/living/simple_animal/mouse/brown/tom
	name = "Tom"
	desc = "Jerry the cat is not amused."
	response_help_continuous = "pets"
	response_help_simple = "pet"
	response_disarm_continuous = "gently pushes aside"
	response_disarm_simple = "gently push aside"
	response_harm_continuous = "splats"
	response_harm_simple = "splat"
	gold_core_spawnable = NO_SPAWN

/mob/living/simple_animal/mouse/brown/tom/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/pet_bonus, "squeaks happily!")
	// Tom fears no cable.
	ADD_TRAIT(src, TRAIT_SHOCKIMMUNE, INNATE_TRAIT)

/obj/item/food/deadmouse
	name = "dead mouse"
	desc = "They look like somebody dropped the bass on it. A lizard's favorite meal."
	icon = 'icons/mob/animal.dmi'
	icon_state = "mouse_gray_dead"
	bite_consumption = 3
	eatverbs = list("devour")
	food_reagents = list(/datum/reagent/consumable/nutriment = 3, /datum/reagent/consumable/nutriment/vitamin = 2)
	foodtypes = GROSS | MEAT | RAW
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
		. += span_warning("They're dripping with fuel and smells terrible.")

/obj/item/food/deadmouse/attackby(obj/item/I, mob/living/user, params)
	if(I.get_sharpness() && user.combat_mode)
		if(isturf(loc))
			new /obj/item/food/meat/slab/mouse(loc)
			to_chat(user, span_notice("You butcher [src]."))
			qdel(src)
		else
			to_chat(user, span_warning("You need to put [src] on a surface to butcher them!"))
	else
		return ..()

/obj/item/food/deadmouse/afterattack(obj/target, mob/living/user, proximity_flag)
	if(proximity_flag && reagents && target.is_open_container())
		// is_open_container will not return truthy if target.reagents doesn't exist
		var/datum/reagents/target_reagents = target.reagents
		var/trans_amount = reagents.maximum_volume - reagents.total_volume * (4 / 3)
		if(target_reagents.has_reagent(/datum/reagent/fuel) && target_reagents.trans_to(src, trans_amount))
			to_chat(user, span_notice("You dip [src] into [target]."))
		else
			to_chat(user, span_warning("That's a terrible idea."))
	else
		return ..()

/obj/item/food/deadmouse/moldy
	name = "moldy dead mouse"
	desc = "A dead rodent, consumed by mold and rot. There is a slim chance that a lizard might still eat it."
	icon_state = "mouse_gray_dead"
	food_reagents = list(/datum/reagent/consumable/nutriment = 3, /datum/reagent/consumable/nutriment/vitamin = 2, /datum/reagent/consumable/mold = 10)
	grind_results = list(/datum/reagent/blood = 20, /datum/reagent/liquidgibs = 5, /datum/reagent/consumable/mold = 10)
	preserved_food = TRUE
