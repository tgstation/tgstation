/obj/item/clothing/under/polychromic
	name = "polychromic suit"
	desc = "For when you want to show off your horrible colour coordination skills."
	icon = 'haven/icons/polyclothes/item/uniform.dmi'
	alternate_worn_icon = 'haven/icons/polyclothes/mob/uniform.dmi'
	icon_state = "polysuit"
	item_color = "polysuit"
	item_state = "sl_suit"
	can_adjust = FALSE

	var/hasprimary = TRUE
	var/hassecondary = TRUE
	var/hastertiary = TRUE

	var/primary_color = "#FFFFFF" //RGB in hexcode
	var/secondary_color = "#FFFFFF"
	var/tertiary_color = "#808080"

/obj/item/clothing/under/polychromic/update_icon()
	..()
	cut_overlays()

	if(hasprimary)
		var/mutable_appearance/primary_overlay = mutable_appearance('haven/icons/polyclothes/item/uniform.dmi', "[item_color]-primary")
		primary_overlay.color = primary_color
		add_overlay(primary_overlay)

	if(hassecondary)
		var/mutable_appearance/secondary_overlay = mutable_appearance('haven/icons/polyclothes/item/uniform.dmi', "[item_color]-secondary")
		secondary_overlay.color = secondary_color
		add_overlay(secondary_overlay)

	if(hastertiary)
		var/mutable_appearance/tertiary_overlay = mutable_appearance('haven/icons/polyclothes/item/uniform.dmi', "[item_color]-tertiary")
		tertiary_overlay.color = tertiary_color
		add_overlay(tertiary_overlay)

/obj/item/clothing/under/polychromic/AltClick(mob/living/user)
	if(user.incapacitated() || !istype(user))
		to_chat(user, "<span class='warning'>You can't do that right now!</span>")
		return
	if(!in_range(src, user))
		return
	if(user.incapacitated() || !istype(user) || !in_range(src, user))
		return

	var/choice = input(user,"polychromic thread options", "Clothing Recolor") as null|anything in list("[hasprimary ? "Primary Color" : ""]", "[hassecondary ? "Secondary Color" : ""]", "[hastertiary ? "Tertiary Color" : ""]")
	switch(choice)

		if("Primary Color")
			var/primary_color_input = input(usr,"Choose Primary Color") as color|null
			if(primary_color_input)
				primary_color = sanitize_hexcolor(primary_color_input, desired_format=6, include_crunch=1)
			update_icon()
			user.update_inv_w_uniform()

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

/obj/item/clothing/under/polychromic/worn_overlays(isinhands, icon_file)
	. = ..()
	if(!isinhands)
		if(hasprimary)
			var/mutable_appearance/primary_worn = mutable_appearance('haven/icons/polyclothes/mob/uniform.dmi', "[item_color]-primary")
			primary_worn.color = primary_color
			. += primary_worn
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
	to_chat(user, "<span class='notice'>Alt-click to recolor it.</span>")

/obj/item/clothing/under/polychromic/Initialize()
	..()
	update_icon()

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

//replaces the jumpsuit contents of the mixed wardrobe

/obj/structure/closet/wardrobe/mixed/PopulateContents()
	if(prob(40))
		new /obj/item/clothing/suit/jacket(src)
	if(prob(40))
		new /obj/item/clothing/suit/jacket(src)
	new /obj/item/clothing/under/polychromic/jumpsuit(src)
	new /obj/item/clothing/under/polychromic/jumpsuit(src)
	new /obj/item/clothing/under/polychromic/jumpsuit(src)
	new /obj/item/clothing/under/polychromic/shirt(src)
	new /obj/item/clothing/under/polychromic/shirt(src)
	new /obj/item/clothing/under/polychromic/shirt(src)
	new /obj/item/clothing/under/polychromic/kilt(src)
	new /obj/item/clothing/under/polychromic/kilt(src)
	new /obj/item/clothing/under/polychromic/kilt(src)
	new /obj/item/clothing/under/polychromic/skirt(src)
	new /obj/item/clothing/under/polychromic/skirt(src)
	new /obj/item/clothing/under/polychromic/skirt(src)
	new /obj/item/clothing/under/polychromic/shorts(src)
	new /obj/item/clothing/under/polychromic/shorts(src)
	new /obj/item/clothing/under/polychromic/shorts(src)
	new /obj/item/clothing/mask/bandana/red(src)
	new /obj/item/clothing/mask/bandana/red(src)
	new /obj/item/clothing/mask/bandana/blue(src)
	new /obj/item/clothing/mask/bandana/blue(src)
	new /obj/item/clothing/mask/bandana/gold(src)
	new /obj/item/clothing/mask/bandana/gold(src)
	new /obj/item/clothing/shoes/sneakers/black(src)
	new /obj/item/clothing/shoes/sneakers/brown(src)
	new /obj/item/clothing/shoes/sneakers/white(src)
	if(prob(30))
		new /obj/item/clothing/suit/hooded/wintercoat(src)
		new /obj/item/clothing/shoes/winterboots(src)
	return