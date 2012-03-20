/obj/item/bodybag
	name = "body bag"
	desc = "A folded bag designed to contain dead things."
	icon = 'bodybag.dmi'
	icon_state = "bodybag_folded"
	w_class = 1.0

	attack_self(mob/user)
		var/obj/structure/closet/body_bag/R = new /obj/structure/closet/body_bag(user.loc)
		R.add_fingerprint(user)
		del(src)


/obj/item/weapon/storage/body_bag_box
	name = "body bags"
	desc = "This box contains body bags."
	icon_state = "bodybags"
	item_state = "syringe_kit"


	New()
		new /obj/item/bodybag(src)
		new /obj/item/bodybag(src)
		new /obj/item/bodybag(src)
		new /obj/item/bodybag(src)
		new /obj/item/bodybag(src)
		new /obj/item/bodybag(src)
		new /obj/item/bodybag(src)
		..()
		return


/obj/structure/closet/body_bag
	name = "body bag"
	desc = "A bag designed to contain dead things."
	icon = 'bodybag.dmi'
	icon_state = "bodybag_closed"
	icon_closed = "bodybag_closed"
	icon_opened = "bodybag_open"
	density = 0


	attackby(P as obj, mob/user as mob)
		if (istype(P, /obj/item/weapon/pen))
			var/t = input(user, "What would you like the label to be?", text("[]", src.name), null)  as text
			if (user.equipped() != P)
				return
			if (!in_range(src, user) && src.loc != user)
				return
			t = copytext(sanitize(t),1,MAX_MESSAGE_LEN)
			if (t)
				src.name = "body bag - "
				src.name += t
			else
				src.name = "body bag"
		..()
		return


	close()
		if(..())
			density = 0
			return 1
		return 0


	MouseDrop(over_object, src_location, over_location)
		..()
		if((over_object == usr && (in_range(src, usr) || usr.contents.Find(src))))
			if(!ishuman(usr))	return
			if(opened)	return 0
			if(contents.len)	return 0
			visible_message("[usr] folds up the [src.name]")
			new/obj/item/bodybag(get_turf(src))
			spawn(0)
				del(src)
			return