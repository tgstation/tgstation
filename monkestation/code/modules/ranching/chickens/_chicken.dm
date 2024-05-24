/mob/living/basic/proc/pass_stats(atom/child, mutant = FALSE)
	return

/mob/living/basic/chicken
	name = "\improper chicken"
	desc = "Hopefully the eggs are good this season."
	gender = FEMALE

	maxHealth = 15
	mob_biotypes = list(MOB_ORGANIC, MOB_BEAST)

	icon = 'monkestation/icons/mob/ranching/chickens.dmi'
	icon_state = "chicken_white"
	icon_living = "chicken_white"
	icon_dead = "dead_state"
	held_state = "chicken_white"

	speak_emote = list("clucks","croons")

	response_help_continuous = "pets"
	response_help_simple = "pet"
	response_disarm_continuous = "gently pushes aside"
	response_disarm_simple = "gently push aside"
	response_harm_continuous = "pecks"
	response_harm_simple = "peck"
	attack_verb_continuous = "pecks"
	attack_verb_simple = "peck"

	density = FALSE
	speed = 1.1
	butcher_results = list(/obj/item/food/meat/slab/chicken = 2)
	worn_slot_flags = ITEM_SLOT_HEAD
	can_be_held = TRUE
	pass_flags = PASSTABLE | PASSMOB
	mob_size = MOB_SIZE_SMALL
	chat_color = "#FFDC9B"

	egg_type = /obj/item/food/egg
	mutation_list = list(/datum/mutation/ranching/chicken/spicy, /datum/mutation/ranching/chicken/brown)

/mob/living/basic/chicken/Initialize(mapload)
	. = ..()
	pixel_x = rand(-6, 6)
	pixel_y = rand(0, 10)
	health = maxHealth

	AddComponent(/datum/component/mutation, mutation_list, TRUE)
	AddComponent(/datum/component/obeys_commands, pet_commands)
	AddComponent(/datum/component/friendship_container, list(FRIENDSHIP_HATED = -100, FRIENDSHIP_DISLIKED = -50, FRIENDSHIP_STRANGER = 0, FRIENDSHIP_NEUTRAL = 10, FRIENDSHIP_ACQUAINTANCES = 25, FRIENDSHIP_FRIEND = 50, FRIENDSHIP_BESTFRIEND = 100), FRIENDSHIP_ACQUAINTANCES)
	AddComponent(/datum/component/aging, death_callback = CALLBACK(src, PROC_REF(old_age_death)))
	AddComponent(/datum/component/happiness_container, max_happiness_per_generation, happy_chems, disliked_chemicals, liked_foods, disliked_foods, disliked_food_types, list(CALLBACK(src, PROC_REF(unhappy_death)) = minimum_living_happiness))
	AddComponent(/datum/component/generic_mob_hunger, 400, 0.5, 3 MINUTES, 200)
	AddComponent(/datum/component/hovering_information, /datum/hover_data/chicken_info)

	AddElement(/datum/element/swabable, CELL_LINE_TABLE_CHICKEN, CELL_VIRUS_TABLE_GENERIC_MOB, 1, 5)
	AddElement(/datum/element/footstep, FOOTSTEP_MOB_CLAW)

	ADD_TRAIT(src, TRAIT_VENTCRAWLER_ALWAYS, INNATE_TRAIT)

	RegisterSignal(src, COMSIG_HUNGER_UPDATED, PROC_REF(handle_hunger_updates))

	if(prob(40))
		gender = MALE

	assign_chicken_icon()
	if(gender == MALE && breed_name)
		if(breed_name_male)
			name = " [breed_name_male]"
		else
			name = "[breed_name] Rooster"
	else
		if(breed_name_female)
			name = " [breed_name_female]"
		else
			name = "[breed_name] Hen"

	build_initial_planning_tree()

	return INITIALIZE_HINT_LATELOAD

/mob/living/basic/chicken/proc/assign_chicken_icon()
	if(!icon_suffix) // should never be the case but if so default to the first set of icons
		return
	var/starting_prefix = "chicken"
	if(gender == MALE)
		starting_prefix = "rooster"
	icon_state = "[starting_prefix]_[icon_suffix]"
	held_state = "[starting_prefix]_[icon_suffix]"
	icon_living = "[starting_prefix]_[icon_suffix]"
	icon_dead = "dead_[icon_suffix]"

/mob/living/basic/chicken/update_overlays()
	. = ..()
	if(is_marked)
		.+= mutable_appearance('monkestation/icons/effects/ranching.dmi', "marked", FLOAT_LAYER, src, plane = src.plane)

/mob/living/basic/chicken/pass_stats(atom/child, mutant = FALSE)
	var/obj/item/food/egg/layed_egg = child

	layed_egg.faction_holder = src.faction
	layed_egg.layer_hen_type = src.type
	layed_egg.consumed_food = src.consumed_food
	layed_egg.consumed_reagents = src.consumed_reagents
	layed_egg.pixel_x = rand(-6,6)
	layed_egg.pixel_y = rand(-6,6)

	if(glass_egg_reagents)
		layed_egg.glass_egg_reagents = glass_egg_reagents
		layed_egg.food_reagents = glass_egg_reagents

	if(production_type)
		layed_egg.production_type = production_type

	if(eggs_fertile)
		if(prob(20 + (fertility_boosting * 0.1)) || length(layed_egg.possible_mutations)) //25
			if(mutant)
				layed_egg.AddComponent(/datum/component/hatching, 100, CALLBACK(layed_egg, TYPE_PROC_REF(/obj/item/food/egg, pre_hatch)), layed_egg.low_temp, layed_egg.high_temp, layed_egg.low_pressure, layed_egg.high_pressure, layed_egg.liquid_depth, layed_egg.turf_requirements, layed_egg.nearby_mob)
			else
				layed_egg.AddComponent(/datum/component/hatching, 100, CALLBACK(layed_egg, TYPE_PROC_REF(/obj/item/food/egg, pre_hatch)))

			SEND_SIGNAL(src, COMSIG_FRIENDSHIP_PASS_FRIENDSHIP, layed_egg)
			SEND_SIGNAL(src, COMSIG_HAPPINESS_PASS_HAPPINESS, layed_egg)
			layed_egg.desc = "You can hear pecking from the inside of this seems it may hatch soon."


/mob/living/basic/chicken/Destroy()
	consumed_food = null
	consumed_reagents = null
	mutation_list = null
	glass_egg_reagents = null
	disliked_foods = null
	return ..()

/mob/living/basic/chicken/AltClick(mob/user)
	. = ..()
	is_marked = !is_marked
	update_appearance()

/mob/living/basic/chicken/attack_hand(mob/living/carbon/human/user)
	..()
	if(stat == DEAD)
		return
	if(!(user.istate & ISTATE_HARM) && likes_pets && max_happiness_per_generation >= 3)
		adjust_happiness(1, user)
		max_happiness_per_generation -= 2 ///petting is not efficent
	else if(!(user.istate & ISTATE_HARM) && !likes_pets)
		adjust_happiness(-1, user)

/mob/living/basic/chicken/attackby(obj/item/given_item, mob/user, params)
	for(var/datum/mutation/ranching/mutation as anything in created_mutations)
		if(!length(mutation.nearby_items))
			continue
		if(given_item.type in mutation.nearby_items)
			mutation.nearby_items -= given_item.type
			user.visible_message(span_notice("[user] gives [given_item] to [src]"))
			qdel(given_item)
			return

	if(istype(given_item, /obj/item/chicken_feed))
		var/obj/item/chicken_feed/feed = given_item
		var/turf/open/targeted_turf = get_turf(src)
		var/list/compiled_reagents = list()
		for(var/datum/reagent/listed_reagent in feed.reagents.reagent_list)
			compiled_reagents += new listed_reagent.type
			compiled_reagents[listed_reagent] = listed_reagent.volume

		var/obj/effect/chicken_feed/new_feed = new(targeted_turf, feed.held_foods, compiled_reagents, mix_color_from_reagents(feed.reagents.reagent_list), feed.name)
		feed.placements_left--
		user.visible_message("[user] gives [src] some of the [feed.name]")
		if(feed.placements_left <= 0)
			qdel(feed)
		eat_feed(new_feed, user)
		SEND_SIGNAL(src, COMSIG_FRIENDSHIP_CHANGE, user, 1)
		return

	if(istype(given_item, /obj/item/food)) //feedin' dem chickens
		if(!stat && current_feed_amount <= 3 )
			feed_food(given_item, user)
			SEND_SIGNAL(src, COMSIG_FRIENDSHIP_CHANGE, user, 1)
		else
			var/turf/vomited_turf = get_turf(src)
			vomited_turf.add_vomit_floor(src, VOMIT_TOXIC)
			to_chat(user, "<span class='warning'>[name] can't keep the food down, it vomits all over the floor!</span>")
			adjust_happiness(-15, user)
			current_feed_amount -= 3
	else
		..()

/mob/living/basic/chicken/proc/feed_food(obj/item/given_item, mob/user)
	if(user)
		var/feedmsg = "[user] feeds [given_item] to [name]! [pick(feedMessages)]"
		user.visible_message(feedmsg)
	SEND_SIGNAL(src, COMSIG_LIVING_ATE, given_item, user)
	SEND_SIGNAL(src, COMSIG_MOB_FEED, given_item, 50)

	qdel(given_item)
	eggs_left += rand(0, 2)
	current_feed_amount++
	total_times_eaten ++
	for(var/datum/mutation/ranching/mutation as anything in created_mutations)
		if(!istype(mutation))
			continue

		if(length(mutation.food_requirements))
			if(given_item.type in mutation.food_requirements)
				mutation.food_requirements -= given_item.type

/mob/living/basic/chicken/proc/eat_feed(obj/effect/chicken_feed/eaten_feed, mob/user)
	SEND_SIGNAL(src, COMSIG_LIVING_ATE, eaten_feed)
	SEND_SIGNAL(src, COMSIG_MOB_FEED, eaten_feed, 25 + (15 * length(eaten_feed.held_foods)) + (10 * length(eaten_feed.held_reagents)))

	if(length(eaten_feed.held_reagents))
		for(var/datum/reagent/listed_reagent in eaten_feed.held_reagents)
			listed_reagent.feed_interaction(src, listed_reagent.volume, user)
			consumed_reagents |= listed_reagent.type

			for(var/datum/mutation/ranching/mutation as anything in created_mutations)
				if(!istype(mutation))
					continue

				if(length(mutation.reagent_requirements))
					if(listed_reagent.type in mutation.reagent_requirements)
						mutation.reagent_requirements -= listed_reagent.type

	for(var/listed_item in eaten_feed.held_foods)
		var/obj/item/food/listed_food = new listed_item
		consumed_food |= listed_food.type

		for(var/datum/mutation/ranching/mutation as anything in created_mutations)
			if(!istype(mutation))
				continue

			if(length(mutation.food_requirements))
				if(listed_food.type in mutation.food_requirements)
					mutation.food_requirements -= listed_food.type

		qdel(listed_food)

	total_times_eaten++
	eggs_left += rand(1, 3)
	qdel(eaten_feed)

/mob/living/basic/chicken/Life()
	. =..()
	if(!.)
		return

	if(instability > initial(instability))
		instability = max(initial(instability), instability - 2)

	if(fertility_boosting > initial(fertility_boosting))
		fertility_boosting = max(initial(fertility_boosting), fertility_boosting - 2)

	if(egg_laying_boosting > initial(egg_laying_boosting))
		egg_laying_boosting = max(initial(egg_laying_boosting), egg_laying_boosting - 2)

	var/animal_count = 0
	for(var/mob/living/basic/animals in view(1, src))
		animal_count ++
	if(animal_count >= overcrowding)
		adjust_happiness(-1)

	if(!stat && prob(3) && current_feed_amount > 0)
		current_feed_amount--

/mob/living/basic/chicken/proc/adjust_happiness(amount, atom/source, natural_cause = FALSE)
	SEND_SIGNAL(src, COMSIG_HAPPINESS_ADJUST, amount, source, natural_cause)

/mob/living/basic/chicken/proc/old_age_death()
	death()

/mob/living/basic/chicken/proc/build_initial_planning_tree()
	var/list/new_planning_subtree = list()

	new_planning_subtree |= /datum/ai_planning_subtree/pet_planning

	var/datum/action/cooldown/mob_cooldown/chicken/feed/feed_ability = new(src)
	feed_ability.Grant(src)
	ai_controller.blackboard[BB_CHICKEN_FEED] = feed_ability
	new_planning_subtree |= /datum/ai_planning_subtree/targeted_mob_ability/min_range/chicken/feed

	if(gender == FEMALE)
		var/datum/action/cooldown/mob_cooldown/chicken/lay_egg/new_ability = new(src)
		new_ability.Grant(src)
		ai_controller.blackboard[BB_CHICKEN_LAY_EGG] = new_ability
		new_planning_subtree |= /datum/ai_planning_subtree/targeted_mob_ability/min_range/chicken/lay_egg

	if(targeted_ability)
		var/datum/action/cooldown/mob_cooldown/created_ability = new targeted_ability(src)
		created_ability.Grant(src)
		ai_controller.blackboard[BB_CHICKEN_TARGETED_ABILITY] = created_ability
		new_planning_subtree |= targeted_ability_planning_tree

	if(self_ability)
		var/datum/action/cooldown/mob_cooldown/created_ability = new self_ability(src)
		created_ability.Grant(src)
		ai_controller.blackboard[BB_CHICKEN_SELF_ABILITY] = created_ability
		new_planning_subtree |= ability_planning_tree

	if(projectile_type)
		AddComponent(/datum/component/ranged_attacks, projectile_sound = 'sound/weapons/barragespellhit.ogg', projectile_type = src.projectile_type, cooldown_time = ranged_cooldown)
		new_planning_subtree |= /datum/ai_planning_subtree/basic_ranged_attack_subtree/chicken

	for(var/datum/ai_planning_subtree/listed_tree as anything in ai_controller.planning_subtrees)
		new_planning_subtree |= listed_tree.type

	ai_controller.replace_planning_subtrees(new_planning_subtree)

/mob/living/basic/chicken/proc/unhappy_death()
	death()

/mob/living/basic/chicken/proc/handle_hunger_updates(datum/source, current_hunger, max_hunger)
	SIGNAL_HANDLER

	var/hunger_precent = current_hunger / max_hunger

	if(hunger_precent > 0.1)
		return

	if(prob(5))
		visible_message("[name] starts pecking at the floor, it must be hungry.")
	adjust_happiness(-0.01, natural_cause = TRUE)
