/obj/item/forensics
	icon = 'icons/obj/forensics.dmi'
	flags = NOBLUDGEON

/obj/item/forensics/proc/handlefiber(ftext)
	return replacetext(replacetext(replacetext(ftext, "material from a pair of ", ""), ".", ""), "Fibers from a", "")


/obj/item/forensics/fiber
	name = "fibers"
	icon_state = "fiber"
	desc = "Fibers from some gloves..."
	var/_fiber

/obj/item/forensics/fiber/New(location, typ)
	..()
	if (typ)
		_fiber = handlefiber(typ)
		name = "[src._fiber] fibers"
		icon_state = "fiberbag"


/obj/item/forensics/fiberbag
	name = "fiber bag"
	icon_state = "bag"
	desc = "A bag containing a fiber from some gloves or clothes."
	var/_fiber = "air"

/obj/item/forensice/fiberbag/update_icon(meh)
	icon_state = meh

/obj/item/forensics/fiberbag/Initialize(location, typ)
	. = ..()
	if (typ)
		_fiber = handlefiber(typ)

/obj/item/forensics/fiberbag/attack_self(mob/user)
	to_chat(user, "<span class='notice'>We dump the fiber out of the bag.</span>")
	new /obj/item/forensics/fiber(get_turf(user), src._fiber)
	new /obj/item/forensics/fiberbag(get_turf(user))
	qdel(src)

/obj/item/forensics/fiberbag/attackby(obj/item/W, mob/user)
	if(istype(W, /obj/item/forensics/fiber))
		var/obj/item/forensics/fiber/H = W
		_fiber = H._fiber
		update_icon("fiberbag")
		qdel(W)

/obj/item/forensics/fiberkit
	name = "fiber kit"
	icon_state = "fiberkit"
	desc = "A magnifying glass and tweezers for finding and extracting fibers"

/obj/item/forensics/fiberkit/afterattack(atom/A, mob/user, params)
	var/list/fibers = list()
	var/list/fibersa = list()
	if(LAZYLEN(A.forensics.fibers))
		fibers = A.forensics.fibers.Copy()
		to_chat(user, "<span class='notice'>We pick up the fibers and lay them in bags on the ground, visibly.</span>")
		for(var/fiber in fibers)
			if (!fibersa.Find(handlefiber(fiber))) //avoid 500 black/insulated glove fiber
				fibersa |= handlefiber(fiber)
				new /obj/item/forensics/fiberbag(get_turf(user), fiber)
	else
		to_chat(user, "<span class='notice'>We could not find any fibers....</span>")
		return