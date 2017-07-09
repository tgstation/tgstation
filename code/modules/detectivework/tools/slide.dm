/obj/item/forensics/slide
	name = "slide"
	desc = "A slide, for putting things like fibers, blood, and swabs under microscopes"
	icon_state = "slide"
	var/A = "nothing" //type of thing on the slide
	var/B = "nothing" //Info about the thingy on the slide
	var/C = 0 //type of thing on the slide (only used for swabs)

/obj/item/forensics/slide/attackby(obj/item/W, mob/user)
	var/thingy = user.get_active_held_item()

	if(istype(thingy, /obj/item/forensics/swabkit)) //are we putting a swab in?
		var/obj/item/forensics/swabkit/H = thingy
		src.icon_state = "slideswab"
		src.name = "slide (swab)"
		src.desc = "A slide with a swab on it."
		src.A = "swab"
		src.B = H.scontents
		src.C = H.stype
		qdel(thingy)
	else if(istype(thingy, /obj/item/forensics/fiber) || istype(thingy, /obj/item/forensics/fiberbag)) //Are we putting a fiber on it?
		if (istype(thingy, /obj/item/forensics/fiberbag))
			var/obj/item/forensics/fiberbag/H = thingy
			H._fiber = null
			H.name = "fiber bag"
			H.icon_state = "bag"
			H.desc = "A bag containing a fiber from some gloves or clothes."
			src.icon_state = "slidefiber"
			src.A = "fiber"
			src.B = H._fiber
			src.name = "slide (fiber)"
			src.desc = "A slide with a fiber on it."
		else
			var/obj/item/forensics/fiber/H = thingy
			src.icon_state = "slidefiber"
			src.A = "fiber"
			src.B = H._fiber
			src.name = "slide (fiber)"
			src.desc = "A slide with a fiber on it."
			qdel(H)

	qdel(thingy)

