//NEVER USE THIS IT SUX -PETETHEGOAT
//IT SUCKS A BIT LESS -GIACOM

/obj/item/paint
	gender= PLURAL
	name = "paint"
	desc = "Used to recolor floors and walls. Can be removed by the janitor."
	icon = 'icons/obj/art/paint.dmi'
	icon_state = "paint_neutral"
	inhand_icon_state = "paintcan"
	w_class = WEIGHT_CLASS_NORMAL
	resistance_flags = FLAMMABLE
	max_integrity = 100
	/// With what color will we paint with
	var/paint_color = COLOR_WHITE
	/// How many uses are left
	var/paintleft = 200

/obj/item/paint/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/falling_hazard, damage = 20, wound_bonus = 5, hardhat_safety = TRUE, crushes = FALSE) // You ever watched home alone?

/obj/item/paint/red
	name = "red paint"
	paint_color = COLOR_RED
	icon_state = "paint_red"

/obj/item/paint/green
	name = "green paint"
	paint_color = COLOR_VIBRANT_LIME
	icon_state = "paint_green"

/obj/item/paint/blue
	name = "blue paint"
	paint_color = COLOR_BLUE
	icon_state = "paint_blue"

/obj/item/paint/yellow
	name = "yellow paint"
	paint_color = COLOR_YELLOW
	icon_state = "paint_yellow"

/obj/item/paint/violet
	name = "violet paint"
	paint_color = COLOR_MAGENTA
	icon_state = "paint_violet"

/obj/item/paint/black
	name = "black paint"
	paint_color = COLOR_ALMOST_BLACK
	icon_state = "paint_black"

/obj/item/paint/white
	name = "white paint"
	paint_color = COLOR_WHITE
	icon_state = "paint_white"

/obj/item/paint/anycolor
	gender = PLURAL
	name = "adaptive paint"
	icon_state = "paint_neutral"

/obj/item/paint/anycolor/cyborg
	paintleft = INFINITY

/obj/item/paint/anycolor/attack_self(mob/user)
	if(paintleft <= 0)
		balloon_alert(user, "no paint left!")
		return	// Don't do any of the following because there's no paint left to be able to change the color of
	var/list/possible_colors = list(
		"black" = image(icon = src.icon, icon_state = "paint_black"),
		"blue" = image(icon = src.icon, icon_state = "paint_blue"),
		"green" = image(icon = src.icon, icon_state = "paint_green"),
		"red" = image(icon = src.icon, icon_state = "paint_red"),
		"violet" = image(icon = src.icon, icon_state = "paint_violet"),
		"white" = image(icon = src.icon, icon_state = "paint_white"),
		"yellow" = image(icon = src.icon, icon_state = "paint_yellow")
		)
	var/picked_color = show_radial_menu(user, src, possible_colors, custom_check = CALLBACK(src, PROC_REF(check_menu), user), radius = 38, require_near = TRUE)
	switch(picked_color)
		if("black")
			paint_color = COLOR_ALMOST_BLACK
		if("blue")
			paint_color = COLOR_BLUE
		if("green")
			paint_color = COLOR_VIBRANT_LIME
		if("red")
			paint_color = COLOR_RED
		if("violet")
			paint_color = COLOR_MAGENTA
		if("white")
			paint_color = COLOR_WHITE
		if("yellow")
			paint_color = COLOR_YELLOW
		else
			return
	icon_state = "paint_[picked_color]"
	add_fingerprint(user)

/**
 * Checks if we are allowed to interact with a radial menu
 *
 * Arguments:
 * * user The mob interacting with the menu
 */
/obj/item/paint/anycolor/proc/check_menu(mob/user)
	if(!istype(user))
		return FALSE
	if(!user.is_holding(src))
		return FALSE
	if(user.incapacitated)
		return FALSE
	return TRUE

/obj/item/paint/interact_with_atom(atom/interacting_with, mob/living/user, list/modifiers)
	if(!isturf(interacting_with) || isspaceturf(interacting_with))
		return NONE
	if(paintleft <= 0)
		return NONE
	paintleft--
	interacting_with.add_atom_colour(paint_color, WASHABLE_COLOUR_PRIORITY)
	if(paintleft <= 0)
		icon_state = "paint_empty"
	return ITEM_INTERACT_SUCCESS

/obj/item/paint/paint_remover
	gender = PLURAL
	name = "paint remover"
	desc = "Used to remove color from anything."
	icon_state = "paint_neutral"

/obj/item/paint/paint_remover/interact_with_atom(atom/interacting_with, mob/living/user, list/modifiers)
	if(!isturf(interacting_with) || !isobj(interacting_with))
		return NONE
	if(interacting_with.color != initial(interacting_with.color))
		interacting_with.remove_atom_colour(WASHABLE_COLOUR_PRIORITY)
		return ITEM_INTERACT_SUCCESS
	return NONE
