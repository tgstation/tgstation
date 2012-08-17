/obj/item/bodybag
	name = "body bag"
	desc = "A folded bag designed to contain dead things."
	icon = 'icons/obj/bodybag.dmi'
	icon_state = "bodybag_folded"

	attack_self(mob/user)
		var/obj/structure/closet/body_bag/R = new /obj/structure/closet/body_bag(user.loc)
		R.add_fingerprint(user)
		del(src)


/obj/item/weapon/storage/body_bag_box
	name = "body bags"
	desc = "This box contains body bags."
	icon_state = "bodybags"
	item_state = "syringe_kit"
	foldable = /obj/item/stack/sheet/cardboard	//BubbleWrap


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
	icon = 'icons/obj/bodybag.dmi'
	icon_state = "bodybag_closed"
	icon_closed = "bodybag_closed"
	icon_opened = "bodybag_open"
	density = 0


	attackby(W as obj, mob/user as mob)
		if (istype(W, /obj/item/weapon/pen))
			var/t = input(user, "What would you like the label to be?", text("[]", src.name), null)  as text
			if (user.get_active_hand() != W)
				return
			if (!in_range(src, user) && src.loc != user)
				return
			t = copytext(sanitize(t),1,MAX_MESSAGE_LEN)
			if (t)
				src.name = "body bag - "
				src.name += t
				src.overlays += image(src.icon, "bodybag_label")
			else
				src.name = "body bag"
		//..() //Doesn't need to run the parent. Since when can fucking bodybags be welded shut? -Agouri
			return
		else if(istype(W, /obj/item/weapon/wirecutters))
			user << "You cut the tag off the bodybag"
			src.name = "body bag"
			src.overlays = null
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

/obj/structure/closet/bodybag/update_icon()
	if(!opened)
		icon_state = icon_closed
	else
		icon_state = icon_opened
