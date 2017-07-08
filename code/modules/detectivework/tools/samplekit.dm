/proc/handlefiber(var/ftext)
	return replacetext(replacetext(replacetext(ftext, "material from a pair of ", ""), ".", ""), "Fibers from a", "")


/obj/item/forensics
	icon = 'icons/obj/forensics.dmi'
	flags = NOBLUDGEON

/obj/item/forensics/fiber
	name = "fibers"
	icon_state = "fiber"
	desc = "Fibers from some gloves..."
	var/_fiber

/obj/item/forensics/fiber/New(var/location, var/type)
	..()
	if (type)
		src._fiber = handlefiber(type)
		src.name = "[src._fiber] fibers"

/obj/item/forensics/fiberbag
	name = "fiber bag"
	icon_state = "fiberbag"
	desc = "A bag containing a fiber from some gloves or clothes."
	var/fiber = "air"

/obj/item/forensics/fiberbag/New(var/location, var/type)
	..()
	if (type)
		src.fiber = handlefiber(type)

/obj/item/forensics/fiberbag/attack_self(mob/user)
	to_chat(user, "<span class='notice'>We dump the fiber out of the bag.</span>")
	new /obj/item/forensics/fiber(get_turf(user), src.fiber)
	qdel(src)


/obj/item/forensics/fiberkit
	name = "fiber kit"
	icon_state = "fiberkit"
	desc = "A magnifying glass and tweezers for finding and extracting fibers"

/obj/item/forensics/fiberkit/afterattack(atom/A, mob/user, params)
	var/list/fibers = list()
	var/list/fibersa = list()
	if(A.suit_fibers && A.suit_fibers.len)
		fibers = A.suit_fibers.Copy()
		to_chat(user, "<span class='notice'>We pick up the fibers and lay them in bags on the ground, visibly.</span>")
		if(fibers && fibers.len)
			sleep(5)
			for(var/fiber in fibers)
				if (!fibersa.Find(handlefiber(fiber))) //avoid 500 black/insulated glove fiber
					fibersa |= handlefiber(fiber)
					new /obj/item/forensics/fiberbag(get_turf(user), fiber)

			qdel(fibers)
			qdel(fibersa)
		else
			to_chat(user, "<span class='notice'>We could not find any fibers....</span>")
			return
			qdel(fibers)
			qdel(fibersa)
	else
		to_chat(user, "<span class='notice'>We could not find any fibers....</span>")
		qdel(fibers)
		qdel(fibersa)
		return