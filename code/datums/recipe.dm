/* * * * * * * * * * * * * * * * * * * * * * * * * *
 * /datum/recipe by rastaf0            13 apr 2011 *
 * * * * * * * * * * * * * * * * * * * * * * * * * *
 * This is powerful and flexible recipe system.
 * It exists not only for food.
 * supports both reagents and objects as prerequisites.
 * In order to use this system you have to define a deriative from /datum/recipe
 * * reagents are reagents. Acid, milc, booze, etc.
 * * items are objects. Fruits, tools, circuit boards.
 * * result is type to create as new object
 * * time is optional parameter, you shall use in in your machine,
     default /datum/recipe/ procs does not rely on this parameter.
 *
 *  Functions you need:
 *  /datum/recipe/proc/make(var/obj/container as obj)
 *    Creates result inside container,
 *    deletes prerequisite reagents,
 *    transfers reagents from prerequisite objects,
 *    deletes all prerequisite objects (even not needed for recipe at the moment).
 *
 *  /proc/select_recipe(list/datum/recipe/avaiable_recipes, obj/obj as obj, exact = 1)
 *    Wonderful function that select suitable recipe for you.
 *    obj is a machine (or magik hat) with prerequisites,
 *    exact = 0 forces algorithm to ignore superfluous stuff.
 *
 *  Functions you do not need to call directly but could:
 *  /datum/recipe/proc/check_reagents(var/datum/reagents/avail_reagents)
 *    //1 = precisely,  0 = insufficiently, -1 = superfluous
 *
 *  /datum/recipe/proc/check_items(var/obj/container as obj)
 *    //1 = precisely, 0=insufficiently, -1 = superfluous
 *
 * */

//The person who made this honestly thought that the average coder from the distant future of 2015 would understand any of this shit without a thorough and painful examination
//And this is exactly why any Chemistry-related system is impenetrable to anyone but the best coders, even things theorically as simple as this
//So as I decrypt this arcane coding technology, I'll add comments where I see it fit, so absolutely fucking everywhere
//I'll take my Nobel Prize with fries thank you
//And yes indeed I know it's a lot of comments, but if you're not here to understand how recipes work, why are you here ?
/datum/recipe

	var/list/reagents //List of reagents needed and their amount, reagents = list(BERRYJUICE = 5)
	var/list/reagents_forbidden //List of reagents that will not be transfered to the cooked item under any circumstance, use smartly and sparringly. reagents_forbidden = list(TOXIN, WATER)
	var/list/items //List of items needed, items = list(/obj/item/weapon/crowbar, /obj/item/weapon/welder)
	var/result //Well gee, what we output, result = /obj/item/weapon/reagent_containers/food/snacks/donut/normal
	var/time = 100 //In tenths of a second, this is how long it takes for the magic to happen. The machine producing the recipe handles this value, but the recipe defines it

//First step, let's check the reagents in our recipe machine (generally a microwave)
//Since it's reagents, it's about time for Chemistry-Holder insanity
/datum/recipe/proc/check_reagents(var/datum/reagents/avail_reagents) //1 = Precisely what we need, 0 = Not enough, -1 = More than needed
	//Now, here comes the arcane magic. Before we even do anything, we estimate we have just what we need. Why ? Who knows
	. = 1
	//Scan the reagents in our recipe machine thingie one by one for shit we need in our recipe (water, hotsauce, salt, etc...)
	for(var/r_r in reagents)
		//Get the amount of said reagent we'll need in our recipe and assign it to that variable
		var/reagent_amount = avail_reagents.get_reagent_amount(r_r)
		//And now, the fun begins. Let's put this in plain words because holy crap
		if(!(abs(reagent_amount - reagents[r_r]) < 0.5)) //If the absolute value of the amount of our reagent minus the needed amount of reagents for the recipe is NOT under 0.5 (rounding sanity)
			if(reagent_amount > reagents[r_r]) //Let's check if the amount of our reagent is above the needed amount
				. = -1 //If so, then we can say that we have more of this reagent that needed
			else //Else
				return 0 //We don't have what we need, abort, ABORT
		//Remember that this is a for loop, so we do this for every reagent listed in our recipe
	//Now, that check was fun, but we need to check for reagents we have not included per se (things not used in our recipe)
	if((reagents ? (reagents.len) : (0)) < avail_reagents.reagent_list.len) //Given we have reagents in our recipe, are there more reagents in our machine than reagents needed in our recipe ?
		return -1 //We have more reagents than needed, period
	//Otherwise, get that value we determined earlier and send it, nevermind that a variable would have worked since it cannot be null
	return . //If we have too much reagent (in numerical amounts) but only the reagents we need, -1, otherwise 1

//We just had fun with reagents, now let's check for items, literally any item, that is in our recipe. Apples, wrenches, dildos
//You would imagine that this would take a few lines of simple code, but you don't grasp oldcoder logic
/datum/recipe/proc/check_items(var/obj/container as obj) //1 = Precisely what we need, 0 = Not enough, -1 = More than needed
	if(!items) //If there's no items in our recipe
		if(locate(/obj/) in container) //And there are items in our recipe machine currently
			return -1 //That's too much, abort
		else //Nothing in our recipe machine
			return 1 //Just what we need, *ping
	. = 1 //The arcane magic rises again
	var/list/checklist = items.Copy() //We need items in our recipe, so let's copy every single item in our recipe into a checklist
	//Time for a loop
	for(var/obj/O in container) //Let's loop through all the objects in our recipe machine
		var/found = 0 //For once we use an actual variable
		for(var/type in checklist) //At every object we find, stop to take a look at our entire checklist
			if(istype(O, type)) //Is that what we are looking for yet
				checklist -= type //Good, strike it out of our checklist
				found = 1 //WE FOUND IT MA
				break //Break that loop, continue downwards
		if(!found) //Did we not find the object in our recipe machine on the checklist ?
			. = -1 //Something extra in our ingredients, notify the cops
	//We start looping through the objects in the container again at this point, until we checked every single one of them
	if(checklist.len) //Are there still items on our recipe checklist ?
		return 0 //Something is missing, abort
	return . //If we found extra items, return -1, otherwise return 1

//Food-related recipe production
//Note : Due to changes to no longer wipe nutriments from cooked items, this is the same as make. So from now on this is THE "turn recipe into new thing" proc
/datum/recipe/proc/make_food(var/obj/container as obj) //Find our recipe machine and let's begin
	var/obj/result_obj = new result(container) //Spawn the result of our little cuisine in the recipe machine in advance to transfer reagents
	for(var/obj/O in (container.contents - result_obj)) //Find all objects (for instance, raw food or beakers) in our machine, excluding the result we just created
		if(O.reagents) //Little sanity, can't hurt
			for(var/r_r in reagents_forbidden) //Check forbidden reagents
				O.reagents.del_reagent("[r_r]") //If we find any, remove
			O.reagents.update_total() //Make sure we're set
			O.reagents.trans_to(result_obj, O.reagents.total_volume) //If we have reagents in here, squeeze them into the end product
		qdel(O) //Delete the object, he has outlived his usefulness
	container.reagents.clear_reagents() //Clear all the reagents we haven't transfered, for instance if we need to cook in water
	score["meals"]++ //Yes, it's a weird placement, but it's sure to work correctly as long as make_food() is used for food
	return result_obj //Here we go, your result sire

//Find what to do with all this shit in the microwave dynamically, without blowing up the station
//We consider all recipes in the game, obj (typecast as obj and estimated as obj because fuck you) and wherever or not its ingredients are exact based on what we learned from the last two procs
/proc/select_recipe(var/list/datum/recipe/avaiable_recipes, var/obj/obj as obj, var/exact = 1 as num)
	if(!exact) //Is the recipe not exact (1)
		exact = -1 //Change it to -1 for simplicity, too much or not enough is the same problem now
	var/list/datum/recipe/possible_recipes = new //Create a list, hopefully not ending the universe in the process
	for(var/datum/recipe/recipe in avaiable_recipes) //Loop through the ingame recipes
		if(recipe.check_reagents(obj.reagents) == exact && recipe.check_items(obj) == exact) //What did we return for reagents and objects ingredient checks, and does it fit with our recipe ?
			possible_recipes += recipe //Perfect, we can make this recipe with our current ingredients, add it
	if(possible_recipes.len == 0) //We're done looping through the ingame recipes, did we find nothing ?
		return null //Game over
	else if(possible_recipes.len == 1) //Do we have precisely ONE recipe, the only one ?
		return possible_recipes[1] //He is the chosen one
	else //Okay, let's select the most complicated recipe //For posterity, this is the only comment oldcoder left outside of defining what "-1", "0" and "1" correspond to, in broken English
		var/reagents_count = 0 //Let's reserve two variables for the fun inbound, this one for reagents
		var/items_count = 0 //Ditto above, this one is for ingredients
		. = possible_recipes[1] //We'll estimate the first recipe we found is the correct one until we start looping, to avoid returning nothing, nevermind this is what . allows
		for(var/datum/recipe/recipe in possible_recipes) //Loop through all those recipes we found to be matching
			var/items_number = (recipe.items) ? (recipe.items.len) : 0 //Get the exact length of items needed for each recipe
			var/reagents_number = (recipe.reagents) ? (recipe.reagents.len) : 0 //Get the exact length of reagents needed for each recipe
			if(items_number > items_count || (items_number == items_count && reagents_number > reagents_count)) //If there's more items or as much items and more reagents than the previous recipe
				reagents_count = reagents_number //Set this as new maximum
				items_count = items_number //And this one too
				. = recipe //This recipe is now our favourite
		return . //We found the most complex recipe, send that
