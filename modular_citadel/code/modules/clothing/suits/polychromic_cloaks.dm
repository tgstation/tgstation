/obj/item/clothing/neck/cloak/polychromic	//enables all three overlays to reduce copypasta and defines basic stuff
	name = "polychromic cloak"
	desc = "For when you want to show off your horrible colour coordination skills."
	icon = 'modular_citadel/icons/polyclothes/item/neck.dmi'
	alternate_worn_icon = 'modular_citadel/icons/polyclothes/mob/neck.dmi'
	icon_state = "polyce"
	item_color = "polyce"
	item_state = "qmcloak"
	hasprimary = TRUE
	hassecondary = TRUE
	hastertiary = TRUE
	primary_color = "#FFFFFF" //RGB in hexcode
	secondary_color = "#FFFFFF"
	tertiary_color = "#808080"

/obj/item/clothing/neck/cloak/polychromic/worn_overlays(isinhands, icon_file)	//this is where the main magic happens. Also mandates that ALL polychromic stuff MUST USE alternate_worn_icon
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

/obj/item/clothing/neck/cloak/polychromic/polyce	//DONATOR ITEM
	name = "polychromic embroidered cloak"
	desc = "A fancy cloak embroidered with polychromatic thread in a pattern that reminds one of the wielders of unlimited power."
	icon_state = "polyce"
	item_color = "polyce"
	primary_color = "#808080" //RGB in hexcode
	secondary_color = "#8CC6FF"
	tertiary_color = "#FF3535"