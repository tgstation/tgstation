/obj/structure/bigDelivery
	desc = "A big wrapped package."
	name = "large parcel"
	icon = 'icons/obj/storage.dmi'
	icon_state = "deliverycloset"
	var/obj/wrapped = null
	density = 1
	var/sortTag = 0
	flags = FPRINT
	mouse_drag_pointer = MOUSE_ACTIVE_POINTER

	attack_hand(mob/user as mob)
		if(wrapped) //sometimes items can disappear. For example, bombs. --rastaf0
			wrapped.loc = (get_turf(src.loc))
			if(istype(wrapped, /obj/structure/closet))
				var/obj/structure/closet/O = wrapped
				O.welded = 0
		del(src)
		return

	attackby(obj/item/W as obj, mob/user as mob)
		if(istype(W, /obj/item/device/destTagger))
			var/obj/item/device/destTagger/O = W
			user << "\blue *TAGGED*"
			src.sortTag = O.currTag
		else if(istype(W, /obj/item/weapon/pen))
			var/str = copytext(sanitize(input(usr,"Label text?","Set label","")),1,MAX_NAME_LEN)
			if(!str || !length(str))
				usr << "\red Invalid text."
				return
			for(var/mob/M in viewers())
				M << "\blue [user] labels [src] as [str]."
			src.name = "[src.name] ([str])"
		return

/obj/item/smallDelivery
	desc = "A small wrapped package."
	name = "small parcel"
	icon = 'icons/obj/storage.dmi'
	icon_state = "deliverycrateSmall"
	var/obj/item/wrapped = null
	var/sortTag = 0
	flags = FPRINT


	attack_self(mob/user as mob)
		if (src.wrapped) //sometimes items can disappear. For example, bombs. --rastaf0
			wrapped.loc = user.loc
			if(ishuman(user))
				user.put_in_hands(wrapped)
			else
				wrapped.loc = get_turf_loc(src)

		del(src)
		return

	attackby(obj/item/W as obj, mob/user as mob)
		if(istype(W, /obj/item/device/destTagger))
			var/obj/item/device/destTagger/O = W
			user << "\blue *TAGGED*"
			src.sortTag = O.currTag
		else if(istype(W, /obj/item/weapon/pen))
			var/str = copytext(sanitize(input(usr,"Label text?","Set label","")),1,MAX_NAME_LEN)
			if(!str || !length(str))
				usr << "\red Invalid text."
				return
			for(var/mob/M in viewers())
				M << "\blue [user] labels [src] as [str]."
			src.name = "[src.name] ([str])"
		return


/obj/item/weapon/packageWrap
	name = "package wrapper"
	icon = 'icons/obj/items.dmi'
	icon_state = "deliveryPaper"
	w_class = 3.0
	var/amount = 25.0


	afterattack(var/obj/target as obj, mob/user as mob)
		if(!(istype(target, /obj)))	//this really shouldn't be necessary (but it is).	-Pete
			return
		if(istype(target, /obj/structure/table) || istype(target, /obj/structure/rack) \
		|| istype(target, /obj/item/smallDelivery) || istype(target,/obj/structure/bigDelivery) \
		|| istype(target, /obj/item/weapon/gift))
			return
		if(target.anchored)
			return
		if(target in user)
			return

		user.attack_log += text("\[[time_stamp()]\] <font color='blue'>Has used [src.name] on \ref[target]</font>")

		if (istype(target, /obj/item) && !(istype(target, /obj/item/weapon/storage)))
			var/obj/item/O = target
			if (src.amount > 1)
				var/obj/item/smallDelivery/P = new /obj/item/smallDelivery(get_turf(O.loc))	//Aaannd wrap it up!
				if(!istype(O.loc, /turf))
					if(user.client)
						user.client.screen -= O
				P.wrapped = O
				O.loc = P
				P.add_fingerprint(usr)
				O.add_fingerprint(usr)
				src.add_fingerprint(usr)
				src.amount -= 1
		else if (istype(target, /obj/structure/closet/crate))
			var/obj/structure/closet/crate/O = target
			if (src.amount > 3 && !O.opened)
				var/obj/structure/bigDelivery/P = new /obj/structure/bigDelivery(get_turf(O.loc))
				P.icon_state = "deliverycrate"
				P.wrapped = O
				O.loc = P
				src.amount -= 3
			else if(src.amount < 3)
				user << "\blue You need more paper."
		else if (istype (target, /obj/structure/closet))
			var/obj/structure/closet/O = target
			if (src.amount > 3 && !O.opened)
				var/obj/structure/bigDelivery/P = new /obj/structure/bigDelivery(get_turf(O.loc))
				P.wrapped = O
				O.welded = 1
				O.loc = P
				src.amount -= 3
			else if(src.amount < 3)
				user << "\blue You need more paper."
		else
			user << "\blue The object you are trying to wrap is unsuitable for the sorting machinery!"
		if (src.amount <= 0)
			new /obj/item/weapon/c_tube( src.loc )
			del(src)
			return
		return

	examine()
		if(src in usr)
			usr << "\blue There are [amount] units of package wrap left!"
		..()
		return


/obj/item/device/destTagger
	name = "destination tagger"
	desc = "Used to set the destination of properly wrapped packages."
	icon_state = "forensic0"
	var/currTag = 0
	var/list/locationList = list("Disposals",
	"Cargo Bay", "QM Office", "Engineering", "CE Office",
	"Atmospherics", "Security", "HoS Office", "Medbay",
	"CMO Office", "Chemistry", "Research", "RD Office",
	"Robotics", "HoP Office", "Library", "Chapel", "Theatre",
	"Bar", "Kitchen", "Hydroponics", "Janitor Closet","Genetics")
	//The whole system for the sorttype var is determined based on the order of this list,
	//disposals must always be 1, since anything that's untagged will automatically go to disposals, or sorttype = 1 --Superxpdude

	//If you don't want to fuck up disposals, add to this list, and don't change the order.
	//If you insist on changing the order, you'll have to change every sort junction to reflect the new order. --Pete

	w_class = 1
	item_state = "electronic"
	flags = FPRINT | TABLEPASS | CONDUCT
	slot_flags = SLOT_BELT

	attack_self(mob/user as mob)
		var/dat = "<TT><B>TagMaster 2.2</B><BR><BR>"
		if (src.currTag == 0)
			dat += "<br>Current Selection: None<br>"
		else
			dat += "<br>Current Selection: [locationList[currTag]]<br><br>"
		for (var/i = 1, i <= locationList.len, i++)
			dat += "<A href='?src=\ref[src];nextTag=[i]'>[locationList[i]]</A>"
			if (i%4==0)
				dat += "<br>"
			else
				dat += "	"
		user << browse(dat, "window=destTagScreen")
		onclose(user, "destTagScreen")
		return

	Topic(href, href_list)
		src.add_fingerprint(usr)
		if(href_list["nextTag"])
			var/n = text2num(href_list["nextTag"])
			src.currTag = n
		src.updateUsrDialog()


/*
	attack(target as obj, mob/user as mob)
		user << "/blue *TAGGED*"
		target.sortTag = src.currTag

	attack(target as obj, mob/user as mob)
		user << "/blue You can only tag properly wrapped delivery packages!"
*/
	attack(target as obj, mob/user as mob)
		if (istype(target, /obj/structure/bigDelivery))
			user << "\blue *TAGGED*"
			var/obj/structure/bigDelivery/O = target
			O.sortTag = src.currTag
		else if (istype(target, /obj/item/smallDelivery))
			user << "\blue *TAGGED*"
			var/obj/item/smallDelivery/O = target
			O.sortTag = src.currTag
		else
			user << "\blue You can only tag properly wrapped delivery packages!"
		return

/obj/machinery/disposal/deliveryChute
	name = "Delivery chute"
	desc = "A chute for big and small packages alike!"
	density = 0
	icon_state = "intake"

	var/c_mode = 0

	New()
		..()
		spawn(5)
			trunk = locate() in src.loc
			if(trunk)
				trunk.linked = src	// link the pipe trunk to self

	interact()
		return

	update()
		return

	HasEntered(AM as mob|obj) //Go straight into the chute
		if(istype(AM, /obj/item/projectile) || istype(AM, /obj/item/weapon/dummy))	return

		if(istype(AM, /obj))
			var/obj/O = AM
			O.loc = src
		else if(istype(AM, /mob))
			var/mob/M = AM
			M.loc = src
		src.flush()

	flush()
		flushing = 1
		flick("intake-closing", src)
		var/deliveryCheck = 0
		var/obj/structure/disposalholder/H = new()	// virtual holder object which actually
													// travels through the pipes.
		for(var/obj/structure/bigDelivery/O in src)
			deliveryCheck = 1
			if(O.sortTag == 0)
				O.sortTag = 1
		for(var/obj/item/smallDelivery/O in src)
			deliveryCheck = 1
			if (O.sortTag == 0)
				O.sortTag = 1
		if(deliveryCheck == 0)
			H.destinationTag = 1


		H.init(src)	// copy the contents of disposer to holder

		air_contents = new()		// new empty gas resv.

		sleep(10)
		playsound(src, 'sound/machines/disposalflush.ogg', 50, 0, 0)
		sleep(5) // wait for animation to finish


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
				playsound(src.loc, 'sound/items/Screwdriver.ogg', 50, 1)
				user << "You remove the screws around the power connection."
				return
			else if(c_mode==1)
				c_mode=0
				playsound(src.loc, 'sound/items/Screwdriver.ogg', 50, 1)
				user << "You attach the screws around the power connection."
				return
		else if(istype(I,/obj/item/weapon/weldingtool) && c_mode==1)
			var/obj/item/weapon/weldingtool/W = I
			if(W.remove_fuel(0,user))
				playsound(src.loc, 'sound/items/Welder2.ogg', 100, 1)
				user << "You start slicing the floorweld off the delivery chute."
				if(do_after(user,20))
					if(!src || !W.isOn()) return
					user << "You sliced the floorweld off the delivery chute."
					var/obj/structure/disposalconstruct/C = new (src.loc)
					C.ptype = 8 // 8 =  Delivery chute
					C.update()
					C.anchored = 1
					C.density = 1
					del(src)
				return
			else
				user << "You need more welding fuel to complete this task."
				return
