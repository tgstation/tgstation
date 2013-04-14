//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//ICE CREAM MACHINE
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

/obj/machinery/icemachine
	name = "Cream-Master Deluxe"
	density = 1
	anchored = 1
	icon = 'icons/obj/vending.dmi'
	icon_state = "icecream"
	use_power = 1
	idle_power_usage = 20
	var/beaker = null
	var/mode = 0
	var/useramount = 15 // Last used amount

/obj/machinery/icemachine/proc/generate_name(var/reagent_name)
	var/name_prefix = pick("Mr.","Mrs.","Super","Happy","Whippy")
	var/name_suffix = pick(" Whippy ","Slappy "," Creamy "," Dippy "," Swirly "," Swirl ")
	var/cone_name = null //Heart failiure prevention.
	cone_name += name_prefix
	cone_name += name_suffix
	cone_name += "[reagent_name] "
	return cone_name

/obj/machinery/icemachine/New()
	var/datum/reagents/R = new/datum/reagents(100)
	reagents = R
	R.my_atom = src

/obj/machinery/icemachine/attackby(var/obj/item/weapon/B as obj, var/mob/user as mob)

	if(istype(B, /obj/item/weapon/reagent_containers/glass))
		if(src.beaker)
			user << "A beaker is already inside the Cream-Master"
			return
		src.beaker = B
		user.drop_item()
		B.loc = src
		user << "You add the beaker to the Cream-Master!"
		src.updateUsrDialog()
	return

/obj/machinery/icemachine/Topic(href, href_list)
	if(..()) return

	src.add_fingerprint(usr)
	usr.set_machine(src)


	if(href_list["close"])
		usr << browse(null, "window=cream_master")
		usr.unset_machine()
		return

	if(beaker)
		var/datum/reagents/R = beaker:reagents
		if (href_list["analyze"])
			var/dat = "<TITLE>Cream-Master Deluxe</TITLE>Chemical infos:<BR><BR>Name:<BR>[href_list["name"]]<BR><BR>Description:<BR>[href_list["desc"]]<BR><BR><BR><A href='?src=\ref[src];main=1'>(Back)</A>"
			usr << browse(dat, "window=cream_master;size=575x400")
			return

		else if (href_list["add"])

			if(href_list["amount"])
				var/id = href_list["add"]
				var/amount = text2num(href_list["amount"])
				R.trans_id_to(src, id, amount)

		else if (href_list["addcustom"])

			var/id = href_list["addcustom"]
			useramount = input("Select the amount to transfer.", 15, useramount) as num
			useramount = isgoodnumber(useramount)
			src.Topic(null, list("amount" = "[useramount]", "add" = "[id]"))

		else if (href_list["remove"])

			if(href_list["amount"])
				var/id = href_list["remove"]
				var/amount = text2num(href_list["amount"])
				if(mode)
					reagents.trans_id_to(beaker, id, amount)
				else
					reagents.remove_reagent(id, amount)


		else if (href_list["removecustom"])

			var/id = href_list["removecustom"]
			useramount = input("Select the amount to transfer.", 15, useramount) as num
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
		else if (href_list["createcup"])
			var/name = generate_name(reagents.get_master_reagent_name())
			name += "Cup"
			var/obj/item/weapon/reagent_containers/food/snacks/icecream/icecreamcup/C
			C = new/obj/item/weapon/reagent_containers/food/snacks/icecream/icecreamcup(src.loc)
			C.name = "[name]"
			C.pixel_x = rand(-7, 7) //random position
			C.pixel_y = rand(-7, 7)
			reagents.trans_to(C,30)

		else if (href_list["createcone"])
			var/name = generate_name(reagents.get_master_reagent_name())
			name += "Cone"
			var/obj/item/weapon/reagent_containers/food/snacks/icecream/icecreamcone/C
			C = new/obj/item/weapon/reagent_containers/food/snacks/icecream/icecreamcone(src.loc)
			C.name = "[name]"
			C.pixel_x = rand(-7, 7) //random position
			C.pixel_y = rand(-7, 7)
			reagents.trans_to(C,15)


	src.updateUsrDialog()
	return

/obj/machinery/icemachine/attack_ai(mob/user as mob)
	return src.attack_hand(user)

/obj/machinery/icemachine/attack_paw(mob/user as mob)
	return src.attack_hand(user)

/obj/machinery/icemachine/attack_hand(mob/user as mob)
	if(..()) return
	user.set_machine(src)
	var/dat = ""
	if(!beaker)
		dat = "Please insert beaker.<BR>"
		dat += "<A href='?src=\ref[src];close=1'>Close</A>"
	else
		var/datum/reagents/R = beaker:reagents
		dat += "<A href='?src=\ref[src];eject=1'>Eject beaker and Clear Buffer</A><BR>"
		if(!R.total_volume)
			dat += "Beaker is empty."
		else
			dat += "Add to buffer:<BR>"
			for(var/datum/reagent/G in R.reagent_list)
				dat += "[G.name] , [G.volume] Units - "
				dat += "<A href='?src=\ref[src];analyze=1;desc=[G.description];name=[G.name]'>(Analyze)</A> "
				dat += "<A href='?src=\ref[src];add=[G.id];amount=1'>(1)</A> "
				dat += "<A href='?src=\ref[src];add=[G.id];amount=5'>(5)</A> "
				dat += "<A href='?src=\ref[src];add=[G.id];amount=10'>(10)</A> "
				dat += "<A href='?src=\ref[src];add=[G.id];amount=[G.volume]'>(All)</A> "
				dat += "<A href='?src=\ref[src];addcustom=[G.id]'>(Custom)</A><BR>"

		dat += "<HR>Transfer to <A href='?src=\ref[src];toggle=1'>[(!mode ? "disposal" : "beaker")]:</A><BR>"
		if(reagents.total_volume)
			for(var/datum/reagent/N in reagents.reagent_list)
				dat += "[N.name] , [N.volume] Units - "
				dat += "<A href='?src=\ref[src];analyze=1;desc=[N.description];name=[N.name]'>(Analyze)</A> "
				dat += "<A href='?src=\ref[src];remove=[N.id];amount=1'>(1)</A> "
				dat += "<A href='?src=\ref[src];remove=[N.id];amount=5'>(5)</A> "
				dat += "<A href='?src=\ref[src];remove=[N.id];amount=10'>(10)</A> "
				dat += "<A href='?src=\ref[src];remove=[N.id];amount=[N.volume]'>(All)</A> "
				dat += "<A href='?src=\ref[src];removecustom=[N.id]'>(Custom)</A><BR>"
		else
			dat += "Empty<BR>"
		dat += "<HR><BR><A href='?src=\ref[src];createcup=1'>Create Cup (30 units max)</A><BR>"
		dat += "<A href='?src=\ref[src];createcone=1'>Create Cone (15 units max)</A>"
	user << browse("<TITLE>Cream-Master Deluxe</TITLE>Cream-Master Deluxe menu:<BR><BR>[dat]", "window=cream_master;size=575x400")
	onclose(user, "cream_master")
	return

/obj/machinery/icemachine/proc/isgoodnumber(var/num)
	if(isnum(num))
		if(num > 200)
			num = 200
		else if(num < 0)
			num = 1
		else
			num = round(num)
		return num
	else
		return 0