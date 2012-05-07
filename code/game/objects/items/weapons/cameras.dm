/obj/item/weapon/storage/photo_album
	name = "Photo album"
	icon = 'items.dmi'
	icon_state = "album"
	item_state = "briefcase"
	can_hold = list("/obj/item/weapon/photo",)

/obj/item/weapon/storage/photo_album/MouseDrop(obj/over_object as obj)

	if ((istype(usr, /mob/living/carbon/human) || (ticker && ticker.mode.name == "monkey")))
		var/mob/M = usr
		if (!( istype(over_object, /obj/screen) ))
			return ..()
		playsound(src.loc, "rustle", 50, 1, -5)
		if ((!( M.restrained() ) && !( M.stat ) && M.back == src))
			if (over_object.name == "r_hand")
				if (!( M.r_hand ))
					M.u_equip(src)
					M.r_hand = src
			else
				if (over_object.name == "l_hand")
					if (!( M.l_hand ))
						M.u_equip(src)
						M.l_hand = src
			M.update_clothing()
			src.add_fingerprint(usr)
			return
		if(over_object == usr && in_range(src, usr) || usr.contents.Find(src))
			if (usr.s_active)
				usr.s_active.close(usr)
			src.show_to(usr)
			return
	return

/obj/item/weapon/storage/photo_album/attackby(obj/item/weapon/W as obj, mob/user as mob)
	..()

/obj/item/weapon/camera_test
	name = "camera"
	icon = 'items.dmi'
	desc = "A one use - polaroid camera. 10 photos left."
	icon_state = "camera"
	item_state = "electropack"
	w_class = 2.0
	flags = 466.0
	m_amt = 2000
	throwforce = 5
	throw_speed = 4
	throw_range = 10
	var/pictures_left = 30
	var/can_use = 1


/obj/item/weapon/photo
	name = "photo"
	icon = 'items.dmi'
	icon_state = "photo"
	item_state = "clipboard"
	w_class = 1.0
	var/icon/img


/obj/item/weapon/photo/attack_self(var/mob/user as mob)
		..()
		examine()


/obj/item/weapon/photo/examine()
		set src in oview(2)
		..()	//We don't want them to see the dumb "this is a paper" thing every time.

		usr << browse_rsc(src.img, "tmp_photo.png")
		usr << browse("<html><head><title>Photo</title></head>" \
			+ "<body style='overflow:hidden'>" \
			+ "<div> <img src='tmp_photo.png' width = '180'" \
			+ "</body></html>", "window=book;size=200x200")
		onclose(usr, "[name]")

		return
//////////////////////////////////////////////////////////////////////////////////////////////////
/obj/item/weapon/camera_test/attack(mob/living/carbon/human/M as mob, mob/user as mob)
	return

/obj/item/weapon/camera_test/proc/get_icon(turf/the_turf as turf)
	var/icon/res = icon('items.dmi',"photo")
	var/icon/turficon = build_composite_icon(the_turf)
	res.Blend(turficon,ICON_OVERLAY,0,0)
	var/icons[] 	= list()		//For all atoms on this turf getting their icons
	var/layers[] 	= list()		//and levels
	for(var/atom/A in the_turf)
		//if(istype(A, /obj/item/weapon/photo))	continue
		if(A.invisibility) continue
		icons.Add(build_composite_icon(A))
		layers.Add(A.layer)

	//Sorting icons based on levels
	var/gap = layers.len
	var/swapped = 1
	while (gap > 1 || swapped)
		swapped = 0
		if (gap > 1)
			gap = round(gap / 1.247330950103979)
		if (gap < 1)
			gap = 1
		for (var/i = 1; gap + i <= layers.len; i++)
			if (layers[i] > layers[gap+i])
				layers.Swap(i, gap + i)
				icons.Swap(i, gap + i)
				swapped = 1

	for (var/i; i <= icons.len; i++)
		if(istype(icons[i], /icon))
			res.Blend(icons[i],ICON_OVERLAY,0,0)
	return res

/obj/item/weapon/camera_test/attack_self(var/mob/user as mob)
	..()
	if (can_use)
		can_use = 0
		icon_state = "camera_off"
	else
		can_use = 1
		icon_state = "camera"

/obj/item/weapon/camera_test/proc/get_mobs(turf/the_turf as turf)
	var/mob_detail
	for(var/mob/living/carbon/A in the_turf)
		if(A.invisibility) continue
		var/holding = null
		if(A.l_hand || A.r_hand)
			if(A.l_hand) holding = "They are holding \a [A.l_hand]"
			if(A.r_hand)
				if(holding)
					holding += " and \a [A.r_hand]."
				else
					holding = "They are holding \a [A.r_hand]."

		if(!mob_detail)
			mob_detail = "You can see [A] on the photo[A:health < 75 ? " - [A] looks hurt":""].[holding ? " [holding]":"."]. "
		else
			mob_detail += "You can also see [A] on the photo[A:health < 75 ? " - [A] looks hurt":""].[holding ? " [holding]":"."]"
	return mob_detail

/obj/item/weapon/camera_test/afterattack(atom/target as mob|obj|turf|area, mob/user as mob, flag)
	if (!can_use || !pictures_left || ismob(target.loc)) return

	var/x_c = target.x - 1
	var/y_c = target.y + 1
	var/z_c	= target.z

	var/icon/temp = icon('96x96.dmi',"")
	var/mobs = ""
	for (var/i = 1; i <= 3; i++)
		for (var/j = 1; j <= 3; j++)
			var/turf/T = locate(x_c,y_c,z_c)
			temp.Blend(get_icon(T),ICON_OVERLAY,31*(j-1),62 - 31*(i-1))
			mobs += get_mobs(T)
			x_c++
		y_c--
		x_c = x_c - 3

	var/obj/item/weapon/photo/P = new/obj/item/weapon/photo( get_turf(src) )
	var/icon/small_img = icon(temp)
	var/icon/ic = icon('items.dmi',"photo")
	small_img.Scale(8,8)
	ic.Blend(small_img,ICON_OVERLAY,10,13)
	P.icon = ic
	P.img = temp
	P.desc = mobs
	P.pixel_x = rand(-10,10)
	P.pixel_y = rand(-10,10)
	playsound(src.loc, pick('polaroid1.ogg','polaroid2.ogg'), 75, 1, -3)

	pictures_left--
	src.desc = "A one use - polaroid camera. [pictures_left] photos left."
	user << "\blue [pictures_left] photos left."
	can_use = 0
	icon_state = "camera_off"
	spawn(50)
		can_use = 1
		icon_state = "camera"


