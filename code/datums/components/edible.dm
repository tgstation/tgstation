/datum/component/edible
	///Reagents datium for this food
	var/datum/reagents/reagents
	///Flags for food 
	var/food_flags = NONE
	///Amount of reagents taken per bite
	var/bite_consumption = 2
	///Amount of bites taken so far
	var/bitecount = 0
	/// Type path For cut-able food.
	var/slice_path = null
	/// Amount of slices for cutting
	var/slices_num = 0 
	/// Time it takes to cut food
	var/slice_duration = 20
	/// How much we affect satiety
	var/junkiness = 0
	///Message to send when eating
	var/eatverb
	///Whether or not this food can be dunked in reagents
	var/dunkable = FALSE // for dunkable food, make true


	//var/dried_type = null //move this to obj/item/dry-able or to a dry component
	//var/dry = 0 //move this to obj/item/dry-able or to a dry component
	
	//var/cooked_type = null  //should be on the item itself.
	//var/filling_color = "#FFFFFF" //color to use when added to custom food.
	//var/custom_food_type = null  //for food customizing. path of the custom food to create
	
	var/customfoodfilling = 1 // whether it can be used as filling in custom food
	var/list/tastes  // for example list("crisps" = 2, "salt" = 1)

/datum/component/edible/Initialize(initial_reagents, new_family_name)
	if(!isatom(parent))
		return COMPONENT_INCOMPATIBLE	
		
	RegisterSignal(parent, COMSIG_PARENT_EXAMINE, .proc/examine)
	RegisterSignal(parent, COMSIG_ATOM_KNIFE_ACT, .proc/cut)
	
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
