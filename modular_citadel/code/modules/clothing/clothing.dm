/*																																//
//											GLOBALIZED POLYCHROME FOR ALL CLOTHING												//
//																																//
//	NOTICE: POLYCHROME STUFF MUST USE ALTERNATE_WORN_ICON AND PLACE THEIR OVERLAYS IN BOTH THE ICON AND ALTERNATE_WORN_ICON		//
//																																//
*/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

//	COPYPASTE THE FOLLOWING PROC TO WHATEVER CATERGORY OF CLOTHING YOU WANT TO POLYCHROME

// THIS IS REQUIRED DUE TO EACH CLOTHING CATEGORY HAVING A SNOWFLAKE WORN_OVERLAYS() THING

// Don't forget to append the appropriate typepath! Also, refer to polychromic_clothes.dm for example implementations

/*
/obj/item/clothing/worn_overlays(isinhands, icon_file)	//this is where the main magic happens. Also mandates that ALL polychromic stuff MUST USE alternate_worn_icon
	. = ..()
	if(hasprimary | hassecondary | hastertiary)
		if(!isinhands)	//prevents the worn sprites from showing up if you're just holding them
			if(hasprimary)	//checks if overlays are enabled
				var/mutable_appearance/primary_worn = mutable_appearance(alternate_worn_icon, "[item_color]-primary")	//automagical sprite selection
				primary_worn.color = primary_color	//colors the overlay
				. += primary_worn	//adds the overlay onto the buffer list to draw on the mob sprite.
			if(hassecondary)
				var/mutable_appearance/secondary_worn = mutable_appearance(alternate_worn_icon, "[item_color]-secondary")
				secondary_worn.color = secondary_color
				. += secondary_worn
			if(hastertiary)
				var/mutable_appearance/tertiary_worn = mutable_appearance(alternate_worn_icon, "[item_color]-tertiary")
				tertiary_worn.color = tertiary_color
				. += tertiary_worn
*/

/obj/item/clothing/
	var/hasprimary = FALSE	//These vars allow you to choose which overlays a clothing has
	var/hassecondary = FALSE
	var/hastertiary = FALSE
	var/primary_color = "#FFFFFF" //RGB in hexcode
	var/secondary_color = "#FFFFFF"
	var/tertiary_color = "#808080"

/obj/item/clothing/update_icon()	// picks the colored overlays from the ICON file
	..()
	if(hasprimary)	//Checks if the overlay is enabled
		var/mutable_appearance/primary_overlay = mutable_appearance(icon, "[item_color]-primary")	//Automagically picks overlays
		primary_overlay.color = primary_color	//Colors the greyscaled overlay
		add_overlay(primary_overlay)	//Applies the coloured overlay onto the item sprite. but NOT the mob sprite.
	if(hassecondary)
		var/mutable_appearance/secondary_overlay = mutable_appearance(icon, "[item_color]-secondary")
		secondary_overlay.color = secondary_color
		add_overlay(secondary_overlay)
	if(hastertiary)
		var/mutable_appearance/tertiary_overlay = mutable_appearance(icon, "[item_color]-tertiary")
		tertiary_overlay.color = tertiary_color
		add_overlay(tertiary_overlay)

/obj/item/clothing/AltClick(mob/living/user)
	..()
	if(hasprimary | hassecondary | hastertiary)
		var/choice = input(user,"polychromic thread options", "Clothing Recolor") as null|anything in list("[hasprimary ? "Primary Color" : ""]", "[hassecondary ? "Secondary Color" : ""]", "[hastertiary ? "Tertiary Color" : ""]")	//generates a list depending on the enabled overlays
		switch(choice)	//Lets the list's options actually lead to something
			if("Primary Color")
				var/primary_color_input = input(usr,"","Choose Primary Color",primary_color) as color|null	//color input menu, the "|null" adds a cancel button to it.
				if(primary_color_input)	//Checks if the color selected is NULL, rejects it if it is NULL.
					primary_color = sanitize_hexcolor(primary_color_input, desired_format=6, include_crunch=1)	//formats the selected color properly
				update_icon()	//updates the item icon
				user.regenerate_icons()	//updates the worn icon. Probably a bad idea, but it works.
			if("Secondary Color")
				var/secondary_color_input = input(usr,"","Choose Secondary Color",secondary_color) as color|null
				if(secondary_color_input)
					secondary_color = sanitize_hexcolor(secondary_color_input, desired_format=6, include_crunch=1)
				update_icon()
				user.regenerate_icons()
			if("Tertiary Color")
				var/tertiary_color_input = input(usr,"","Choose Tertiary Color",tertiary_color) as color|null
				if(tertiary_color_input)
					tertiary_color = sanitize_hexcolor(tertiary_color_input, desired_format=6, include_crunch=1)
				update_icon()
				user.regenerate_icons()

/obj/item/clothing/examine(mob/user)
	..()
	if(hasprimary | hassecondary | hastertiary)
		to_chat(user, "<span class='notice'>Alt-click to recolor it.</span>")	// so people don't "OOC how do you use polychromic clothes????"

/obj/item/clothing/Initialize()
	..()
	if(hasprimary | hassecondary | hastertiary)
		update_icon()	//Applies the overlays and default colors onto the clothes on spawn.