/mob/living/basic/proc/pass_stats(atom/child)
	return


/datum/ai_controller/basic_controller/chick
	blackboard = list(
		BB_TARGETING_STRATEGY = /datum/targeting_strategy/basic,
		BB_FIND_MOM_TYPES = list(/mob/living/basic/chicken),
		BB_IGNORE_MOM_TYPES = list(/mob/living/basic/chick),
	)

	ai_traits = STOP_MOVING_WHEN_PULLED
	ai_movement = /datum/ai_movement/basic_avoidance
	idle_behavior = /datum/idle_behavior/idle_random_walk

	planning_subtrees = list(
		/datum/ai_planning_subtree/find_nearest_thing_which_attacked_me_to_flee,
		/datum/ai_planning_subtree/flee_target,
		/datum/ai_planning_subtree/look_for_adult,
	)

/**
 * ## Chicks
 *
 * Baby birds that grow into big chickens.
 */
/mob/living/basic/chick
	name = "\improper chick"
	desc = "Adorable! They make such a racket though."
	icon = 'monkestation/icons/mob/ranching/chickens.dmi'
	icon_state = "chick"
	icon_living = "chick"
	icon_dead = "chick_dead"
	icon_gib = "chick_gib"
	gender = FEMALE
	mob_biotypes = MOB_ORGANIC|MOB_BEAST
	speak_emote = list("cheeps")
	density = FALSE
	butcher_results = list(/obj/item/food/meat/slab/chicken = 1)
	response_help_continuous = "pets"
	response_help_simple = "pet"
	response_disarm_continuous = "gently pushes aside"
	response_disarm_simple = "gently push aside"
	response_harm_continuous = "kicks"
	response_harm_simple = "kick"
	attack_verb_continuous = "kicks"
	attack_verb_simple = "kick"
	health = 3
	maxHealth = 3
	pass_flags = PASSTABLE | PASSGRILLE | PASSMOB
	mob_size = MOB_SIZE_TINY
	gold_core_spawnable = FRIENDLY_SPAWN

	ai_controller = /datum/ai_controller/basic_controller/chick

	/// What we grow into.
	var/grown_type = /mob/living/basic/chicken
	///Glass chicken exclusive:what reagent were the eggs filled with?
	var/list/glass_egg_reagent = list()
	///Stone Chicken Exclusive: what ore type is in the eggs?
	var/obj/item/stack/ore/production_type = null
	/// list of friends inherited by parent
	var/list/Friends = list()

/mob/living/basic/chick/Initialize(mapload)
	. = ..()
	pixel_x = base_pixel_x + rand(-6, 6)
	pixel_y = base_pixel_y + rand(0, 10)

	ADD_TRAIT(src, TRAIT_VENTCRAWLER_ALWAYS, INNATE_TRAIT)

	AddElement(/datum/element/pet_bonus, "chirps!")
	AddElement(/datum/element/swabable, CELL_LINE_TABLE_CHICKEN, CELL_VIRUS_TABLE_GENERIC_MOB, 1, 5)
	AddElement(/datum/element/footstep, FOOTSTEP_MOB_CLAW)

	if(!isnull(grown_type)) // we don't have a set time to grow up beyond whatever RNG dictates, and if we somehow get a client, all growth halts.
		AddComponent(\
			/datum/component/growth_and_differentiation,\
			growth_time = null,\
			growth_path = grown_type,\
			growth_probability = 100,\
			lower_growth_value = 1,\
			upper_growth_value = 2,\
			signals_to_kill_on = list(COMSIG_MOB_CLIENT_LOGIN),\
			optional_checks = CALLBACK(src, PROC_REF(ready_to_grow)),\
			optional_grow_behavior = CALLBACK(src, PROC_REF(grow_up)),\
		)

/// We don't grow into a chicken if we're not conscious.
/mob/living/basic/chick/proc/ready_to_grow()
	return (stat == CONSCIOUS)

/// Variant of chick that just spawns in the holodeck so you can pet it. Doesn't grow up.
/mob/living/basic/chick/permanent
	grown_type = null

/mob/living/basic/chick/proc/assign_chick_icon(mob/living/basic/chicken/chicken_type)
	if(!chicken_type) // do we have a grown type?
		return

	var/mob/living/basic/chicken/hatched_type = new chicken_type(src)
	icon_state = "chick_[hatched_type.icon_suffix]"
	held_state = "chick_[hatched_type.icon_suffix]"
	icon_living = "chick_[hatched_type.icon_suffix]"
	icon_dead = "dead_[hatched_type.icon_suffix]"
	qdel(hatched_type)

/mob/living/basic/chick/proc/grow_up()
	if(!grown_type)
		return
	var/mob/living/basic/chicken/new_chicken = new grown_type(src.loc)
	new_chicken.Friends = src.Friends
	new_chicken.happiness = src.happiness
	new_chicken.age += rand(1,10) //add a bit of age to each chicken causing staggered deaths

	for(var/mob/living/friend as anything in new_chicken.Friends)
		if(new_chicken.Friends[friend] >= 25)
			new_chicken.befriend(friend)

	if(istype(new_chicken, /mob/living/basic/chicken/glass))
		for(var/list_item in glass_egg_reagent)
			new_chicken.glass_egg_reagents.Add(list_item)

	if(istype(new_chicken, /mob/living/basic/chicken/stone))
		if(production_type)
			new_chicken.production_type = production_type
	qdel(src)


/mob/living/basic/chick/death(gibbed)
	Friends = null
	..()

/mob/living/basic/chick/Destroy()
	Friends = null
	return ..()

/mob/living/basic/chick/proc/absorb_eggstat(obj/item/food/egg/host_egg)
	for(var/listed_faction in host_egg.faction_holder)
		src.faction |= listed_faction

	src.happiness = host_egg.happiness
	src.Friends = host_egg.Friends
	if(istype(grown_type, /mob/living/basic/chicken/glass))
		for(var/list_item in host_egg.glass_egg_reagents)
			src.glass_egg_reagent.Add(list_item)

	if(istype(grown_type, /mob/living/basic/chicken/stone))
		if(host_egg.production_type)
			src.production_type = host_egg.production_type

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

	AddComponent(/datum/component/mutation, mutation_list, TRUE)
	AddElement(/datum/element/swabable, CELL_LINE_TABLE_CHICKEN, CELL_VIRUS_TABLE_GENERIC_MOB, 1, 5)
	AddElement(/datum/element/footstep, FOOTSTEP_MOB_CLAW)
	AddComponent(/datum/component/obeys_commands, pet_commands)
	ADD_TRAIT(src, TRAIT_VENTCRAWLER_ALWAYS, INNATE_TRAIT)
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

	var/list/new_planning_subtree = list()

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
		AddComponent(/datum/component/ranged_attacks, projectile_type = src.projectile_type, cooldown_time = ranged_cooldown)
		new_planning_subtree |= /datum/ai_planning_subtree/basic_ranged_attack_subtree/chicken

	for(var/datum/ai_planning_subtree/listed_tree as anything in ai_controller.planning_subtrees)
		new_planning_subtree |= listed_tree.type

	ai_controller.replace_planning_subtrees(new_planning_subtree)

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

/mob/living/basic/chicken/proc/add_visual(method)
	if(applied_visual)
		return
	applied_visual = mutable_appearance('monkestation/icons/effects/ranching_text.dmi', "chicken_[method]", FLOAT_LAYER, src, plane = src.plane)
	add_overlay(applied_visual)
	addtimer(CALLBACK(src, PROC_REF(remove_visual)), 3 SECONDS)

/mob/living/basic/chicken/proc/remove_visual()
	cut_overlay(applied_visual)
	applied_visual = null

/mob/living/basic/chicken/pass_stats(atom/child)
	var/obj/item/food/egg/layed_egg = child

	layed_egg.Friends = src.Friends
	layed_egg.faction_holder = src.faction
	layed_egg.layer_hen_type = src.type
	layed_egg.happiness = src.happiness
	layed_egg.consumed_food = src.consumed_food
	layed_egg.consumed_reagents = src.consumed_reagents
	layed_egg.pixel_x = rand(-6,6)
	layed_egg.pixel_y = rand(-6,6)

	if(glass_egg_reagents)
		layed_egg.food_reagents = glass_egg_reagents

	if(production_type)
		layed_egg.production_type = production_type

	if(eggs_fertile)
		if(prob(20 + (fertility_boosting * 0.1)) || layed_egg.possible_mutations.len) //25
			START_PROCESSING(SSobj, layed_egg)
			layed_egg.is_fertile = TRUE
			flop_animation(layed_egg)
			layed_egg.desc = "You can hear pecking from the inside of this seems it may hatch soon."

/mob/living/basic/chicken/death(gibbed)
	Friends = null
	..()

/mob/living/basic/chicken/Destroy()
	Friends = null
	consumed_food = null
	consumed_reagents = null
	mutation_list = null
	glass_egg_reagents = null
	speech_buffer = null
	applied_visual = null
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
	if(istype(given_item, /obj/item/food)) //feedin' dem chickens
		if(!stat && current_feed_amount <= 3 )
			feed_food(given_item, user)
			set_friendship(user, 1)
		else
			var/turf/vomited_turf = get_turf(src)
			vomited_turf.add_vomit_floor(src, VOMIT_TOXIC)
			to_chat(user, "<span class='warning'>[name] can't keep the food down, it vomits all over the floor!</span>")
			adjust_happiness(-15, user)
			current_feed_amount -= 3
	else
		..()

/mob/living/basic/chicken/proc/set_friendship(atom/new_friend, amount = 1)
	if(!Friends[new_friend])
		Friends[new_friend] = 0
	Friends[new_friend] += amount
	if(Friends[new_friend] >= 25)
		befriend(new_friend)

/mob/living/basic/chicken/proc/feed_food(obj/item/given_item, mob/user)
	handle_happiness_changes(given_item, user)
	if(user)
		var/feedmsg = "[user] feeds [given_item] to [name]! [pick(feedMessages)]"
		user.visible_message(feedmsg)

	qdel(given_item)
	eggs_left += rand(0, 2)
	current_feed_amount ++
	total_times_eaten ++

/mob/living/basic/chicken/proc/eat_feed(obj/effect/chicken_feed/eaten_feed)
	if(eaten_feed.held_reagents.len)
		for(var/datum/reagent/listed_reagent in eaten_feed.held_reagents)
			listed_reagent.feed_interaction(src, listed_reagent.volume)
			consumed_reagents |= listed_reagent

	for(var/listed_item in eaten_feed.held_foods)
		var/obj/item/food/listed_food = new listed_item
		consumed_food |= listed_food.type

		for(var/food_type in listed_food.foodtypes)
			if(food_type in disliked_food_types)
				var/type_value = disliked_food_types[food_type]
				adjust_happiness(-type_value)

		if((listed_food.type in liked_foods) && max_happiness_per_generation >= liked_foods[listed_food.type])
			var/liked_value = liked_foods[listed_food.type]
			adjust_happiness(liked_value)

		else if(listed_food.type in disliked_foods)
			var/disliked_value = disliked_foods[listed_food.type]
			adjust_happiness(-disliked_value)
		qdel(listed_food)
	total_times_eaten++
	eggs_left += rand(1, 3)
	qdel(eaten_feed)

/mob/living/basic/chicken/proc/handle_happiness_changes(obj/given_item, mob/user)
	for(var/datum/reagent/reagent in given_item.reagents.reagent_list)
		if(reagent in happy_chems && max_happiness_per_generation >= (happy_chems[reagent.type] * reagent.volume))
			var/liked_value = happy_chems[reagent.type]
			adjust_happiness(liked_value * reagent.volume, user)
		else if(reagent in disliked_chemicals)
			var/disliked_value = disliked_chemicals[reagent.type]
			adjust_happiness(-(disliked_value * reagent.volume), user)
		if(!(reagent in consumed_reagents))
			consumed_reagents.Add(reagent)

	if(!istype(given_item, /obj/item/food))
		return

	var/obj/item/food/placeholder_food_item = given_item
	if(!(placeholder_food_item.type in consumed_food))
		consumed_food.Add(placeholder_food_item.type)

	for(var/food_type in placeholder_food_item.foodtypes)
		if(food_type in disliked_food_types)
			var/type_value = disliked_food_types[food_type]
			adjust_happiness(-type_value, user)

	if((placeholder_food_item.type in liked_foods) && max_happiness_per_generation >= liked_foods[placeholder_food_item.type])
		var/liked_value = liked_foods[placeholder_food_item.type]
		adjust_happiness(liked_value, user)

	else if(placeholder_food_item.type in disliked_foods)
		var/disliked_value = disliked_foods[placeholder_food_item.type]
		adjust_happiness(-disliked_value, user)

/mob/living/basic/chicken/Hear(message, atom/movable/speaker, message_langs, raw_message, radio_freq, spans, list/message_mods = list())
	. = ..()
	if(speaker != src && !radio_freq && !stat)
		if (speaker in Friends)
			speech_buffer = list()
			speech_buffer += speaker
			speech_buffer += lowertext(html_decode(message))

/mob/living/basic/chicken/Life()
	. =..()
	if(!.)
		return
	if(COOLDOWN_FINISHED(src, age_cooldown))
		COOLDOWN_START(src, age_cooldown, age_speed)
		age ++

	if(age > max_age)
		src.death()

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

	if(current_feed_amount == 0)
		adjust_happiness(-0.01, natural_cause = TRUE)

	if(happiness < minimum_living_happiness)
		src.death()
	if(!stat && prob(3) && current_feed_amount > 0)
		current_feed_amount --
		if(current_feed_amount == 0)
			var/list/users = get_hearers_in_view(4, src.loc)
			for(var/mob/living/carbon/human/user in users)
				user.visible_message("[src] starts pecking at the floor, it must be hungry.")

/obj/item/food/egg/process(seconds_per_tick)
	amount_grown += rand(3,6) * seconds_per_tick
	if(amount_grown >= 100)
		pre_hatch()

/obj/item/food/egg/pickup(mob/user)
	. = ..()
	STOP_PROCESSING(SSobj, src)

/obj/item/food/egg/dropped(mob/user, silent)
	. = ..()
	if(is_fertile)
		START_PROCESSING(SSobj, src)

/obj/item/food/egg/proc/pre_hatch()
	var/list/final_mutations = list()
	var/failed_mutations = FALSE
	for(var/datum/mutation/ranching/chicken/mutation in possible_mutations)
		if(mutation.cycle_requirements(src, TRUE))
			final_mutations |= mutation
		else
			desc = "Huh it seems like nothing is coming out of this one, maybe it needed something else?"
			failed_mutations = TRUE
			animate(src, transform = matrix()) //stop animation

	hatch(final_mutations, failed_mutations)

/obj/item/food/egg/proc/hatch(list/possible_mutations, failed_mutations)
	STOP_PROCESSING(SSobj, src)
	if(failed_mutations || !src.loc)
		return
	var/mob/living/basic/chick/birthed = new /mob/living/basic/chick(src.loc)

	if(possible_mutations.len)
		var/datum/mutation/ranching/chicken/chosen_mutation = pick(possible_mutations)
		birthed.grown_type = chosen_mutation.chicken_type
		if(chosen_mutation.nearby_items.len)
			absorbed_required_items(chosen_mutation.nearby_items)
	else
		birthed.grown_type = layer_hen_type //if no possible mutations default to layer hen type

	if(birthed.grown_type == /mob/living/basic/chicken/glass)
		for(var/list_item in src.reagents.reagent_list)
			birthed.glass_egg_reagent.Add(list_item)

	if(birthed.grown_type == /mob/living/basic/chicken/stone)
		birthed.production_type = src.production_type

	birthed.absorb_eggstat(src)
	birthed.assign_chick_icon(birthed.grown_type)
	visible_message("[src] hatches with a quiet cracking sound.")
	qdel(src)

/obj/item/food/egg/proc/absorbed_required_items(list/required_items)
	for(var/item in required_items)
		var/obj/item/removal_item = item
		var/obj/item/temp = locate(removal_item) in view(3, src.loc)
		if(temp)
			visible_message("[src] absorbs the nearby [temp.name] into itself.")
			qdel(temp)

/mob/living/basic/chicken/turkey
	name = "\improper turkey"
	desc = "it's that time again."
	breed_name = null
	icon_state = "turkey_plain"
	icon_living = "turkey_plain"
	icon_dead = "turkey_plain_dead"
	speak_emote = list("clucks","gobbles")
	density = FALSE
	health = 15
	maxHealth = 15
	response_harm_continuous = "pecks"
	feedMessages = list("It gobbles up the food voraciously.","It clucks happily.")
	chat_color = "#FFDC9B"
	breed_name_male = "Turkey"
	breed_name_female = "Turkey"

	mutation_list = list()


/mob/living/basic/chicken/turkey/LateInitialize() //reset this as regular chickens override
	. = ..()
	icon_state = "turkey_plain"
	icon_living = "turkey_plain"
	icon_dead = "turkey_plain_dead"

/mob/living/basic/chicken/hen/LateInitialize()
	.=..()
	gender = FEMALE

/mob/living/basic/chicken/proc/adjust_happiness(amount, atom/source, natural_cause = FALSE)
	happiness += amount
	if(amount > 0)
		max_happiness_per_generation -= amount
		add_visual("love")
	else
		if(!natural_cause)
			add_visual("angry")
	if(source)
		set_friendship(source, amount * 0.5)


/datum/action/cooldown/mob_cooldown/chicken/lay_egg
	name = "Lay Egg"
	desc = "Lay an egg."
	button_icon = 'icons/mob/actions/actions_ecult.dmi'
	button_icon_state = "eye"
	background_icon_state = "bg_demon"
	overlay_icon_state = "bg_demon_border"

	click_to_activate = FALSE
	cooldown_time = 15 SECONDS
	check_flags = AB_CHECK_CONSCIOUS | AB_CHECK_INCAPACITATED
	shared_cooldown = NONE
	what_range = /datum/ai_behavior/targeted_mob_ability/min_range/chicken/on_top

/datum/action/cooldown/mob_cooldown/chicken/lay_egg/PreActivate(atom/target)
	var/mob/living/basic/chicken/chicken_owner = owner
	if(!istype(chicken_owner))
		return
	if(chicken_owner.eggs_left <= 0)
		return
	. = ..()

/datum/action/cooldown/mob_cooldown/chicken/lay_egg/Activate(atom/target)
	. = ..()
	var/mob/living/basic/chicken/chicken_owner = owner
	chicken_owner.visible_message("[chicken_owner] [pick(chicken_owner.layMessage)]")

	var/passes_minimum_checks = FALSE
	if(chicken_owner.total_times_eaten > 4 && prob(25 + chicken_owner.instability))
		passes_minimum_checks = TRUE

	SEND_SIGNAL(chicken_owner, COMSIG_MUTATION_TRIGGER, get_turf(chicken_owner), passes_minimum_checks)
	chicken_owner.eggs_left--
	StartCooldown(cooldown_time / max(1, (chicken_owner.egg_laying_boosting * 0.02)))
	return TRUE

/datum/action/cooldown/mob_cooldown/chicken/feed
	name = "Feast"
	desc = "Eat from some laid feed."
	button_icon = 'icons/mob/actions/actions_ecult.dmi'
	button_icon_state = "eye"
	background_icon_state = "bg_demon"
	overlay_icon_state = "bg_demon_border"

	cooldown_time = 20 SECONDS
	check_flags = AB_CHECK_CONSCIOUS | AB_CHECK_INCAPACITATED
	shared_cooldown = NONE
	what_range = /datum/ai_behavior/targeted_mob_ability/min_range/chicken/on_top

/datum/action/cooldown/mob_cooldown/chicken/feed/PreActivate(atom/target)
	if(!istype(target, /obj/effect/chicken_feed))
		return
	if(!owner.CanReach(target))
		return
	. = ..()

/datum/action/cooldown/mob_cooldown/chicken/feed/Activate(atom/target)
	. = ..()
	var/mob/living/basic/chicken/chicken_owner = owner
	chicken_owner.eat_feed(target)
	StartCooldown()
	return TRUE

#define PAUSE_BETWEEN_PHASES 15
#define PAUSE_BETWEEN_FLOPS 2
#define FLOP_COUNT 2
#define FLOP_DEGREE 20
#define FLOP_SINGLE_MOVE_TIME 1.5
#define JUMP_X_DISTANCE 5
#define JUMP_Y_DISTANCE 6
/// This animation should be applied to actual parent atom instead of vc_object.
/proc/flop_animation(atom/movable/animation_target)
	var/pause_between = PAUSE_BETWEEN_PHASES + rand(1, 5) //randomized a bit so fish are not in sync
	animate(animation_target, time = pause_between, loop = -1)
	//move nose down and up
	for(var/_ in 1 to FLOP_COUNT)
		var/matrix/up_matrix = matrix()
		up_matrix.Turn(FLOP_DEGREE)
		var/matrix/down_matrix = matrix()
		down_matrix.Turn(-FLOP_DEGREE)
		animate(transform = down_matrix, time = FLOP_SINGLE_MOVE_TIME, loop = -1)
		animate(transform = up_matrix, time = FLOP_SINGLE_MOVE_TIME, loop = -1)
		animate(transform = matrix(), time = FLOP_SINGLE_MOVE_TIME, loop = -1, easing = BOUNCE_EASING | EASE_IN)
		animate(time = PAUSE_BETWEEN_FLOPS, loop = -1)
	//bounce up and down
	animate(time = pause_between, loop = -1, flags = ANIMATION_PARALLEL)
	var/jumping_right = FALSE
	var/up_time = 3 * FLOP_SINGLE_MOVE_TIME / 2
	for(var/_ in 1 to FLOP_COUNT)
		jumping_right = !jumping_right
		var/x_step = jumping_right ? JUMP_X_DISTANCE/2 : -JUMP_X_DISTANCE/2
		animate(time = up_time, pixel_y = JUMP_Y_DISTANCE , pixel_x=x_step, loop = -1, flags= ANIMATION_RELATIVE, easing = BOUNCE_EASING | EASE_IN)
		animate(time = up_time, pixel_y = -JUMP_Y_DISTANCE, pixel_x=x_step, loop = -1, flags= ANIMATION_RELATIVE, easing = BOUNCE_EASING | EASE_OUT)
		animate(time = PAUSE_BETWEEN_FLOPS, loop = -1)
#undef PAUSE_BETWEEN_PHASES
#undef PAUSE_BETWEEN_FLOPS
#undef FLOP_COUNT
#undef FLOP_DEGREE
#undef FLOP_SINGLE_MOVE_TIME
#undef JUMP_X_DISTANCE
#undef JUMP_Y_DISTANCE
