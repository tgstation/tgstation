/obj/item/organ/cyberimp/arm/lighter
	name = "lighter arm implant"
	desc = "A nigh useless arm implant containing only a lighter. Why would you ever want this?"
	contents = newlist(/obj/item/lighter/greyscale)

/obj/item/organ/cyberimp/arm/lighter/emag_act()
	. = ..()
	if(obj_flags & EMAGGED)
		return
	obj_flags |= EMAGGED
	to_chat(usr, "<span class='notice'>You unlock [src]'s integrated zippo lighter! Finally, classy smoking!</span>")
	items_list += new /obj/item/lighter(src)
	return TRUE

/obj/item/organ/cyberimp/arm/centcomtools
	name = "centcom tools implant"
	desc = "A set of tools of the highest caliber made to be implanted, available only to central command 'peace operatives' and ERTs."
	contents = newlist(/obj/item/crowbar/abductor, /obj/item/screwdriver/abductor, /obj/item/weldingtool/abductor, /obj/item/wirecutters/abductor, /obj/item/wrench/abductor, /obj/item/multitool/abductor, /obj/item/construction/rcd/arcd, /obj/item/construction/rld, /obj/item/construction/plumbing)

/obj/item/organ/cyberimp/arm/clocktools
	name = "clockwork tools implant"
	desc = "A set of intricate tools made of brass, built into your arm. Probably more for show than function - No multitool is included."
	contents = newlist(/obj/item/crowbar/brass, /obj/item/screwdriver/brass, /obj/item/weldingtool/brass, /obj/item/wirecutters/brass, /obj/item/wrench/brass)