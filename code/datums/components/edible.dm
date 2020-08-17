/*!

This component makes it possible to make things edible. What this means is that you can take a bite or force someone to take a bite (in the case of items).
These items take a specific time to eat, and can do most of the things our original food items could.

Behavior that's still missing from this component that original food items had that should either be put into seperate components or somewhere else:
	Components:
	Drying component (jerky etc)
	Customizable component (custom pizzas etc)
	Processable component (Slicing and cooking behavior essentialy, making it go from item A to B when conditions are met.)
	Dunkable component (Dunking things into reagent containers to absorb a specific amount of reagents)

	Misc:
	Something for cakes (You can store things inside)

*/
/datum/component/edible
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
	///Last time we checked for food likes
	var/last_check_time

/datum/component/edible/Initialize(list/initial_reagents, food_flags = NONE, foodtypes = NONE, volume = 50, eat_time = 30, list/tastes, list/eatverbs = list("bite","chew","nibble","gnaw","gobble","chomp"), bite_consumption = 2, datum/callback/after_eat)
	if(!isatom(parent))
		return COMPONENT_INCOMPATIBLE

	RegisterSignal(parent, COMSIG_PARENT_EXAMINE, .proc/examine)
	RegisterSignal(parent, COMSIG_ATOM_ATTACK_ANIMAL, .proc/UseByAnimal)
	if(isitem(parent))
		RegisterSignal(parent, COMSIG_ITEM_ATTACK, .proc/UseFromHand)
	else if(isturf(parent))
		RegisterSignal(parent, COMSIG_ATOM_ATTACK_HAND, .proc/TryToEatTurf)

	src.bite_consumption = bite_consumption
	src.food_flags = food_flags
	src.foodtypes = foodtypes
	src.eat_time = eat_time
	src.eatverbs = eatverbs
	src.junkiness = junkiness
	src.after_eat = after_eat

	var/atom/owner = parent

	owner.create_reagents(volume, INJECTABLE)

	if(initial_reagents)
		for(var/rid in initial_reagents)
			var/amount = initial_reagents[rid]
			if(tastes && tastes.len && (rid == /datum/reagent/consumable/nutriment || rid == /datum/reagent/consumable/nutriment/vitamin))
				owner.reagents.add_reagent(rid, amount, tastes.Copy())
			else
				owner.reagents.add_reagent(rid, amount)

/datum/component/edible/proc/examine(datum/source, mob/user, list/examine_list)
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
	return TryToEat(M, user)

/datum/component/edible/proc/TryToEatTurf(datum/source, mob/user)
	return TryToEat(user, user)

///All the checks for the act of eating itself and
/datum/component/edible/proc/TryToEat(mob/living/eater, mob/living/feeder)

	set waitfor = FALSE

	var/atom/owner = parent

	if(feeder.a_intent == INTENT_HARM)
		return
	if(!owner.reagents.total_volume)//Shouldn't be needed but it checks to see if it has anything left in it.
		to_chat(feeder, "<span class='warning'>None of [owner] left, oh no!</span>")
		if(isturf(parent))
			var/turf/T = parent
			T.ScrapeAway(1, CHANGETURF_INHERIT_AIR)
		else
			qdel(parent)
		return
	if(!CanConsume(eater, feeder))
		return
	var/fullness = eater.nutrition + 10 //The theoretical fullness of the person eating if they were to eat this
	for(var/datum/reagent/consumable/C in eater.reagents.reagent_list) //we add the nutrition value of what we're currently digesting
		fullness += C.nutriment_factor * C.volume / C.metabolization_rate

	. = COMPONENT_ITEM_NO_ATTACK //Point of no return I suppose

	if(eater == feeder)//If you're eating it yourself.
		if(!do_mob(feeder, eater, eat_time)) //Gotta pass the minimal eat time
			return
		var/eatverb = pick(eatverbs)
		if(junkiness && eater.satiety < -150 && eater.nutrition > NUTRITION_LEVEL_STARVING + 50 && !HAS_TRAIT(eater, TRAIT_VORACIOUS))
			to_chat(eater, "<span class='warning'>You don't feel like eating any more junk food at the moment!</span>")
			return
		else if(fullness <= 50)
			eater.visible_message("<span class='notice'>[eater] hungrily [eatverb]s \the [parent], gobbling it down!</span>", "<span class='notice'>You hungrily [eatverb] \the [parent], gobbling it down!</span>")
		else if(fullness > 50 && fullness < 150)
			eater.visible_message("<span class='notice'>[eater] hungrily [eatverb]s \the [parent].</span>", "<span class='notice'>You hungrily [eatverb] \the [parent].</span>")
		else if(fullness > 150 && fullness < 500)
			eater.visible_message("<span class='notice'>[eater] [eatverb]s \the [parent].</span>", "<span class='notice'>You [eatverb] \the [parent].</span>")
		else if(fullness > 500 && fullness < 600)
			eater.visible_message("<span class='notice'>[eater] unwillingly [eatverb]s a bit of \the [parent].</span>", "<span class='notice'>You unwillingly [eatverb] a bit of \the [parent].</span>")
		else if(fullness > (600 * (1 + eater.overeatduration / 2000)))	// The more you eat - the more you can eat
			eater.visible_message("<span class='warning'>[eater] cannot force any more of \the [parent] to go down [eater.p_their()] throat!</span>", "<span class='warning'>You cannot force any more of \the [parent] to go down your throat!</span>")
			return
	else //If you're feeding it to someone else.
		if(isbrain(eater))
			to_chat(feeder, "<span class='warning'>[eater] doesn't seem to have a mouth!</span>")
			return
		if(fullness <= (600 * (1 + eater.overeatduration / 1000)))
			eater.visible_message("<span class='danger'>[feeder] attempts to feed [eater] [parent].</span>", \
									"<span class='userdanger'>[feeder] attempts to feed you [parent].</span>")
		else
			eater.visible_message("<span class='warning'>[feeder] cannot force any more of [parent] down [eater]'s throat!</span>", \
									"<span class='warning'>[feeder] cannot force any more of [parent] down your throat!</span>")
			return
		if(!do_mob(feeder, eater)) //Wait 3 seconds before you can feed
			return

		log_combat(feeder, eater, "fed", owner.reagents.log_list())
		eater.visible_message("<span class='danger'>[feeder] forces [eater] to eat [parent]!</span>", \
									"<span class='userdanger'>[feeder] forces you to eat [parent]!</span>")

	TakeBite(eater, feeder)

///This function lets the eater take a bite and transfers the reagents to the eater.
/datum/component/edible/proc/TakeBite(mob/living/eater, mob/living/feeder)

	var/atom/owner = parent

	if(!owner?.reagents)
		return FALSE
	if(eater.satiety > -200)
		eater.satiety -= junkiness
	playsound(eater.loc,'sound/items/eatfood.ogg', rand(10,50), TRUE)
	if(owner.reagents.total_volume)
		SEND_SIGNAL(parent, COMSIG_FOOD_EATEN, eater, feeder)
		var/fraction = min(bite_consumption / owner.reagents.total_volume, 1)
		owner.reagents.trans_to(eater, bite_consumption, transfered_by = feeder, method = INGEST)
		bitecount++
		On_Consume(eater)
		checkLiked(fraction, eater)

		//Invoke our after eat callback if it is valid
		if(after_eat)
			after_eat.Invoke(eater, feeder)

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
		to_chat(feeder, "<span class='warning'>You have to remove [who] [covered] first!</span>")
		return FALSE
	return TRUE

///Check foodtypes to see if we should send a moodlet
/datum/component/edible/proc/checkLiked(var/fraction, mob/M)
	if(last_check_time + 50 > world.time)
		return FALSE
	if(!ishuman(M))
		return FALSE
	var/mob/living/carbon/human/H = M
	if(HAS_TRAIT(H, TRAIT_AGEUSIA) && foodtypes & H.dna.species.toxic_food)
		to_chat(H, "<span class='warning'>You don't feel so good...</span>")
		H.adjust_disgust(25 + 30 * fraction)
	else
		if(foodtypes & H.dna.species.toxic_food)
			to_chat(H,"<span class='warning'>What the hell was that thing?!</span>")
			H.adjust_disgust(25 + 30 * fraction)
			SEND_SIGNAL(H, COMSIG_ADD_MOOD_EVENT, "toxic_food", /datum/mood_event/disgusting_food)
		else if(foodtypes & H.dna.species.disliked_food)
			to_chat(H,"<span class='notice'>That didn't taste very good...</span>")
			H.adjust_disgust(11 + 15 * fraction)
			SEND_SIGNAL(H, COMSIG_ADD_MOOD_EVENT, "gross_food", /datum/mood_event/gross_food)
		else if(foodtypes & H.dna.species.liked_food)
			to_chat(H,"<span class='notice'>I love this taste!</span>")
			H.adjust_disgust(-5 + -2.5 * fraction)
			SEND_SIGNAL(H, COMSIG_ADD_MOOD_EVENT, "fav_food", /datum/mood_event/favorite_food)
	if((foodtypes & BREAKFAST) && world.time - SSticker.round_start_time < STOP_SERVING_BREAKFAST)
		SEND_SIGNAL(H, COMSIG_ADD_MOOD_EVENT, "breakfast", /datum/mood_event/breakfast)
	last_check_time = world.time

///Delete the item when it is fully eaten
/datum/component/edible/proc/On_Consume(mob/living/eater)

	var/atom/owner = parent

	if(!eater)
		return
	if(!owner.reagents.total_volume)
		if(isturf(parent))
			var/turf/T = parent
			T.ScrapeAway(1, CHANGETURF_INHERIT_AIR)
		else
			qdel(parent)

///Ability to feed food to puppers
/datum/component/edible/proc/UseByAnimal(datum/source, mob/user)

	var/atom/owner = parent

	if(!isdog(user))
		return
	var/mob/living/L = user
	if(bitecount == 0 || prob(50))
		L.emote("me", 1, "nibbles away at \the [parent]")
	bitecount++
	. = COMPONENT_ITEM_NO_ATTACK
	L.taste(owner.reagents) // why should carbons get all the fun?
	if(bitecount >= 5)
		var/sattisfaction_text = pick("burps from enjoyment", "yaps for more", "woofs twice", "looks at the area where \the [parent] was")
		if(sattisfaction_text)
			L.emote("me", 1, "[sattisfaction_text]")
		qdel(parent)
