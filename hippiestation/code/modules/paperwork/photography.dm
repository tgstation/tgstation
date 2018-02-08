/datum/photo_disguise
	var/name = ""
	var/examine_override = ""
	var/icon/disguise_icon

/obj/item/photo
	desc = ""
	var/list/potential_disguises = list()

/obj/structure/closet/cardboard
	var/datum/photo_disguise/disguise
	desc = "Just a box. Looks like you could place a photo of someone on it to fool people..."

/obj/item/device/camera/proc/find_disguises(mob/user, list/turfs)
	var/list/targets = list()

	for(var/turf/T in turfs)
		for(var/mob/living/carbon/C in T)
			if (!istype(C))
				continue
			if(is_vampire(C))
				continue
			if(C.invisibility)
				continue

			var/datum/photo_disguise/D = new()
			D.name = C.name
			D.examine_override = C.examine(null) // Don't actually print anything please
			D.disguise_icon = getFlatIcon(C, no_anim = TRUE)

			LAZYSET(targets, C.name, D)

	return targets

/obj/item/device/camera/printpicture(mob/user, icon/temp, mobs, flag, list/potential_disguises) //Normal camera proc for creating photos
	var/obj/item/photo/P = new/obj/item/photo(get_turf(src))
	if(in_range(src, user)) //needed because of TK
		user.put_in_hands(P)
	var/icon/small_img = icon(temp)
	var/icon/ic = icon('icons/obj/items_and_weapons.dmi',"photo")
	small_img.Scale(8, 8)
	ic.Blend(small_img,ICON_OVERLAY, 13, 13)
	P.icon = ic
	P.img = temp
	P.desc = mobs
	P.pixel_x = rand(-10, 10)
	P.pixel_y = rand(-10, 10)

	if(blueprints)
		P.blueprints = 1
		blueprints = 0

	if (potential_disguises)
		P.potential_disguises = potential_disguises
	
/obj/structure/closet/cardboard/attackby(obj/item/W, mob/user, params)
	// Apply the thing
	if (istype(W, /obj/item/photo))
		var/obj/item/photo/P = W
		if (LAZYLEN(P.potential_disguises) > 0)
			var/chosen = input("Select a target to disguise as", "Pick target") as null|anything in P.potential_disguises

			if (chosen)
				var/datum/photo_disguise/D = P.potential_disguises[chosen]

				if (D)
					to_chat(user, "<span class='notice'>You gently place the cut-out of [chosen] onto the box, careful to make sure it looks genuine.</span>")
					disguise = D
					qdel(P)

					if (!opened)
						icon = null
						add_overlay(D.disguise_icon)
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
			cut_overlays()
			icon = initial(icon)
	else
		. = ..()

/obj/structure/closet/cardboard/close(mob/living/user)
	. = ..()

	if (disguise)
		icon = null
		add_overlay(disguise.disguise_icon)

/obj/structure/closet/cardboard/open(mob/living/user)
	if (!icon)
		cut_overlays()
		icon = initial(icon)

	. = ..()