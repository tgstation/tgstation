/datum/component/edible
	///Reagents datium for this food
	var/datum/reagents/reagents
	///Amount of reagents taken per bite
	var/bite_consumption = 2
	///Amount of bites taken so far
	var/bitecount = 0
	///Food groups that decide what kind of meter this fills. YOU CAN DO ANYTHING
	var/list/food_groups
	///Flags for food 
	var/food_flags = NONE
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
	///Type of obj this food spawns after eating
	var/trash


	//var/dried_type = null //move this to obj/item/dry-able or to a dry component
	//var/dry = 0 //move this to obj/item/dry-able or to a dry component
	
	//var/cooked_type = null  //should be on the item itself.
	//var/filling_color = "#FFFFFF" //color to use when added to custom food.
	//var/custom_food_type = null  //for food customizing. path of the custom food to create
	
	//var/customfoodfilling = 1 // whether it can be used as filling in custom food

/datum/component/edible/Initialize(list/initial_reagents, bite_consumption = 2, list/food_groups, food_flags = NONE, list/tastes, list/eatverbs = list("bite","chew","nibble","gnaw","gobble","chomp"), slice_path, slices_num = 0, slice_duration = 20, dunk_amount, trash)
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
	src.tastes = tastes
	src.eatverbs = eatverbs
	src.slice_path = slice_path
	src.slices_num = slices_num
	src.slice_duration = slice_duration
	src.junkiness = junkiness
	src.dunk_amount = dunk_amount
	src.trash = trash

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
				. += "[src] was bitten by someone!"
			if(2,3)
				. += "[src] was bitten [bitecount] times!"
			else
				. += "[src] was bitten multiple times!"

/datum/component/edible/proc/UseFromHand(mob/living/M, mob/living/user)
	if(user.a_intent == INTENT_HARM)
		return ..()
	if(!reagents.total_volume)//Shouldn't be needed but it checks to see if it has anything left in it.
		to_chat(user, "<span class='warning'>None of [src] left, oh no!</span>")
		qdel(parent)
	if(!iscarbon(M))
		return
	if(!canconsume(M, user))
		return FALSE

	var/fullness = M.nutrition + 10
	for(var/datum/reagent/consumable/C in M.reagents.reagent_list) //we add the nutrition value of what we're currently digesting
		fullness += C.nutriment_factor * C.volume / C.metabolization_rate

	if(M == user)								//If you're eating it yourself.
		if(junkiness && M.satiety < -150 && M.nutrition > NUTRITION_LEVEL_STARVING + 50 && !HAS_TRAIT(user, TRAIT_VORACIOUS))
			to_chat(M, "<span class='warning'>You don't feel like eating any more junk food at the moment!</span>")
			return FALSE
		else if(fullness <= 50)
			user.visible_message("<span class='notice'>[user] hungrily [eatverb]s \the [src], gobbling it down!</span>", "<span class='notice'>You hungrily [eatverb] \the [src], gobbling it down!</span>")
		else if(fullness > 50 && fullness < 150)
			user.visible_message("<span class='notice'>[user] hungrily [eatverb]s \the [src].</span>", "<span class='notice'>You hungrily [eatverb] \the [src].</span>")
		else if(fullness > 150 && fullness < 500)
			user.visible_message("<span class='notice'>[user] [eatverb]s \the [src].</span>", "<span class='notice'>You [eatverb] \the [src].</span>")
		else if(fullness > 500 && fullness < 600)
			user.visible_message("<span class='notice'>[user] unwillingly [eatverb]s a bit of \the [src].</span>", "<span class='notice'>You unwillingly [eatverb] a bit of \the [src].</span>")
		else if(fullness > (600 * (1 + M.overeatduration / 2000)))	// The more you eat - the more you can eat
			user.visible_message("<span class='warning'>[user] cannot force any more of \the [src] to go down [user.p_their()] throat!</span>", "<span class='warning'>You cannot force any more of \the [src] to go down your throat!</span>")
			return FALSE
		if(HAS_TRAIT(M, TRAIT_VORACIOUS))
			M.changeNext_move(CLICK_CD_MELEE * 0.5) //nom nom nom
	else
		if(!isbrain(M))		//If you're feeding it to someone else.
			if(fullness <= (600 * (1 + M.overeatduration / 1000)))
				M.visible_message("<span class='danger'>[user] attempts to feed [M] [src].</span>", \
									"<span class='userdanger'>[user] attempts to feed you [src].</span>")
			else
				M.visible_message("<span class='warning'>[user] cannot force any more of [src] down [M]'s throat!</span>", \
									"<span class='warning'>[user] cannot force any more of [src] down your throat!</span>")
				return FALSE

			if(!do_mob(user, M))
				return
			log_combat(user, M, "fed", reagents.log_list())
			M.visible_message("<span class='danger'>[user] forces [M] to eat [src]!</span>", \
									"<span class='userdanger'>[user] forces you to eat [src]!</span>")

		else
			to_chat(user, "<span class='warning'>[M] doesn't seem to have a mouth!</span>")
			return
	TakeBite(M, user)

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
		var/mob/living/location = loc
		var/obj/item/trash_item = generate_trash(location)
		qdel(src)
		if(istype(location))
			location.put_in_hands(trash_item)


/obj/item/reagent_containers/microwave_act(obj/machinery/microwave/M)
	reagents.expose_temperature(1000)
	..()

/obj/item/reagent_containers/temperature_expose(datum/gas_mixture/air, exposed_temperature, exposed_volume)
	reagents.expose_temperature(exposed_temperature)
