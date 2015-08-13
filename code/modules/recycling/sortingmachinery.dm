/obj/structure/bigDelivery
	name = "large parcel"
	desc = "A big wrapped package."
	icon = 'icons/obj/storage.dmi'
	icon_state = "deliverycloset"
	density = 1
	mouse_drag_pointer = MOUSE_ACTIVE_POINTER
	var/obj/wrapped = null
	var/giftwrapped = 0
	var/sortTag = 0


/obj/structure/bigDelivery/attack_hand(mob/user)
	playsound(src.loc, 'sound/items/poster_ripped.ogg', 50, 1)
	qdel(src)

/obj/structure/bigDelivery/Destroy()
	if(wrapped) //sometimes items can disappear. For example, bombs. --rastaf0
		wrapped.loc = (get_turf(loc))
		if(istype(wrapped, /obj/structure/closet))
			var/obj/structure/closet/O = wrapped
			O.welded = 0
	var/turf/T = get_turf(src)
	for(var/atom/movable/AM in contents)
		AM.loc = T
	..()

/obj/structure/bigDelivery/attackby(obj/item/W, mob/user, params)
	if(istype(W, /obj/item/device/destTagger))
		var/obj/item/device/destTagger/O = W

		if(sortTag != O.currTag)
			var/tag = uppertext(TAGGERLOCATIONS[O.currTag])
			user << "<span class='notice'>*[tag]*</span>"
			sortTag = O.currTag
			playsound(loc, 'sound/machines/twobeep.ogg', 100, 1)

	else if(istype(W, /obj/item/weapon/pen))
		var/str = copytext(sanitize(input(user,"Label text?","Set label","")),1,MAX_NAME_LEN)
		if(!str || !length(str))
			user << "<span class='warning'>Invalid text!</span>"
			return
		user.visible_message("[user] labels [src] as [str].")
		name = "[name] ([str])"

	else if(istype(W, /obj/item/stack/wrapping_paper) && !giftwrapped)
		var/obj/item/stack/wrapping_paper/WP = W
		if(WP.use(3))
			user.visible_message("[user] wraps the package in festive paper!")
			giftwrapped = 1
			if(istype(wrapped, /obj/structure/closet/crate))
				icon_state = "giftcrate"
			else
				icon_state = "giftcloset"
			if(WP.amount <= 0 && !WP.loc) //if we used our last wrapping paper, drop a cardboard tube
				new /obj/item/weapon/c_tube( get_turf(user) )
		else
			user << "<span class='warning'>You need more paper!</span>"


/obj/item/smallDelivery
	name = "small parcel"
	desc = "A small wrapped package."
	icon = 'icons/obj/storage.dmi'
	icon_state = "deliverycrateSmall"
	var/obj/item/wrapped = null
	var/giftwrapped = 0
	var/sortTag = 0


/obj/item/smallDelivery/attack_self(mob/user)
	if(wrapped && wrapped.loc) //sometimes items can disappear. For example, bombs. --rastaf0
		wrapped.loc = user.loc
		if(ishuman(user))
			user.put_in_hands(wrapped)
		else
			wrapped.loc = get_turf(src)
	playsound(src.loc, 'sound/items/poster_ripped.ogg', 50, 1)
	qdel(src)


/obj/item/smallDelivery/attackby(obj/item/W, mob/user, params)
	if(istype(W, /obj/item/device/destTagger))
		var/obj/item/device/destTagger/O = W

		if(sortTag != O.currTag)
			var/tag = uppertext(TAGGERLOCATIONS[O.currTag])
			user << "<span class='notice'>*[tag]*</span>"
			sortTag = O.currTag
			playsound(loc, 'sound/machines/twobeep.ogg', 100, 1)

	else if(istype(W, /obj/item/weapon/pen))
		var/str = copytext(sanitize(input(user,"Label text?","Set label","")),1,MAX_NAME_LEN)
		if(!str || !length(str))
			user << "<span class='warning'>Invalid text!</span>"
			return
		user.visible_message("[user] labels [src] as [str].")
		name = "[name] ([str])"

	else if(istype(W, /obj/item/stack/wrapping_paper) && !giftwrapped)
		var/obj/item/stack/wrapping_paper/WP = W
		if(WP.use(1))
			icon_state = "giftcrate[wrapped.w_class]"
			giftwrapped = 1
			user.visible_message("[user] wraps the package in festive paper!")
			if(WP.amount <= 0 && !WP.loc) //if we used our last wrapping paper, drop a cardboard tube
				new /obj/item/weapon/c_tube( get_turf(user) )
		else
			user << "<span class='warning'>You need more paper!</span>"



/obj/item/stack/packageWrap
	name = "package wrapper"
	icon = 'icons/obj/items.dmi'
	icon_state = "deliveryPaper"
	flags = NOBLUDGEON
	amount = 25
	max_amount = 25
	burn_state = 0 //burnable


/obj/item/stack/packageWrap/afterattack(obj/target, mob/user, proximity)
	if(!proximity) return
	if(!istype(target))	//this really shouldn't be necessary (but it is).	-Pete
		return
	if(istype(target, /obj/item/smallDelivery) || istype(target,/obj/structure/bigDelivery) \
	|| istype(target, /obj/item/weapon/evidencebag) || istype(target, /obj/structure/closet/body_bag))
		return
	if(target.anchored)
		return
	if(target in user)
		return



	if(istype(target, /obj/item) && !(istype(target, /obj/item/weapon/storage) && !istype(target,/obj/item/weapon/storage/box)))
		var/obj/item/O = target
		if(use(1))
			var/obj/item/smallDelivery/P = new /obj/item/smallDelivery(get_turf(O.loc))	//Aaannd wrap it up!
			if(!istype(O.loc, /turf))
				if(user.client)
					user.client.screen -= O
			P.wrapped = O
			O.loc = P
			var/i = round(O.w_class)
			if(i in list(1,2,3,4,5))
				P.icon_state = "deliverycrate[i]"
				P.w_class = i
			P.add_fingerprint(usr)
			O.add_fingerprint(usr)
			add_fingerprint(usr)
		else
			return
	else if(istype(target, /obj/structure/closet/crate))
		var/obj/structure/closet/crate/O = target
		if(O.opened)
			return
		if(use(3))
			var/obj/structure/bigDelivery/P = new /obj/structure/bigDelivery(get_turf(O.loc))
			P.icon_state = "deliverycrate"
			P.wrapped = O
			O.loc = P
		else
			user << "<span class='warning'>You need more paper!</span>"
			return
	else if(istype (target, /obj/structure/closet))
		var/obj/structure/closet/O = target
		if(O.opened)
			return
		if(use(3))
			var/obj/structure/bigDelivery/P = new /obj/structure/bigDelivery(get_turf(O.loc))
			P.wrapped = O
			O.welded = 1
			O.loc = P
		else
			user << "<span class='warning'>You need more paper!</span>"
			return
	else
		user << "<span class='warning'>The object you are trying to wrap is unsuitable for the sorting machinery!</span>"
		return

	user.visible_message("[user] wraps [target].")
	user.attack_log += text("\[[time_stamp()]\] <font color='blue'>Has used [name] on [target]</font>")

	if(amount <= 0 && !src.loc) //if we used our last wrapping paper, drop a cardboard tube
		new /obj/item/weapon/c_tube( get_turf(user) )
	return


/obj/item/device/destTagger
	name = "destination tagger"
	desc = "Used to set the destination of properly wrapped packages."
	icon_state = "cargotagger"
	var/currTag = 0
	//The whole system for the sorttype var is determined based on the order of this list,
	//disposals must always be 1, since anything that's untagged will automatically go to disposals, or sorttype = 1 --Superxpdude

	//If you don't want to fuck up disposals, add to this list, and don't change the order.
	//If you insist on changing the order, you'll have to change every sort junction to reflect the new order. --Pete

	w_class = 1
	item_state = "electronic"
	flags = CONDUCT
	slot_flags = SLOT_BELT

/obj/item/device/destTagger/proc/openwindow(mob/user)
	var/dat = "<tt><center><h1><b>TagMaster 2.2</b></h1></center>"

	dat += "<table style='width:100%; padding:4px;'><tr>"
	for (var/i = 1, i <= TAGGERLOCATIONS.len, i++)
		dat += "<td><a href='?src=\ref[src];nextTag=[i]'>[TAGGERLOCATIONS[i]]</a></td>"

		if(i%4==0)
			dat += "</tr><tr>"

	dat += "</tr></table><br>Current Selection: [currTag ? TAGGERLOCATIONS[currTag] : "None"]</tt>"

	user << browse(dat, "window=destTagScreen;size=450x350")
	onclose(user, "destTagScreen")

/obj/item/device/destTagger/attack_self(mob/user)
	openwindow(user)
	return

/obj/item/device/destTagger/Topic(href, href_list)
	add_fingerprint(usr)
	if(href_list["nextTag"])
		var/n = text2num(href_list["nextTag"])
		currTag = n
	openwindow(usr)


/obj/item/weapon/c_tube
	name = "cardboard tube"
	desc = "A tube... of cardboard."
	icon = 'icons/obj/items.dmi'
	icon_state = "c_tube"
	throwforce = 0
	w_class = 1.0
	throw_speed = 3
	throw_range = 5