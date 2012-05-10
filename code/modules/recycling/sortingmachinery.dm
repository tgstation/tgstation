/obj/structure/bigDelivery
	desc = "A big wrapped package."
	name = "large parcel"
	icon = 'storage.dmi'
	icon_state = "deliverycloset"
	var/tmp/obj/wrapped = null
	density = 1
	var/sortTag = null
	flags = FPRINT
	mouse_drag_pointer = MOUSE_ACTIVE_POINTER
	var/examtext = null
	var/label_x = 0
	var/tag_x = 0
	var/waswelded = 0


	attack_hand(mob/user as mob)
		return unwrap()

	proc/unwrap()
		if(wrapped) //sometimes items can disappear. For example, bombs. --rastaf0
			wrapped.loc = (get_turf(src.loc))
			if(istype(wrapped, /obj/structure/closet))
				var/obj/structure/closet/O = wrapped
				O.welded = waswelded
		del(src)
		return

	update_icon()
		overlays = new()
		if(name != initial(name) || examtext)
			var/image/I = new/image('storage.dmi',"delivery_label")
			if(!label_x)
				label_x = rand(-8, 6)
			I.pixel_x = label_x
			I.pixel_y = -3
			overlays += I
		if(sortTag)
			var/image/I = new/image('storage.dmi',"delivery_tag")
			if(!tag_x)
				tag_x = rand(-8, 6)
			I.pixel_x = tag_x
			I.pixel_y = -3
			overlays += I

	attackby(obj/item/W as obj, mob/user as mob)
		if(istype(W, /obj/item/device/destTagger))
			var/obj/item/device/destTagger/O = W
			user << "\blue *TAGGED*"
			src.sortTag = O.currTag
			update_icon()
		else if(istype(W, /obj/item/weapon/pen))
			switch(alert("What would you like to alter?",,"Title","Description", "Cancel"))
				if("Title")
					var/str = input(usr,"Label text?","Set label","")
					if(!str || !length(str))
						usr << "\red Invalid text."
						return
					if(length(str) > 64)
						usr << "\red Text too long."
						return
					var/label = str
					for(var/mob/M in viewers())
						M << "\blue [user] labels [src] as [label]."
					src.name = "[src.name] ([label])"
					update_icon()
				if("Description")
					var/str = input(usr,"Label text?","Set label","")
					if(!str || !length(str))
						usr << "\red Invalid text."
						return
					if(length(str) > 64)
						usr << "\red Text too long."
						return
					examtext = str
					for(var/mob/M in viewers())
						M << "\blue [user] labels [src] with the note: [examtext]."
					update_icon()
		return

	examine()
		if(src in oview(4))
			if(sortTag)
				usr << "\blue It is labeled \"[sortTag]\""
			if(examtext)
				usr << examtext
		..()
		return

	relaymove(mob/user as mob)
		for(var/obj/structure/closet/F in src)
			user.loc = F
			F.contents += user
			F.opened = 0
			break

/obj/item/smallDelivery
	desc = "A small wrapped package."
	name = "small parcel"
	icon = 'storage.dmi'
	icon_state = "deliverycrateSmall"
	var/tmp/obj/item/wrapped = null
	var/sortTag = null
	flags = FPRINT
	var/examtext = null


	attack_self(mob/user)
		if (src.wrapped) //sometimes items can disappear. For example, bombs. --rastaf0
			src.wrapped.loc = (get_turf(src.loc))

		del(src)
		return

	update_icon()
		overlays = new()
		if(name != initial(name) || examtext)
			overlays += new/image('storage.dmi',"delivery_label")
		if(sortTag)
			overlays += new/image('storage.dmi',"delivery_tag")

	attackby(obj/item/W as obj, mob/user as mob)
		if(istype(W, /obj/item/device/destTagger))
			var/obj/item/device/destTagger/O = W
			user << "\blue *TAGGED*"
			src.sortTag = O.currTag
			update_icon()
		else if(istype(W, /obj/item/weapon/pen))
			switch(alert("What would you like to alter?",,"Title","Description", "Cancel"))
				if("Title")
					var/str = input(usr,"Label text?","Set label","")
					if(!str || !length(str))
						usr << "\red Invalid text."
						return
					if(length(str) > 64)
						usr << "\red Text too long."
						return
					var/label = str
					for(var/mob/M in viewers())
						M << "\blue [user] labels [src] as [label]."
					src.name = "[src.name] ([label])"
					update_icon()
				if("Description")
					var/str = input(usr,"Label text?","Set label","")
					if(!str || !length(str))
						usr << "\red Invalid text."
						return
					if(length(str) > 64)
						usr << "\red Text too long."
						return
					examtext = str
					for(var/mob/M in viewers())
						M << "\blue [user] labels [src] with the note: [examtext]."
					update_icon()
		return

	examine()
		if(src in oview(4))
			if(sortTag)
				usr << "\blue It is labeled \"[sortTag]\""
			if(examtext)
				usr << examtext
		..()
		return

/obj/item/weapon/packageWrap
	name = "package wrapper"
	icon = 'items.dmi'
	icon_state = "deliveryPaper"
	w_class = 3.0
	var/amount = 25.0


	afterattack(var/obj/target as obj, mob/user as mob)
		if(!(istype(target, /obj)))	//this really shouldn't be necessary (but it is).	-Pete
			return
		if(istype(target, /obj/structure/table) || istype(target, /obj/structure/rack) || istype(target,/obj/item/smallDelivery))
			return
		if(target.anchored)
			return
		if(target in user)
			return

		user.attack_log += text("\[[time_stamp()]\] <font color='blue'>Has used [src.name] on \ref[target]</font>")

		if (istype(target, /obj/item))
			var/obj/item/O = target
			if (src.amount > 1)
				var/obj/item/smallDelivery/P = new /obj/item/smallDelivery(get_turf(O.loc))	//Aaannd wrap it up!
				if(!istype(O.loc, /turf))
					if(user.client)
						user.client.screen -= O
				P.wrapped = O
				O.loc = P
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
				P.waswelded = O.welded
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

/*/obj/item/proc/wrap(obj/item/I as obj, mob/user as mob)
	if(istype(I, /obj/item/weapon/packageWrap))
		var/obj/item/weapon/packageWrap/C = I
		if(anchored)
			return
		else if (C.amount > 1)
			var/obj/item/smallDelivery/P = new /obj/item/smallDelivery(get_turf(src.loc))
			P.wrapped = src
			src.loc = P
			C.amount -= 1
		if (C.amount <= 0)
			new /obj/item/weapon/c_tube( C.loc )
			del(C)
			return*/

/obj/item/device/destTagger
	name = "destination tagger"
	desc = "Used to set the destination of properly wrapped packages."
	icon_state = "forensic0"
	var/currTag = null
	var/list/spaceList = list(0,1,0,0,0,1,0,0,0,1,0,0,0,1,0,0,1,0,0,0,1,0,0,0,0,1,0,0,0,1,0,0,1,0,0,0) // Breaks up departments with whitespace.
	var/list/locationList = list("Disposals",
	"Mail Office", "Cargo Bay", "QM Office","Mining Bay",
	"Locker Room", "Tool Storage", "Laundry Room", "Toilets",
	"Security", "Courtroom", "Detective's Office", "Law Office",
	"Research Division", "Research Director", "Genetics",
	"Medbay", "CMO", "Chemistry", "Morgue",
	"Library", "Chapel", "Chapel Office", "Theater", "Janitor",
	"Bar", "Kitchen", "Diner", "Hydroponics",
	"Meeting Room", "HoP Office", "Captain",
	"Atmospherics", "Engineering", "Chief Engineer", "Robotics",)

	mining
		locationList = list("Mining Main","Mining North","Mining West")
		spaceList = list(0,0,0)

	w_class = 1
	item_state = "electronic"
	flags = FPRINT | TABLEPASS | ONBELT | CONDUCT

	attack_self(mob/user as mob)
		interact(user)

	proc/interact(mob/user as mob)
		var/dat = "<TT><B>TagMaster 2.2</B><BR><BR>"
		if (!currTag)
			dat += "<br>Current Selection: None<br>"
		else
			dat += "<br>Current Selection: [currTag]<br><br>"
		dat += "<A href='?src=\ref[src];nextTag=[locationList.len + 1]'>Set Custom Destination</A><br><br>"
		for (var/i = 1, i <= locationList.len, i++)
			if(spaceList[i])
				dat += "<br>"
			dat += "<A href='?src=\ref[src];nextTag=[i]'>[locationList[i]]</A>"
			dat += "<br>"
		user << browse(dat, "window=destTagScreen")
		onclose(user, "destTagScreen")
		return

	Topic(href, href_list)
		usr.machine = src
		src.add_fingerprint(usr)
		if(href_list["nextTag"])
			var/n = text2num(href_list["nextTag"])
			if(n > locationList.len)
				var/t1 = input("Which tag?","Tag") as null|text
				if(t1)
					src.currTag = t1
			else
				src.currTag = locationList[n]
		if(istype(loc,/mob))
			interact(loc)
		else
			updateDialog()
			return

	attack(target as obj, mob/user as mob)
		if (istype(target, /obj/structure/bigDelivery))
			user << "\blue *TAGGED*"
			var/obj/structure/bigDelivery/O = target
			O.sortTag = src.currTag
			O.update_icon()
		else if (istype(target, /obj/item/smallDelivery))
			user << "\blue *TAGGED*"
			var/obj/item/smallDelivery/O = target
			O.sortTag = src.currTag
			O.update_icon()
		else
			user << "\blue You can only tag properly wrapped delivery packages!"
		return

/obj/machinery/disposal/deliveryChute
	name = "Delivery chute"
	desc = "A chute for big and small packages alike!"
	density = 0
	icon_state = "intake"
	var/currentlyFlushing = 0

	interact()
		return

	HasEntered(AM as mob|obj) //Go straight into the chute
		if (istype(AM, /obj))
			var/obj/O = AM
			O.loc = src
		else if (istype(AM, /mob))
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
			if(!O.sortTag)
				O.sortTag = "Disposals"
		for(var/obj/item/smallDelivery/O in src)
			deliveryCheck = 1
			if (!O.sortTag)
				O.sortTag = "Disposals"
		if(deliveryCheck == 0)
			H.destinationTag = "Disposals"


		H.init(src)	// copy the contents of disposer to holder

		air_contents = new()		// new empty gas resv.

		sleep(10)	// Prevent sound spam when several objects are flushed simultaneously.
		if(!currentlyFlushing)
			currentlyFlushing = 1
			playsound(src, 'disposalflush.ogg', 50, 0, 0)
			spawn(17)	// Sound file is ~3 seconds long, adjust this if it becomes longer/shorter.
				currentlyFlushing = 0

		sleep(5) // wait for animation to finish


		H.start(src) // start the holder processing movement
		flushing = 0
		// now reset disposal state
		flush = 0
		if(mode == 2)	// if was ready,
			mode = 1	// switch to charging
		update()
		return

	CanPass(atom/A, turf/T)
		if(istype(A, /mob/living)) // You Shall Not Pass!
			var/mob/living/M = A
			HasEntered(M)
			return 0
		if(istype(A, /obj)) // You Shall Not Pass!
			var/obj/M = A
			HasEntered(M)
			return 1
		return 1
