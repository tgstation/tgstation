/obj/item/clothing
	var/cuttable = FALSE //If you can cut the clothing with anything sharp
	var/clothamnt = 0 //How much cloth

/// Clothing + sharp = cloth sheet
/obj/item/clothing/attackby(obj/item/W, mob/user, params, cloth/C)
	if(W.get_sharpness() && cuttable)
		if(QDELETED(src))
			to_chat(user, "<span class='notice'>The item doesn't exist anymore!.</span>")
			return
		playsound(src.loc, 'sound/items/poster_ripped.ogg', 100, TRUE)
		to_chat(user, "<span class='notice'>You cut the [src] into strips with [W].</span>")
		var/obj/item/stack/sheet/cloth/result = new (get_turf(src), clothamnt)
		qdel(src)
		return TRUE
	..()

/obj/item/clothing/neck
	cuttable = TRUE
	clothamnt = 1

/obj/item/clothing/under
	cuttable = TRUE
	clothamnt = 2
