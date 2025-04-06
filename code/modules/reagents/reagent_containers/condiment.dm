
///////////////////////////////////////////////Condiments
//Notes by Darem: The condiments food-subtype is for stuff you don't actually eat but you use to modify existing food. They all
// leave empty containers when used up and can be filled/re-filled with other items. Formatting for first section is identical
// to mixed-drinks code. If you want an object that starts pre-loaded, you need to make it in addition to the other code.

//Food items that aren't eaten normally and leave an empty container behind.
/obj/item/reagent_containers/condiment
	name = "condiment bottle"
	desc = "Just your average condiment bottle."
	icon = 'icons/obj/food/containers.dmi'
	icon_state = "bottle"
	inhand_icon_state = "beer" //Generic held-item sprite until unique ones are made.
	lefthand_file = 'icons/mob/inhands/items/drinks_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/items/drinks_righthand.dmi'
	reagent_flags = OPENCONTAINER
	obj_flags = UNIQUE_RENAME
	possible_transfer_amounts = list(1, 5, 10, 15, 20, 25, 30, 50)
	volume = 50
	fill_icon_thresholds = list(0, 10, 25, 50, 75, 100)
	/// Icon (icon_state) to be used when container becomes empty (no change if falsy)
	var/icon_empty
	/// Holder for original icon_state value if it was overwritten by icon_emty to change back to
	var/icon_preempty

/obj/item/reagent_containers/condiment/update_icon_state()
	. = ..()
	if(reagents.reagent_list.len)
		if(icon_preempty)
			icon_state = icon_preempty
			icon_preempty = null
		return ..()

	if(icon_empty && !icon_preempty)
		icon_preempty = icon_state
		icon_state = icon_empty
	return ..()

/obj/item/reagent_containers/condiment/suicide_act(mob/living/carbon/user)
	user.visible_message(span_suicide("[user] is trying to eat the entire [src]! It looks like [user.p_they()] forgot how food works!"))
	return OXYLOSS

/obj/item/reagent_containers/condiment/attack(mob/M, mob/user, def_zone)

	if(!reagents || !reagents.total_volume)
		to_chat(user, span_warning("None of [src] left, oh no!"))
		return FALSE

	if(!canconsume(M, user))
		return FALSE

	if(M == user)
		user.visible_message(span_notice("[user] swallows some of the contents of \the [src]."), \
			span_notice("You swallow some of the contents of \the [src]."))
	else
		M.visible_message(span_warning("[user] attempts to feed [M] from [src]."), \
			span_warning("[user] attempts to feed you from [src]."))
		if(!do_after(user, 3 SECONDS, M))
			return
		if(!reagents || !reagents.total_volume)
			return // The condiment might be empty after the delay.
		M.visible_message(span_warning("[user] fed [M] from [src]."), \
			span_warning("[user] fed you from [src]."))
		log_combat(user, M, "fed", reagents.get_reagent_log_string())
	reagents.trans_to(M, 10, transferred_by = user, methods = INGEST)
	playsound(M.loc,'sound/items/drink.ogg', rand(10,50), TRUE)
	return TRUE

/obj/item/reagent_containers/condiment/interact_with_atom(atom/target, mob/living/user, list/modifiers)
	if(istype(target, /obj/structure/reagent_dispensers)) //A dispenser. Transfer FROM it TO us.
		if(!target.reagents.total_volume)
			to_chat(user, span_warning("[target] is empty!"))
			return ITEM_INTERACT_BLOCKING

		if(reagents.total_volume >= reagents.maximum_volume)
			to_chat(user, span_warning("[src] is full!"))
			return ITEM_INTERACT_BLOCKING

		var/trans = round(target.reagents.trans_to(src, amount_per_transfer_from_this, transferred_by = user), CHEMICAL_VOLUME_ROUNDING)
		to_chat(user, span_notice("You fill [src] with [trans] units of the contents of [target]."))
		return ITEM_INTERACT_SUCCESS

	//Something like a glass or a food item. Player probably wants to transfer TO it.
	else if(target.is_drainable() || IS_EDIBLE(target))
		if(!reagents.total_volume)
			to_chat(user, span_warning("[src] is empty!"))
			return ITEM_INTERACT_BLOCKING
		if(target.reagents.total_volume >= target.reagents.maximum_volume)
			to_chat(user, span_warning("you can't add anymore to [target]!"))
			return ITEM_INTERACT_BLOCKING
		var/trans = round(reagents.trans_to(target, amount_per_transfer_from_this, transferred_by = user), CHEMICAL_VOLUME_ROUNDING)
		to_chat(user, span_notice("You transfer [trans] units of the condiment to [target]."))
		return ITEM_INTERACT_SUCCESS

	return NONE

/obj/item/reagent_containers/condiment/enzyme
	name = "universal enzyme"
	desc = "Used in cooking various dishes."
	icon_state = "enzyme"
	list_reagents = list(/datum/reagent/consumable/enzyme = 50)
	fill_icon_thresholds = null

/obj/item/reagent_containers/condiment/enzyme/examine(mob/user)
	. = ..()
	var/datum/chemical_reaction/recipe = GLOB.chemical_reactions_list[/datum/chemical_reaction/food/cheesewheel]
	var/milk_required = recipe.required_reagents[/datum/reagent/consumable/milk]
	var/enzyme_required = recipe.required_catalysts[/datum/reagent/consumable/enzyme]
	. += span_notice("[milk_required] milk, [enzyme_required] enzyme and you got cheese.")
	. += span_warning("Remember, the enzyme isn't used up, so return it to the bottle, dingus!")

/obj/item/reagent_containers/condiment/sugar
	name = "sugar sack"
	desc = "Tasty spacey sugar!"
	icon_state = "sugar"
	inhand_icon_state = "carton"
	lefthand_file = 'icons/mob/inhands/items/drinks_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/items/drinks_righthand.dmi'
	list_reagents = list(/datum/reagent/consumable/sugar = 50)
	fill_icon_thresholds = null

/obj/item/reagent_containers/condiment/sugar/examine(mob/user)
	. = ..()
	var/datum/chemical_reaction/recipe = GLOB.chemical_reactions_list[/datum/chemical_reaction/food/cakebatter]
	var/flour_required = recipe.required_reagents[/datum/reagent/consumable/flour]
	var/eggyolk_required = recipe.required_reagents[/datum/reagent/consumable/eggyolk]
	var/sugar_required = recipe.required_reagents[/datum/reagent/consumable/sugar]
	. += span_notice("[flour_required] flour, [eggyolk_required] egg yolk (or soy milk), [sugar_required] sugar makes cake dough. You can make pie dough from it.")

/obj/item/reagent_containers/condiment/saltshaker //Separate from above since it's a small shaker rather then
	name = "salt shaker" // a large one.
	desc = "Salt. From space oceans, presumably."
	icon_state = "saltshakersmall"
	icon_empty = "emptyshaker"
	inhand_icon_state = ""
	possible_transfer_amounts = list(1,20) //for clown turning the lid off
	amount_per_transfer_from_this = 1
	volume = 20
	list_reagents = list(/datum/reagent/consumable/salt = 20)
	fill_icon_thresholds = null

/obj/item/reagent_containers/condiment/saltshaker/suicide_act(mob/living/user)
	user.visible_message(span_suicide("[user] begins to swap forms with the salt shaker! It looks like [user.p_theyre()] trying to commit suicide!"))
	var/newname = "[name]"
	name = "[user.name]"
	user.name = newname
	user.real_name = newname
	desc = "Salt. From dead crew, presumably."
	return TOXLOSS

/obj/item/reagent_containers/condiment/saltshaker/interact_with_atom(atom/target, mob/living/user, list/modifiers)
	. = ..()
	if(. & ITEM_INTERACT_ANY_BLOCKER)
		return .
	if(isturf(target))
		if(!reagents.has_reagent(/datum/reagent/consumable/salt, 2))
			to_chat(user, span_warning("You don't have enough salt to make a pile!"))
			return
		user.visible_message(span_notice("[user] shakes some salt onto [target]."), span_notice("You shake some salt onto [target]."))
		reagents.remove_reagent(/datum/reagent/consumable/salt, 2)
		new/obj/effect/decal/cleanable/food/salt(target)
		return ITEM_INTERACT_SUCCESS
	return .

/obj/item/reagent_containers/condiment/peppermill
	name = "pepper mill"
	desc = "Often used to flavor food or make people sneeze."
	icon_state = "peppermillsmall"
	icon_empty = "emptyshaker"
	inhand_icon_state = ""
	possible_transfer_amounts = list(1,20) //for clown turning the lid off
	amount_per_transfer_from_this = 1
	volume = 20
	list_reagents = list(/datum/reagent/consumable/blackpepper = 20)
	fill_icon_thresholds = null

/obj/item/reagent_containers/condiment/milk
	name = "space milk"
	desc = "It's milk. White and nutritious goodness!"
	icon_state = "milk"
	inhand_icon_state = "carton"
	lefthand_file = 'icons/mob/inhands/items/drinks_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/items/drinks_righthand.dmi'
	list_reagents = list(/datum/reagent/consumable/milk = 50)
	fill_icon_thresholds = null

/obj/item/reagent_containers/condiment/milk/examine(mob/user)
	. = ..()
	var/datum/chemical_reaction/recipe = GLOB.chemical_reactions_list[/datum/chemical_reaction/food/cheesewheel]
	var/milk_required = recipe.required_reagents[/datum/reagent/consumable/milk]
	var/enzyme_required = recipe.required_catalysts[/datum/reagent/consumable/enzyme]
	. += span_notice("[milk_required] milk, [enzyme_required] enzyme and you got cheese.")
	. += span_warning("Remember, the enzyme isn't used up, so return it to the bottle, dingus!")

/obj/item/reagent_containers/condiment/flour
	name = "flour sack"
	desc = "A big bag of flour. Good for baking!"
	icon_state = "flour"
	inhand_icon_state = "carton"
	lefthand_file = 'icons/mob/inhands/items/drinks_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/items/drinks_righthand.dmi'
	list_reagents = list(/datum/reagent/consumable/flour = 30)
	fill_icon_thresholds = null

/obj/item/reagent_containers/condiment/flour/examine(mob/user)
	. = ..()
	var/datum/chemical_reaction/recipe_dough = GLOB.chemical_reactions_list[/datum/chemical_reaction/food/dough]
	var/datum/chemical_reaction/recipe_cakebatter = GLOB.chemical_reactions_list[/datum/chemical_reaction/food/cakebatter]
	var/dough_flour_required = recipe_dough.required_reagents[/datum/reagent/consumable/flour]
	var/dough_water_required = recipe_dough.required_reagents[/datum/reagent/water]
	var/cakebatter_flour_required = recipe_cakebatter.required_reagents[/datum/reagent/consumable/flour]
	var/cakebatter_eggyolk_required = recipe_cakebatter.required_reagents[/datum/reagent/consumable/eggyolk]
	var/cakebatter_sugar_required = recipe_cakebatter.required_reagents[/datum/reagent/consumable/sugar]
	. += "<b><i>You retreat inward and recall the teachings of... Making Dough...</i></b>"
	. += span_notice("[dough_flour_required] flour, [dough_water_required] water makes normal dough. You can make flat dough from it.")
	. += span_notice("[cakebatter_flour_required] flour, [cakebatter_eggyolk_required] egg yolk (or soy milk), [cakebatter_sugar_required] sugar makes cake dough. You can make pie dough from it.")

/obj/item/reagent_containers/condiment/soymilk
	name = "soy milk"
	desc = "It's soy milk. White and nutritious goodness!"
	icon_state = "soymilk"
	inhand_icon_state = "carton"
	lefthand_file = 'icons/mob/inhands/items/drinks_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/items/drinks_righthand.dmi'
	list_reagents = list(/datum/reagent/consumable/soymilk = 50)
	fill_icon_thresholds = null

/obj/item/reagent_containers/condiment/rice
	name = "rice sack"
	desc = "A big bag of rice. Good for cooking!"
	icon_state = "rice"
	inhand_icon_state = "carton"
	lefthand_file = 'icons/mob/inhands/items/drinks_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/items/drinks_righthand.dmi'
	list_reagents = list(/datum/reagent/consumable/rice = 30)
	fill_icon_thresholds = null

/obj/item/reagent_containers/condiment/cornmeal
	name = "cornmeal box"
	desc = "A big box of cornmeal. Great for southern style cooking."
	icon_state = "cornmeal"
	inhand_icon_state = "carton"
	lefthand_file = 'icons/mob/inhands/items/drinks_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/items/drinks_righthand.dmi'
	list_reagents = list(/datum/reagent/consumable/cornmeal = 30)
	fill_icon_thresholds = null

/obj/item/reagent_containers/condiment/bbqsauce
	name = "bbq sauce"
	desc = "Hand wipes not included."
	icon_state = "bbqsauce"
	list_reagents = list(/datum/reagent/consumable/bbqsauce = 50)

/obj/item/reagent_containers/condiment/soysauce
	name = "soy sauce"
	desc = "A salty soy-based flavoring."
	icon_state = "soysauce"
	list_reagents = list(/datum/reagent/consumable/soysauce = 50)
	fill_icon_thresholds = null

/obj/item/reagent_containers/condiment/mayonnaise
	name = "mayonnaise"
	desc = "An oily condiment made from egg yolks."
	icon_state = "mayonnaise"
	list_reagents = list(/datum/reagent/consumable/mayonnaise = 50)
	fill_icon_thresholds = null

/obj/item/reagent_containers/condiment/vinegar
	name = "vinegar"
	desc = "Perfect for chips, if you're feeling Space British."
	icon_state = "vinegar"
	list_reagents = list(/datum/reagent/consumable/vinegar = 50)
	fill_icon_thresholds = null

/obj/item/reagent_containers/condiment/vegetable_oil
	name = "cooking oil"
	desc = "For all your deep-frying needs."
	icon_state = "cooking_oil"
	list_reagents = list(/datum/reagent/consumable/nutriment/fat/oil = 50)
	fill_icon_thresholds = null

/obj/item/reagent_containers/condiment/olive_oil
	name = "quality oil"
	desc = "For the fancy chef inside everyone."
	icon_state = "oliveoil"
	list_reagents = list(/datum/reagent/consumable/nutriment/fat/oil/olive = 50)
	fill_icon_thresholds = null

/obj/item/reagent_containers/condiment/yoghurt
	name = "yoghurt carton"
	desc = "Creamy and smooth."
	icon_state = "yoghurt"
	list_reagents = list(/datum/reagent/consumable/yoghurt = 50)
	fill_icon_thresholds = null

/obj/item/reagent_containers/condiment/peanut_butter
	name = "peanut butter"
	desc = "Tasty, fattening processed peanuts in a jar."
	icon_state = "peanutbutter"
	list_reagents = list(/datum/reagent/consumable/peanut_butter = 50)
	fill_icon_thresholds = null

/obj/item/reagent_containers/condiment/cherryjelly
	name = "cherry jelly"
	desc = "A jar of super-sweet cherry jelly."
	icon_state = "cherryjelly"
	list_reagents = list(/datum/reagent/consumable/cherryjelly = 50)
	fill_icon_thresholds = null

/obj/item/reagent_containers/condiment/honey
	name = "honey"
	desc = "A jar of sweet and viscous honey."
	icon_state = "honey"
	list_reagents = list(/datum/reagent/consumable/honey = 50)
	fill_icon_thresholds = null

/obj/item/reagent_containers/condiment/ketchup
	name = "ketchup"
	// At time of writing, "ketchup" mechanically, is just ground tomatoes,
	// rather than // tomatoes plus vinegar plus sugar.
	desc = "A tomato slurry in a tall plastic bottle. Somehow still vaguely American."
	icon_state = "ketchup"
	list_reagents = list(/datum/reagent/consumable/ketchup = 50)
	fill_icon_thresholds = null

/obj/item/reagent_containers/condiment/worcestershire
	name = "worcestershire sauce"
	desc = "A fermented sauce of legend from old England. Makes almost anything better."
	icon_state = "worcestershire"
	list_reagents = list(/datum/reagent/consumable/worcestershire = 50)
	fill_icon_thresholds = null

/obj/item/reagent_containers/condiment/red_bay
	name = "\improper Red Bay seasoning"
	desc = "Mars' favourite seasoning."
	icon_state = "red_bay"
	list_reagents = list(/datum/reagent/consumable/red_bay = 50)
	fill_icon_thresholds = null

/obj/item/reagent_containers/condiment/curry_powder
	name = "curry powder"
	desc = "It's this yellow magic that makes curry taste like curry."
	icon_state = "curry_powder"
	list_reagents = list(/datum/reagent/consumable/curry_powder = 50)
	fill_icon_thresholds = null

/obj/item/reagent_containers/condiment/dashi_concentrate
	name = "dashi concentrate"
	desc = "A bottle of Amagi brand dashi concentrate. Simmer with water in a 1:8 ratio for a perfect dashi broth."
	icon_state = "dashi_concentrate"
	list_reagents = list(/datum/reagent/consumable/dashi_concentrate = 50)
	fill_icon_thresholds = null

/obj/item/reagent_containers/condiment/coconut_milk
	name = "coconut milk"
	desc = "It's coconut milk. Toasty!"
	icon_state = "coconut_milk"
	inhand_icon_state = "carton"
	lefthand_file = 'icons/mob/inhands/items/drinks_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/items/drinks_righthand.dmi'
	list_reagents = list(/datum/reagent/consumable/coconut_milk = 50)
	fill_icon_thresholds = null

/obj/item/reagent_containers/condiment/grounding_solution
	name = "grounding solution"
	desc = "A food-safe ionic solution designed to neutralise the enigmatic \"liquid electricity\" that is common to food from Sprout, forming harmless salt on contact."
	icon_state = "grounding_solution"
	list_reagents = list(/datum/reagent/consumable/grounding_solution = 50)
	fill_icon_thresholds = null

/obj/item/reagent_containers/condiment/protein
	name = "protein powder"
	desc = "Fuel for your inner Hulk - because you can't spell 'swole' without 'whey'!"
	icon_state = "protein"
	list_reagents = list(/datum/reagent/consumable/nutriment/protein = 40)
	fill_icon_thresholds = null

//technically condiment packs but they are non transparent

/obj/item/reagent_containers/condiment/creamer
	name = "coffee creamer pack"
	desc = "Better not think about what they're making this from."
	icon_state = "condi_creamer"
	volume = 5
	list_reagents = list(/datum/reagent/consumable/creamer = 5)
	fill_icon_thresholds = null

/obj/item/reagent_containers/condiment/chocolate
	name = "chocolate sprinkle pack"
	desc= "The amount of sugar that's already there wasn't enough for you?"
	icon_state = "condi_chocolate"
	list_reagents = list(/datum/reagent/consumable/choccyshake = 10)


/obj/item/reagent_containers/condiment/hotsauce
	name = "hotsauce bottle"
	desc= "You can almost TASTE the stomach ulcers!"
	icon_state = "hotsauce"
	list_reagents = list(/datum/reagent/consumable/capsaicin = 50)

/obj/item/reagent_containers/condiment/coldsauce
	name = "coldsauce bottle"
	desc= "Leaves the tongue numb from its passage."
	icon_state = "coldsauce"
	list_reagents = list(/datum/reagent/consumable/frostoil = 50)

//Food packs. To easily apply deadly toxi... delicious sauces to your food!

/obj/item/reagent_containers/condiment/pack
	name = "condiment pack"
	desc = "A small plastic pack with condiments to put on your food."
	icon_state = "condi_empty"
	volume = 10
	amount_per_transfer_from_this = 10
	possible_transfer_amounts = list(10)
	/**
	  * List of possible styles (list(<icon_state>, <name>, <desc>)) for condiment packs.
	  * Since all of them differs only in color should probably be replaced with usual reagentfillings instead
	  */
	var/list/possible_states = list(
		/datum/reagent/consumable/ketchup = list("condi_ketchup", "Ketchup", "You feel more American already."),
		/datum/reagent/consumable/capsaicin = list("condi_hotsauce", "Hotsauce", "You can almost TASTE the stomach ulcers now!"),
		/datum/reagent/consumable/soysauce = list("condi_soysauce", "Soy Sauce", "A salty soy-based flavoring"),
		/datum/reagent/consumable/frostoil = list("condi_frostoil", "Coldsauce", "Leaves the tongue numb in its passage"),
		/datum/reagent/consumable/salt = list("condi_salt", "Salt Shaker", "Salt. From space oceans, presumably"),
		/datum/reagent/consumable/blackpepper = list("condi_pepper", "Pepper Mill", "Often used to flavor food or make people sneeze"),
		/datum/reagent/consumable/nutriment/fat/oil = list("condi_cornoil", "Vegetable Oil", "A delicious oil used in cooking."),
		/datum/reagent/consumable/sugar = list("condi_sugar", "Sugar", "Tasty spacey sugar!"),
		/datum/reagent/consumable/astrotame = list("condi_astrotame", "Astrotame", "The sweetness of a thousand sugars but none of the calories."),
		/datum/reagent/consumable/bbqsauce = list("condi_bbq", "BBQ sauce", "Hand wipes not included."),
		/datum/reagent/consumable/peanut_butter = list("condi_peanutbutter", "Peanut Butter", "A creamy paste made from ground peanuts."),
		/datum/reagent/consumable/cherryjelly = list("condi_cherryjelly", "Cherry Jelly", "A jar of super-sweet cherry jelly."),
		/datum/reagent/consumable/mayonnaise = list("condi_mayo", "Mayonnaise", "Not an instrument."),
	)
	/// Can't use initial(name) for this. This stores the name set by condimasters.
	var/originalname = "condiment"

/obj/item/reagent_containers/condiment/pack/create_reagents(max_vol, flags)
	. = ..()
	RegisterSignal(reagents, COMSIG_REAGENTS_HOLDER_UPDATED, PROC_REF(on_reagent_update), TRUE)

/obj/item/reagent_containers/condiment/pack/update_icon()
	SHOULD_CALL_PARENT(FALSE)
	return

/obj/item/reagent_containers/condiment/pack/attack(mob/M, mob/user, def_zone) //Can't feed these to people directly.
	return

/obj/item/reagent_containers/condiment/pack/interact_with_atom(atom/target, mob/living/user, list/modifiers)
	//You can tear the bag open above food to put the condiments on it, obviously.
	if(IS_EDIBLE(target))
		if(!reagents.total_volume)
			to_chat(user, span_warning("You tear open [src], but there's nothing in it."))
			qdel(src)
			return ITEM_INTERACT_BLOCKING
		if(target.reagents.total_volume >= target.reagents.maximum_volume)
			to_chat(user, span_warning("You tear open [src], but [target] is stacked so high that it just drips off!") )
			qdel(src)
			return ITEM_INTERACT_BLOCKING
		to_chat(user, span_notice("You tear open [src] above [target] and the condiments drip onto it."))
		reagents.trans_to(target, amount_per_transfer_from_this, transferred_by = user)
		qdel(src)
		return ITEM_INTERACT_SUCCESS
	return ..()

/// Handles reagents getting added to the condiment pack.
/obj/item/reagent_containers/condiment/pack/proc/on_reagent_update(datum/reagents/reagents)
	SIGNAL_HANDLER

	if(!reagents.total_volume)
		icon_state = "condi_empty"
		desc = "A small condiment pack. It is empty."
		return
	var/datum/reagent/main_reagent = reagents.get_master_reagent()

	var/list/temp_list = possible_states[main_reagent.type]
	if(length(temp_list))
		icon_state = temp_list[1]
		desc = temp_list[3]
	else
		icon_state = "condi_mixed"
		desc = "A small condiment pack. The label says it contains [originalname]"

//Ketchup
/obj/item/reagent_containers/condiment/pack/ketchup
	name = "ketchup pack"
	originalname = "ketchup"
	list_reagents = list(/datum/reagent/consumable/ketchup = 10)

//Hot sauce
/obj/item/reagent_containers/condiment/pack/hotsauce
	name = "hotsauce pack"
	originalname = "hotsauce"
	list_reagents = list(/datum/reagent/consumable/capsaicin = 10)

/obj/item/reagent_containers/condiment/pack/astrotame
	name = "astrotame pack"
	originalname = "astrotame"
	volume = 5
	list_reagents = list(/datum/reagent/consumable/astrotame = 5)

/obj/item/reagent_containers/condiment/pack/bbqsauce
	name = "bbq sauce pack"
	originalname = "bbq sauce"
	list_reagents = list(/datum/reagent/consumable/bbqsauce = 10)

/obj/item/reagent_containers/condiment/pack/creamer
	name = "creamer pack"
	originalname = "creamer"
	volume = 5
	list_reagents = list(/datum/reagent/consumable/cream = 5)

/obj/item/reagent_containers/condiment/pack/sugar
	name = "sugar pack"
	originalname = "sugar"
	volume = 5
	list_reagents = list(/datum/reagent/consumable/sugar = 5)

/obj/item/reagent_containers/condiment/pack/soysauce
	name = "soy sauce pack"
	originalname = "soy sauce"
	volume = 5
	list_reagents = list(/datum/reagent/consumable/soysauce = 5)

/obj/item/reagent_containers/condiment/pack/mayonnaise
	name = "mayonnaise pack"
	originalname = "mayonnaise"
	volume = 5
	list_reagents = list(/datum/reagent/consumable/mayonnaise = 5)
