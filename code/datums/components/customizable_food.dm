#define INGREDIENTS_FILL 1
#define INGREDIENTS_SCATTER 2
#define INGREDIENTS_STACK 3
#define INGREDIENTS_STACKPLUSTOP 4
#define INGREDIENTS_LINE 5

///Customizable food component, lets you insert items with the edible component into it to make big food
/datum/component/customizable_food
	//var/ingredients_placement	// sprite placement of toppings on the main sprite of the parent food item
	/// the max allowed ingredients you can place onto this cusotmizable food
	var/max_ingredients
	/// List of ingredients or toppings the customizable food currently has on it
	var/list/ingredients
	///the prefix name that gets placed before the original food name, i.e. "custom pizza", "custom burger"
	var/customname
	///This is the edible component of the parent. Not my favorite thing but customizable food is legally co-dependent on it so I think Ninjanomnom will spare me
	var/datum/component/edible/ourfood
	///Color of the customizable food. Done by mixing, used for INGREDIENTS_FILL placement type and slices.
	var/ourcolor = "#000000"

///Setup the variables and ensure the original reagents are transferred.
/datum/component/customizable_food/Initialize(datum/component/edible/ourfood, ingredients_placement = INGREDIENTS_FILL,	max_ingredients = 6, ingredients = list(), customname = "custom", ourcolor = "#000000", obj/item/original_item, obj/item/catalyst_item, mob/creator)
	if(!isitem(parent))
		return COMPONENT_INCOMPATIBLE

	RegisterSignal(parent, COMSIG_USE_FOOD_ON, .proc/AddFoodTo)
	RegisterSignal(parent, COMSIG_PARENT_EXAMINE, .proc/examine)

	src.max_ingredients = max_ingredients
	src.ingredients = ingredients
	src.ingredients_placement = ingredients_placement
	src.customname = customname
	src.ourfood = ourfood
	src.ourcolor = ourcolor

	original_item.reagents.trans_to(parent,original_item.reagents.total_volume, transferred_by = creator)

	for(var/obj/O in original_item.contents)
		parent.contents += O

	if(catalyst_item && user)
		parent.attackby(catalyst_item, user)

///Destroy all of the ingredients inside.
/datum/component/customizable_food/Destroy()
	for(var/I in ingredients)
		qdel(I)

///Add all of the ingredient names together and show a length.
/datum/component/customizable_food/examine(datum/source, mob/user)
	. = ..()
	var/ingredients_listed = ""
	for(var/obj/item/ING in ingredients)
		ingredients_listed += "[ING.name], "
	var/size = "standard"
	if(ingredients.len<2)
		size = "small"
	if(ingredients.len>5)
		size = "big"
	if(ingredients.len>8)
		size = "monster"
	. += "It contains [ingredients.len?"[ingredients_listed]":"no ingredient, "]making a [size]-sized [initial(name)]."


///This comes from the edible component, source is the edible component. This proc puts the food into the customizable food
/datum/component/customizable_food/proc/AddFoodTo(datum/source, mob/user)

	var/datum/component/edible/usedfood = source //We know this because this is only called from food.
	var/obj/item/I = food.parent //We know this because only items send this signal.

	if(!food.customizable_food_ingredient) //Can not be used in customizable food, go back.
		return NONE

	if(I.w_class > WEIGHT_CLASS_SMALL)
		to_chat(user, "<span class='warning'>The ingredient is too big for [src]!</span>")
		return COMPONENT_NO_ATTACK

	if((ingredients.len >= ingMax) || (parent.reagents.total_volume >= volume))
		to_chat(user, "<span class='warning'>You can't add more ingredients to [src]!</span>")
		return COMPONENT_NO_ATTACK

	if(!user.transferItemToLoc(I, src))
		return
	if(usedfood.trash)
		usedfood.generate_trash(get_turf(user))
	ingredients += I
	mix_filling_color(I) todo
	I.reagents.trans_to(parent,min(I.reagents.total_volume, 15), transfered_by = user) //limit of 15, we don't want our custom food to be completely filled by just one ingredient with large reagent volume.
	ourfood |= usedfood.foodtypes
	set_filling(usedfood.filling_color)
	to_chat(user, "<span class='notice'>You add the [I.name] to the [parent.name].</span>")
	//update_name(S) todo

///Mixes together the color of the new ingredient. This is the combined color of all ingredients
/datum/component/customizable_food/proc/mix_filling_color(color)
	if(ingredients.len == 1)
		ourfood.filling_color = color
	else
		var/list/rgbcolor = list(0,0,0,0)
		var/customcolor = GetColors(filling_color)
		var/ingcolor =  GetColors(color)
		rgbcolor[1] = (customcolor[1]+ingcolor[1])/2
		rgbcolor[2] = (customcolor[2]+ingcolor[2])/2
		rgbcolor[3] = (customcolor[3]+ingcolor[3])/2
		rgbcolor[4] = (customcolor[4]+ingcolor[4])/2
		ourfood.filling_color = rgb(rgbcolor[1], rgbcolor[2], rgbcolor[3], rgbcolor[4])

///This either gives the custom food a filling with the color of the used food, or makes it use the color made in mix filling colors.
/datum/component/customizable_food/proc/set_filling(color)
	var/mutable_appearance/filling = mutable_appearance(icon, "[initial(parent.icon_state)]_filling")
	if(color == "#FFFFFF")
		filling.color = pick("#FF0000","#0000FF","#008000","#FFFF00")
	else
		filling.color = color

	switch(ingredients_placement)
		if(INGREDIENTS_SCATTER)
			filling.pixel_x = rand(-1,1)
			filling.pixel_y = rand(-1,1)
		if(INGREDIENTS_STACK)
			filling.pixel_x = rand(-1,1)
			filling.pixel_y = 2 * ingredients.len - 1
		if(INGREDIENTS_STACKPLUSTOP)
			filling.pixel_x = rand(-1,1)
			filling.pixel_y = 2 * ingredients.len - 1
			if(overlays && overlays.len >= ingredients.len) //remove the old top if it exists
				overlays -= overlays[ingredients.len]
			var/mutable_appearance/TOP = mutable_appearance(icon, "[parent.icon_state]_top")
			TOP.pixel_y = 2 * ingredients.len + 3
			add_overlay(filling)
			add_overlay(TOP)
			return
		if(INGREDIENTS_FILL)
			cut_overlays()
			filling.color = filling_color
		if(INGREDIENTS_LINE)
			filling.pixel_x = filling.pixel_y = rand(-8,3)
	add_overlay(filling)

///Updates the name of the parent item by pre-fixing the food's name, (or just making it say custom in the case of multiple ingredients)
/datum/component/customizable_food/proc/update_name(obj/item/food)
	for(var/obj/item/I in ingredients)
		if(!istype(food, I.type))
			customname = "custom"
			break
	if(ingredients.len == 1) //first ingredient
		customname = S.name
	name = "[customname] [initial(parent.name)]"

#undef INGREDIENTS_FILL
#undef INGREDIENTS_SCATTER
#undef INGREDIENTS_STACK
#undef INGREDIENTS_STACKPLUSTOP
#undef INGREDIENTS_LINE
