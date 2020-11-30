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
/datum/component/customizableatom
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


/datum/component/customizableatom/Initialize(
		atom/replacement,
		fill_type,
		ingredient_type = CUSTOM_INGREDIENT_TYPE_EDIBLE,
		max_ingredients = INFINITY,
		list/obj/item/initial_ingredients = null)
	if(!isatom(parent))
		return COMPONENT_INCOMPATIBLE

	src.replacement = replacement
	src.fill_type = fill_type
	src.max_ingredients = max_ingredients
	src.ingredient_type = ingredient_type

	if (initial_ingredients)
		for (var/ingr in initial_ingredients)
			var/obj/item/I = ingr
			add_ingredient(I)
			handle_fill(I)


/datum/component/customizableatom/Destroy(force, silent)
	QDEL_NULL(top_overlay)
	return ..()


/datum/component/customizableatom/RegisterWithParent()
	. = ..()
	RegisterSignal(parent, COMSIG_PARENT_ATTACKBY, .proc/customizable_attack)
	RegisterSignal(parent, COMSIG_PARENT_EXAMINE, .proc/on_examine)
	RegisterSignal(parent, COMSIG_ATOM_PROCESSED, .proc/on_processed)


/datum/component/customizableatom/UnregisterFromParent()
	. = ..()
	UnregisterSignal(parent, list(
			COMSIG_PARENT_ATTACKBY,
			COMSIG_PARENT_EXAMINE,
			COMSIG_ATOM_PROCESSED
		)
	)


/datum/component/customizableatom/PostTransfer()
	if(!isatom(parent))
		return COMPONENT_INCOMPATIBLE


///Handles when the customizable food is examined.
/datum/component/customizableatom/proc/on_examine(atom/A, mob/user, list/examine_list)
	SIGNAL_HANDLER

	var/atom/P = parent
	var/ingredients_listed = ""
	if (LAZYLEN(ingredients))
		for (var/i in 1 to ingredients.len)
			var/obj/item/I = ingredients[i]
			var/ending = ", "
			switch(length(ingredients))
				if (2)
					if (i == 1)
						ending = " and "
				if (3 to INFINITY)
					if (i == ingredients.len - 1)
						ending = ", and "
			ingredients_listed += "\a [I.name][ending]"
	examine_list += "It contains [LAZYLEN(ingredients) ? "[ingredients_listed]" : " no ingredients, "]making a [custom_adjective()]-sized [initial(P.name)]."


///Handles when the customizable food is attacked by something.
/datum/component/customizableatom/proc/customizable_attack(datum/source, obj/item/I, mob/M, silent = FALSE, force = FALSE)
	SIGNAL_HANDLER

	var/valid_ingredient = TRUE

	switch (ingredient_type)
		if (CUSTOM_INGREDIENT_TYPE_EDIBLE)
			valid_ingredient = IS_EDIBLE(I)

	// only accept valid ingredients
	if (!valid_ingredient)
		to_chat(M, "<span class='warning'>[I] doesn't belong on [parent]!</span>")
		return

	if (LAZYLEN(ingredients) >= max_ingredients)
		to_chat(M, "<span class='warning'>[parent] is too full for any more ingredients!</span>")
		return

	var/atom/P = parent
	if(!M.transferItemToLoc(I, P))
		return
	if (replacement)
		var/atom/R = new replacement(P.loc)
		I.forceMove(R)
		replacement = null
		RemoveComponent()
		R.TakeComponent(src)
		qdel(P)
	handle_reagents(I)
	add_ingredient(I)
	handle_fill(I)


///Handles the icon update for a new ingredient.
/datum/component/customizableatom/proc/handle_fill(obj/item/I)
	if (fill_type == CUSTOM_INGREDIENT_ICON_NOCHANGE)
		//don't bother doing the icon procs
		return
	var/atom/P = parent
	var/mutable_appearance/filling = mutable_appearance(P.icon, "[initial(P.icon_state)]_filling")
	// get average color
	var/icon/ico = new(I.icon, I.icon_state)
	ico.Scale(1, 1)
	var/fillcol = copytext(ico.GetPixel(1, 1), 1, 8) // remove opacity
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
			filling.pixel_y = 2 *  LAZYLEN(ingredients) - 1
			if (top_overlay) // delete old top if exists
				P.cut_overlay(top_overlay)
			top_overlay = mutable_appearance(P.icon, "[P.icon_state]_top")
			top_overlay.pixel_y = 2 * LAZYLEN(ingredients) + 3
			P.add_overlay(filling)
			P.add_overlay(top_overlay)
			return
		if(CUSTOM_INGREDIENT_ICON_FILL)
			if (top_overlay)
				filling.color = mix_color(filling.color)
				P.cut_overlay(top_overlay)
			top_overlay = filling
		if(CUSTOM_INGREDIENT_ICON_LINE)
			filling.pixel_x = filling.pixel_y = rand(-8,3)
	P.add_overlay(filling)


///Takes the reagents from an ingredient.
/datum/component/customizableatom/proc/handle_reagents(obj/item/I)
	var/atom/P = parent
	if (P.reagents && I.reagents)
		I.reagents.trans_to(P, I.reagents.total_volume)
	return


///Adds a new ingredient and updates the parent's name.
/datum/component/customizableatom/proc/add_ingredient(obj/item/I)
	var/atom/P = parent
	LAZYADD(ingredients, I)
	P.name = "[custom_adjective()] [custom_type()] [initial(P.name)]"
	SEND_SIGNAL(P, COMSIG_ATOM_CUSTOMIZED, I)
	SEND_SIGNAL(I, COMSIG_ITEM_USED_AS_INGREDIENT, P)


///Gives an adjective to describe the size of the custom food.
/datum/component/customizableatom/proc/custom_adjective()
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
/datum/component/customizableatom/proc/custom_type()
	var/custom_type = "empty"
	if (LAZYLEN(ingredients))
		var/obj/item/I = ingredients[1]
		if (istype(I, /obj/item/food/meat))
			var/obj/item/food/meat/M = I
			if (M.subjectname)
				custom_type = M.subjectname
			else if (M.subjectjob)
				custom_type = M.subjectjob
		if (custom_type == "empty" && I.name)
			custom_type = I.name
	return custom_type


///Returns the color of the input mixed with the top_overlay's color.
/datum/component/customizableatom/proc/mix_color(color)
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
/datum/component/customizableatom/proc/on_processed(datum/source, mob/living/user, obj/item/I, list/atom/results)
	SIGNAL_HANDLER

	// Reagents are not transferred since that should be handled elsewhere.
	for (var/r in results)
		var/atom/result = r
		result.AddComponent(/datum/component/customizableatom, null, fill_type, ingredient_type = ingredient_type, max_ingredients = max_ingredients, initial_ingredients = ingredients)
