////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//	Polychromic Clothes:																							  //
//																													  //
//		Polychromic clothes simply consist of 4 sprites: A base, unrecoloured sprite, and up to 3 greyscaled sprites. //
//	In order to add more polychromic clothes, simply create a base sprite, and up to 3 recolourable overlays for it,  //
//	and then name them as follows: [name], [name]-primary, [name]-secondary, [name]-tertiary. The sprites should	  //
//	ideally be in 'haven/icons/polyclothes/item/uniform.dmi' and 'haven/icons/polyclothes/mob/uniform.dmi' for the	  //
//	worn sprites. After that, copy paste the code from any of the example clothes beneath the giant mass of procs and //
//	change the names around. [name] should go in BOTH icon_state and item_color. You can preset colors and disable	  //
//	any overlays using the self-explainatory vars.																					  //
//																													  //
//																								-Tori				  //
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

/obj/item/clothing/under/polychromic	//This is the parent object. DO NOT copy paste this and its vars if you want to make something new.
	name = "polychromic suit"
	desc = "For when you want to show off your horrible colour coordination skills."
	icon = 'haven/icons/polyclothes/item/uniform.dmi'
	alternate_worn_icon = 'haven/icons/polyclothes/mob/uniform.dmi'	//To make human/update_icon.dm read worn sprites from here.
	icon_state = "polysuit"
	item_color = "polysuit"		//The item color is used to select its mob icon
	item_state = "sl_suit"	//Inhand sprites. Would be an arse to make one for all the clothes. Should probably be standardized to rainbow.
	can_adjust = FALSE	//to prevent you from "wearing it casually"

	var/hasprimary = TRUE	//These vars allow you to choose which overlays a clothing has
	var/hassecondary = TRUE
	var/hastertiary = TRUE

	var/primary_color = "#FFFFFF" //RGB in hexcode
	var/secondary_color = "#FFFFFF"
	var/tertiary_color = "#808080"

/obj/item/clothing/under/polychromic/update_icon()
	..()
	cut_overlays()	//prevents the overlays from infinitely stacking
	if(hasprimary)	//Checks if the overlay is enabled
		var/mutable_appearance/primary_overlay = mutable_appearance('haven/icons/polyclothes/item/uniform.dmi', "[item_color]-primary")	//Automagically picks overlays
		primary_overlay.color = primary_color	//Colors the greyscaled overlay
		add_overlay(primary_overlay)	//Applies the coloured overlay onto the item sprite. but NOT the mob sprite.
	if(hassecondary)
		var/mutable_appearance/secondary_overlay = mutable_appearance('haven/icons/polyclothes/item/uniform.dmi', "[item_color]-secondary")
		secondary_overlay.color = secondary_color
		add_overlay(secondary_overlay)
	if(hastertiary)
		var/mutable_appearance/tertiary_overlay = mutable_appearance('haven/icons/polyclothes/item/uniform.dmi', "[item_color]-tertiary")
		tertiary_overlay.color = tertiary_color
		add_overlay(tertiary_overlay)

/obj/item/clothing/under/polychromic/AltClick(mob/living/user)
	if(!in_range(src, user))	//Basic checks to prevent abuse
		return
	if(user.incapacitated() || !istype(user))
		to_chat(user, "<span class='warning'>You can't do that right now!</span>")
		return

	var/choice = input(user,"polychromic thread options", "Clothing Recolor") as null|anything in list("[hasprimary ? "Primary Color" : ""]", "[hassecondary ? "Secondary Color" : ""]", "[hastertiary ? "Tertiary Color" : ""]")	//generates a list depending on the enabled overlays
	switch(choice)	//Lets the list's options actually lead to something
		if("Primary Color")
			var/primary_color_input = input(usr,"Choose Primary Color") as color|null	//color input menu, the "|null" adds a cancel button to it.
			if(primary_color_input)	//Checks if the color selected is NULL, rejects it if it is NULL.
				primary_color = sanitize_hexcolor(primary_color_input, desired_format=6, include_crunch=1)	//formats the selected color properly
			update_icon()	//updates the item icon
			user.update_inv_w_uniform()	//updates the worn icon
		if("Secondary Color")
			var/secondary_color_input = input(usr,"Choose Secondary Color") as color|null
			if(secondary_color_input)
				secondary_color = sanitize_hexcolor(secondary_color_input, desired_format=6, include_crunch=1)
			update_icon()
			user.update_inv_w_uniform()
		if("Tertiary Color")
			var/tertiary_color_input = input(usr,"Choose Tertiary Color") as color|null
			if(tertiary_color_input)
				tertiary_color = sanitize_hexcolor(tertiary_color_input, desired_format=6, include_crunch=1)
			update_icon()
			user.update_inv_w_uniform()

/obj/item/clothing/under/polychromic/worn_overlays(isinhands, icon_file)	//this is where the main magic happens
	. = ..()
	if(!isinhands)	//prevents the worn sprites from showing up if you're just holding them
		if(hasprimary)	//checks if overlays are enabled
			var/mutable_appearance/primary_worn = mutable_appearance('haven/icons/polyclothes/mob/uniform.dmi', "[item_color]-primary")	//automagical sprite selection
			primary_worn.color = primary_color	//colors the overlay
			. += primary_worn	//adds the overlay onto the buffer list to draw on the mob sprite.
		if(hassecondary)
			var/mutable_appearance/secondary_worn = mutable_appearance('haven/icons/polyclothes/mob/uniform.dmi', "[item_color]-secondary")
			secondary_worn.color = secondary_color
			. += secondary_worn
		if(hastertiary)
			var/mutable_appearance/tertiary_worn = mutable_appearance('haven/icons/polyclothes/mob/uniform.dmi', "[item_color]-tertiary")
			tertiary_worn.color = tertiary_color
			. += tertiary_worn

/obj/item/clothing/under/polychromic/examine(mob/user)
	..()
	to_chat(user, "<span class='notice'>Alt-click to recolor it.</span>")	// so people don't "OOC how do you use polychromic clothes????"

/obj/item/clothing/under/polychromic/Initialize()
	..()
	update_icon()	//Applies the overlays and default colors onto the clothes on spawn.

/obj/item/clothing/under/polychromic/shirt
	name = "polychromic button-up shirt"
	desc = "A fancy button-up shirt made with polychromic threads."
	icon_state = "polysuit"
	item_color = "polysuit"
	item_state = "sl_suit"
	hasprimary = TRUE
	hassecondary = TRUE
	hastertiary = TRUE
	primary_color = "#FFFFFF" //RGB in hexcode
	secondary_color = "#353535"
	tertiary_color = "#353535"

/obj/item/clothing/under/polychromic/kilt
	name = "polychromic kilt"
	desc = "It's not a skirt!"
	icon_state = "polykilt"
	item_color = "polykilt"
	item_state = "kilt"
	hasprimary = TRUE
	hassecondary = TRUE
	hastertiary = TRUE
	primary_color = "#FFFFFF" //RGB in hexcode
	secondary_color = "#F08080"
	tertiary_color = "#808080"

/obj/item/clothing/under/polychromic/skirt
	name = "polychromic skirt"
	desc = "A fancy skirt made with polychromic threads."
	icon_state = "polyskirt"
	item_color = "polyskirt"
	item_state = "rainbow"
	hasprimary = TRUE
	hassecondary = TRUE
	hastertiary = TRUE
	primary_color = "#FFFFFF" //RGB in hexcode
	secondary_color = "#F08080"
	tertiary_color = "#808080"

/obj/item/clothing/under/polychromic/shorts
	name = "polychromic shorts"
	desc = "For ease of movement and style."
	icon_state = "polyshorts"
	item_color = "polyshorts"
	item_state = "rainbow"
	hasprimary = TRUE
	hassecondary = TRUE
	hastertiary = TRUE
	primary_color = "#353535" //RGB in hexcode
	secondary_color = "#808080"
	tertiary_color = "#808080"

/obj/item/clothing/under/polychromic/jumpsuit
	name = "polychromic tri-tone jumpsuit"
	desc = "A fancy jumpsuit made with polychromic threads."
	icon_state = "polyjump"
	item_color = "polyjump"
	item_state = "rainbow"
	hasprimary = TRUE
	hassecondary = TRUE
	hastertiary = TRUE
	primary_color = "#FFFFFF" //RGB in hexcode
	secondary_color = "#808080"
	tertiary_color = "#FF3535"