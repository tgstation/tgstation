/mob/living/simple_animal/proc/pass_stats(atom/child)
	return
/mob/living/simple_animal/chick
	name = "\improper chick"
	desc = "Adorable! They make such a racket though."
	icon = 'monkestation/icons/mob/ranching/chickens.dmi'
	icon_state = "chick"
	icon_living = "chick"
	icon_dead = "dead_state"
	icon_gib = "chick_gib"
	worn_slot_flags = ITEM_SLOT_HEAD
	held_state = "chick"
	gender = FEMALE
	mob_biotypes = list(MOB_ORGANIC, MOB_BEAST)
	speak = list("Cherp.","Cherp?","Chirrup.","Cheep!")
	speak_emote = list("cheeps")
	emote_hear = list("cheeps.")
	emote_see = list("pecks at the ground.","flaps its tiny wings.")
	density = FALSE
	speak_chance = 2
	turns_per_move = 2
	butcher_results = list(/obj/item/food/meat/slab/chicken = 1)
	response_help  = "pets"
	response_disarm = "gently pushes aside"
	response_harm   = "pecks"
	attacktext = "pecks"
	health = 3
	maxHealth = 3
	ventcrawler = VENTCRAWLER_ALWAYS
	pass_flags = PASSTABLE | PASSGRILLE | PASSMOB
	mob_size = MOB_SIZE_TINY
	chat_color = "#FFDC9B"

	do_footstep = TRUE

	///How close to being an adult is this chicken
	var/amount_grown = 0
	///What type of chicken is this?
	var/grown_type = /mob/living/simple_animal/chicken
	///Glass chicken exclusive:what reagent were the eggs filled with?
	var/list/glass_egg_reagent = list()
	///Stone Chicken Exclusive: what ore type is in the eggs?
	var/obj/item/stack/ore/production_type = null
	/// list of friends inherited by parent
	var/list/friends = list()

/mob/living/simple_animal/chick/Initialize(mapload)
	. = ..()
	pixel_x = rand(-6, 6)
	pixel_y = rand(0, 10)
	GLOB.total_chickens++

/mob/living/simple_animal/chick/proc/assign_chick_icon(mob/living/simple_animal/chicken/chicken_type)
	if(!chicken_type) // do we have a grown type?
		return

	var/mob/living/simple_animal/chicken/hatched_type = new chicken_type(src)
	icon_state = "chick_[hatched_type.icon_suffix]"
	held_state = "chick_[hatched_type.icon_suffix]"
	icon_living = "chick_[hatched_type.icon_suffix]"
	icon_dead = "dead_[hatched_type.icon_suffix]"
	qdel(hatched_type)

/mob/living/simple_animal/chick/Life()
	. =..()
	if(!.)
		return
	if(!stat && !ckey)
		amount_grown += rand(1,2)
		if(amount_grown >= 100)
			if(!grown_type)
				return
			var/mob/living/simple_animal/chicken/new_chicken = new grown_type(src.loc)
			new_chicken.Friends = src.friends
			new_chicken.age += rand(1,10) //add a bit of age to each chicken causing staggered deaths
			if(istype(new_chicken, /mob/living/simple_animal/chicken/glass))
				for(var/list_item in glass_egg_reagent)
					new_chicken.glass_egg_reagents.Add(list_item)

			if(istype(new_chicken, /mob/living/simple_animal/chicken/stone))
				if(production_type)
					new_chicken.production_type = production_type
			qdel(src)

/mob/living/simple_animal/chick/death(gibbed)
	friends = null
	GLOB.total_chickens--
	..()

/mob/living/simple_animal/chick/Destroy()
	friends = null
	if(stat != DEAD)
		GLOB.total_chickens--
	return ..()

/mob/living/simple_animal/chick/holo/Life()
	..()
	amount_grown = 0

/mob/living/simple_animal/chicken
	name = "\improper chicken"
	desc = "Hopefully the eggs are good this season."
	gender = FEMALE

	maxHealth = 15
	mob_biotypes = list(MOB_ORGANIC, MOB_BEAST)

	icon = 'monkestation/icons/mob/ranching/chickens.dmi'
	icon_state = "chicken_white"
	icon_living = "chicken_white"
	icon_dead = "dead_state"
	head_icon = 'icons/mob/pets_held_large.dmi'
	held_state = "chicken_white"

	speak_chance = 2
	speak = list("Cluck!","BWAAAAARK BWAK BWAK BWAK!","Bwaak bwak.")
	speak_emote = list("clucks","croons")
	emote_hear = list("clucks.")
	emote_see = list("pecks at the ground.","flaps its wings viciously.")

	response_help  = "pets"
	response_disarm = "gently pushes aside"
	response_harm   = "kicks"
	attacktext = "kicks"

	density = FALSE
	turns_per_move = 3
	butcher_results = list(/obj/item/food/meat/slab/chicken = 2)
	ventcrawler = VENTCRAWLER_ALWAYS
	worn_slot_flags = ITEM_SLOT_HEAD
	can_be_held = TRUE
	pass_flags = PASSTABLE | PASSMOB
	mob_size = MOB_SIZE_SMALL
	chat_color = "#FFDC9B"
	mobchatspan = "stationengineer"

	do_footstep = TRUE

	egg_type = /obj/item/food/egg
	mutation_list = list(/datum/mutation/ranching/chicken/spicy, /datum/mutation/ranching/chicken/brown)

/obj/effect/proc_holder/spell/self/lay_egg
	name = "Lay Egg"
	desc = "Lays an egg assuming you've been fed"
	school = "mime"
	antimagic_allowed = TRUE
	clothes_req = TRUE
	human_req = FALSE
	charge_max = 60 SECONDS
	charge_counter = 3

	action_icon = 'monkestation/icons/obj/ranching/eggs.dmi'
	action_icon_state = "chicken"

/obj/effect/proc_holder/spell/self/lay_egg/can_cast(mob/user = usr)
	. = ..()
	if(!isturf(user.loc))
		return FALSE

/obj/effect/proc_holder/spell/self/lay_egg/cast(mob/living/simple_animal/chicken/user = usr)
	if(user.eggs_left <= 0)
		to_chat(user, span_notice("You can't seem to lay any eggs"))
		return
	var/passes_minimum_checks = FALSE
	if(user.total_times_eaten > 4 && prob(25))
		passes_minimum_checks = TRUE
	SEND_SIGNAL(user, COMSIG_MUTATION_TRIGGER, get_turf(user), passes_minimum_checks)
	user.eggs_left--

/mob/living/simple_animal/chicken/Initialize(mapload)
	. = ..()
	pixel_x = rand(-6, 6)
	pixel_y = rand(0, 10)
	GLOB.total_chickens++
	AddComponent(/datum/component/mutation, mutation_list, TRUE)
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

	if(unique_ability)
		ai_controller.blackboard[BB_CHICKEN_SPECALITY_ABILITY] = unique_ability

	AddSpell(new /obj/effect/proc_holder/spell/self/lay_egg)
	return INITIALIZE_HINT_LATELOAD

/mob/living/simple_animal/chicken/proc/assign_chicken_icon()
	if(!icon_suffix) // should never be the case but if so default to the first set of icons
		return
	var/starting_prefix = "chicken"
	if(gender == MALE)
		starting_prefix = "rooster"
	icon_state = "[starting_prefix]_[icon_suffix]"
	held_state = "[starting_prefix]_[icon_suffix]"
	icon_living = "[starting_prefix]_[icon_suffix]"
	icon_dead = "dead_[icon_suffix]"

/mob/living/simple_animal/chicken/update_overlays()
	. = ..()
	if(is_marked)
		.+= mutable_appearance('monkestation/icons/effects/ranching.dmi', "marked", FLOAT_LAYER, src.plane)

/mob/living/simple_animal/chicken/proc/add_visual(method)
	if(applied_visual)
		return
	applied_visual = mutable_appearance('monkestation/icons/effects/ranching_text.dmi', "chicken_[method]", FLOAT_LAYER, src.plane)
	add_overlay(applied_visual)
	addtimer(CALLBACK(src, .proc/remove_visual), 3 SECONDS)

/mob/living/simple_animal/chicken/proc/remove_visual()
	cut_overlay(applied_visual)
	applied_visual = null

/mob/living/simple_animal/chicken/pass_stats(atom/child)
	var/obj/item/food/egg/layed_egg = child

	layed_egg.Friends = src.Friends
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
		if(prob(40) || layed_egg.possible_mutations.len) //25
			START_PROCESSING(SSobj, layed_egg)
			layed_egg.is_fertile = TRUE
			flop_animation(layed_egg)
			layed_egg.desc = "You can hear pecking from the inside of this seems it may hatch soon."

/mob/living/simple_animal/chicken/death(gibbed)
	Friends = null
	GLOB.total_chickens--
	..()

/mob/living/simple_animal/chicken/Destroy()
	Friends = null
	if(stat != DEAD)
		GLOB.total_chickens--
	return ..()

/mob/living/simple_animal/chicken/AltClick(mob/user)
	. = ..()
	is_marked = !is_marked
	update_appearance()

/mob/living/simple_animal/chicken/attack_hand(mob/living/carbon/human/user)
	..()
	if(stat == DEAD)
		return
	if(user.a_intent == "help" && likes_pets && max_happiness_per_generation >= 3)
		adjust_happiness(1, user)
		max_happiness_per_generation -= 2 ///petting is not efficent
	else if(user.a_intent == "help" && !likes_pets)
		adjust_happiness(-1, user)

/mob/living/simple_animal/chicken/attackby(obj/item/given_item, mob/user, params)
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

/mob/living/simple_animal/chicken/proc/set_friendship(new_friend, amount = 1)
	if(!Friends[new_friend])
		Friends[new_friend] = 0
	Friends[new_friend] += amount

/mob/living/simple_animal/chicken/proc/feed_food(obj/item/given_item, mob/user)
	handle_happiness_changes(given_item, user)
	if(user)
		var/feedmsg = "[user] feeds [given_item] to [name]! [pick(feedMessages)]"
		user.visible_message(feedmsg)

	qdel(given_item)
	eggs_left += rand(0, 2)
	current_feed_amount ++
	total_times_eaten ++

/mob/living/simple_animal/chicken/proc/eat_feed(obj/effect/chicken_feed/eaten_feed)
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

/mob/living/simple_animal/chicken/proc/handle_happiness_changes(obj/given_item, mob/user)
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

/mob/living/simple_animal/chicken/Hear(message, atom/movable/speaker, message_langs, raw_message, radio_freq, spans, list/message_mods = list())
	. = ..()
	if(speaker != src && !radio_freq && !stat)
		if (speaker in Friends)
			speech_buffer = list()
			speech_buffer += speaker
			speech_buffer += lowertext(html_decode(message))

/mob/living/simple_animal/chicken/proc/handle_speech()
	if (speech_buffer.len > 0)
		var/who = speech_buffer[1] // Who said it?
		var/phrase = speech_buffer[2] // What did they say?
		if (findtext(phrase, "chickens")) // Talking to us
			if(findtext(phrase, "follow"))
				if (ai_controller.blackboard[BB_CHICKEN_CURRENT_LEADER])
					if(Friends[who] > Friends[ai_controller.blackboard[BB_CHICKEN_CURRENT_LEADER]]) // following you bby
						ai_controller.blackboard[BB_CHICKEN_CURRENT_LEADER] = who
						ai_controller.queue_behavior(/datum/ai_behavior/follow_leader)
				else
					if (Friends[who] >= CHICKEN_FRIENDSHIP_FOLLOW)
						ai_controller.blackboard[BB_CHICKEN_CURRENT_LEADER] = who
						ai_controller.queue_behavior(/datum/ai_behavior/follow_leader)

			else if (findtext(phrase, "stop"))
				ai_controller.blackboard[BB_CHICKEN_CURRENT_ATTACK_TARGET] = null

			else if (findtext(phrase, "stay"))
				if(ai_controller.blackboard[BB_CHICKEN_CURRENT_LEADER] == who)
					AIStatus = AI_STATUS_ON
					ai_controller.blackboard[BB_CHICKEN_CURRENT_LEADER] = null
					SSmove_manager.stop_looping(src)

			else if (findtext(phrase, "attack"))
				if (Friends[who] >= CHICKEN_FRIENDSHIP_ATTACK)
					for (var/mob/living/target in view(7,src)-list(src,who))
						if (findtext(phrase, lowertext(target.name)))
							if (istype(target, /mob/living/simple_animal/chicken))
								return
							else if((!Friends[target] || Friends[target] < 1))
								if(ai_controller.blackboard[BB_CHICKEN_CURRENT_LEADER])
									ai_controller.blackboard[BB_CHICKEN_CURRENT_LEADER] = null
								ai_controller.blackboard[BB_CHICKEN_CURRENT_ATTACK_TARGET] = target
						break
		speech_buffer = list()

/mob/living/simple_animal/chicken/Life()
	. =..()
	if(!.)
		return

	handle_speech()

	if(COOLDOWN_FINISHED(src, age_cooldown))
		COOLDOWN_START(src, age_cooldown, age_speed)
		age ++

	if(age > max_age)
		src.death()

	var/animal_count = 0
	for(var/mob/living/simple_animal/animals in view(1, src))
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

/obj/item/food/egg/process(delta_time)
	amount_grown += rand(3,6) * delta_time
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
	if(failed_mutations)
		return
	var/mob/living/simple_animal/chick/birthed = new /mob/living/simple_animal/chick(get_turf(src))

	if(possible_mutations.len)
		var/datum/mutation/ranching/chicken/chosen_mutation = pick(possible_mutations)
		birthed.grown_type = chosen_mutation.chicken_type
		if(chosen_mutation.nearby_items.len)
			absorbed_required_items(chosen_mutation.nearby_items)
	else
		birthed.grown_type = layer_hen_type //if no possible mutations default to layer hen type

	if(birthed.grown_type == /mob/living/simple_animal/chicken/glass)
		for(var/list_item in src.reagents.reagent_list)
			birthed.glass_egg_reagent.Add(list_item)

	if(birthed.grown_type == /mob/living/simple_animal/chicken/stone)
		birthed.production_type = src.production_type

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

/mob/living/simple_animal/chicken/turkey
	name = "\improper turkey"
	desc = "it's that time again."
	icon = 'icons/mob/animal.dmi'
	breed_name = null
	icon_state = "turkey_plain"
	icon_living = "turkey_plain"
	icon_dead = "turkey_plain_dead"
	speak = list("Gobble!","GOBBLE GOBBLE GOBBLE!","Cluck.")
	speak_emote = list("clucks","gobbles")
	emote_hear = list("gobbles.")
	emote_see = list("pecks at the ground.","flaps its wings viciously.")
	density = FALSE
	health = 15
	maxHealth = 15
	attacktext = "pecks"
	attack_sound = 'sound/creatures/turkey.ogg'
	ventcrawler = VENTCRAWLER_ALWAYS
	feedMessages = list("It gobbles up the food voraciously.","It clucks happily.")
	chat_color = "#FFDC9B"
	breed_name_male = "Turkey"
	breed_name_female = "Turkey"

	mutation_list = list()


/mob/living/simple_animal/chicken/turkey/LateInitialize() //reset this as regular chickens override
	. = ..()
	icon_state = "turkey_plain"
	icon_living = "turkey_plain"
	icon_dead = "turkey_plain_dead"

/mob/living/simple_animal/chicken/hen/LateInitialize()
	.=..()
	gender = FEMALE

/mob/living/simple_animal/chicken/proc/adjust_happiness(amount, atom/source, natural_cause = FALSE)
	happiness += amount
	if(amount > 0)
		max_happiness_per_generation -= amount
		add_visual("love")
	else
		if(!natural_cause)
			add_visual("angry")
	if(source)
		set_friendship(source, amount * 0.1)
