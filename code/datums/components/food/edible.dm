/*!

This component makes it possible to make things edible. What this means is that you can take a bite or force someone to take a bite (in the case of items).
These items take a specific time to eat, and can do most of the things our original food items could.

Behavior that's still missing from this component that original food items had that should either be put into separate components or somewhere else:
	Components:
	Drying component (jerky etc)
	Processable component (Slicing and cooking behavior essentialy, making it go from item A to B when conditions are met.)

	Misc:
	Something for cakes (You can store things inside)

*/
/datum/component/edible
	dupe_mode = COMPONENT_DUPE_UNIQUE_PASSARGS
	///Amount of reagents taken per bite
	var/bite_consumption = 2
	///Amount of bites taken so far
	var/bitecount = 0
	///Flags for food
	var/food_flags = NONE
	///Bitfield of the types of this food
	var/foodtypes = NONE
	///Amount of seconds it takes to eat this food
	var/eat_time = 30
	///Defines how much it lowers someones satiety (Need to eat, essentialy)
	var/junkiness = 0
	///Message to send when eating
	var/list/eatverbs
	///Callback to be ran for when you take a bite of something
	var/datum/callback/after_eat
	///Callback to be ran for when you take a bite of something
	var/datum/callback/on_consume
	///Callback to be ran for when the code check if the food is liked, allowing for unique overrides for special foods like donuts with cops.
	var/datum/callback/check_liked
	///Last time we checked for food likes
	var/last_check_time
	///The initial reagents of this food when it is made
	var/list/initial_reagents
	///The initial volume of the foods reagents
	var/volume
	///The flavortext for taste (haha get it flavor text)
	var/list/tastes
	///The type of atom this creates when the object is microwaved.
	var/atom/microwaved_type


/datum/component/edible/Initialize(
	list/initial_reagents,
	food_flags = NONE,
	foodtypes = NONE,
	volume = 50,
	eat_time = 10,
	list/tastes,
	list/eatverbs = list("bite","chew","nibble","gnaw","gobble","chomp"),
	bite_consumption = 2,
	microwaved_type,
	junkiness,
	datum/callback/after_eat,
	datum/callback/on_consume,
	datum/callback/check_liked,
)
	if(!isatom(parent))
		return COMPONENT_INCOMPATIBLE

	RegisterSignal(parent, COMSIG_PARENT_EXAMINE, .proc/examine)
	RegisterSignal(parent, COMSIG_ATOM_ATTACK_ANIMAL, .proc/UseByAnimal)
	RegisterSignal(parent, COMSIG_ATOM_CHECKPARTS, .proc/OnCraft)
	RegisterSignal(parent, COMSIG_ATOM_CREATEDBY_PROCESSING, .proc/OnProcessed)
	RegisterSignal(parent, COMSIG_ITEM_MICROWAVE_COOKED, .proc/OnMicrowaveCooked)
	RegisterSignal(parent, COMSIG_EDIBLE_INGREDIENT_ADDED, .proc/edible_ingredient_added)
	RegisterSignal(parent, COMSIG_OOZE_EAT_ATOM, .proc/on_ooze_eat)

	if(!isturf(parent))
		var/static/list/loc_connections = list(
			COMSIG_ATOM_ENTERED = .proc/on_entered,
		)
		AddComponent(/datum/component/connect_loc_behalf, parent, loc_connections)
	else
		RegisterSignal(parent, COMSIG_ATOM_ENTERED, .proc/on_entered)

	if(isitem(parent))
		RegisterSignal(parent, COMSIG_ITEM_ATTACK, .proc/UseFromHand)
		RegisterSignal(parent, COMSIG_ITEM_FRIED, .proc/OnFried)
		RegisterSignal(parent, COMSIG_GRILL_FOOD, .proc/GrillFood)
		RegisterSignal(parent, COMSIG_ITEM_MICROWAVE_ACT, .proc/OnMicrowaved)
		RegisterSignal(parent, COMSIG_FOOD_SILVER_SPAWNED, .proc/on_silver_slime_reaction)
		RegisterSignal(parent, COMSIG_ITEM_USED_AS_INGREDIENT, .proc/used_to_customize)

		var/obj/item/item = parent
		if (!item.grind_results)
			item.grind_results = list() //If this doesn't already exist, add it as an empty list. This is needed for the grinder to accept it.

	else if(isturf(parent) || isstructure(parent))
		RegisterSignal(parent, COMSIG_ATOM_ATTACK_HAND, .proc/TryToEatIt)

	src.bite_consumption = bite_consumption
	src.food_flags = food_flags
	src.foodtypes = foodtypes
	src.eat_time = eat_time
	src.eatverbs = string_list(eatverbs)
	src.junkiness = junkiness
	src.after_eat = after_eat
	src.on_consume = on_consume
	src.initial_reagents = string_assoc_list(initial_reagents)
	src.tastes = string_assoc_list(tastes)
	src.microwaved_type = microwaved_type
	src.check_liked = check_liked

	var/atom/owner = parent

	owner.create_reagents(volume, INJECTABLE)

	for(var/rid in initial_reagents)
		var/amount = initial_reagents[rid]
		if(length(tastes) && (rid == /datum/reagent/consumable/nutriment || rid == /datum/reagent/consumable/nutriment/vitamin))
			owner.reagents.add_reagent(rid, amount, tastes.Copy())
		else
			owner.reagents.add_reagent(rid, amount)

/datum/component/edible/InheritComponent(
	datum/component/C,
	i_am_original,
	list/initial_reagents,
	food_flags = NONE,
	foodtypes = NONE,
	volume = 50,
	eat_time = 10,
	list/tastes,
	list/eatverbs = list("bite","chew","nibble","gnaw","gobble","chomp"),
	bite_consumption = 2,
	microwaved_type,
	junkiness,
	datum/callback/after_eat,
	datum/callback/on_consume,
	datum/callback/check_liked,
)
	. = ..()
	src.bite_consumption = bite_consumption
	src.food_flags = food_flags
	src.foodtypes = foodtypes
	src.eat_time = eat_time
	src.eatverbs = eatverbs
	src.junkiness = junkiness
	src.after_eat = after_eat
	src.on_consume = on_consume

/datum/component/edible/Destroy(force, silent)
	QDEL_NULL(after_eat)
	QDEL_NULL(on_consume)
	return ..()

/datum/component/edible/proc/examine(datum/source, mob/user, list/examine_list)
	SIGNAL_HANDLER

	if(microwaved_type)
		examine_list += "[parent] could be <b>microwaved</b> into [initial(microwaved_type.name)]!"

	if(!(food_flags & FOOD_IN_CONTAINER))
		switch (bitecount)
			if (0)
				return
			if(1)
				examine_list += "[parent] was bitten by someone!"
			if(2,3)
				examine_list += "[parent] was bitten [bitecount] times!"
			else
				examine_list += "[parent] was bitten multiple times!"

/datum/component/edible/proc/UseFromHand(obj/item/source, mob/living/M, mob/living/user)
	SIGNAL_HANDLER

	return TryToEat(M, user)

/datum/component/edible/proc/TryToEatIt(datum/source, mob/user)
	SIGNAL_HANDLER

	return TryToEat(user, user)

/datum/component/edible/proc/OnFried(datum/source, atom/fry_object)
	SIGNAL_HANDLER
	var/atom/our_atom = parent
	fry_object.reagents.maximum_volume = our_atom.reagents.maximum_volume
	our_atom.reagents.trans_to(fry_object, our_atom.reagents.total_volume)
	qdel(our_atom)
	return COMSIG_FRYING_HANDLED

/datum/component/edible/proc/GrillFood(datum/source, atom/fry_object, grill_time)
	SIGNAL_HANDLER

	var/atom/this_food = parent

	switch(grill_time) //no 0-20 to prevent spam
		if(20 to 30)
			this_food.name = "lightly-grilled [this_food.name]"
			this_food.desc = "[this_food.desc] It's been lightly grilled."
		if(30 to 80)
			this_food.name = "grilled [this_food.name]"
			this_food.desc = "[this_food.desc] It's been grilled."
			foodtypes |= FRIED
		if(80 to 100)
			this_food.name = "heavily grilled [this_food.name]"
			this_food.desc = "[this_food.desc] It's been heavily grilled."
			foodtypes |= FRIED
		if(100 to INFINITY) //grill marks reach max alpha
			this_food.name = "Powerfully Grilled [this_food.name]"
			this_food.desc = "A [this_food.name]. Reminds you of your wife, wait, no, it's prettier!"
			foodtypes |= FRIED


///Called when food is created through processing (Usually this means it was sliced). We use this to pass the OG items reagents.
/datum/component/edible/proc/OnProcessed(datum/source, atom/original_atom, list/chosen_processing_option)
	SIGNAL_HANDLER

	if(!original_atom.reagents)
		return

	var/atom/this_food = parent

	//Make sure we have a reagent container large enough to fit the original atom's reagents.
	volume = max(volume, ROUND_UP(original_atom.reagents.maximum_volume / chosen_processing_option[TOOL_PROCESSING_AMOUNT]))

	this_food.create_reagents(volume)
	original_atom.reagents.copy_to(this_food, original_atom.reagents.total_volume, 1 / chosen_processing_option[TOOL_PROCESSING_AMOUNT])

	if(original_atom.name != initial(original_atom.name))
		this_food.name = "slice of [original_atom.name]"
	if(original_atom.desc != initial(original_atom.desc))
		this_food.desc = "[original_atom.desc]"

///Called when food is crafted through a crafting recipe datum.
/datum/component/edible/proc/OnCraft(datum/source, list/parts_list, datum/crafting_recipe/food/recipe)
	SIGNAL_HANDLER

	var/atom/this_food = parent

	this_food.reagents.multiply_reagents(CRAFTED_FOOD_BASE_REAGENT_MODIFIER)
	this_food.reagents.maximum_volume *= CRAFTED_FOOD_BASE_REAGENT_MODIFIER

	for(var/obj/item/food/crafted_part in parts_list)
		if(!crafted_part.reagents)
			continue

		this_food.reagents.maximum_volume += crafted_part.reagents.maximum_volume * CRAFTED_FOOD_INGREDIENT_REAGENT_MODIFIER
		crafted_part.reagents.trans_to(this_food.reagents, crafted_part.reagents.maximum_volume, CRAFTED_FOOD_INGREDIENT_REAGENT_MODIFIER)

	this_food.reagents.maximum_volume = ROUND_UP(this_food.reagents.maximum_volume) // Just because I like whole numbers for this.

	SSblackbox.record_feedback("tally", "food_made", 1, type)

/datum/component/edible/proc/OnMicrowaved(datum/source, obj/machinery/microwave/used_microwave)
	SIGNAL_HANDLER

	var/turf/parent_turf = get_turf(parent)

	if(!microwaved_type)
		new /obj/item/food/badrecipe(parent_turf)
		qdel(parent)
		return

	var/obj/item/result

	result = new microwaved_type(parent_turf)

	var/efficiency = istype(used_microwave) ? used_microwave.efficiency : 1

	SEND_SIGNAL(result, COMSIG_ITEM_MICROWAVE_COOKED, parent, efficiency)

	SSblackbox.record_feedback("tally", "food_made", 1, result.type)
	qdel(parent)
	return COMPONENT_SUCCESFUL_MICROWAVE

///Corrects the reagents on the newly cooked food
/datum/component/edible/proc/OnMicrowaveCooked(datum/source, obj/item/source_item, cooking_efficiency = 1)
	SIGNAL_HANDLER

	var/atom/this_food = parent

	this_food.reagents.multiply_reagents(cooking_efficiency * CRAFTED_FOOD_BASE_REAGENT_MODIFIER)

	source_item.reagents?.trans_to(this_food, source_item.reagents.total_volume)

///Makes sure the thing hasn't been destroyed or fully eaten to prevent eating phantom edibles
/datum/component/edible/proc/IsFoodGone(atom/owner, mob/living/feeder)
	if(QDELETED(owner)|| !(IS_EDIBLE(owner)))
		return TRUE
	if(owner.reagents.total_volume)
		return FALSE
	return TRUE

///All the checks for the act of eating itself and
/datum/component/edible/proc/TryToEat(mob/living/eater, mob/living/feeder)

	set waitfor = FALSE

	var/atom/owner = parent

	if(feeder.combat_mode)
		return

	. = COMPONENT_CANCEL_ATTACK_CHAIN //Point of no return I suppose

	if(IsFoodGone(owner, feeder))
		return

	if(!CanConsume(eater, feeder))
		return
	var/fullness = eater.get_fullness() + 10 //The theoretical fullness of the person eating if they were to eat this

	if(eater == feeder)//If you're eating it yourself.
		if(eat_time && !do_mob(feeder, eater, eat_time, timed_action_flags = food_flags & FOOD_FINGER_FOOD ? IGNORE_USER_LOC_CHANGE | IGNORE_TARGET_LOC_CHANGE : NONE)) //Gotta pass the minimal eat time
			return
		if(IsFoodGone(owner, feeder))
			return
		var/eatverb = pick(eatverbs)

		var/message_to_nearby_audience = ""
		var/message_to_consumer = ""
		var/message_to_blind_consumer = ""

		if(junkiness && eater.satiety < -150 && eater.nutrition > NUTRITION_LEVEL_STARVING + 50 && !HAS_TRAIT(eater, TRAIT_VORACIOUS))
			to_chat(eater, span_warning("You don't feel like eating any more junk food at the moment!"))
			return
		else if(fullness > (600 * (1 + eater.overeatduration / (4000 SECONDS)))) // The more you eat - the more you can eat
			message_to_nearby_audience = span_warning("[eater] cannot force any more of \the [parent] to go down [eater.p_their()] throat!")
			message_to_consumer = span_warning("You cannot force any more of \the [parent] to go down your throat!")
			message_to_blind_consumer = message_to_consumer
			eater.show_message(message_to_consumer, MSG_VISUAL, message_to_blind_consumer)
			eater.visible_message(message_to_nearby_audience, ignored_mobs = eater)
			//if we're too full, return because we can't eat whatever it is we're trying to eat
			return
		else if(fullness > 500)
			message_to_nearby_audience = span_notice("[eater] unwillingly [eatverb]s a bit of \the [parent].")
			message_to_consumer = span_notice("You unwillingly [eatverb] a bit of \the [parent].")
		else if(fullness > 150)
			message_to_nearby_audience = span_notice("[eater] [eatverb]s \the [parent].")
			message_to_consumer = span_notice("You [eatverb] \the [parent].")
		else if(fullness > 50)
			message_to_nearby_audience = span_notice("[eater] hungrily [eatverb]s \the [parent].")
			message_to_consumer = span_notice("You hungrily [eatverb] \the [parent].")
		else
			message_to_nearby_audience = span_notice("[eater] hungrily [eatverb]s \the [parent], gobbling it down!")
			message_to_consumer = span_notice("You hungrily [eatverb] \the [parent], gobbling it down!")

		//if we're blind, we want to feel how hungrily we ate that food
		message_to_blind_consumer = message_to_consumer
		eater.show_message(message_to_consumer, MSG_VISUAL, message_to_blind_consumer)
		eater.visible_message(message_to_nearby_audience, ignored_mobs = eater)

	else //If you're feeding it to someone else.
		if(isbrain(eater))
			to_chat(feeder, span_warning("[eater] doesn't seem to have a mouth!"))
			return
		if(fullness <= (600 * (1 + eater.overeatduration / (2000 SECONDS))))
			eater.visible_message(
				span_danger("[feeder] attempts to [eater.get_bodypart(BODY_ZONE_HEAD) ? "feed [eater] [parent]." : "stuff [parent] down [eater]'s throat hole! Gross."]"),
				span_userdanger("[feeder] attempts to [eater.get_bodypart(BODY_ZONE_HEAD) ? "feed you [parent]." : "stuff [parent] down your throat hole! Gross."]")
			)
		else
			eater.visible_message(
				span_danger("[feeder] cannot force any more of [parent] down [eater]'s [eater.get_bodypart(BODY_ZONE_HEAD) ? "throat!" : "throat hole! Eugh."]"),
				span_userdanger("[feeder] cannot force any more of [parent] down your [eater.get_bodypart(BODY_ZONE_HEAD) ? "throat!" : "throat hole! Eugh."]")
			)
			return
		if(!do_mob(feeder, eater)) //Wait 3 seconds before you can feed
			return
		if(IsFoodGone(owner, feeder))
			return
		log_combat(feeder, eater, "fed", owner.reagents.get_reagent_log_string())
		eater.visible_message(
			span_danger("[feeder] forces [eater] to eat [parent]!"),
			span_userdanger("[feeder] forces you to eat [parent]!")
		)

	TakeBite(eater, feeder)

	//If we're not force-feeding and there's an eat delay, try take another bite
	if(eater == feeder && eat_time)
		INVOKE_ASYNC(src, .proc/TryToEat, eater, feeder)


///This function lets the eater take a bite and transfers the reagents to the eater.
/datum/component/edible/proc/TakeBite(mob/living/eater, mob/living/feeder)

	var/atom/owner = parent

	if(!owner?.reagents)
		stack_trace("[eater] failed to bite [owner], because [owner] had no reagents.")
		return FALSE
	if(eater.satiety > -200)
		eater.satiety -= junkiness
	playsound(eater.loc,'sound/items/eatfood.ogg', rand(10,50), TRUE)
	if(owner.reagents.total_volume)
		SEND_SIGNAL(parent, COMSIG_FOOD_EATEN, eater, feeder, bitecount, bite_consumption)
		var/fraction = min(bite_consumption / owner.reagents.total_volume, 1)
		owner.reagents.trans_to(eater, bite_consumption, transfered_by = feeder, methods = INGEST)
		bitecount++
		if(!owner.reagents.total_volume)
			On_Consume(eater, feeder)
		checkLiked(fraction, eater)

		//Invoke our after eat callback if it is valid
		if(after_eat)
			after_eat.Invoke(eater, feeder, bitecount)

		return TRUE

///Checks whether or not the eater can actually consume the food
/datum/component/edible/proc/CanConsume(mob/living/eater, mob/living/feeder)
	if(!iscarbon(eater))
		return FALSE
	var/mob/living/carbon/C = eater
	var/covered = ""
	if(C.is_mouth_covered(head_only = 1))
		covered = "headgear"
	else if(C.is_mouth_covered(mask_only = 1))
		covered = "mask"
	if(covered)
		var/who = (isnull(feeder) || eater == feeder) ? "your" : "[eater.p_their()]"
		to_chat(feeder, span_warning("You have to remove [who] [covered] first!"))
		return FALSE
	return TRUE

///Check foodtypes to see if we should send a moodlet
/datum/component/edible/proc/checkLiked(fraction, mob/M)
	if(last_check_time + 50 > world.time)
		return FALSE
	if(!ishuman(M))
		return FALSE
	var/mob/living/carbon/human/H = M

	//Bruh this breakfast thing is cringe and shouldve been handled separately from food-types, remove this in the future (Actually, just kill foodtypes in general)
	if((foodtypes & BREAKFAST) && world.time - SSticker.round_start_time < STOP_SERVING_BREAKFAST)
		SEND_SIGNAL(H, COMSIG_ADD_MOOD_EVENT, "breakfast", /datum/mood_event/breakfast)
	last_check_time = world.time

	if(HAS_TRAIT(H, TRAIT_AGEUSIA))
		if(foodtypes & H.dna.species.toxic_food)
			to_chat(H, span_warning("You don't feel so good..."))
			H.adjust_disgust(25 + 30 * fraction)
		return // Don't care about the later checks if user has ageusia

	var/food_taste_reaction

	if(check_liked) //Callback handling; use this as an override for special food like donuts
		food_taste_reaction = check_liked.Invoke(fraction, H)

	if(!food_taste_reaction)
		if(foodtypes & H.dna.species.toxic_food)
			food_taste_reaction = FOOD_TOXIC
		else if(foodtypes & H.dna.species.disliked_food)
			food_taste_reaction = FOOD_DISLIKED
		else if(foodtypes & H.dna.species.liked_food)
			food_taste_reaction = FOOD_LIKED
	if(food_flags & FOOD_SILVER_SPAWNED) // it's not real food
		food_taste_reaction = FOOD_TOXIC

	switch(food_taste_reaction)
		if(FOOD_TOXIC)
			to_chat(H,span_warning("What the hell was that thing?!"))
			H.adjust_disgust(25 + 30 * fraction)
			SEND_SIGNAL(H, COMSIG_ADD_MOOD_EVENT, "toxic_food", /datum/mood_event/disgusting_food)
		if(FOOD_DISLIKED)
			to_chat(H,span_notice("That didn't taste very good..."))
			H.adjust_disgust(11 + 15 * fraction)
			SEND_SIGNAL(H, COMSIG_ADD_MOOD_EVENT, "gross_food", /datum/mood_event/gross_food)
		if(FOOD_LIKED)
			to_chat(H,span_notice("I love this taste!"))
			H.adjust_disgust(-5 + -2.5 * fraction)
			SEND_SIGNAL(H, COMSIG_ADD_MOOD_EVENT, "fav_food", /datum/mood_event/favorite_food)
			if(istype(parent, /obj/item/food))
				var/obj/item/food/memorable_food = parent
				if(memorable_food.venue_value >= FOOD_PRICE_EXOTIC)
					H.mind?.add_memory(MEMORY_MEAL, list(DETAIL_FOOD = memorable_food), story_value = STORY_VALUE_OKAY)

///Delete the item when it is fully eaten
/datum/component/edible/proc/On_Consume(mob/living/eater, mob/living/feeder)
	SEND_SIGNAL(parent, COMSIG_FOOD_CONSUMED, eater, feeder)

	on_consume?.Invoke(eater, feeder)

	to_chat(feeder, span_warning("There is nothing left of [parent], oh no!"))
	if(isturf(parent))
		var/turf/T = parent
		T.ScrapeAway(1, CHANGETURF_INHERIT_AIR)
	else
		qdel(parent)

///Ability to feed food to puppers
/datum/component/edible/proc/UseByAnimal(datum/source, mob/user)

	SIGNAL_HANDLER


	var/atom/owner = parent

	if(!isdog(user))
		return
	var/mob/living/L = user
	if(bitecount == 0 || prob(50))
		L.manual_emote("nibbles away at \the [parent].")
	bitecount++
	. = COMPONENT_CANCEL_ATTACK_CHAIN
	L.taste(owner.reagents) // why should carbons get all the fun?
	if(bitecount >= 5)
		var/satisfaction_text = pick("burps from enjoyment.", "yaps for more!", "woofs twice.", "looks at the area where \the [parent] was.")
		L.manual_emote(satisfaction_text)
		qdel(parent)


///Ability to feed food to puppers
/datum/component/edible/proc/on_entered(datum/source, atom/movable/arrived, atom/old_loc, list/atom/old_locs)
	SIGNAL_HANDLER
	SEND_SIGNAL(parent, COMSIG_FOOD_CROSSED, arrived, bitecount)

///Response to being used to customize something
/datum/component/edible/proc/used_to_customize(datum/source, atom/customized)
	SIGNAL_HANDLER

	SEND_SIGNAL(customized, COMSIG_EDIBLE_INGREDIENT_ADDED, src)

///Adds this flag to the item to make it taste disgusting
/datum/component/edible/proc/on_silver_slime_reaction(obj/item/source)
	SIGNAL_HANDLER
	food_flags |= FOOD_SILVER_SPAWNED

///Response to an edible ingredient being added to parent.
/datum/component/edible/proc/edible_ingredient_added(datum/source, datum/component/edible/ingredient)
	SIGNAL_HANDLER

	var/datum/component/edible/E = ingredient
	if (LAZYLEN(E.tastes))
		tastes = tastes.Copy()
		for (var/t in E.tastes)
			tastes[t] += E.tastes[t]
	foodtypes |= E.foodtypes

/// Response to oozes trying to eat something edible
/datum/component/edible/proc/on_ooze_eat(datum/source, mob/eater, edible_flags)
	SIGNAL_HANDLER

	if(foodtypes & edible_flags)
		var/atom/eaten_food = parent
		eaten_food.reagents.trans_to(eater, eaten_food.reagents.total_volume, transfered_by = eater)
		eater.visible_message(span_warning("[src] eats [eaten_food]!"), span_notice("You eat [eaten_food]."))
		playsound(get_turf(eater),'sound/items/eatfood.ogg', rand(30,50), TRUE)
		qdel(eaten_food)
		return COMPONENT_ATOM_EATEN
