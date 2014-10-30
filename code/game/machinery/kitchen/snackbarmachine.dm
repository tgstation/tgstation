/obj/machinery/snackbar_machine
	name = "SnackBar Machine"
	density = 1
	anchored = 1
	icon = 'icons/obj/chemical.dmi'
	icon_state = "mixer0"
	use_power = 1
	idle_power_usage = 20
	var/obj/item/weapon/reagent_containers/glass/beaker = null
	var/mode = 0
	var/opened = 0
	var/useramount = 30 // Last used amount

	machine_flags = SCREWTOGGLE | CROWDESTROY

	l_color = "#7BF9FF"
	power_change()
		..()
		if(!(stat & (BROKEN|NOPOWER)))
			SetLuminosity(2)
		else
			SetLuminosity(0)

/********************************************************************
**   Adding Stock Parts to VV so preconstructed shit has its candy **
********************************************************************/
/obj/machinery/snackbar_machine/New()
	. = ..()
	create_reagents(100)

	component_parts = newlist(\
		/obj/item/weapon/circuitboard/snackbar_machine,\
		/obj/item/weapon/stock_parts/manipulator,\
		/obj/item/weapon/stock_parts/manipulator,\
		/obj/item/weapon/stock_parts/scanning_module,\
		/obj/item/weapon/stock_parts/scanning_module,\
		/obj/item/weapon/stock_parts/micro_laser,\
		/obj/item/weapon/stock_parts/micro_laser,\
		/obj/item/weapon/stock_parts/console_screen,\
		/obj/item/weapon/stock_parts/console_screen\
	)

	RefreshParts()

	overlays += image('icons/obj/chemical.dmi', src, "[icon_state]_overlay")

/obj/machinery/snackbar_machine/ex_act(severity)
	switch(severity)
		if(1.0)
			qdel(src)
			return
		if(2.0)
			if (prob(50))
				qdel(src)
				return

/obj/machinery/snackbar_machine/blob_act()
	if (prob(50))
		qdel(src)

/obj/machinery/snackbar_machine/meteorhit()
	qdel(src)
	return

/obj/machinery/snackbar_machine/power_change()
	if(powered())
		stat &= ~NOPOWER
	else
		spawn(rand(0, 15))
			stat |= NOPOWER

/obj/machinery/snackbar_machine/attackby(var/obj/item/weapon/B as obj, var/mob/user as mob)

	if(istype(B, /obj/item/weapon/reagent_containers/glass))
		if(src.beaker)
			user << "A beaker is already loaded into the machine."
			return
		src.beaker = B
		user.drop_item()
		B.loc = src
		user << "You add the beaker to the machine!"
		src.updateUsrDialog()
		update_icon()

	else
		..()

/obj/machinery/snackbar_machine/Topic(href, href_list)
	if(stat & (BROKEN|NOPOWER)) 		return
	if(usr.stat || usr.restrained())	return
	if(!in_range(src, usr)) 			return

	src.add_fingerprint(usr)
	usr.set_machine(src)

	if(href_list["close"])
		usr << browse(null, "window=snackbar_machine")
		usr.unset_machine()
		return

	if(beaker)
		var/datum/reagents/R = beaker.reagents
		if (href_list["analyze"])
			var/dat = ""
			dat += "<TITLE>SnackBar Machine</TITLE>Reagent info:<BR><BR>Name:<BR>[href_list["name"]]<BR><BR>Description:<BR>[href_list["desc"]]<BR><BR><BR><A href='?src=\ref[src];main=1'>(Back)</A>"
			usr << browse(dat, "window=snackbar_machine;size=575x400")
			return

		else if (href_list["add"])

			if(href_list["amount"])
				var/id = href_list["add"]
				var/amount = text2num(href_list["amount"])
				if (amount < 0) return
				R.trans_id_to(src, id, amount)

		else if (href_list["addcustom"])

			var/id = href_list["addcustom"]
			useramount = input("Select the amount to transfer.", 30, useramount) as num
			useramount = isgoodnumber(useramount)
			src.Topic(null, list("amount" = "[useramount]", "add" = "[id]"))

		else if (href_list["remove"])

			if(href_list["amount"])
				var/id = href_list["remove"]
				var/amount = text2num(href_list["amount"])
				if (amount < 0) return
				if(mode)
					reagents.trans_id_to(beaker, id, amount)
				else
					reagents.remove_reagent(id, amount)

		else if (href_list["removecustom"])

			var/id = href_list["removecustom"]
			useramount = input("Select the amount to transfer.", 30, useramount) as num
			useramount = isgoodnumber(useramount)
			src.Topic(null, list("amount" = "[useramount]", "remove" = "[id]"))

		else if (href_list["toggle"])
			mode = !mode

		else if (href_list["main"])
			attack_hand(usr)
			return

		else if (href_list["eject"])
			if(beaker)
				beaker:loc = src.loc
				beaker = null
				reagents.clear_reagents()
				update_icon()

		else if (href_list["createbar"])
			var/obj/item/weapon/reagent_containers/food/snacks/snackbar/SB = new/obj/item/weapon/reagent_containers/food/snacks/snackbar(src.loc)
			reagents.trans_to(SB, 10)

	src.updateUsrDialog()
	return

/obj/machinery/snackbar_machine/attack_ai(mob/user as mob)
	src.add_hiddenprint(user)
	return src.attack_hand(user)

/obj/machinery/snackbar_machine/attack_paw(mob/user as mob)
	return src.attack_hand(user)

/obj/machinery/snackbar_machine/attack_hand(mob/user as mob)
	if(stat & BROKEN)
		return
	user.set_machine(src)

	var/dat = ""
	if(!beaker)
		dat = "Please insert beaker.<BR>"
		dat += "<A href='?src=\ref[src];close=1'>Close</A>"
	else
		var/datum/reagents/R = beaker.reagents
		dat += "<A href='?src=\ref[src];eject=1'>Eject beaker and Clear Buffer</A><BR>"
		if(!R.total_volume)
			dat += "Beaker is empty."
		else
			dat += "Add to buffer:<BR>"
			for(var/datum/reagent/G in R.reagent_list)
				dat += {"[G.name] , [G.volume] Units -
					<A href='?src=\ref[src];analyze=1;desc=[G.description];name=[G.name]'>(Analyze)</A>
					<A href='?src=\ref[src];add=[G.id];amount=1'>(1)</A>
					<A href='?src=\ref[src];add=[G.id];amount=5'>(5)</A>
					<A href='?src=\ref[src];add=[G.id];amount=10'>(10)</A>
					<A href='?src=\ref[src];add=[G.id];amount=[G.volume]'>(All)</A>
					<A href='?src=\ref[src];addcustom=[G.id]'>(Custom)</A><BR>"}

		dat += "<HR>Transfer to <A href='?src=\ref[src];toggle=1'>[(!mode ? "disposal" : "beaker")]:</A><BR>"
		if(reagents.total_volume)
			for(var/datum/reagent/N in reagents.reagent_list)
				dat += {"[N.name] , [N.volume] Units -
					<A href='?src=\ref[src];analyze=1;desc=[N.description];name=[N.name]'>(Analyze)</A>
					<A href='?src=\ref[src];remove=[N.id];amount=1'>(1)</A>
					<A href='?src=\ref[src];remove=[N.id];amount=5'>(5)</A>
					<A href='?src=\ref[src];remove=[N.id];amount=10'>(10)</A>
					<A href='?src=\ref[src];remove=[N.id];amount=[N.volume]'>(All)</A>
					<A href='?src=\ref[src];removecustom=[N.id]'>(Custom)</A><BR>"}
			dat += "<A href='?src=\ref[src];createbar=1'>Create snack bar (10 units max)</A>"
		else
			dat += "Buffer is empty.<BR>"

	user << browse("<TITLE>SnackBar Machine</TITLE>SnackBar Machine menu:<BR><BR>[dat]", "window=snackbar_machine;size=575x400")
	onclose(user, "snackbar_machine")
	return

/obj/machinery/snackbar_machine/proc/isgoodnumber(var/num)
	if(isnum(num))
		if(num > 100)
			num = 100
		else if(num < 0)
			num = 1
		else
			num = round(num)
		return num
	else
		return 0

/obj/machinery/snackbar_machine/update_icon()
	if(beaker)
		icon_state = "mixer1"
	else
		icon_state = "mixer0"

	var/image/overlay = image('icons/obj/chemical.dmi', src, "[icon_state]_overlay")
	if(reagents.total_volume)
		overlay.icon += mix_color_from_reagents(reagents.reagent_list)
	overlays.Cut()
	overlays += overlay

/obj/machinery/snackbar_machine/on_reagent_change()
	update_icon()