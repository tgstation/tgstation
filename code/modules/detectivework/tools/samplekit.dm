/obj/item/forensics/proc/handlefiber(ftext)
	return replacetext(replacetext(replacetext(ftext, "material from a pair of ", ""), ".", ""), "Fibers from a", "")


/obj/item/forensics
	icon = 'icons/obj/forensics.dmi'
	flags = NOBLUDGEON

/obj/item/forensics/fiber
	name = "fibers"
	icon_state = "fiber"
	desc = "Fibers from some gloves..."
	var/_fiber

/obj/item/forensics/fiber/New(location, type)
	..()
	if (type)
		src._fiber = handlefiber(type)
		src.name = "[src._fiber] fibers"
		src.icon_state = "fiberbag"

/obj/item/forensics/fiberbag
	name = "fiber bag"
	icon_state = "bag"
	desc = "A bag containing a fiber from some gloves or clothes."
	var/_fiber = "air"

/obj/item/forensics/fiberbag/New(location, type)
	..()
	if (type)
		src._fiber = handlefiber(type)

/obj/item/forensics/fiberbag/attack_self(mob/user)
	to_chat(user, "<span class='notice'>We dump the fiber out of the bag.</span>")
	new /obj/item/forensics/fiber(get_turf(user), src._fiber)
	new /obj/item/forensics/fiberbag(get_turf(user))
	qdel(src)

/obj/item/forensics/fiberbag/attackby(obj/item/W, mob/user)
	var/thingy = user.get_active_held_item()

	if(istype(thingy, /obj/item/forensics/fiber))
		var/obj/item/forensics/fiber/H = thingy
		src._fiber = H._fiber
		src.icon_state = "fiberbag"
		qdel(thingy)

	return

/obj/item/forensics/fiberkit
	name = "fiber kit"
	icon_state = "fiberkit"
	desc = "A magnifying glass and tweezers for finding and extracting fibers"

/obj/item/forensics/fiberkit/afterattack(atom/A, mob/user, params)
	var/list/fibers = list()
	var/list/fibersa = list()
	if(A.forensics.fibers && A.forensics.fibers.len)
		fibers = A.forensics.fibers.Copy()
		to_chat(user, "<span class='notice'>We pick up the fibers and lay them in bags on the ground, visibly.</span>")
		if(LAZYLEN(fibers))
			for(var/fiber in fibers)
				if (!fibersa.Find(handlefiber(fiber))) //avoid 500 black/insulated glove fiber
					fibersa |= handlefiber(fiber)
					new /obj/item/forensics/fiberbag(get_turf(user), fiber)
		else
			to_chat(user, "<span class='notice'>We could not find any fibers....</span>")
			return
	else
		to_chat(user, "<span class='notice'>We could not find any fibers....</span>")
		return