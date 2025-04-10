/obj/item/clothing
	var/cuttable = FALSE //If you can cut the clothing with anything sharp
	var/clothamnt = 0 //How much cloth

/// Clothing + sharp = cloth sheet
/obj/item/clothing/attackby(obj/item/W, mob/user, params)
	if(W.get_sharpness() && cuttable)
		if (!(flags_1 & HOLOGRAM_1))
			if(QDELETED(src))
				to_chat(user, "<span class='notice'>The item doesn't exist anymore!.</span>")
				return
			var/obj/item/stack/sheet/cloth/shreds = new (get_turf(src), clothamnt)
			if(!QDELETED(shreds)) //stacks merged
				transfer_fingerprints_to(shreds)
				shreds.add_fingerprint(user)
		qdel(src)
		to_chat(user, span_notice("You tear [src] up."))
		playsound(src.loc, 'sound/items/poster/poster_ripped.ogg', 100, TRUE)
		return TRUE
	..()

/obj/item/clothing/neck
	cuttable = TRUE
	clothamnt = 1

/obj/item/clothing/under
	cuttable = TRUE
	clothamnt = 2
