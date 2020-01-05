/datum/component/edible
	///Amount of reagents taken per bite
	var/bite_consumption = 2
	///Amount of bites taken so far
	var/bitecount = 0
	///Food groups that decide what kind of meter this fills. YOU CAN DO ANYTHING
	var/list/food_groups
	///Flags for food
	var/food_flags = NONE
	///Size of the food's volume
	var/volume = 50
	///Amount of seconds it takes to eat this food using the right utensils
	var/eat_time = 30
	///Amount of seconds you can be penalized if you eat this food using no utensils
	var/penalty_eat_time = 50
	///List of tastes players can taste when they consume something, for example list("crisps" = 2, "salt" = 1)
	var/list/tastes = list("nothing")
	///Message to send when eating
	var/list/eatverbs
	/// Type path For cut-able food.
	var/slice_path = null
	/// Amount of slices for cutting
	var/slices_num = 0
	/// Time it takes to cut food
	var/slice_duration = 20
	///Whether or not this food can be dunked in reagents
	var/dunk_amount = 0 // If this is higher than 0 you can dunk this in reagents.
	///Type of obj this object spawns after eating
	var/trash


	//var/dried_type = null //move this to obj/item/dry-able or to a dry component
	//var/dry = 0 //move this to obj/item/dry-able or to a dry component

	//var/cooked_type = null  //should be on the item itself.
	//var/filling_color = "#FFFFFF" //color to use when added to custom food.
	//var/custom_food_type = null  //for food customizing. path of the custom food to create

	//var/customfoodfilling = 1 // whether it can be used as filling in custom food

/datum/component/edible/Initialize(list/initial_reagents, bite_consumption = 2, list/food_groups, food_flags = NONE, volume = 50, eat_time = 30, penalty_eat_time = 50, list/tastes, list/eatverbs = list("bite","chew","nibble","gnaw","gobble","chomp"), slice_path, slices_num = 0, slice_duration = 20, dunk_amount, trash)
	if(!isatom(parent))
		return COMPONENT_INCOMPATIBLE

	RegisterSignal(parent, COMSIG_PARENT_EXAMINE, .proc/examine)
	RegisterSignal(parent, COMSIG_ATOM_KNIFE_ACT, .proc/cut)
	if(isitem(parent))
		var/obj/item/I = parent
		RegisterSignal(I, COMSIG_MOB_ITEM_ATTACK, ./proc/UseFromHand)

	src.bite_consumption = bite_consumption
	src.food_flags = food_flags
	src.food_groups = food_groups
	src.volume = volume
	src.eat_time = eat_time
	src.penalty_eat_time = penalty_eat_time
	src.tastes = tastes
	src.eatverbs = eatverbs
	src.slice_path = slice_path
	src.slices_num = slices_num
	src.slice_duration = slice_duration
	src.junkiness = junkiness
	src.dunk_amount = dunk_amount
	src.trash = trash

	src.create_reagents(volume, INJECTABLE)

	if(initial_reagents)
		for(var/rid in initial_reagents)
			var/amount = initial_reagents[rid]
			if(tastes && tastes.len && (rid == /datum/reagent/consumable/nutriment || rid == /datum/reagent/consumable/nutriment/vitamin))
				reagents.add_reagent(rid, amount, tastes.Copy())
			else
				reagents.add_reagent(rid, amount)

/datum/component/edible/proc/examine(datum/source, mob/user, list/examine_list)
	if(!food_flags & FOOD_IN_CONTAINER)
		switch (bitecount)
			if (0)
				return
			if(1)
				examine_list += "[parent] was bitten by someone!"
			if(2,3)
				examine_list += "[parent] was bitten [bitecount] times!"
			else
				examine_list += "[parent] was bitten multiple times!"

/datum/component/edible/proc/UseFromHand(mob/living/M, mob/living/user)
	TryToEat(M, user, null)//No utensils used. YOU MADMAN!!

/datum/component/edible/proc/TryToEat(mob/living/eater, mob/living/feeder, utensils_used)
	if(eater.a_intent == INTENT_HARM)
		return
	if(!reagents.total_volume)//Shouldn't be needed but it checks to see if it has anything left in it.
		to_chat(feeder, "<span class='warning'>None of [src] left, oh no!</span>")
		qdel(parent)
	if(!iscarbon(eater))
		return
	if(!canconsume(eater, feeder))
		return FALSE

	var/fullness = eater.nutrition + 10 //The theoretical fullness of the person eating if they were to eat this
	for(var/datum/reagent/consumable/C in eater.reagents.reagent_list) //we add the nutrition value of what we're currently digesting
		fullness += eater.nutriment_factor * eater.volume / eater.metabolization_rate

	if(eater == feeder)//If you're eating it yourself.
		if(junkiness && eater.satiety < -150 && eater.nutrition > NUTRITION_LEVEL_STARVING + 50 && !HAS_TRAIT(eater, TRAIT_VORACIOUS))
			to_chat(eater, "<span class='warning'>You don't feel like eating any more junk food at the moment!</span>")
			return FALSE
		else if(fullness <= 50)
			eater.visible_message("<span class='notice'>[eater] hungrily [eatverb]s \the [src], gobbling it down!</span>", "<span class='notice'>You hungrily [eatverb] \the [src], gobbling it down!</span>")
		else if(fullness > 50 && fullness < 150)
			eater.visible_message("<span class='notice'>[eater] hungrily [eatverb]s \the [src].</span>", "<span class='notice'>You hungrily [eatverb] \the [src].</span>")
		else if(fullness > 150 && fullness < 500)
			eater.visible_message("<span class='notice'>[eater] [eatverb]s \the [src].</span>", "<span class='notice'>You [eatverb] \the [src].</span>")
		else if(fullness > 500 && fullness < 600)
			eater.visible_message("<span class='notice'>[eater] unwillingly [eatverb]s a bit of \the [src].</span>", "<span class='notice'>You unwillingly [eatverb] a bit of \the [src].</span>")
		else if(fullness > (600 * (1 + eater.overeatduration / 2000)))	// The more you eat - the more you can eat
			eater.visible_message("<span class='warning'>[eater] cannot force any more of \the [src] to go down [eater.p_their()] throat!</span>", "<span class='warning'>You cannot force any more of \the [src] to go down your throat!</span>")
			return FALSE
	else //If you're feeding it to someone else.
		if(isbrain(eater))
			to_chat(feeder, "<span class='warning'>[eater] doesn't seem to have a mouth!</span>")
			return
		if(fullness <= (600 * (1 + eater.overeatduration / 1000)))
			eater.visible_message("<span class='danger'>[feeder] attempts to feed [eater] [src].</span>", \
									"<span class='userdanger'>[feeder] attempts to feed you [src].</span>")
		else
			eater.visible_message("<span class='warning'>[feeder] cannot force any more of [src] down [eater]'s throat!</span>", \
									"<span class='warning'>[feeder] cannot force any more of [src] down your throat!</span>")
			return FALSE
		if(!do_mob(feeder, eater)) //Wait 3 seconds before you can feed
			return
		log_combat(feeder, eater, "fed", reagents.log_list())
		eater.visible_message("<span class='danger'>[feeder] forces [eater] to eat [src]!</span>", \
									"<span class='userdanger'>[feeder] forces you to eat [src]!</span>")

	TakeBite(eater, feeder)

/datum/component/edible/proc/TakeBite(mob/living/eater, mob/living/feeder)
	if(!reagents)
		return FALSE
	if(M.satiety > -200)
		M.satiety -= junkiness
	playsound(M.loc,'sound/items/eatfood.ogg', rand(10,50), TRUE)
	if(reagents.total_volume)
		SEND_SIGNAL(src, COMSIG_FOOD_EATEN, M, user)
		var/fraction = min(bitesize / reagents.total_volume, 1)
		reagents.trans_to(M, bitesize, transfered_by = user, method = INGEST)
		bitecount++
		On_Consume(M)
		checkLiked(fraction, M)
		return TRUE

/datum/component/edible/proc/On_Consume(mob/living/eater)
	if(!eater)
		return
	if(!reagents.total_volume)
		var/location = parent.loc
		var/obj/item/trash_item = generate_trash(location)
		qdel(src)
		if(istype(location, /mob/living))
			var/mob/living/L = location
			L.put_in_hands(trash_item)

/datum/component/edible/proc/generate_trash(atom/location)
	if(!trash)
		return
	if(ispath(trash, /obj/item))
		. = new trash(location)
		trash = null
	else if(isitem(trash))
		var/obj/item/trash_item = trash
		trash_item.forceMove(location)
		. = trash
		trash = null
