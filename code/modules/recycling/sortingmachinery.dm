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


/obj/structure/bigDelivery/attack_hand(mob/user as mob)
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

/obj/structure/bigDelivery/attackby(obj/item/W as obj, mob/user as mob, params)
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


/obj/item/smallDelivery/attack_self(mob/user as mob)
	if(wrapped && wrapped.loc) //sometimes items can disappear. For example, bombs. --rastaf0
		wrapped.loc = user.loc
		if(ishuman(user))
			user.put_in_hands(wrapped)
		else
			wrapped.loc = get_turf(src)
	playsound(src.loc, 'sound/items/poster_ripped.ogg', 50, 1)
	qdel(src)


/obj/item/smallDelivery/attackby(obj/item/W as obj, mob/user as mob, params)
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


/obj/item/stack/packageWrap/afterattack(var/obj/target as obj, mob/user as mob, proximity)
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

/obj/item/device/destTagger/proc/openwindow(mob/user as mob)
	var/dat = "<tt><center><h1><b>TagMaster 2.2</b></h1></center>"

	dat += "<table style='width:100%; padding:4px;'><tr>"
	for (var/i = 1, i <= TAGGERLOCATIONS.len, i++)
		dat += "<td><a href='?src=\ref[src];nextTag=[i]'>[TAGGERLOCATIONS[i]]</a></td>"

		if(i%4==0)
			dat += "</tr><tr>"

	dat += "</tr></table><br>Current Selection: [currTag ? TAGGERLOCATIONS[currTag] : "None"]</tt>"

	user << browse(dat, "window=destTagScreen;size=450x350")
	onclose(user, "destTagScreen")

/obj/item/device/destTagger/attack_self(mob/user as mob)
	openwindow(user)
	return

/obj/item/device/destTagger/Topic(href, href_list)
	add_fingerprint(usr)
	if(href_list["nextTag"])
		var/n = text2num(href_list["nextTag"])
		currTag = n
	openwindow(usr)

/obj/machinery/disposal/deliveryChute
	name = "delivery chute"
	desc = "A chute for big and small packages alike!"
	density = 1
	icon_state = "intake"

	var/start_flush = 0
	var/c_mode = 0

/obj/machinery/disposal/deliveryChute/New(loc,var/obj/structure/disposalconstruct/make_from)
	..()
	stored.ptype = DISP_END_CHUTE
	spawn(5)
		trunk = locate() in loc
		if(trunk)
			trunk.linked = src	// link the pipe trunk to self

/obj/machinery/disposal/deliveryChute/Destroy()
	if(trunk)
		trunk.linked = null
	..()

/obj/machinery/disposal/deliveryChute/interact()
	return

/obj/machinery/disposal/deliveryChute/update()
	return

/obj/machinery/disposal/deliveryChute/Bumped(var/atom/movable/AM) //Go straight into the chute
	if(!AM.disposalEnterTry())
		return
	switch(dir)
		if(NORTH)
			if(AM.loc.y != loc.y+1) return
		if(EAST)
			if(AM.loc.x != loc.x+1) return
		if(SOUTH)
			if(AM.loc.y != loc.y-1) return
		if(WEST)
			if(AM.loc.x != loc.x-1) return

	if(istype(AM, /obj))
		var/obj/O = AM
		O.loc = src
	else if(istype(AM, /mob))
		var/mob/M = AM
		M.loc = src
	flush()

/atom/movable/proc/disposalEnterTry()
	return 1

/obj/item/projectile/disposalEnterTry()
	return

/obj/mecha/disposalEnterTry()
	return

/obj/machinery/disposal/deliveryChute/flush()
	flushing = 1
	flick("intake-closing", src)
	var/deliveryCheck = 0
	var/obj/structure/disposalholder/H = new()	// virtual holder object which actually
												// travels through the pipes.
/*		for(var/obj/structure/bigDelivery/O in src)
		deliveryCheck = 1
		if(O.sortTag == 0)						//This auto-sorts package wrapped objects to disposals
			O.sortTag = 1						//Cargo techs can do this themselves with their taggers
	for(var/obj/item/smallDelivery/O in src)	//With this disabled packages will loop back round and come out the mail chute
		deliveryCheck = 1
		if(O.sortTag == 0)
			O.sortTag = 1						*/
	if(deliveryCheck == 0)
		H.destinationTag = 1

	sleep(10)
	if((start_flush + 15) < world.time)
		start_flush = world.time
		playsound(src, 'sound/machines/disposalflush.ogg', 50, 0, 0)
	sleep(5) // wait for animation to finish

	H.init(src)	// copy the contents of disposer to holder
	air_contents = new()		// new empty gas resv.

	H.start(src) // start the holder processing movement
	flushing = 0
	// now reset disposal state
	flush = 0
	if(mode == 2)	// if was ready,
		mode = 1	// switch to charging
	update()
	return

/obj/machinery/disposal/deliveryChute/attackby(var/obj/item/I, var/mob/user, params)
	if(!I || !user)
		return

	if(istype(I, /obj/item/weapon/screwdriver))
		if(c_mode==0)
			c_mode=1
			playsound(loc, 'sound/items/Screwdriver.ogg', 50, 1)
			user << "<span class='notice'>You remove the screws around the power connection.</span>"
			return
		else if(c_mode==1)
			c_mode=0
			playsound(loc, 'sound/items/Screwdriver.ogg', 50, 1)
			user << "<span class='notice'>You attach the screws around the power connection.</span>"
			return
	else if(istype(I,/obj/item/weapon/weldingtool) && c_mode==1)
		var/obj/item/weapon/weldingtool/W = I

		if(W.remove_fuel(0,user))
			playsound(loc, 'sound/items/Welder2.ogg', 100, 1)
			user << "<span class='notice'>You start slicing the floorweld off the delivery chute...</span>"
			if(do_after(user,20, target = src))
				if(!src || !W.isOn()) return
				Deconstruct()
				user << "<span class='notice'>You slice the floorweld off the delivery chute.</span>"
			return
		else
			return

/obj/machinery/disposal/deliveryChute/process()
	return PROCESS_KILL

/obj/item/weapon/c_tube
	name = "cardboard tube"
	desc = "A tube... of cardboard."
	icon = 'icons/obj/items.dmi'
	icon_state = "c_tube"
	throwforce = 0
	w_class = 1.0
	throw_speed = 3
	throw_range = 5