/obj/item/stack/package_wrap
	name = "package wrap"
	desc = "Wrapping paper designed to help goods safely navigate the mail system."
	icon = 'icons/obj/items.dmi'
	icon_state = "deliveryPaper"
	w_class = 2
	amount = 24
	var/smallpath = /obj/item/smallDelivery //We use this for items
	var/bigpath = /obj/structure/bigDelivery //We use this for structures, e.g.: crates
	var/manpath = null //We use this for people
	var/human_wrap_speed = 100 //Handcuffs are 30

	var/list/cannot_wrap = list(
		/obj/structure/table,
		/obj/structure/rack,
		/obj/item/smallDelivery,
		/obj/structure/bigDelivery,
		/obj/item/weapon/gift,
		/obj/item/weapon/winter_gift,
		/obj/item/weapon/evidencebag,
		/obj/item/weapon/legcuffs/bolas,
		/obj/item/weapon/storage
		)

	var/list/wrappable_big_stuff = list(
		/obj/structure/closet,
		/obj/structure/vendomatpack,
		/obj/structure/stackopacks
		)

/obj/item/stack/package_wrap/afterattack(var/obj/target as obj, mob/user as mob)
	if(!istype(target))
		return
	if(is_type_in_list(target, cannot_wrap))
		return
	if(target.anchored)
		return
	if(target in user)
		return

	user.attack_log += text("\[[time_stamp()]\] <font color='blue'>Has used [src.name] on \ref[target]</font>")
	target.add_fingerprint(usr)
	src.add_fingerprint(usr)

	if(istype(target, /obj/item) && smallpath)
		if (amount >= 1)
			var/obj/item/I = target
			var/obj/item/P = new smallpath(get_turf(target.loc),target,round(I.w_class))
			if(!istype(target.loc, /turf))
				if(user.client)
					user.client.screen -= target
			target.forceMove(P)
			P.add_fingerprint(user)
			use(1)
		else
			user << "<span class='warning'>You need more paper!</span>"
	else if(is_type_in_list(target,wrappable_big_stuff) && bigpath)
		if(istype(target,/obj/structure/closet))
			var/obj/structure/closet/C = target
			if(C.opened) return
		if(amount >= 3)
			var/obj/item/P = new bigpath(get_turf(target.loc),target)
			target.forceMove(P)
			P.add_fingerprint(usr)
			use(3)
		else
			user << "<span class='warning'>You need more paper!</span>"
	else if(istype(target, /mob/living/carbon/human) && manpath)
		var/mob/living/carbon/human/H = target
		if(istype(H.wear_suit, /obj/item/clothing/suit/straight_jacket) || H.stat || human_wrap_speed < 100) //Syndicate wrapping paper doesn't need them to be jacketed.
			user << "<span class='warning'>[target] is moving around too much! Straight-jacket [target] first.</span>"
			return
		if(amount >= 2)
			target.visible_message("<span class='danger'>[user] is trying to wrap up [target]!</span>")
			if(do_after(user,target,human_wrap_speed))
				var/obj/present = new manpath(get_turf(H))
				if (H.client)
					H.client.perspective = EYE_PERSPECTIVE
					H.client.eye = present
				H.loc = present
				H.attack_log += text("\[[time_stamp()]\] <font color='orange'>Has been wrapped with [src.name]  by [user.name] ([user.ckey])</font>")
				user.attack_log += text("\[[time_stamp()]\] <font color='red'>Used the [src.name] to wrap [H.name] ([H.ckey])</font>")
				if(!iscarbon(user))
					H.LAssailant = null
				else
					H.LAssailant = user
				log_attack("<font color='red'>[user.name] ([user.ckey]) used the [src.name] to wrap [H.name] ([H.ckey])</font>")
				use(2)
		else
			user << "<span class='warning'>You need more paper!</span>"
	else
		user << "<span class='warning'>[target] won't go through the mail!</span>"
	return

/obj/item/stack/package_wrap/Destroy()
	..()
	new /obj/item/weapon/c_tube(get_turf(loc))

/obj/item/stack/package_wrap/gift //For more details, see gift_wrappaper.dm
	name = "gift wrap"
	desc = "A festive wrap for hand-delivered presents. Not compatible with mail."
	icon_state = "wrap_paper"
	smallpath = /obj/item/weapon/gift
	bigpath = null
	manpath = /obj/structure/strange_present

/obj/structure/bigDelivery
	desc = "A big wrapped package."
	name = "large parcel"
	icon = 'icons/obj/storage.dmi'
	icon_state = "deliverycloset"
	var/obj/wrapped = null
	density = 1
	var/sortTag
	flags = FPRINT
	mouse_drag_pointer = MOUSE_ACTIVE_POINTER

/obj/structure/bigDelivery/New(turf/loc, var/obj/structure/target)
	..(loc)
	wrapped = target
	if(istype(wrapped,/obj/structure/closet/crate)) icon_state = "deliverycrate"
	else if(istype(wrapped,/obj/structure/vendomatpack)) icon_state = "deliverypack"
	else if(istype(wrapped,/obj/structure/stackopacks)) icon_state = "deliverystack"

/obj/structure/bigDelivery/attack_robot(mob/user)
	if(!Adjacent(user))
		return
	attack_hand(user)

/obj/structure/bigDelivery/attack_hand(mob/user as mob)
	if(wrapped) //sometimes items can disappear. For example, bombs. --rastaf0
		wrapped.forceMove(get_turf(src.loc))
		if(istype(wrapped, /obj/structure/closet))
			var/obj/structure/closet/O = wrapped
			O.welded = 0
	qdel(src)

/obj/structure/bigDelivery/attackby(obj/item/W as obj, mob/user as mob)
	if(istype(W, /obj/item/device/destTagger))
		var/obj/item/device/destTagger/O = W

		if(src.sortTag != O.currTag)
			var/tag = uppertext(O.destinations[O.currTag])
			user << "<span class='notice'>*[tag]*</span>"
			sortTag = tag
			playsound(get_turf(src), 'sound/machines/twobeep.ogg', 100, 1)
			overlays = 0
			overlays += "deliverytag"
			src.desc = "A big wrapped package. It has a label reading [tag]"

	else if(istype(W, /obj/item/weapon/pen))
		var/str = copytext(sanitize(input(usr,"Label text?","Set label","")),1,MAX_NAME_LEN)
		if (!Adjacent(user) || user.stat) return
		if(!str || !length(str))
			usr << "<span class='warning'>Invalid text.</span>"
			return
		for(var/mob/M in viewers())
			M << "<span class='notice'>[user] labels [src] as [str].</span>"
		src.name = "[src.name] ([str])" //needs updating

/obj/item/smallDelivery
	desc = "A small wrapped package."
	name = "small parcel"
	icon = 'icons/obj/storage.dmi'
	icon_state = "deliverycrateSmall"
	var/sortTag
	var/obj/item/wrapped
	flags = FPRINT

/obj/item/smallDelivery/New(turf/loc, var/obj/item/target = null, var/size = 2)
	..(loc)
	wrapped = target
	icon_state = "deliverycrate[size]"

/obj/item/smallDelivery/attack_self(mob/user as mob)
	if(wrapped)
		wrapped.forceMove(user.loc)
		if(ishuman(user))
			user.put_in_hands(wrapped)
		else
			wrapped.forceMove(get_turf(src))
	qdel(src)
	return

/obj/item/smallDelivery/attackby(obj/item/W as obj, mob/user as mob)
	if(istype(W, /obj/item/device/destTagger))
		var/obj/item/device/destTagger/O = W

		if(src.sortTag != O.currTag)
			var/tag = uppertext(O.destinations[O.currTag])
			user << "<span class='notice'>*[tag]*</span>"
			sortTag = tag
			playsound(get_turf(src), 'sound/machines/twobeep.ogg', 100, 1)
			overlays = 0
			overlays += "deliverytag"
			src.desc = "A small wrapped package. It has a label reading [tag]"

	else if(istype(W, /obj/item/weapon/pen))
		var/str = copytext(sanitize(input(usr,"Label text?","Set label","")),1,MAX_NAME_LEN)
		if (!Adjacent(user) || user.stat) return
		if(!str || !length(str))
			usr << "<span class='warning'>Invalid text.</span>"
			return
		for(var/mob/M in viewers())
			M << "<span class='notice'>[user] labels [src] as [str].</span>"
		src.name = "[src.name] ([str])" //also needs updating
	return
