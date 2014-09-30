//Also contains /obj/structure/closet/body_bag because I doubt anyone would think to look for bodybags in /object/structures

/obj/item/bodybag
	name = "body bag"
	desc = "A folded bag designed for the storage and transportation of cadavers."
	icon = 'icons/obj/bodybag.dmi'
	icon_state = "bodybag_folded"

	attack_self(mob/user)
		var/obj/structure/closet/body_bag/R = new /obj/structure/closet/body_bag(user.loc)
		R.add_fingerprint(user)
		qdel(src)


/obj/item/weapon/storage/box/bodybags
	name = "body bag kit"
	desc = "A kit specifically designed to fit bodybags."
	icon_state = "bodybags"
	max_w_class = 3
	max_combined_w_class = 21
	can_hold = list("/obj/item/bodybag") //Needed due to the last two variables, figures
	New()
		..()
		new /obj/item/bodybag(src)
		new /obj/item/bodybag(src)
		new /obj/item/bodybag(src)
		new /obj/item/bodybag(src)
		new /obj/item/bodybag(src)
		new /obj/item/bodybag(src)
		new /obj/item/bodybag(src)


/obj/structure/closet/body_bag
	name = "body bag"
	desc = "A plastic bag designed for the storage and transportation of cadavers."
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
			src.name = "body bag"
			if(t)
				src.name += " [t]"
			src.overlays += image(src.icon, "bodybag_label")
			return
		else if(istype(W, /obj/item/weapon/wirecutters))
			user << "You cut the tag off the bodybag"
			src.name = "body bag"
			src.overlays.Cut()
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


/obj/item/bodybag/cryobag
	name = "stasis bag"
	desc = "A folded, non-reusable bag designed for the preservation of an occupant's brain by stasis."
	icon = 'icons/obj/cryobag.dmi'
	icon_state = "bodybag_folded"

	attack_self(mob/user)
		var/obj/structure/closet/body_bag/cryobag/R = new /obj/structure/closet/body_bag/cryobag(user.loc)
		R.add_fingerprint(user)
		del(src)



/obj/structure/closet/body_bag/cryobag
	name = "stasis bag"
	desc = "A non-reusable plastic bag designed for the preservation of an occupant's brain by stasis."
	icon = 'icons/obj/cryobag.dmi'
	icon_state = "bodybag_closed"
	icon_closed = "bodybag_closed"
	icon_opened = "bodybag_open"
	density = 0

	var/used = 0

	open()
		. = ..()
		if(used)
			var/obj/item/O = new/obj/item(src.loc)
			O.name = "used stasis bag"
			O.icon = src.icon
			O.icon_state = "bodybag_used"
			O.desc = "Pretty useless now.."
			del(src)

	MouseDrop(over_object, src_location, over_location)
		if((over_object == usr && (in_range(src, usr) || usr.contents.Find(src))))
			if(!ishuman(usr))	return
			usr << "\red You can't fold that up anymore.."
		..()