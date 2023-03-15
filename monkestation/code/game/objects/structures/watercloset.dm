/obj/structure/toilet/attackby(obj/item/I, mob/living/user, params)
	if (istype(I, /obj/item/flamethrower))
		if (!user.is_holding_item_of_type(/obj/item/crowbar))
			to_chat(user, "<span class='notice'>You need a crowbar to retrofit this toilet into a bong!</span>")
			return
		playsound(loc, 'sound/effects/stonedoor_openclose.ogg', 50, 1)
		user.visible_message("<span class='notice'>[user] begins to attach [I] to [src]...</span>", "<span class='notice'>You begin attaching [I] to [src]...</span>")
		if (!do_after(user, 5 SECONDS, target = src))
			return
		for (var/obj/item/cistern_item in contents)
			cistern_item.forceMove(loc)
			visible_message("<span class='warning'>[cistern_item] falls out of [src]!</span>")
		var/obj/structure/toilet_bong/bong = new(loc)
		bong.dir = dir
		qdel(I)
		qdel(src)
	else
		return ..()
