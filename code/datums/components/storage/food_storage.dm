/datum/component/food_storage
	/// If an item has been stored in the food
	var/stored_item = FALSE
	/// The amount of volume the food has on creation
	var/initial_volume = 10
	/// Minimum size items that can be inserted
	var/minimum_weight_class = WEIGHT_CLASS_SMALL
	/// What are the odds we bite the stored item?
	var/bad_chance_of_discovery = 0
	/// What are the odds we see the stored item, but don't bite it?
	var/good_chance_of_discovery = 100
	/// We've found the item in the food
	var/discovered = FALSE
	/// parent in atom form
	var/atom/food

/datum/component/food_storage/Initialize(_initial_volume = 10, _minimum_weight_class = WEIGHT_CLASS_SMALL)

	RegisterSignal(parent, COMSIG_PARENT_ATTACKBY, .proc/insert_item)
	RegisterSignal(parent, COMSIG_FOOD_EATEN, .proc/consume_food_storage)

	if(_initial_volume) //initial volume should not be 0
		initial_volume =  _initial_volume
	minimum_weight_class = _minimum_weight_class
	food = parent

/datum/component/food_storage/proc/insert_item(datum/source, obj/item/inserted_item, mob/user, params)
	if(istype(inserted_item, /obj/item/storage) || istype(inserted_item, /obj/item/reagent_containers/food/snacks))
		return

	if(inserted_item.w_class > minimum_weight_class)
		to_chat(user, "<span class='warning'>[inserted_item.name] won't fit.</span>")
		return

	if(stored_item)
		to_chat(user, "<span class='warning'>There's something in [food.name].</span>")
		return

	if(food.contents.len >= 20)
		to_chat(user, "<span class='warning'>[food.name] is full.</span>")
		return

	user.visible_message("<span class='notice'>[user.name] begins inserting [inserted_item.name] into [food.name].</span>", \
					"<span class='notice'>You start to insert the [inserted_item.name] into \the [food.name].</span>")
	if(!do_after(user, 1.5 SECONDS, target = food))
		return

	to_chat(user, "<span class='notice'>You slip [inserted_item.name] inside [food.name].</span>")
	user.transferItemToLoc(inserted_item, food)
	food.log_message("[key_name(user)] inserted [inserted_item] into [food] at [AREACOORD(food)]", LOG_ATTACK)
	food.add_fingerprint(user)
	food.contents += inserted_item
	stored_item = TRUE

/datum/component/food_storage/proc/consume_food_storage(datum/source, mob/living/target, mob/living/user, bitecount, bitesize)
	if(stored_item)
		//chance of biting the held item = amount of bites / (intitial reagents / reagents per bite) * 100
		bad_chance_of_discovery = (bitecount / (initial_volume / bitesize))*100
		//chance of finding the held item = bad chance - 50
		good_chance_of_discovery = bad_chance_of_discovery - 50

		for(var/obj/item/I in food.contents)
			if(istype(I, /obj/item/reagent_containers/food/snacks))
				continue

			if(prob(good_chance_of_discovery))
				discovered = TRUE
				to_chat(target, "<span class='warning'>It feels like there's something in this [food.name]...!</span>")

			else if(prob(bad_chance_of_discovery))
				food.log_message("[key_name(user)] just fed [key_name(target)] a/an [I] which was hidden in [food] at [AREACOORD(food)]", LOG_ATTACK)
				discovered = I.on_accidental_consumption(target, user, parent)

			if(QDELETED(I))
				stored_item = FALSE

			else if(discovered)
				food.contents -= I
				stored_item = FALSE
				if(target.put_in_hands(I)) //the moment when you slowly pull out whatever you just bit into in your food
					to_chat(target, "<span class='warning'>You slowly pull [I.name] out of \the [food.name].</span>")
				else
					food.visible_message("<span class='warning'>[I.name] falls out of \the [food.name].</span>")
