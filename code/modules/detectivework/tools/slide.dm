/obj/item/forensics/slide
	name = "slide"
	desc = "A slide, for putting things like fibers, blood, and swabs under microscopes"
	icon_state = "slide"
	var/A = "nothing" //type of thing on the slide
	var/B = "nothing" //Info about the thingy on the slide
	var/C = 0 //type of thing on the slide (only used for swabs)

/obj/item/forensics/slide/update_icon(ihatethis)
	switch(ihatethis)
		if(0)
			icon_state = "slideswab"

/obj/item/forensics/slide/attackby(obj/item/W, mob/user)

	if(istype(W, /obj/item/forensics/swabkit)) //are we putting a swab in?
		var/obj/item/forensics/swabkit/H = W
		update_icon(0)
		name = "slide (swab)"
		desc = "A slide with a swab on it."
		A = "swab"
		B = H.scontents
		C = H.stype
	else if(istype(W, /obj/item/forensics/fiber) || istype(W, /obj/item/forensics/fiberbag)) //Are we putting a fiber on it?
		if (istype(W, /obj/item/forensics/fiberbag))
			var/obj/item/forensics/fiberbag/H = W
			H._fiber = null
			H.name = "fiber bag"
			H.update_icon(1)
			H.desc = "A bag containing a fiber from some gloves or clothes."
			icon_state = "slidefiber"
			A = "fiber"
			B = H._fiber
			name = "slide (fiber)"
			desc = "A slide with a fiber on it."
		else
			var/obj/item/forensics/fiber/H = W
			icon_state = "slidefiber"
			A = "fiber"
			B = H._fiber
			name = "slide (fiber)"
			desc = "A slide with a fiber on it."
			qdel(H)

	qdel(W)

