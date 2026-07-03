/mob/living/basic/mouse
	name = "mouse"
	desc = "Этому милому малышу просто нравится вкус проводов под напряжением. Разве он не очарователен?"
	icon_state = "mouse_gray"
	icon_living = "mouse_gray"
	icon_dead = "mouse_gray_dead"
	held_state = "mouse_gray"

	maxHealth = 5
	health = 5
	density = FALSE
	pass_flags = PASSTABLE|PASSGRILLE|PASSMOB
	mob_size = MOB_SIZE_TINY
	can_be_held = TRUE
	held_w_class = WEIGHT_CLASS_TINY
	mob_biotypes = MOB_ORGANIC|MOB_BEAST
	gold_core_spawnable = FRIENDLY_SPAWN
	faction = list(FACTION_RAT, FACTION_MAINT_CREATURES)
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
	///list of pet commands we follow
	var/static/list/pet_commands = list(
		/datum/pet_command/idle,
		/datum/pet_command/free,
		/datum/pet_command/follow/start_active,
		/datum/pet_command/perform_trick_sequence,
	)

	// SS220 ADD - START
	var/body_icon_state = "mouse"
	var/list/possible_body_colors = list("brown", "gray", "white", "wooly") // wooly - мохнатая мышка из кастомных спрайтов
	var/squeak_sound = 'sound/mobs/non-humanoids/mouse/mousesqueek.ogg'
	// SS220 ADD - END

/datum/emote/mouse
	abstract_type = /datum/emote/mouse
	mob_type_allowed_typecache = /mob/living/basic/mouse
	mob_type_blacklist_typecache = list()

/datum/emote/mouse/squeak
	key = "squeak"
	key_third_person = "squeaks"
	message = "пищит!"
	emote_type = EMOTE_VISIBLE | EMOTE_AUDIBLE
	vary = TRUE
	sound = 'sound/mobs/non-humanoids/mouse/mousesqueek.ogg'

/mob/living/basic/mouse/Initialize(mapload, tame = FALSE, new_body_color)
	. = ..()
	if(contributes_to_ratcap)
		SSmobs.cheeserats |= src
	ADD_TRAIT(src, TRAIT_VENTCRAWLER_ALWAYS, INNATE_TRAIT)

	if(tame)
		ADD_TRAIT(src, TRAIT_TAMED, INNATE_TRAIT)
	if(!isnull(new_body_color))
		body_color = new_body_color
	if(isnull(body_color))
		body_color = pick(possible_body_colors)	// SS220 edit
	if(!isnull(body_icon_state)) held_state = "[body_icon_state]_[body_color]" // not handled by variety element // SS220 EDIT
	if(!isnull(body_icon_state)) AddElement(/datum/element/animal_variety, "[body_icon_state]", body_color, FALSE)	// SS220 EDIT
	AddElement(/datum/element/swabable, CELL_LINE_TABLE_MOUSE, CELL_VIRUS_TABLE_GENERIC_MOB, 1, 10)
	AddComponent(/datum/component/squeak, list(squeak_sound = 1), 100, extrarange = SHORT_RANGE_SOUND_EXTRARANGE) //as quiet as a mouse or whatever
	var/static/list/loc_connections = list(
		COMSIG_ATOM_ENTERED = PROC_REF(on_entered),
	)
	AddComponent(/datum/component/obeys_commands, pet_commands)
	AddElement(/datum/element/connect_loc, loc_connections)
	make_tameable()
	AddComponent(/datum/component/swarming, 16, 16) //max_x, max_y

/mob/living/basic/mouse/proc/make_tameable()
	if (HAS_TRAIT(src, TRAIT_TAMED))
		add_faction(FACTION_NEUTRAL)
	else
		var/static/list/food_types = list(/obj/item/food/cheese)
		AddComponent(/datum/component/tameable, food_types = food_types, tame_chance = 100)

	AddElement(/datum/element/regal_rat_minion, converted_path = /mob/living/basic/mouse/rat, pet_commands = GLOB.regal_rat_minion_commands)

/mob/living/basic/mouse/Destroy()
	SSmobs.cheeserats -= src
	return ..()

/mob/living/basic/mouse/examine(mob/user)
	. = ..()

	var/sameside = user.faction_check_atom(src, exact_match = TRUE)
	if(isregalrat(user))
		if(sameside)
			. += span_notice("Этот грызун служит Вам.")
		else
			. += span_warning("Этот смерд служит другому королю! Сокрушите [ru_p_them()]!")

	else if(user != src && ismouse(user))
		if(sameside)
			. += span_notice("Вы служите одному королю.")
		else
			. += span_warning("Этот глупец служит другому королю!")

/// Kills the rat and changes its icon state to be splatted (bloody).
/mob/living/basic/mouse/proc/splat()
	icon_dead = "[body_icon_state]_[body_color]_splat"	// SS220 EDIT
	adjust_health(maxHealth)

// On revival, re-add the mouse to the ratcap, or block it if we're at it
/mob/living/basic/mouse/revive(full_heal_flags = NONE, excess_healing = 0, force_grab_ghost = FALSE)
	if(!contributes_to_ratcap)
		return ..()

	var/aheal_included = full_heal_flags & HEAL_ADMIN
	var/cap = CONFIG_GET(number/ratcap)
	if(!aheal_included && !ckey && length(SSmobs.cheeserats) >= cap)
		visible_message(span_warning("[src] дёргается, но перестаёт двигаться \
			из-за переполнения грызунов на станции!"))
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
		var/make_a_corpse = TRUE
		var/place_to_make_corpse = loc
		var/must_equip = FALSE
		var/equip_slot
		var/mob/holding_mob
		var/obj/item/mob_holder/found_holder
		if(istype(loc, /obj/item/mob_holder))//If our mouse is dying in place holder we want to put the dead mouse where the place holder was
			found_holder = loc
			place_to_make_corpse = found_holder.loc
			if(istype(found_holder.loc,/mob/living/carbon))
				holding_mob = found_holder.loc
				place_to_make_corpse = get_turf(holding_mob)
				equip_slot = holding_mob.get_slot_by_item(found_holder)
				if(equip_slot == ITEM_SLOT_HANDS || equip_slot == ITEM_SLOT_RPOCKET || equip_slot == ITEM_SLOT_LPOCKET)
					must_equip = TRUE
			if(istype(found_holder.loc, /obj/machinery/microwave))//Microwaves gib things that die when cooked, so we don't need to make a dead body too
				make_a_corpse = FALSE
		if(make_a_corpse)
			var/obj/item/food/deadmouse/mouse = new(place_to_make_corpse)
			mouse.copy_corpse(src)
			if(HAS_TRAIT(src, TRAIT_BEING_SHOCKED))
				mouse.desc = "Он подгорел до корочки."
				mouse.add_atom_colour("#3A3A3A", FIXED_COLOUR_PRIORITY)
			found_holder?.release(FALSE)
			if(must_equip)
				if(equip_slot == ITEM_SLOT_HANDS)
					holding_mob.dropItemToGround(found_holder)
				holding_mob.equip_to_slot(mouse,equip_slot)
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
		to_chat(entered, span_notice("[icon2html(src, entered)] Сквик!"))

/// Called when a mouse is hand-fed some cheese, it will stop being afraid of humans
/mob/living/basic/mouse/tamed(mob/living/tamer, obj/item/food/cheese/cheese)
	. = ..()
	new /obj/effect/temp_visual/heart(loc)
	add_faction(FACTION_NEUTRAL)
	try_consume_cheese(cheese)
	ai_controller.CancelActions() // Interrupt any current fleeing

/// Attempts to consume a piece of cheese, causing a few effects.
/mob/living/basic/mouse/proc/try_consume_cheese(obj/item/food/cheese/cheese)
	// Royal cheese will evolve us into a regal rat
	if(istype(cheese, /obj/item/food/cheese/royal))
		visible_message(
			span_warning("[capitalize(declent_ru(NOMINATIVE))] поглощает [cheese.declent_ru(ACCUSATIVE)]! Он превращается во что-то... великое!"),
			span_notice("Вы поглощаете [cheese.declent_ru(ACCUSATIVE)], и начинаете превращаться во что-то... великое!"),
		)
		evolve_into_regal_rat()
		qdel(cheese)
		return

	var/cap = CONFIG_GET(number/ratcap)
	// Normal cheese will either heal us
	if(prob(90) || health < maxHealth)
		visible_message(
			span_notice("[capitalize(declent_ru(NOMINATIVE))] надкусывает [cheese.declent_ru(NOMINATIVE)]."),
			span_notice("Вы надкусываете [cheese.declent_ru(NOMINATIVE)][health < maxHealth ? ", восстанавливая своё здоровье!" : ""].")
		)
		adjust_health(-maxHealth)

	// Or, if we're at full health, there's a 10% chance that normal cheese will spawn a new mouse
	// ...if the rat cap allows us, that is
	else if(length(SSmobs.cheeserats) >= cap)
		visible_message(
			span_warning("[capitalize(declent_ru(NOMINATIVE))] осторожно ест [cheese.declent_ru(NOMINATIVE)], пряча его от [cap] других грызунов!"),
			span_notice("Вы осторожно надкусываете [cheese.declent_ru(NOMINATIVE)], пряча его от [cap] других грызунов на станции.")
		)
	else
		visible_message(
			span_notice("[capitalize(declent_ru(NOMINATIVE))] прогрызает [cheese.declent_ru(NOMINATIVE)], привлекая другого грызуна!"),
			span_notice("Вы прогрызаете [cheese.declent_ru(NOMINATIVE)], привлекая другого грызуна!")
		)
		create_a_new_rat()

	qdel(cheese)

/// Evolves this rat into a regal rat
/mob/living/basic/mouse/proc/evolve_into_regal_rat()
	var/mob/living/basic/regal_rat/controlled/regalrat = new(loc)
	mind?.transfer_to(regalrat)
	INVOKE_ASYNC(regalrat, TYPE_PROC_REF(/atom/movable, say), "ВОССТАНЬТЕ, МОИ ПОДДАННЫЕ! СКРИИИИИ!")
	qdel(src)

/// Creates a new mouse based on this mouse's subtype.
/mob/living/basic/mouse/proc/create_a_new_rat()
	new /mob/living/basic/mouse(loc, HAS_TRAIT(src, TRAIT_TAMED))

/// Biting into a cable will cause a mouse to get shocked and die if applicable. Or do nothing if they're lucky.
/mob/living/basic/mouse/proc/try_bite_cable(obj/structure/cable/cable)
	if(cable.avail() && !HAS_TRAIT(src, TRAIT_SHOCKIMMUNE) && prob(cable_zap_prob))
		visible_message(
			span_warning("[capitalize(declent_ru(NOMINATIVE))] прогрызает провод и поджаривается!"),
			span_userdanger("Как только Вы полностью прогрызаете [cable.declent_ru(NOMINATIVE)], до Вас внезапно доходит мысль, что это была плохая идея..."),
			span_hear("Вы слышите электрический треск."),
		)
		// Finely toasted
		ADD_TRAIT(src, TRAIT_BEING_SHOCKED, TRAIT_GENERIC)
		// Unfortunately we can't check the return value of electrocute_act before displaying a message,
		// as it's possible the damage from electrocution results in our hunter being deleted.
		// But what are the odds of the shock failing? Hahaha...
		electrocute_act(maxHealth * 2, cable, flags = SHOCK_SUPPRESS_MESSAGE)

	else
		visible_message(
			span_warning("[capitalize(declent_ru(NOMINATIVE))] прогрызает [cable.declent_ru(NOMINATIVE)]."),
			span_notice("Вы прогрызаете [cable.declent_ru(NOMINATIVE)]."),
		)

	playsound(cable, 'sound/effects/sparks/sparks2.ogg', 100, TRUE)
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
	desc = "Он совсем не забавляет кота Джерри."
	response_help_continuous = "pets"
	response_help_simple = "pet"
	response_disarm_continuous = "gently pushes aside"
	response_disarm_simple = "gently push aside"
	response_harm_continuous = "splats"
	response_harm_simple = "splat"
	gold_core_spawnable = NO_SPAWN
	contributes_to_ratcap = FALSE

/mob/living/basic/mouse/brown/tom/make_tameable()
	ADD_TRAIT(src, TRAIT_TAMED, INNATE_TRAIT)
	return ..()

/mob/living/basic/mouse/brown/tom/Initialize(mapload)
	. = ..()
	// Tom fears no cable.
	ADD_TRAIT(src, TRAIT_SHOCKIMMUNE, INNATE_TRAIT)
	AddElement(/datum/element/pet_bonus, "squeak")

/mob/living/basic/mouse/brown/tom/create_a_new_rat()
	new /mob/living/basic/mouse/brown(loc, HAS_TRAIT(src, TRAIT_TAMED)) // dominant gene

/mob/living/basic/mouse/rat
	name = "крыса"
	desc = "Это мерзкие, уродливые, злобные, гневные и пораженные болезнями грызуны."

	gold_core_spawnable = HOSTILE_SPAWN
	melee_damage_lower = 3
	melee_damage_upper = 5
	obj_damage = 5
	maxHealth = 15
	health = 15

	ai_controller = /datum/ai_controller/basic_controller/mouse/rat

/mob/living/basic/mouse/rat/make_tameable()
	return // Unlike in real life, space rats are horrible creatures who don't like you

/mob/living/basic/mouse/rat/create_a_new_rat()
	new /mob/living/basic/mouse/rat(loc)

/// Mice turn into food when they die
/obj/item/food/deadmouse
	name = "мертвая мышь"
	desc = "Он выглядит так, будто на него уронили рояль. Любимая еда ящеров."
	icon = 'icons/mob/simple/animal.dmi'
	icon_state = "mouse_gray_dead"
	bite_consumption = 3
	eatverbs = list("devour")
	food_reagents = list(/datum/reagent/consumable/nutriment = 3, /datum/reagent/consumable/nutriment/vitamin = 2)
	foodtypes = GORE | MEAT | RAW
	decomp_req_handle = TRUE
	ant_attracting = FALSE
	decomp_type = /obj/item/food/deadmouse/moldy
	var/body_color = "gray"
	var/critter_type = /mob/living/basic/mouse

/obj/item/food/deadmouse/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/swabable, CELL_LINE_TABLE_MOUSE, CELL_VIRUS_TABLE_GENERIC_MOB, 1, 10)
	RegisterSignal(src, COMSIG_ATOM_ON_LAZARUS_INJECTOR, PROC_REF(use_lazarus))

/obj/item/food/deadmouse/grind_results()
	return list(/datum/reagent/blood = 20, /datum/reagent/consumable/liquidgibs = 5)

/// Copy properties from an imminently dead mouse
/obj/item/food/deadmouse/proc/copy_corpse(mob/living/basic/mouse/dead_critter)
	body_color = dead_critter.body_color
	critter_type = dead_critter.type
	name = dead_critter.name
	icon = dead_critter.icon // SS220 EDIT - rats and hamsters
	icon_state = dead_critter.icon_dead

/obj/item/food/deadmouse/examine(mob/user)
	. = ..()
	if (reagents?.has_reagent(/datum/reagent/yuck) || reagents?.has_reagent(/datum/reagent/fuel))
		. += span_warning("С [ru_p_theirs()] капает топливо и исходит ужасный запах.")

///Spawn a new mouse from this dead mouse item when hit by a lazarus injector and conditions are met.
/obj/item/food/deadmouse/proc/use_lazarus(datum/source, obj/item/lazarus_injector/injector, mob/user)
	SIGNAL_HANDLER
	if(injector.revive_type != SENTIENCE_ORGANIC)
		balloon_alert(user, "недопустимое существо!")
		return
	var/mob/living/basic/mouse/revived_critter = new critter_type (drop_location(), FALSE, body_color)
	revived_critter.name = name
	revived_critter.lazarus_revive(user, injector.malfunctioning)
	injector.expend(revived_critter, user)
	qdel(src)
	return LAZARUS_INJECTOR_USED

/obj/item/food/deadmouse/attackby(obj/item/attacking_item, mob/user, list/modifiers, list/attack_modifiers)
	var/mob/living/living_user = user
	if(istype(living_user) && attacking_item.get_sharpness() && living_user.combat_mode)
		if(!isturf(loc))
			balloon_alert(user, "нельзя разделать здесь!")
			return

		balloon_alert(user, "разделываем...")
		if(!do_after(user, 0.75 SECONDS, src))
			balloon_alert(user, "прервано!")
			return

		loc.balloon_alert(user, "разделан")
		new /obj/item/food/meat/slab/mouse(loc)
		qdel(src)
		return

	return ..()

/obj/item/food/deadmouse/interact_with_atom(atom/interacting_with, mob/living/user, list/modifiers)
	if(isnull(reagents) || !interacting_with.is_open_container())
		return NONE

	// is_open_container will not return truthy if target.reagents doesn't exist
	var/datum/reagents/target_reagents = interacting_with.reagents
	var/trans_amount = reagents.maximum_volume - reagents.total_volume * (4 / 3)
	if(target_reagents.has_reagent(/datum/reagent/fuel) && target_reagents.trans_to(src, trans_amount))
		to_chat(user, span_notice("Вы погружаете [declent_ru(ACCUSATIVE)] в [interacting_with.declent_ru(ACCUSATIVE)]."))
		return ITEM_INTERACT_SUCCESS

/obj/item/food/deadmouse/moldy
	name = "заплесневелая мертвая мышь"
	desc = "Мёртвый грызун, поглощённый гнилью и плесенью. Есть небольшой шанс, что ящер съест это."
	icon_state = "mouse_gray_dead"
	food_reagents = list(/datum/reagent/consumable/nutriment = 3, /datum/reagent/consumable/nutriment/vitamin = 2, /datum/reagent/consumable/mold = 10)
	foodtypes = GORE | MEAT | RAW | GROSS
	preserved_food = TRUE

/obj/item/food/deadmouse/moldy/grind_results()
	return list(/datum/reagent/blood = 20, /datum/reagent/consumable/liquidgibs = 5, /datum/reagent/consumable/mold = 10)

/// The mouse AI controller
/datum/ai_controller/basic_controller/mouse
	blackboard = list( // Always cowardly
		BB_TARGETING_STRATEGY = /datum/targeting_strategy/basic, // Use this to find people to run away from
		BB_PET_TARGETING_STRATEGY = /datum/targeting_strategy/basic/not_friends,
		BB_BASIC_MOB_FLEE_DISTANCE = 3,
		BB_SONG_LINES = MOUSE_SONG,
	)

	ai_traits = PASSIVE_AI_FLAGS
	ai_movement = /datum/ai_movement/basic_avoidance
	idle_behavior = /datum/idle_behavior/idle_random_walk
	planning_subtrees = list(
		// Try to speak, because it's cute
		/datum/ai_planning_subtree/random_speech/mouse,
		// Follow the boss's orders
		/datum/ai_planning_subtree/pet_planning,
		// Look for and execute hunts for cheese even if someone is looking at us
		/datum/ai_planning_subtree/find_and_hunt_target/look_for_cheese,
		// Next priority is to try and appreoach a keyboard
		/datum/ai_planning_subtree/approach_synthesizer,
		// And play it if we are near it
		/datum/ai_planning_subtree/generic_play_instrument/end_planning,
		// Next priority is see if anyone is looking at us
		/datum/ai_planning_subtree/simple_find_nearest_target_to_flee,
		// Skedaddle
		/datum/ai_planning_subtree/flee_target/mouse,
		// Otherwise, look for and execute hunts for cabling
		/datum/ai_planning_subtree/find_and_hunt_target/look_for_cables,
	)

/// Don't look for anything to run away from if you are distracted by being adjacent to cheese
/datum/ai_planning_subtree/flee_target/mouse

/datum/ai_planning_subtree/flee_target/mouse/SelectBehaviors(datum/ai_controller/controller, seconds_per_tick)
	var/atom/hunted_cheese = controller.blackboard[BB_CURRENT_HUNTING_TARGET]
	if (!isnull(hunted_cheese))
		return // We see some cheese, which is more important than our life
	return ..()

/// AI controller for rats, slightly more complex than mice becuase they attack people
/datum/ai_controller/basic_controller/mouse/rat
	blackboard = list(
		BB_TARGETING_STRATEGY = /datum/targeting_strategy/basic,
		BB_PET_TARGETING_STRATEGY = /datum/targeting_strategy/basic/not_friends,
		BB_BASIC_MOB_CURRENT_TARGET = null, // heathen
		BB_CURRENT_HUNTING_TARGET = null, // cheese
		BB_LOW_PRIORITY_HUNTING_TARGET = null, // cable
		BB_OWNER_SELF_HARM_RESPONSES = list(
			"*me cleans its whiskers in disapproval.",
			"*me squeaks sadly.",
			"*me sheds a single small tear."
		)
	)

	ai_traits = DEFAULT_AI_FLAGS | STOP_MOVING_WHEN_PULLED
	ai_movement = /datum/ai_movement/basic_avoidance
	idle_behavior = /datum/idle_behavior/idle_random_walk
	planning_subtrees = list(
		/datum/ai_planning_subtree/escape_captivity,
		/datum/ai_planning_subtree/pet_planning,
		/datum/ai_planning_subtree/simple_find_target,
		/datum/ai_planning_subtree/attack_obstacle_in_path,
		/datum/ai_planning_subtree/basic_melee_attack_subtree,
		/datum/ai_planning_subtree/find_and_hunt_target/look_for_cheese,
		/datum/ai_planning_subtree/random_speech/mouse/rat,	// SS220 EDIT
		/datum/ai_planning_subtree/find_and_hunt_target/look_for_cables,
	)
