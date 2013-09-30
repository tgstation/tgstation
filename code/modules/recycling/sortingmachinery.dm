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

			if(src.sortTag != O.currTag)
				var/tag = uppertext(TAGGERLOCATIONS[O.currTag])
				user << "\blue *[tag]*"
				src.sortTag = O.currTag
				playsound(src.loc, 'sound/machines/twobeep.ogg', 100, 1)

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

			if(src.sortTag != O.currTag)
				var/tag = uppertext(TAGGERLOCATIONS[O.currTag])
				user << "\blue *[tag]*"
				src.sortTag = O.currTag
				playsound(src.loc, 'sound/machines/twobeep.ogg', 100, 1)

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
		if(!istype(target))	//this really shouldn't be necessary (but it is).	-Pete
			return
		if(istype(target, /obj/structure/table) || istype(target, /obj/structure/rack) \
		|| istype(target, /obj/item/smallDelivery) || istype(target,/obj/structure/bigDelivery) \
		|| istype(target, /obj/item/weapon/gift) || istype(target, /obj/item/weapon/evidencebag))
			return
		if(target.anchored)
			return
		if(target in user)
			return

		user.attack_log += text("\[[time_stamp()]\] <font color='blue'>Has used [src.name] on \ref[target]</font>")


		if (istype(target, /obj/item) && !(istype(target, /obj/item/weapon/storage) && !istype(target,/obj/item/weapon/storage/box)))
			var/obj/item/O = target
			if (src.amount > 1)
				var/obj/item/smallDelivery/P = new /obj/item/smallDelivery(get_turf(O.loc))	//Aaannd wrap it up!
				if(!istype(O.loc, /turf))
					if(user.client)
						user.client.screen -= O
				P.wrapped = O
				O.loc = P
				var/i = round(O.w_class)
				if(i in list(1,2,3,4,5))
					P.icon_state = "deliverycrate[i]"
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
	//The whole system for the sorttype var is determined based on the order of this list,
	//disposals must always be 1, since anything that's untagged will automatically go to disposals, or sorttype = 1 --Superxpdude

	//If you don't want to fuck up disposals, add to this list, and don't change the order.
	//If you insist on changing the order, you'll have to change every sort junction to reflect the new order. --Pete

	w_class = 1
	item_state = "electronic"
	flags = FPRINT | TABLEPASS | CONDUCT
	slot_flags = SLOT_BELT

	proc/openwindow(mob/user as mob)

		// AUTOFIXED BY fix_string_idiocy.py
		// C:\Users\Rob\Documents\Projects\vgstation13\code\modules\recycling\sortingmachinery.dm:174: var/dat = "<tt><center><h1><b>TagMaster 2.2</b></h1></center>"
		var/dat = {"<tt><center><h1><b>TagMaster 2.2</b></h1></center>
<table style='width:100%; padding:4px;'><tr>"}
		// END AUTOFIX
		for (var/i = 1, i <= TAGGERLOCATIONS.len, i++)
			dat += "<td><a href='?src=\ref[src];nextTag=[i]'>[TAGGERLOCATIONS[i]]</a></td>"

			if (i%4==0)
				dat += "</tr><tr>"

		dat += "</tr></table><br>Current Selection: [currTag ? TAGGERLOCATIONS[currTag] : "None"]</tt>"

		user << browse(dat, "window=destTagScreen;size=450x350")
		onclose(user, "destTagScreen")

	attack_self(mob/user as mob)
		openwindow(user)
		return

	Topic(href, href_list)
		src.add_fingerprint(usr)
		if(href_list["nextTag"])
			var/n = text2num(href_list["nextTag"])
			src.currTag = n
		openwindow(usr)

/obj/machinery/disposal/deliveryChute
	name = "Delivery chute"
	desc = "A chute for big and small packages alike!"
	density = 1
	icon_state = "intake"
	var/c_mode = 0
	var/doFlushIn=0
	var/num_contents=0

	New()
		..()
		processing_objects.Remove(src)
		spawn(5)
			trunk = locate() in src.loc
			if(trunk)
				trunk.linked = src	// link the pipe trunk to self

	interact()
		return

	update()
		return

	Bumped(var/atom/movable/AM) //Go straight into the chute
		if(istype(AM, /obj/item/projectile) || istype(AM, /obj/item/weapon/dummy))	return
		switch(dir)
			if(NORTH)
				if(AM.loc.y != src.loc.y+1) return
			if(EAST)
				if(AM.loc.x != src.loc.x+1) return
			if(SOUTH)
				if(AM.loc.y != src.loc.y-1) return
			if(WEST)
				if(AM.loc.x != src.loc.x-1) return

		//testing("[src] FUCKING BUMPED BY \a [AM]")

		if(istype(AM, /obj))
			var/obj/O = AM
			O.loc = src
		else if(istype(AM, /mob))
			var/mob/M = AM
			M.loc = src
		//src.flush() This spams audio like fucking crazy.
		// Instead, we queue up for the next process.
		if(!(src in processing_objects))
			processing_objects.Add(src)
		doFlushIn=5 // Ticks, adjust if delay is too long or too short
		num_contents++

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

		air_contents = new()		// new empty gas resv.

		sleep(10)
		playsound(src, 'sound/machines/disposalflush.ogg', 50, 0, 0)
		sleep(5) // wait for animation to finish

		H.init(src)	// copy the contents of disposer to holder
		num_contents=0
		doFlushIn=0

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

	process()
		if(doFlushIn>0)
			if(doFlushIn==1 || num_contents>=50)
				//testing("[src] FLUSHING")
				src.flush()
			doFlushIn--


/obj/machinery/sorting_machine
	name = "Sorting Machine"
	desc = "Sorts stuff."
	density = 1
	icon = 'icons/obj/recycling.dmi'
	icon_state = "grinder-b1"
	anchored=1

	var/select_txt
	var/list/selection=list()
	var/list/selected_types=list()
	var/list/types=list(
		"Carcasses" = list(
			/mob/living/carbon,
			/mob/living/simple_animal
		),
		"Glasses" = list(
			/obj/item/weapon/shard,
			/obj/item/stack/sheet/glass,
			/obj/item/stack/sheet/rglass,
			/obj/item/stack/tile/light,
			/obj/item/weapon/broken_bottle,
			/obj/item/weapon/reagent_containers/glass/bucket,
			/obj/item/weapon/reagent_containers/glass/bottle,
			/obj/item/weapon/reagent_containers/syringe,
			/obj/item/weapon/reagent_containers/food/drinks/bottle,
			/obj/item/weapon/reagent_containers/food/drinks/drinkingglass,
			/obj/item/weapon/reagent_containers/food/drinks/jar,
			/obj/item/clothing/head/welding,
			/obj/item/weapon/stock_parts/console_screen,
			/obj/item/weapon/light/tube,
			/obj/item/weapon/light/bulb,
		),
		"Electronics" = list(
			/obj/item/weapon/circuitboard,
			/obj/item/weapon/aiModule,
			/obj/item/device/flashlight,
			/obj/item/device/multitool,
			/obj/item/device/t_scanner,
			/obj/item/weapon/airlock_electronics,
			/obj/item/weapon/airalarm_electronics,
			/obj/item/weapon/firealarm_electronics,
			/obj/item/device/taperecorder,
			/obj/item/device/assembly/igniter,
			/obj/item/device/assembly/signaler,
			/obj/item/device/radio/headset,
			/obj/item/device/radio,
			/obj/item/device/assembly/infra,
			/obj/item/device/assembly/timer,
			/obj/item/weapon/camera_assembly
		),
		"Metals/Minerals" = list(
			/obj/item/stack/rods,
			/obj/item/stack/sheet/plasteel,
			/obj/item/stack/sheet/metal,
			/obj/item/stack/sheet/metal/cyborg,
			/obj/item/stack/sheet/mineral,
			/obj/item/apc_frame,
			/obj/item/alarm_frame,
			/obj/item/firealarm_frame,
			/obj/item/weapon/table_parts,
			/obj/item/weapon/table_parts/reinforced,
			/obj/item/weapon/rack_parts,
			/obj/item/weapon/crowbar,
			/obj/item/weapon/extinguisher,
			/obj/item/weapon/weldingtool,
			/obj/item/weapon/screwdriver,
			/obj/item/weapon/wirecutters,
			/obj/item/weapon/wrench,
			/obj/item/weapon/rcd_ammo,
			/obj/item/weapon/kitchenknife,
			/obj/item/weapon/scalpel,
			/obj/item/weapon/circular_saw,
			/obj/item/weapon/surgicaldrill,
			/obj/item/weapon/retractor,
			/obj/item/weapon/cautery,
			/obj/item/ammo_casing/shotgun/blank,
			/obj/item/ammo_casing/shotgun/beanbag,
			/obj/item/ammo_magazine/c38,
			/obj/structure/closet, // 2 sheets
			/obj/machinery/portable_atmospherics/canister, //10 sheets
			/obj/item/stack/tile/plasteel, //1/4 of a sheet
			/obj/item/weapon/grenade/chem_grenade,
			/obj/item/borg/upgrade,
			/obj/item/robot_parts,
			/obj/item/weapon/ore
		)
	)

	var/obj/machinery/mineral/input = null
	var/obj/machinery/mineral/output = null
	var/obj/machinery/mineral/selected_output = null

/obj/machinery/sorting_machine/New()
	..()
	spawn( 5 )
		var i = 0;
		for (var/dir in cardinal)
			var/turf/T=get_step(src, dir)
			if(!input)
				src.input = locate(/obj/machinery/mineral/input, T)
				i++
			if(!output)
				src.output = locate(/obj/machinery/mineral/output, T)
				i++
			if(!selected_output)
				src.selected_output = locate(/obj/machinery/mineral/selected_output, T)
				i++
			if(src.output && src.input && src.selected_output)
				break
		if(i<3)
			diary << "\a [src] couldn't find an input or output plate."
		if(select_txt)
			for(var/n in text2list(select_txt," "))
				selected_types += n
				selection += types[n]
	return



/obj/machinery/sorting_machine/process()
	if(stat & (BROKEN | NOPOWER))
		return
	use_power(100)

	var/affecting = input.loc.contents		// moved items will be all in loc
	spawn(1)	// slight delay to prevent infinite propagation due to map order	//TODO: please no spawn() in process(). It's a very bad idea
		var/items_moved = 0
		for(var/atom/movable/A in affecting)
			if(!A.anchored)
				if(A.loc == input.loc) // prevents the object from being affected if it's not currently here.
					var/found=0
					for(var/t in selection)
						if(istype(A,t))
							A.loc=selected_output.loc
							found=1
							break
					if(!found)
						A.loc=output.loc
					items_moved++
			if(items_moved >= 10)
				break

/obj/machinery/sorting_machine/proc/openwindow(mob/user as mob)
	var/dat = {"
		<html>
			<head>
				<style type="text/css">
html,body {
	font-family:sans-serif,verdana;
	font-size:smaller;
	color:#666;
}
h1 {
	border-bottom:1px solid maroon;
}
table {
	width:100%;
	padding:4px;
}
				</style>
			</head>
			<body>
				<h1>SortMaster 5000</h1><br>
				<p>Select the desired items to sort from the line.</p>"}
	dat += "<ul>"
	for (var/n in types)
		dat += "<li>"
		var/selected = (n in selected_types)
		if(selected)
			dat+="<b>"
		dat+="<a href='?src=\ref[src];set_types=[n]'>[n]</a>"
		if(selected)
			dat+="</b>"
		dat+="</li>"

	dat += "</ul></body></html>"

	user << browse(dat, "window=destTagScreen;size=450x350")
	onclose(user, "destTagScreen")

/obj/machinery/sorting_machine/attack_hand(mob/user as mob)
	openwindow(user)
	return

/obj/machinery/sorting_machine/proc/toggleCategory(var/n)
	if(n in selected_types)
		selected_types -= n
		selection -= types[n]
	else
		selected_types += n
		selection += types[n]

/obj/machinery/sorting_machine/Topic(href, href_list)
	src.add_fingerprint(usr)
	if(href_list["set_types"])
		var/n = href_list["set_types"]
		toggleCategory(n)
	openwindow(usr)