/*
* All vanity items go here. (ex. perc zippo, perc cigs, drinks, bobblehead)
*/


/*
* Perc Zippo
*/

/obj/item/lighter/zippo/perc
	name = "Limited Edition Award Zippo in Recognition of Meritorious Service"
	desc = "This precious limited edition zippo is an award only issued to the longest serving and most meritorious of Enforcers."
	icon_state = "p_zippo"
	icon = 'icons/oldschool/perseus.dmi'
	item_state = "zippo"

/*
* Bobblehead
*/

/obj/item/bobblehead/blackwell
	name = "Theodore Blackwell"
	desc = "This commemorative bobble head statue is placed here in observance and respect of the Perseus C.E.O. and founder, Theodore Blackwell."
	icon = 'icons/oldschool/perseus.dmi'
	icon_state = "bobble"

/*
* Perc Cigs
*/

/obj/item/storage/fancy/cigarettes/perc
	name = "Perc Brand Cigarette packet"
	desc = "A pack of Perc Brand Cigarettes. Sponsored by Perseus, the merc team that always smokes Perc. Now with 20% more nicotine."
	icon = 'icons/oldschool/perseus.dmi'
	icon_state = "pcigpacket"
	item_state = "pcigpacket"
	can_hold = list("/obj/item/clothing/mask/cigarette", "/obj/item/lighter/zippo/perc")

/obj/item/storage/fancy/cigarettes/perc/update_icon()
	if(fancy_open && !contents.len)
		cut_overlays()
		icon_state = initial(icon_state)
		var/mutable_appearance/open_overlay = mutable_appearance(overlay_icon_file)
		open_overlay.icon_state = "[icon_state]_open"
		add_overlay(open_overlay)
		return
	return ..()

/*
* Victory Cigar
*/

/obj/item/clothing/mask/cigarette/cigar/victory
	name = "Victory Smokes"
	desc = "Space Cuban cigars, meant only to be smoked in celebration of a job well done."
	icon_state = "cigar2off"
	icon_on = "cigar2on"
	icon_off = "cigar2off"

/*
* Bed Sheet
*/

/obj/item/bedsheet/perc
	icon = 'icons/oldschool/perseus.dmi'
	icon_state = "sheetperc"
	item_color = "blue"
	alternate_worn_icon = 'icons/oldschool/perseus_worn.dmi'
	dream_messages = list("blue", "monster truck", "energy project")
