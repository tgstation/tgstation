/**
 * # Custom Atom Component
 *
 * When added to an atom, item ingredients can be put into that.
 * The sprite is updated and reagents are transfered.
 *
 * If the component is added to something that is processed, creating new objects (being cut, for example),
 * the replacement type needs to also have the component. The ingredients will be copied over. Reagents are not
 * copied over since other components already take care of that.
 */
/datum/component/customizable_reagent_holder
	can_transfer = TRUE
	///List of item ingredients.
	var/list/obj/item/ingredients
	///Type path of replacement atom.
	var/replacement
	///Type of fill, can be [CUSTOM_INGREDIENT_ICON_NOCHANGE] for example.
	var/fill_type
	///Number of max ingredients.
	var/max_ingredients
	///Overlay used for certain fill types, always shows up on top.
	var/mutable_appearance/top_overlay
	///Type of ingredients to accept, [CUSTOM_INGREDIENT_TYPE_EDIBLE] for example.
	var/ingredient_type


/datum/component/customizable_reagent_holder/Initialize(
		atom/replacement,
		fill_type,
		ingredient_type = CUSTOM_INGREDIENT_TYPE_EDIBLE,
		max_ingredients = INFINITY,
		list/obj/item/initial_ingredients = null)
	if(!isatom(parent))
		return COMPONENT_INCOMPATIBLE
	var/atom/atom_parent = parent
	if (!atom_parent.reagents)
		return COMPONENT_INCOMPATIBLE

	src.replacement = replacement
	src.fill_type = fill_type
	src.max_ingredients = max_ingredients
	src.ingredient_type = ingredient_type

	if (initial_ingredients)
		for (var/_ingredient in initial_ingredients)
			var/obj/item/ingredient = _ingredient
			add_ingredient(ingredient)
			handle_fill(ingredient)


/datum/component/customizable_reagent_holder/Destroy(force, silent)
	QDEL_NULL(top_overlay)
	return ..()


/datum/component/customizable_reagent_holder/RegisterWithParent()
	. = ..()
	RegisterSignal(parent, COMSIG_PARENT_ATTACKBY, .proc/customizable_attack)
	RegisterSignal(parent, COMSIG_PARENT_EXAMINE, .proc/on_examine)
	RegisterSignal(parent, COMSIG_ATOM_PROCESSED, .proc/on_processed)
	ADD_TRAIT(parent, TRAIT_CUSTOMIZABLE_REAGENT_HOLDER, src)


/datum/component/customizable_reagent_holder/UnregisterFromParent()
	. = ..()
	UnregisterSignal(parent, list(
		COMSIG_PARENT_ATTACKBY,
		COMSIG_PARENT_EXAMINE,
		COMSIG_ATOM_PROCESSED,
	))
	REMOVE_TRAIT(parent, TRAIT_CUSTOMIZABLE_REAGENT_HOLDER, src)


/datum/component/customizable_reagent_holder/PostTransfer()
	if(!isatom(parent))
		return COMPONENT_INCOMPATIBLE
	var/atom/atom_parent = parent
	if (!atom_parent.reagents)
		return COMPONENT_INCOMPATIBLE

///Handles when the customizable food is examined.
/datum/component/customizable_reagent_holder/proc/on_examine(atom/A, mob/user, list/examine_list)
	SIGNAL_HANDLER

	var/atom/atom_parent = parent
	var/ingredients_listed = ""
	if (LAZYLEN(ingredients))
		for (var/i in 1 to ingredients.len)
			var/obj/item/ingredient = ingredients[i]
			var/ending = ", "
			switch(length(ingredients))
				if (2)
					if (i == 1)
						ending = " and "
				if (3 to INFINITY)
					if (i == ingredients.len - 1)
						ending = ", and "
			ingredients_listed += "\a [ingredient.name][ending]"
	examine_list += "It contains [LAZYLEN(ingredients) ? "[ingredients_listed]" : " no ingredients, "]making a [custom_adjective()]-sized [initial(atom_parent.name)]."


///Handles when the customizable food is attacked by something.
/datum/component/customizable_reagent_holder/proc/customizable_attack(datum/source, obj/ingredient, mob/attacker, silent = FALSE, force = FALSE)
	SIGNAL_HANDLER

	var/valid_ingredient = TRUE

	switch (ingredient_type)
		if (CUSTOM_INGREDIENT_TYPE_EDIBLE)
			valid_ingredient = IS_EDIBLE(ingredient)

	// only accept valid ingredients
	if (!valid_ingredient || HAS_TRAIT(ingredient, TRAIT_CUSTOMIZABLE_REAGENT_HOLDER))
		to_chat(attacker, "<span class='warning'>[ingredient] doesn't belong on [parent]!</span>")
		return

	if (LAZYLEN(ingredients) >= max_ingredients)
		to_chat(attacker, "<span class='warning'>[parent] is too full for any more ingredients!</span>")
		return COMPONENT_NO_AFTERATTACK

	var/atom/atom_parent = parent
	if(!attacker.transferItemToLoc(ingredient, atom_parent))
		return
	if (replacement)
		var/atom/replacement_parent = new replacement(atom_parent.loc)
		ingredient.forceMove(replacement_parent)
		replacement = null
		RemoveComponent()
		replacement_parent.TakeComponent(src)
		qdel(atom_parent)
	handle_reagents(ingredient)
	add_ingredient(ingredient)
	handle_fill(ingredient)


///Handles the icon update for a new ingredient.
/datum/component/customizable_reagent_holder/proc/handle_fill(obj/item/ingredient)
	if (fill_type == CUSTOM_INGREDIENT_ICON_NOCHANGE)
		//don't bother doing the icon procs
		return
	var/atom/atom_parent = parent
	var/mutable_appearance/filling = mutable_appearance(atom_parent.icon, "[initial(atom_parent.icon_state)]_filling")
	// get average color
	var/icon/icon = new(ingredient.icon, ingredient.icon_state)
	icon.Scale(1, 1)
	var/fillcol = copytext(icon.GetPixel(1, 1), 1, 8) // remove opacity
	filling.color = fillcol

	switch(fill_type)
		if(CUSTOM_INGREDIENT_ICON_SCATTER)
			filling.pixel_x = rand(-1,1)
			filling.pixel_y = rand(-1,1)
		if(CUSTOM_INGREDIENT_ICON_STACK)
			filling.pixel_x = rand(-1,1)
			filling.pixel_y = 2 * LAZYLEN(ingredients) - 1
		if(CUSTOM_INGREDIENT_ICON_STACKPLUSTOP)
			filling.pixel_x = rand(-1,1)
			filling.pixel_y = 2 * LAZYLEN(ingredients) - 1
			if (top_overlay) // delete old top if exists
				atom_parent.cut_overlay(top_overlay)
			top_overlay = mutable_appearance(atom_parent.icon, "[atom_parent.icon_state]_top")
			top_overlay.pixel_y = 2 * LAZYLEN(ingredients) + 3
			atom_parent.add_overlay(filling)
			atom_parent.add_overlay(top_overlay)
			return
		if(CUSTOM_INGREDIENT_ICON_FILL)
			if (top_overlay)
				filling.color = mix_color(filling.color)
				atom_parent.cut_overlay(top_overlay)
			top_overlay = filling
		if(CUSTOM_INGREDIENT_ICON_LINE)
			filling.pixel_x = filling.pixel_y = rand(-8,3)
	atom_parent.add_overlay(filling)


///Takes the reagents from an ingredient.
/datum/component/customizable_reagent_holder/proc/handle_reagents(obj/item/ingredient)
	var/atom/atom_parent = parent
	if (atom_parent.reagents && ingredient.reagents)
		ingredient.reagents.trans_to(atom_parent, ingredient.reagents.total_volume)
	return


///Adds a new ingredient and updates the parent's name.
/datum/component/customizable_reagent_holder/proc/add_ingredient(obj/item/ingredient)
	var/atom/atom_parent = parent
	LAZYADD(ingredients, ingredient)
	atom_parent.name = "[custom_adjective()] [custom_type()] [initial(atom_parent.name)]"
	SEND_SIGNAL(atom_parent, COMSIG_ATOM_CUSTOMIZED, ingredient)
	SEND_SIGNAL(ingredient, COMSIG_ITEM_USED_AS_INGREDIENT, atom_parent)


///Gives an adjective to describe the size of the custom food.
/datum/component/customizable_reagent_holder/proc/custom_adjective()
	switch(LAZYLEN(ingredients))
		if (0 to 2)
			return "small"
		if (3 to 5)
			return "standard"
		if (6 to 8)
			return "big"
		if (8 to 11)
			return "ridiculous"
		if (12 to INFINITY)
			return "monstrous"


///Gives the type of custom food (based on what the first ingredient was).
/datum/component/customizable_reagent_holder/proc/custom_type()
	var/custom_type = "empty"
	if (LAZYLEN(ingredients))
		var/obj/item/first_ingredient = ingredients[1]
		if (istype(first_ingredient, /obj/item/food/meat))
			var/obj/item/food/meat/meat = first_ingredient
			if (meat.subjectname)
				custom_type = meat.subjectname
			else if (meat.subjectjob)
				custom_type = meat.subjectjob
		if (custom_type == "empty" && first_ingredient.name)
			custom_type = first_ingredient.name
	return custom_type


///Returns the color of the input mixed with the top_overlay's color.
/datum/component/customizable_reagent_holder/proc/mix_color(color)
	if(LAZYLEN(ingredients) == 1 || !top_overlay)
		return color
	else
		var/list/rgbcolor = list(0,0,0,0)
		var/customcolor = GetColors(color)
		var/ingcolor =  GetColors(top_overlay.color)
		rgbcolor[1] = (customcolor[1]+ingcolor[1])/2
		rgbcolor[2] = (customcolor[2]+ingcolor[2])/2
		rgbcolor[3] = (customcolor[3]+ingcolor[3])/2
		rgbcolor[4] = (customcolor[4]+ingcolor[4])/2
		return rgb(rgbcolor[1], rgbcolor[2], rgbcolor[3], rgbcolor[4])


///Copies over the parent's ingredients to the processing results (such as slices when the parent is cut).
/datum/component/customizable_reagent_holder/proc/on_processed(datum/source, mob/living/user, obj/item/ingredient, list/atom/results)
	SIGNAL_HANDLER

	// Reagents are not transferred since that should be handled elsewhere.
	for (var/r in results)
		var/atom/result = r
		result.AddComponent(/datum/component/customizable_reagent_holder, null, fill_type, ingredient_type = ingredient_type, max_ingredients = max_ingredients, initial_ingredients = ingredients)
