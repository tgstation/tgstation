////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//	Polychromic Uniforms:																							 					  //
//																													 					  //
//		Polychromic clothes simply consist of 4 sprites: A base, unrecoloured sprite, and up to 3 greyscaled sprites. 					  //
//	In order to add more polychromic clothes, simply create a base sprite, and up to 3 recolourable overlays for it,  					  //
//	and then name them as follows: [name], [name]-primary, [name]-secondary, [name]-tertiary. The sprites should	  					  //
//	ideally be in 'modular_citadel/icons/polyclothes/item/uniform.dmi' and 'modular_citadel/icons/polyclothes/mob/uniform.dmi' for the	  //
//	worn sprites. After that, copy paste the code from any of the example clothes and 													  //
//	change the names around. [name] should go in BOTH icon_state and item_color. You can preset colors and disable	  					  //
//	any overlays using the self-explainatory vars.																	  					  //
//																													  					  //
//																								-Tori				  					  //
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

/obj/item/clothing/under/polychromic	//enables all three overlays to reduce copypasta and defines basic stuff
	name = "polychromic suit"
	desc = "For when you want to show off your horrible colour coordination skills."
	icon = 'modular_citadel/icons/polyclothes/item/uniform.dmi'
	alternate_worn_icon = 'modular_citadel/icons/polyclothes/mob/uniform.dmi'
	icon_state = "polysuit"
	item_color = "polysuit"
	item_state = "sl_suit"
	hasprimary = TRUE
	hassecondary = TRUE
	hastertiary = TRUE
	primary_color = "#FFFFFF" //RGB in hexcode
	secondary_color = "#FFFFFF"
	tertiary_color = "#808080"
	can_adjust = FALSE

/obj/item/clothing/under/polychromic/worn_overlays(isinhands, icon_file)	//this is where the main magic happens. Also mandates that ALL polychromic stuff MUST USE alternate_worn_icon
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

/obj/item/clothing/under/polychromic/shirt	//COPY PASTE THIS TO MAKE A NEW THING
	name = "polychromic button-up shirt"
	desc = "A fancy button-up shirt made with polychromic threads."
	icon_state = "polysuit"
	item_color = "polysuit"
	item_state = "sl_suit"
	primary_color = "#FFFFFF" //RGB in hexcode
	secondary_color = "#353535"
	tertiary_color = "#353535"

/obj/item/clothing/under/polychromic/kilt
	name = "polychromic kilt"
	desc = "It's not a skirt!"
	icon_state = "polykilt"
	item_color = "polykilt"
	item_state = "kilt"
	primary_color = "#FFFFFF" //RGB in hexcode
	secondary_color = "#F08080"
	tertiary_color = "#808080"

/obj/item/clothing/under/polychromic/skirt
	name = "polychromic skirt"
	desc = "A fancy skirt made with polychromic threads."
	icon_state = "polyskirt"
	item_color = "polyskirt"
	item_state = "rainbow"
	primary_color = "#FFFFFF" //RGB in hexcode
	secondary_color = "#F08080"
	tertiary_color = "#808080"

/obj/item/clothing/under/polychromic/shorts
	name = "polychromic shorts"
	desc = "For ease of movement and style."
	icon_state = "polyshorts"
	item_color = "polyshorts"
	item_state = "rainbow"
	primary_color = "#353535" //RGB in hexcode
	secondary_color = "#808080"
	tertiary_color = "#808080"

/obj/item/clothing/under/polychromic/jumpsuit
	name = "polychromic tri-tone jumpsuit"
	desc = "A fancy jumpsuit made with polychromic threads."
	icon_state = "polyjump"
	item_color = "polyjump"
	item_state = "rainbow"
	primary_color = "#FFFFFF" //RGB in hexcode
	secondary_color = "#808080"
	tertiary_color = "#FF3535"

/obj/item/clothing/under/polychromic/shortpants
	name = "polychromic athletic shorts"
	desc = "95% Polychrome, 5% Spandex!"
	icon_state = "polyshortpants"
	item_color = "polyshortpants"
	item_state = "rainbow"
	hastertiary = FALSE
	primary_color = "#FFFFFF" //RGB in hexcode
	secondary_color = "#F08080"
	gender = PLURAL	//Because shortS
	body_parts_covered = GROIN	//Because there's no shirt included

/obj/item/clothing/under/polychromic/pleat
	name = "polychromic pleated skirt"
	desc = "A magnificent pleated skirt complements the woolen polychromatic sweater."
	icon_state = "polypleat"
	item_color = "polypleat"
	item_state = "rainbow"
	primary_color = "#8CC6FF" //RGB in hexcode
	secondary_color = "#808080"
	tertiary_color = "#FF3535"

/obj/item/clothing/under/polychromic/femtank
	name = "polychromic feminine tank top"
	desc = "Great for showing off your chest in style. Not recommended for males."
	icon_state = "polyfemtankpantsu"
	item_color = "polyfemtankpantsu"
	item_state = "rainbow"
	hastertiary = FALSE
	primary_color = "#808080" //RGB in hexcode
	secondary_color = "#FF3535"

/obj/item/clothing/under/polychromic/shortpants/pantsu
	name = "polychromic panties"
	desc = "Topless striped panties. Now with 120% more polychrome!"
	icon_state = "polypantsu"
	item_color = "polypantsu"
	item_state = "rainbow"
	hastertiary = FALSE
	primary_color = "#FFFFFF" //RGB in hexcode
	secondary_color = "#8CC6FF"

/obj/item/clothing/under/polychromic/bottomless
	name = "polychromic bottomless shirt"
	desc = "Great for showing off your junk in dubious style."
	icon_state = "polybottomless"
	item_color = "polybottomless"
	item_state = "rainbow"
	hastertiary = FALSE
	primary_color = "#808080" //RGB in hexcode
	secondary_color = "#FF3535"
	body_parts_covered = CHEST	//Because there's no bottom included

/obj/item/clothing/under/polychromic/shimatank
	name = "polychromic tank top"
	desc = "For those lazy summer days."
	icon_state = "polyshimatank"
	item_color = "polyshimatank"
	item_state = "rainbow"
	primary_color = "#808080" //RGB in hexcode
	secondary_color = "#FFFFFF"
	tertiary_color = "#8CC6FF"