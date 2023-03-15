/obj/item/organ/cyberimp/arm/lighter
	name = "lighter implant"
	desc = "A lighter, meant to be surgically implanted in a subject's arm."
	contents = newlist(/obj/item/lighter/greyscale)

/obj/item/organ/cyberimp/arm/lighter/emag_act()
	. = ..()
	if(obj_flags & EMAGGED)
		return
	obj_flags |= EMAGGED
	to_chat(usr, "<span class='notice'>You unlock [src]'s integrated Zippo lighter! Finally, classy smoking!</span>")
	items_list += new /obj/item/lighter(src) //Now you can choose between bad and worse!
	return TRUE
