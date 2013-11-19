/obj/structure/bigDelivery
	name = "large parcel"
	desc = "A big wrapped package."
	icon = 'icons/obj/storage.dmi'
	icon_state = "deliverycloset"
	density = 1
	flags = FPRINT
	mouse_drag_pointer = MOUSE_ACTIVE_POINTER
	var/obj/wrapped = null
	var/sortTag = 0


/obj/structure/bigDelivery/attack_hand(mob/user as mob)
	del(src)

/obj/structure/bigDelivery/Del()
	if(wrapped) //sometimes items can disappear. For example, bombs. --rastaf0
		wrapped.loc = (get_turf(loc))
		if(istype(wrapped, /obj/structure/closet))
			var/obj/structure/closet/O = wrapped
			O.welded = 0
	var/turf/T = get_turf(src)
	for(var/atom/movable/AM in contents)
		AM.loc = T
	..()

/obj/structure/bigDelivery/attackby(obj/item/W as obj, mob/user as mob)
	if(istype(W, /obj/item/device/destTagger))
		var/obj/item/device/destTagger/O = W

		if(sortTag != O.currTag)
			var/tag = uppertext(TAGGERLOCATIONS[O.currTag])
			user << "\blue *[tag]*"
			sortTag = O.currTag
			playsound(loc, 'sound/machines/twobeep.ogg', 100, 1)

	else if(istype(W, /obj/item/weapon/pen))
		var/str = copytext(sanitize(input(user,"Label text?","Set label","")),1,MAX_NAME_LEN)
		if(!str || !length(str))
			user << "<span class='notice'>Invalid text.</span>"
			return
		user.visible_message("<span class='notice'>[user] labels [src] as [str].</span>")
		name = "[name] ([str])"

	else if(istype(W, /obj/item/weapon/wrapping_paper))
		user.visible_message("<span class='notice'>[user] wraps the package in festive paper!</span>")
		if(istype(wrapped, /obj/structure/closet/crate))
			icon_state = "giftcrate"
		else
			icon_state = "giftcloset"


/obj/item/smallDelivery
	name = "small parcel"
	desc = "A small wrapped package."
	icon = 'icons/obj/storage.dmi'
	icon_state = "deliverycrateSmall"
	flags = FPRINT
	var/obj/item/wrapped = null
	var/sortTag = 0


	attack_self(mob/user as mob)
		if(wrapped) //sometimes items can disappear. For example, bombs. --rastaf0
			wrapped.loc = user.loc
			if(ishuman(user))
				user.put_in_hands(wrapped)
			else
				wrapped.loc = get_turf(src)

		del(src)


	attackby(obj/item/W as obj, mob/user as mob)
		if(istype(W, /obj/item/device/destTagger))
			var/obj/item/device/destTagger/O = W

			if(sortTag != O.currTag)
				var/tag = uppertext(TAGGERLOCATIONS[O.currTag])
				user << "\blue *[tag]*"
				sortTag = O.currTag
				playsound(loc, 'sound/machines/twobeep.ogg', 100, 1)

		else if(istype(W, /obj/item/weapon/pen))
			var/str = copytext(sanitize(input(user,"Label text?","Set label","")),1,MAX_NAME_LEN)
			if(!str || !length(str))
				user << "<span class='notice'>Invalid text.</span>"
				return
			user.visible_message("<span class='notice'>[user] labels [src] as [str].</span>")
			name = "[name] ([str])"

		else if(istype(W, /obj/item/weapon/wrapping_paper))
			icon_state = "giftcrate[wrapped.w_class]"
			user.visible_message("<span class='notice'>[user] wraps the package in festive paper!</span>")


/obj/item/weapon/packageWrap
	name = "package wrapper"
	icon = 'icons/obj/items.dmi'
	icon_state = "deliveryPaper"
	flags = FPRINT | NOBLUDGEON
	w_class = 3.0
	var/amount = 25.0


	afterattack(var/obj/target as obj, mob/user as mob, proximity)
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

		user.attack_log += text("\[[time_stamp()]\] <font color='blue'>Has used [name] on \ref[target]</font>")


		if(istype(target, /obj/item) && !(istype(target, /obj/item/weapon/storage) && !istype(target,/obj/item/weapon/storage/box)))
			var/obj/item/O = target
			if(amount > 1)
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
				amount -= 1
		else if(istype(target, /obj/structure/closet/crate))
			var/obj/structure/closet/crate/O = target
			if(amount > 3 && !O.opened)
				var/obj/structure/bigDelivery/P = new /obj/structure/bigDelivery(get_turf(O.loc))
				P.icon_state = "deliverycrate"
				P.wrapped = O
				O.loc = P
				amount -= 3
			else if(amount < 3)
				user << "<span class='notice'>You need more paper.</span>"
		else if(istype (target, /obj/structure/closet))
			var/obj/structure/closet/O = target
			if(amount > 3 && !O.opened)
				var/obj/structure/bigDelivery/P = new /obj/structure/bigDelivery(get_turf(O.loc))
				P.wrapped = O
				O.welded = 1
				O.loc = P
				amount -= 3
			else if(amount < 3)
				user << "<span class='notice'>You need more paper.</span>"
		else
			user << "<span class='notice'>The object you are trying to wrap is unsuitable for the sorting machinery.</span>"
		if(amount <= 0)
			new /obj/item/weapon/c_tube( loc )
			del(src)
			return
		return


	examine()
		if(src in usr)
			usr << "<span class='notice'>There are [amount] units of package wrap left.</span>"
		..()
		return


/obj/item/device/destTagger
	name = "destination tagger"
	desc = "Used to set the destination of properly wrapped packages."
	icon_state = "forensic0"
	var/currTag = 0
	//The whole system for the sorttype var is determined based on the order of this list,
	//disposals must always be 1, since anything that's untagged will automatically go to disposals, or sorttype = 1 --Superxpdude

	//If you don't want to fuck up disposals, add to this list, and don't change the order.
	//If you insist on changing the order, you'll have to change every sort junction to reflect the new order. --Pete

	w_class = 1
	item_state = "electronic"
	flags = FPRINT | TABLEPASS | CONDUCT
	slot_flags = SLOT_BELT

	proc/openwindow(mob/user as mob)
		var/dat = "<tt><center><h1><b>TagMaster 2.2</b></h1></center>"

		dat += "<table style='width:100%; padding:4px;'><tr>"
		for (var/i = 1, i <= TAGGERLOCATIONS.len, i++)
			dat += "<td><a href='?src=\ref[src];nextTag=[i]'>[TAGGERLOCATIONS[i]]</a></td>"

			if(i%4==0)
				dat += "</tr><tr>"

		dat += "</tr></table><br>Current Selection: [currTag ? TAGGERLOCATIONS[currTag] : "None"]</tt>"

		user << browse(dat, "window=destTagScreen;size=450x350")
		onclose(user, "destTagScreen")

	attack_self(mob/user as mob)
		openwindow(user)
		return

	Topic(href, href_list)
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

	New()
		..()
		spawn(5)
			trunk = locate() in loc
			if(trunk)
				trunk.linked = src	// link the pipe trunk to self

	interact()
		return

	update()
		return

	Bumped(var/atom/movable/AM) //Go straight into the chute
		if(istype(AM, /obj/item/projectile))	return
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

	flush()
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

		air_contents = new()		// new empty gas resv.

		sleep(10)
		if((start_flush + 15) < world.time)
			start_flush = world.time
			playsound(src, 'sound/machines/disposalflush.ogg', 50, 0, 0)
		sleep(5) // wait for animation to finish

		H.init(src)	// copy the contents of disposer to holder

		H.start(src) // start the holder processing movement
		flushing = 0
		// now reset disposal state
		flush = 0
		if(mode == 2)	// if was ready,
			mode = 1	// switch to charging
		update()
		return

	attackby(var/obj/item/I, var/mob/user)
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
				user << "<span class='notice'>You start slicing the floorweld off the delivery chute.</span>"
				if(do_after(user,20))
					if(!src || !W.isOn()) return
					user << "<span class='notice'>You sliced the floorweld off the delivery chute.</span>"
					var/obj/structure/disposalconstruct/C = new (loc)
					C.ptype = 8 // 8 =  Delivery chute
					C.update()
					C.anchored = 1
					C.density = 1
					del(src)
				return
			else
				user << "<span class='notice'>You need more welding fuel to complete this task.</span>"
				return
