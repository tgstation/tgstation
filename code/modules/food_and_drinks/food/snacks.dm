/** # Snacks

Items in the "Snacks" subcategory are food items that people actually eat. The key points are that they are created
already filled with reagents and are destroyed when empty. Additionally, they make a "munching" noise when eaten.

Notes by Darem: Food in the "snacks" subtype can hold a maximum of 50 units. Generally speaking, you don't want to go over 40
total for the item because you want to leave space for extra condiments. If you want effect besides healing, add a reagent for
it. Try to stick to existing reagents when possible (so if you want a stronger healing effect, just use omnizine). On use
effect (such as the old officer eating a donut code) requires a unique reagent (unless you can figure out a better way).

The nutriment reagent and bitesize variable replace the old heal_amt and amount variables. Each unit of nutriment is equal to
2 of the old heal_amt variable. Bitesize is the rate at which the reagents are consumed. So if you have 6 nutriment and a
bitesize of 2, then it'll take 3 bites to eat. Unlike the old system, the contained reagents are evenly spread among all
the bites. No more contained reagents = no more bites.

Here is an example of the new formatting for anyone who wants to add more food items.
```
/obj/item/reagent_containers/food/snacks/xenoburger			//Identification path for the object.
	name = "Xenoburger"													//Name that displays in the UI.
	desc = "Smells caustic. Tastes like heresy."						//Duh
	icon_state = "xburger"												//Refers to an icon in food.dmi
/obj/item/reagent_containers/food/snacks/xenoburger/Initialize()		//Don't mess with this. | nO I WILL MESS WITH THIS
	. = ..()														//Same here.
	reagents.add_reagent(/datum/reagent/xenomicrobes, 10)						//This is what is in the food item. you may copy/paste
	reagents.add_reagent(/datum/reagent/consumable/nutriment, 2)							//this line of code for all the contents.
	bitesize = 3													//This is the amount each bite consumes.
```

All foods are distributed among various categories. Use common sense.
*/
/obj/item/reagent_containers/food/snacks
	name = "snack"
	desc = "Yummy."
	icon = 'icons/obj/food/food.dmi'
	icon_state = null
	lefthand_file = 'icons/mob/inhands/misc/food_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/misc/food_righthand.dmi'
	obj_flags = UNIQUE_RENAME
	grind_results = list() //To let them be ground up to transfer their reagents
	var/bitesize = 2
	var/bitecount = 0
	var/trash = null
	var/slice_path    // for sliceable food. path of the item resulting from the slicing
	var/slices_num
	var/eatverb
	var/dried_type = null
	var/dry = 0
	var/dunk_amount = 10 // how much reagent is transferred per dunk
	var/cooked_type = null  //for microwave cooking. path of the resulting item after microwaving
	var/filling_color = "#FFFFFF" //color to use when added to custom food.
	var/custom_food_type = null  //for food customizing. path of the custom food to create
	var/junkiness = 0  //for junk food. used to lower human satiety.
	var/list/bonus_reagents //the amount of reagents (usually nutriment and vitamin) added to crafted/cooked snacks, on top of the ingredients reagents.
	var/customfoodfilling = 1 // whether it can be used as filling in custom food
	var/list/tastes  // for example list("crisps" = 2, "salt" = 1)
	var/value = 10	//Which export tier of value the item falls under.
	var/silver_spawned = FALSE	//Special case used for exporting, only true if created from a silver slime to prevent cheese.

	//Placeholder for effect that trigger on eating that aren't tied to reagents.

/obj/item/reagent_containers/food/snacks/add_initial_reagents()
	if(tastes && tastes.len)
		if(list_reagents)
			for(var/rid in list_reagents)
				var/amount = list_reagents[rid]
				if(rid == /datum/reagent/consumable/nutriment || rid == /datum/reagent/consumable/nutriment/vitamin)
					reagents.add_reagent(rid, amount, tastes.Copy())
				else
					reagents.add_reagent(rid, amount)
	else
		..()

/obj/item/reagent_containers/food/snacks/proc/On_Consume(mob/living/eater)
	if(!eater)
		return
	if(!reagents.total_volume)
		var/mob/living/location = loc
		var/obj/item/trash_item = generate_trash(location)
		qdel(src)
		if(istype(location))
			location.put_in_hands(trash_item)

//it's never an accident when you eat food! right?
/obj/item/reagent_containers/food/snacks/on_accidental_consumption(mob/living/carbon/M, mob/living/carbon/user, obj/item/source_item,  discover_after = TRUE)
	return TRUE

/obj/item/reagent_containers/food/snacks/attack_self(mob/user)
	return

/obj/item/reagent_containers/food/snacks/attack(mob/living/M, mob/living/user, def_zone)
	if(user.a_intent == INTENT_HARM)
		return ..()
	if(!eatverb)
		eatverb = pick("bite","chew","nibble","gnaw","gobble","chomp")
	if(!reagents.total_volume)						//Shouldn't be needed but it checks to see if it has anything left in it.
		to_chat(user, "<span class='warning'>None of [src] left, oh no!</span>")
		qdel(src)
		return FALSE
	if(iscarbon(M))
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

		if(reagents)								//Handle ingestion of the reagent.
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

	return 0

/obj/item/reagent_containers/food/snacks/examine(mob/user)
	. = ..()
	if(!in_container)
		switch (bitecount)
			if (0)
				return
			if(1)
				. += "[src] was bitten by someone!"
			if(2,3)
				. += "[src] was bitten [bitecount] times!"
			else
				. += "[src] was bitten multiple times!"

/obj/item/reagent_containers/food/snacks/attackby(obj/item/W, mob/user, params)
	if(istype(W, /obj/item/storage))
		..() // -> item/attackby()
		return 0
	if(istype(W, /obj/item/reagent_containers/food/snacks))
		var/obj/item/reagent_containers/food/snacks/S = W
		if(custom_food_type && ispath(custom_food_type))
			if(S.w_class > WEIGHT_CLASS_SMALL)
				to_chat(user, "<span class='warning'>[S] is too big for [src]!</span>")
				return 0
			if(!S.customfoodfilling || istype(W, /obj/item/reagent_containers/food/snacks/customizable) || istype(W, /obj/item/reagent_containers/food/snacks/pizzaslice/custom) || istype(W, /obj/item/reagent_containers/food/snacks/cakeslice/custom))
				to_chat(user, "<span class='warning'>[src] can't be filled with [S]!</span>")
				return 0
			if(contents.len >= 20)
				to_chat(user, "<span class='warning'>You can't add more ingredients to [src]!</span>")
				return 0
			var/obj/item/reagent_containers/food/snacks/customizable/C = new custom_food_type(get_turf(src))
			C.initialize_custom_food(src, S, user)
			return 0
	if(user.a_intent != INTENT_DISARM)
		var/sharp = W.get_sharpness()
		return sharp && slice(sharp, W, user)
	else
		..()

//Called when you finish tablecrafting a snack.
/obj/item/reagent_containers/food/snacks/CheckParts(list/parts_list, datum/crafting_recipe/food/R)
	..()
	reagents.clear_reagents()
	for(var/obj/item/reagent_containers/RC in contents)
		RC.reagents.trans_to(reagents, RC.reagents.maximum_volume)
	if(istype(R))
		contents_loop:
			for(var/A in contents)
				for(var/B in R.real_parts)
					if(istype(A, B))
						continue contents_loop
				qdel(A)
	SSblackbox.record_feedback("tally", "food_made", 1, type)

	if(bonus_reagents && bonus_reagents.len)
		for(var/r_id in bonus_reagents)
			var/amount = bonus_reagents[r_id]
			if(r_id == /datum/reagent/consumable/nutriment || r_id == /datum/reagent/consumable/nutriment/vitamin)
				reagents.add_reagent(r_id, amount, tastes)
			else
				reagents.add_reagent(r_id, amount)

/obj/item/reagent_containers/food/snacks/proc/slice(accuracy, obj/item/W, mob/user)
	if((slices_num <= 0 || !slices_num) || !slice_path) //is the food sliceable?
		return FALSE

	if ( \
			!isturf(src.loc) || \
			!(locate(/obj/structure/table) in src.loc) && \
			!(locate(/obj/structure/table/optable) in src.loc) && \
			!(locate(/obj/item/storage/bag/tray) in src.loc) \
		)
		to_chat(user, "<span class='warning'>You cannot slice [src] here! You need a table or at least a tray.</span>")
		return FALSE

	user.visible_message("[user] slices [src].", "<span class='notice'>You slice [src].</span>")

	var/reagents_per_slice = reagents.total_volume/slices_num
	for(var/i in 1 to slices_num)
		var/obj/item/reagent_containers/food/snacks/slice = new slice_path (loc)
		initialize_slice(slice, reagents_per_slice)
	qdel(src)
	return TRUE

/obj/item/reagent_containers/food/snacks/proc/initialize_slice(obj/item/reagent_containers/food/snacks/slice, reagents_per_slice)
	slice.create_reagents(slice.volume)
	reagents.trans_to(slice,reagents_per_slice)
	if(name != initial(name))
		slice.name = "slice of [name]"
	if(desc != initial(desc))
		slice.desc = "[desc]"
	if(foodtype != initial(foodtype))
		slice.foodtype = foodtype //if something happens that overrode our food type, make sure the slice carries that over

/obj/item/reagent_containers/food/snacks/proc/generate_trash(atom/location)
	if(!trash)
		return

	if(ispath(trash, /obj/item))
		. = new trash(location)
		trash = null
		return
	else if(isitem(trash))
		var/obj/item/trash_item = trash
		trash_item.forceMove(location)
		. = trash
		trash = null
		return

/obj/item/reagent_containers/food/snacks/proc/update_snack_overlays(obj/item/reagent_containers/food/snacks/S)
	cut_overlays()
	var/mutable_appearance/filling = mutable_appearance(icon, "[initial(icon_state)]_filling")
	if(S.filling_color == "#FFFFFF")
		filling.color = pick("#FF0000","#0000FF","#008000","#FFFF00")
	else
		filling.color = S.filling_color

	add_overlay(filling)

// initialize_cooked_food() is called when microwaving the food
/obj/item/reagent_containers/food/snacks/proc/initialize_cooked_food(obj/item/reagent_containers/food/snacks/S, cooking_efficiency = 1)
	S.create_reagents(S.volume)
	if(reagents)
		reagents.trans_to(S, reagents.total_volume)
	if(S.bonus_reagents && S.bonus_reagents.len)
		for(var/r_id in S.bonus_reagents)
			var/amount = S.bonus_reagents[r_id] * cooking_efficiency
			if(r_id == /datum/reagent/consumable/nutriment || r_id == /datum/reagent/consumable/nutriment/vitamin)
				S.reagents.add_reagent(r_id, amount, tastes)
			else
				S.reagents.add_reagent(r_id, amount)

/obj/item/reagent_containers/food/snacks/microwave_act(obj/machinery/microwave/M)
	var/turf/T = get_turf(src)
	var/obj/item/result

	if(cooked_type)
		result = new cooked_type(T)
		if(istype(M))
			initialize_cooked_food(result, M.efficiency)
		else
			initialize_cooked_food(result, 1)
		SSblackbox.record_feedback("tally", "food_made", 1, result.type)
	else
		result = new /obj/item/reagent_containers/food/snacks/badrecipe(T)
		if(istype(M) && M.dirty < 100)
			M.dirty++
	qdel(src)

	return result

/obj/item/reagent_containers/food/snacks/Destroy()
	if(contents)
		for(var/atom/movable/something in contents)
			something.forceMove(drop_location())
	return ..()

/obj/item/reagent_containers/food/snacks/attack_animal(mob/M)
	if(isanimal(M))
		if(isdog(M))
			var/mob/living/L = M
			if(bitecount == 0 || prob(50))
				M.manual_emote("nibbles away at \the [src]")
			bitecount++
			L.taste(reagents) // why should carbons get all the fun?
			if(bitecount >= 5)
				var/sattisfaction_text = pick("burps from enjoyment", "yaps for more", "woofs twice", "looks at the area where \the [src] was")
				if(sattisfaction_text)
					M.emote(sattisfaction_text)
				qdel(src)


// //////////////////////////////////////////////Store////////////////////////////////////////
/// All the food items that can store an item inside itself, like bread or cake.
/obj/item/reagent_containers/food/snacks/store
	w_class = WEIGHT_CLASS_NORMAL
	/// If an item has been stored in the food
	var/stored_item = FALSE
	/// The amount of volume the food has on creation
	var/volume_on_creation = 0
	/// Allows someone to bypass the small weight class requirement, so they can put whatever they want into a slice of bread
	var/bypass_weight_limit = FALSE

/obj/item/reagent_containers/food/snacks/store/Initialize()
	. = ..()
	if(reagents?.total_volume)
		volume_on_creation = reagents.total_volume

/obj/item/reagent_containers/food/snacks/store/attackby(obj/item/W, mob/user, params)
	..()
	if(istype(W, /obj/item/reagent_containers/food/snacks)) //can't slip snacks inside, they're used for custom foods.
		return FALSE

	if((bypass_weight_limit || W.w_class <= WEIGHT_CLASS_SMALL))
		if(W.get_sharpness() && user.a_intent != INTENT_DISARM)
			return FALSE
		if(istype(W, /obj/item/storage))
			return FALSE
		if(stored_item)
			return FALSE
		if(!iscarbon(user))
			return FALSE
		if(contents.len >= 20)
			to_chat(user, "<span class='warning'>[src] is full.</span>")
			return FALSE
		user.visible_message("<span class='notice'>[user.name] begins inserting [W] into [src].</span>", \
						"<span class='notice'>You start to insert the [W] into \the [src].</span>")
		if(!do_after(user, 1.5 SECONDS, target = src))
			return FALSE
		to_chat(user, "<span class='notice'>You slip [W] inside [src].</span>")
		user.transferItemToLoc(W, src)
		log_message("[key_name(user)] inserted [W.name] into [src.name] at [AREACOORD(src)]", LOG_ATTACK)
		add_fingerprint(user)
		contents += W
		stored_item = TRUE
		return TRUE // no afterattack here

/obj/item/reagent_containers/food/snacks/store/attack(mob/living/carbon/M, mob/living/carbon/user, def_zone)
	if(!..())
		return
	/// What are the odds we eat glass? - [Bitecount / Max number of bites] * 100
	var/bad_chance_of_discovery = (bitecount / (volume_on_creation / bitesize))*100	//the closer you get to finishing it, the higher the chance you bite into it
	/// What are the odds we see the glass but don't bite it? - ([Bitecount / Max number of bites] * 100) - 50
	var/good_chance_of_discovery = bad_chance_of_discovery - 50	//the closer you get to finishing it, the more likely you can see what is in it
	/// We've found the item, and plan on remove it
	var/discovered = FALSE

	if(stored_item)
		for(var/obj/item/I in contents)
			if(istype(I, /obj/item/reagent_containers/food/snacks))
				return FALSE
			if(prob(good_chance_of_discovery))
				discovered = TRUE
				to_chat(M, "<span class='warning'>It feels like there's something in this [src.name]...!</span>")

			else if(prob(bad_chance_of_discovery))
				log_message("[key_name(user)] just fed [key_name(M)] a/an [I.name] which was hidden in [src.name] at [AREACOORD(src)]", LOG_ATTACK)
				discovered = I.on_accidental_consumption(M, user, src)

			if(!QDELETED(I) && discovered)
				contents -= I
				stored_item = FALSE
				if(M.put_in_hands(I)) //the moment when you slowly pull out whatever you just bit into in your food
					to_chat(M, "<span class='warning'>You slowly pull [I] out of \the [src].</span>")
				else
					to_chat(M, "<span class='warning'>[I] falls out of \the [src].</span>")

	return FALSE

/obj/item/reagent_containers/food/snacks/MouseDrop(atom/over)
	var/turf/T = get_turf(src)
	var/obj/structure/table/TB = locate(/obj/structure/table) in T
	if(TB)
		TB.MouseDrop(over)
	else
		return ..()
