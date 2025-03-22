#define PATH_PEST_KILLER "path_pest_killer"
#define PATH_PLANT_HEALER "path_plant_healer"
#define PATH_PLANT_MUTATOR "path_plant_mutator"
#define REQUIRED_TREE_GROWTH 250
#define UPPER_BOUND_VOLUME 50
#define LOWER_BOUND_VOLUME 10

/mob/living/basic/turtle
	name = "turtle"
	desc = "Dog."
	icon_state = "turtle"
	icon_living = "turtle"
	icon_dead = "turtle_dead"
	base_icon_state = "turtle"
	icon = 'icons/mob/simple/pets.dmi'
	butcher_results = list(/obj/item/food/meat/slab = 3, /obj/item/food/pickle = 1, /obj/item/stack/sheet/mineral/wood = 10)
	mob_biotypes = MOB_ORGANIC | MOB_PLANT
	mobility_flags = MOBILITY_FLAGS_REST_CAPABLE_DEFAULT
	health = 100
	maxHealth = 100
	speed = 5
	verb_say = "snaps"
	verb_ask = "snaps curiously"
	verb_exclaim = "snaps loudly"
	verb_yell = "snaps loudly"
	faction = list(FACTION_NEUTRAL)
	ai_controller = /datum/ai_controller/basic_controller/turtle
	///our displayed tree
	var/mutable_appearance/grown_tree
	///growth progress of our tree
	var/list/path_growth_progress = list(
		PATH_PLANT_HEALER = 0,
		PATH_PLANT_MUTATOR = 0,
		PATH_PEST_KILLER = 0,
	)
	///what nutrients leads to each evolution path
	var/static/list/path_requirements = list(
		//plant healers
		/datum/reagent/plantnutriment/eznutriment = PATH_PLANT_HEALER,
		/datum/reagent/plantnutriment/robustharvestnutriment = PATH_PLANT_HEALER,
		/datum/reagent/plantnutriment/endurogrow = PATH_PLANT_HEALER,
		//plant mutators
		/datum/reagent/plantnutriment/left4zednutriment = PATH_PLANT_MUTATOR,
		/datum/reagent/uranium = PATH_PLANT_MUTATOR,
		//pest killers
		/datum/reagent/toxin/pestkiller = PATH_PEST_KILLER,
	)
	///if we are fully grown, what is our path
	var/developed_path
	///our last east/west direction
	var/last_direction = WEST
	///seeds our stomach cannot process into fruit, we will spit these seeds out after a short time instead
	var/static/list/indigestible_seeds = typecacheof(list(
		/obj/item/seeds/random,
	))

/mob/living/basic/turtle/Initialize(mapload)
	. = ..()

	desc = pick(
		"Likely Dog...",
		"Praise the Dog!",
		"Dog ahead.",
		"Could this be a Dog?",
	)
	var/static/list/eatable_food = list(/obj/item/seeds)
	ai_controller.set_blackboard_key(BB_BASIC_FOODS, typecacheof(eatable_food))
	AddElement(/datum/element/basic_eating, food_types = eatable_food)
	AddComponent(/datum/component/happiness)
	RegisterSignal(src, COMSIG_MOB_PRE_EAT, PROC_REF(pre_eat_food))
	RegisterSignal(src, COMSIG_MOB_ATE, PROC_REF(post_eat))
	update_appearance()
	create_reagents(150, REAGENT_HOLDER_ALIVE)
	add_verb(src, /mob/living/proc/toggle_resting)
	START_PROCESSING(SSprocessing, src)

/mob/living/basic/turtle/setDir(newdir)
	if(REVERSE_DIR(last_direction) & newdir)
		transform = transform.Scale(-1, 1)
		last_direction = REVERSE_DIR(last_direction)
	return ..()

/mob/living/basic/turtle/proc/retrieve_destined_path()
	var/current_max_growth = 0
	var/destined_path
	for(var/evolution_path in path_growth_progress)
		if(path_growth_progress[evolution_path] > current_max_growth)
			destined_path = evolution_path
			current_max_growth = path_growth_progress[evolution_path]
	if(isnull(destined_path))
		destined_path = PATH_PLANT_HEALER
	return destined_path

/mob/living/basic/turtle/process(seconds_per_tick)
	if(isnull(reagents) || !length(reagents.reagent_list)) //if we have no reagents, default to our highest destined path
		set_plant_growth(retrieve_destined_path(), 0.5)
		return

	for(var/datum/reagent/existing_reagent as anything in reagents.reagent_list)
		var/evolution_path = path_requirements[existing_reagent.type]

		switch(existing_reagent.volume)
			if(UPPER_BOUND_VOLUME to INFINITY)
				set_plant_growth(evolution_path, 3)
			if(LOWER_BOUND_VOLUME to UPPER_BOUND_VOLUME)
				set_plant_growth(evolution_path, 2)
			if(1 to LOWER_BOUND_VOLUME)
				set_plant_growth(evolution_path, 1)

		reagents.remove_reagent(existing_reagent.type, 0.5)

/mob/living/basic/turtle/proc/set_plant_growth(evolution_path, amount)
	path_growth_progress[evolution_path] += amount
	if(path_growth_progress[evolution_path] >= REQUIRED_TREE_GROWTH)
		evolve_turtle(evolution_path)

/mob/living/basic/turtle/examine(mob/user)
	. = ..()

	if(stat == DEAD)
		. += span_notice("Its tree seems to be all withered...")
		return

	var/destined_path = retrieve_destined_path()
	var/current_max_growth = path_growth_progress[destined_path]

	var/text_to_display = "Its tree seems to be exuding "
	switch(destined_path)
		if(PATH_PEST_KILLER)
			text_to_display += "pest killing"
		if(PATH_PLANT_HEALER)
			text_to_display += "plant healing"
		if(PATH_PLANT_MUTATOR)
			text_to_display += "plant mutating"

	text_to_display += " properties... which [current_max_growth >= REQUIRED_TREE_GROWTH ? "seems to be fully grown" : "is yet to develop"]."
	. += span_notice(text_to_display)


/mob/living/basic/turtle/proc/evolve_turtle(evolution_path)
	var/static/list/evolution_gains = list(
		PATH_PLANT_HEALER = list(
			"tree_appearance" = "healer_tree",
			"tree_ability" = /datum/action/cooldown/mob_cooldown/turtle_tree/healer,
		),
		PATH_PEST_KILLER = list(
			"tree_appearance" = "killer_tree",
			"tree_ability" = /datum/action/cooldown/mob_cooldown/turtle_tree/killer,
		),
		PATH_PLANT_MUTATOR = list(
			"tree_appearance" = "mutator_tree",
			"tree_ability" = /datum/action/cooldown/mob_cooldown/turtle_tree/mutator,
		),
	)

	var/tree_icon_state = evolution_gains[evolution_path]["tree_appearance"]
	grown_tree = mutable_appearance(icon = 'icons/mob/simple/turtle_trees.dmi', icon_state = tree_icon_state)

	var/new_ability_path = evolution_gains[evolution_path]["tree_ability"]
	developed_path = evolution_path
	var/datum/action/cooldown/tree_ability = new new_ability_path(src)
	tree_ability?.Grant(src)
	ai_controller?.set_blackboard_key(BB_TURTLE_TREE_ABILITY, tree_ability)
	STOP_PROCESSING(SSprocessing, src)
	update_appearance()

/mob/living/basic/turtle/update_icon_state()
	. = ..()
	if(stat == DEAD)
		return
	icon_state = resting ? "[base_icon_state]_resting" : base_icon_state

/mob/living/basic/turtle/update_overlays()
	. = ..()
	if(stat == DEAD)
		var/mutable_appearance/dead_overlay = mutable_appearance(icon = 'icons/mob/simple/pets.dmi', icon_state = developed_path ? "dead_tree" : "growing_tree")
		dead_overlay.pixel_z = -2
		. += dead_overlay
		return
	var/pixel_offset = resting ?  -2 : 2
	var/mutable_appearance/living_tree = grown_tree ? grown_tree : mutable_appearance(icon = icon, icon_state = "growing_tree")
	living_tree.pixel_z = pixel_offset
	. += living_tree

/mob/living/basic/turtle/update_resting()
	. = ..()
	if(stat == DEAD)
		return
	update_appearance()

/mob/living/basic/turtle/item_interaction(mob/living/user, obj/item/used_item, list/modifiers)
	if(!istype(used_item, /obj/item/reagent_containers))
		return NONE

	if(isnull(used_item.reagents))
		balloon_alert(user, "empty!")
		return ITEM_INTERACT_SUCCESS

	if(stat == DEAD)
		balloon_alert(user, "its dead!")
		return ITEM_INTERACT_SUCCESS

	var/should_transfer = FALSE
	for(var/reagent in path_requirements)
		if(used_item.reagents.has_reagent(reagent))
			should_transfer = TRUE
			break

	if(!should_transfer)
		balloon_alert(user, "refuses to drink!")
		return ITEM_INTERACT_SUCCESS

	if(!do_after(user, 1.5 SECONDS, target = src))
		return ITEM_INTERACT_SUCCESS

	used_item.reagents.trans_to(reagents, 5)
	balloon_alert(user, "drinks happily")
	playsound(src, 'sound/items/drink.ogg', vol = 25, vary = TRUE)
	return ITEM_INTERACT_SUCCESS

/mob/living/basic/turtle/proc/pre_eat_food(datum/source, obj/item/seeds/potential_food)
	SIGNAL_HANDLER

	if(!istype(potential_food))
		return NONE

	return ispath(potential_food.product, /obj/item/food/grown) ? NONE : COMSIG_MOB_CANCEL_EAT

/mob/living/basic/turtle/proc/post_eat(datum/source, obj/item/seeds/potential_food)
	SIGNAL_HANDLER
	if(is_type_in_typecache(potential_food, indigestible_seeds))
		potential_food.forceMove(src)
		addtimer(CALLBACK(src, PROC_REF(process_food), potential_food), 20 SECONDS)
		return COMSIG_MOB_TERMINATE_EAT

	addtimer(CALLBACK(src, PROC_REF(process_food), potential_food.product), 30 SECONDS)
	return NONE

/mob/living/basic/turtle/proc/process_food(potential_food)
	if(QDELETED(src) || stat != CONSCIOUS)
		return

	if(ispath(potential_food))
		new potential_food(drop_location())

	else if((!isnull(potential_food)) && (potential_food in contents))
		var/atom/movable/movable_food = potential_food
		movable_food.forceMove(drop_location())

	balloon_alert_to_viewers("spits out some food")

/mob/living/basic/turtle/death(gibbed)
	. = ..()
	STOP_PROCESSING(SSprocessing, src)

#undef PATH_PEST_KILLER
#undef PATH_PLANT_HEALER
#undef PATH_PLANT_MUTATOR
#undef REQUIRED_TREE_GROWTH
#undef UPPER_BOUND_VOLUME
#undef LOWER_BOUND_VOLUME
