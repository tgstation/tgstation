/datum/photo_disguise
	var/name = ""
	var/examine_override = ""
	var/special_appearance

/datum/picture
	var/list/potential_disguises = list()

/obj/effect/appearance_clone
	var/based_on

/obj/effect/appearance_clone/New(loc, atom/A)
	. = ..()
	if(istype(A))
		based_on = A

/obj/structure/closet/cardboard
	var/datum/photo_disguise/disguise
	desc = "Just a box. Looks like you could place a photo of someone on it to fool people..."

/obj/item/camera
	var/list/atomslist = list()

/obj/item/camera/after_picture(mob/user, datum/picture/picture, proximity_flag)
	for(var/A in atomslist)
		var/obj/effect/appearance_clone/clone = A
		if(ismob(clone.based_on))
			var/mob/C = clone.based_on
			if(!istype(C))
				continue
			if(is_vampire(C))
				continue
			if(C.invisibility)
				continue
			var/datum/photo_disguise/D = new()
			D.name = C.name
			D.examine_override = C.examine(null) // Don't actually print anything please
			D.special_appearance = C.appearance
			picture.potential_disguises[C.name] = D
	..()

/obj/structure/closet/cardboard/attackby(obj/item/W, mob/user, params)
	// Apply the thing
	if (istype(W, /obj/item/photo))
		var/obj/item/photo/photo = W
		var/datum/picture/P = photo.picture
		if (LAZYLEN(P.potential_disguises) > 0)
			var/chosen = input("Select a target to disguise as", "Pick target") as null|anything in P.potential_disguises

			if (chosen)
				var/datum/photo_disguise/D = P.potential_disguises[chosen]

				if (D)
					to_chat(user, "<span class='notice'>You gently place the cut-out of [chosen] onto the box, careful to make sure it looks genuine.</span>")
					disguise = D
					qdel(W)

					if (!opened)
						icon = null
						appearance = D.special_appearance
	else
		. = ..()

/obj/structure/closet/cardboard/examine(mob/user)
	// If you're examining it from far enough away it looks like a regular person
	if (get_dist(src, user) > 1 && disguise && !opened)
		to_chat(user, disguise.examine_override)
		return

	. = ..()

	if (get_dist(src, user) <= 1 && disguise && !opened)
		to_chat(user, "<span class='warning'>Upon close inspection it looks like a shoddy impersonation of [disguise]!</span>")
		to_chat(user, "<span class='notice'>Alt-click to remove the impersonation</span>")

/obj/structure/closet/cardboard/AltClick(mob/user)
	if (disguise)
		visible_message("<span class='warning'>[user] rips the cut-out of [disguise] from the [src]!<span>")
		playsound(loc, 'sound/items/poster_ripped.ogg', 100, 1)
		disguise = null

		if (!opened)
			appearance = initial(appearance)
	else
		. = ..()

/obj/structure/closet/cardboard/close(mob/living/user)
	. = ..()

	if (disguise)
		appearance = disguise.special_appearance

/obj/structure/closet/cardboard/open(mob/living/user)
	appearance = initial(appearance)

	. = ..()
