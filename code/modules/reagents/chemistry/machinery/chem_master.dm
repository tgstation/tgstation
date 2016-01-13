/obj/machinery/chem_master
	name = "ChemMaster 3000"
	desc = "Used to bottle chemicals to create pills."
	density = 1
	anchored = 1
	icon = 'icons/obj/chemical.dmi'
	icon_state = "mixer0"
	use_power = 1
	idle_power_usage = 20
	var/obj/item/weapon/reagent_containers/glass/beaker = null
	var/obj/item/weapon/storage/pill_bottle/bottle = null
	var/mode = 0
	var/condi = 0
	var/useramount = 30 // Last used amount

/obj/machinery/chem_master/New()
	create_reagents(100)
	overlays += "waitlight"

/obj/machinery/chem_master/ex_act(severity, target)
	if(severity < 3)
		..()

/obj/machinery/chem_master/blob_act()
	if (prob(50))
		qdel(src)

/obj/machinery/chem_master/power_change()
	if(powered())
		stat &= ~NOPOWER
	else
		spawn(rand(0, 15))
			stat |= NOPOWER

/obj/machinery/chem_master/attackby(obj/item/I, mob/user, params)
	if(default_unfasten_wrench(user, I))
		return

	if(istype(I, /obj/item/weapon/reagent_containers/glass))
		if(isrobot(user))
			return
		if(beaker)
			user << "<span class='warning'>A beaker is already loaded into the machine!</span>"
			return
		if(!user.drop_item())
			return

		beaker = I
		beaker.loc = src
		user << "<span class='notice'>You add the beaker to the machine.</span>"
		src.updateUsrDialog()
		icon_state = "mixer1"

	else if(!condi && istype(I, /obj/item/weapon/storage/pill_bottle))
		if(bottle)
			user << "<span class='warning'>A pill bottle is already loaded into the machine!</span>"
			return
		if(!user.drop_item())
			return

		bottle = I
		bottle.loc = src
		user << "<span class='notice'>You add the pill bottle into the dispenser slot.</span>"
		src.updateUsrDialog()

	return

/obj/machinery/chem_master/Topic(href, href_list)
	if(..())
		return

	usr.set_machine(src)

	if(href_list["ejectp"])
		if(bottle)
			bottle.loc = src.loc
			bottle = null

	else if(href_list["close"])
		usr << browse(null, "window=chem_master")
		usr.unset_machine()
		return

	else if(href_list["toggle"])
		mode = !mode

	else if(href_list["createbottle"])
		var/name = stripped_input(usr, "Name:","Name your bottle!", (reagents.total_volume ? reagents.get_master_reagent_name() : " "), MAX_NAME_LEN)
		if(!name)
			return
		var/obj/item/weapon/reagent_containers/P
		if(condi)
			P = new/obj/item/weapon/reagent_containers/food/condiment(src.loc)
		else
			P = new/obj/item/weapon/reagent_containers/glass/bottle(src.loc)
			P.pixel_x = rand(-7, 7) //random position
			P.pixel_y = rand(-7, 7)
		P.name = trim("[name] bottle")
		reagents.trans_to(P, P.volume)

	if(beaker)

		if(href_list["analyze"])
			if(locate(href_list["reagent"]))
				var/datum/reagent/R = locate(href_list["reagent"])
				if(R)
					var/dat = ""
					dat += "<H1>[condi ? "Condiment" : "Chemical"] information:</H1>"
					dat += "<B>Name:</B> [initial(R.name)]<BR><BR>"
					dat += "<B>State:</B> "
					if(initial(R.reagent_state) == 1)
						dat += "Solid"
					else if(initial(R.reagent_state) == 2)
						dat += "Liquid"
					else if(initial(R.reagent_state) == 3)
						dat += "Gas"
					else
						dat += "Unknown"
					dat += "<BR>"
					dat += "<B>Color:</B> <span style='color:[initial(R.color)];background-color:[initial(R.color)];font:Lucida Console'>[initial(R.color)]</span><BR><BR>"
					dat += "<B>Description:</B> [initial(R.description)]<BR><BR>"
					var/const/P = 3 //The number of seconds between life ticks
					var/T = initial(R.metabolization_rate) * (60 / P)
					dat += "<B>Metabolization Rate:</B> [T]u/minute<BR>"
					dat += "<B>Overdose Threshold:</B> [initial(R.overdose_threshold) ? "[initial(R.overdose_threshold)]u" : "none"]<BR>"
					dat += "<B>Addiction Threshold:</B> [initial(R.addiction_threshold) ? "[initial(R.addiction_threshold)]u" : "none"]<BR><BR>"
					dat += "<BR><A href='?src=\ref[src];main=1'>Back</A>"
					var/datum/browser/popup = new(usr, "chem_master", name)
					popup.set_content(dat)
					popup.set_title_image(usr.browse_rsc_icon(src.icon, src.icon_state))
					popup.open(1)
					return

		else if(href_list["main"]) // Used to exit the analyze screen.
			attack_hand(usr)
			return

		else if(href_list["add"])
			if(href_list["amount"])
				var/id = href_list["add"]
				var/amount = text2num(href_list["amount"])
				if (amount > 0)
					beaker.reagents.trans_id_to(src, id, amount)

		else if(href_list["addcustom"])
			var/id = href_list["addcustom"]
			var/amt_temp = isgoodnumber(input(usr, "Select the amount to transfer.", "Transfer how much?", useramount) as num|null)
			if(!amt_temp)
				return
			useramount = amt_temp
			src.Topic(null, list("amount" = "[useramount]", "add" = "[id]"))

		else if(href_list["remove"])
			if(href_list["amount"])
				var/id = href_list["remove"]
				var/amount = text2num(href_list["amount"])
				if (amount > 0)
					if(mode)
						reagents.trans_id_to(beaker, id, amount)
					else
						reagents.remove_reagent(id, amount)

		else if(href_list["removecustom"])
			var/id = href_list["removecustom"]
			var/amt_temp = isgoodnumber(input(usr, "Select the amount to transfer.", "Transfer how much?", useramount) as num|null)
			if(!amt_temp)
				return
			useramount = amt_temp
			src.Topic(null, list("amount" = "[useramount]", "remove" = "[id]"))

		else if(href_list["eject"])
			if(beaker)
				beaker.loc = src.loc
				beaker = null
				reagents.clear_reagents()
				icon_state = "mixer0"

		else if(href_list["createpill"]) //Also used for condiment packs.
			if(reagents.total_volume == 0) return
			if(!condi)
				var/amount = 1
				var/vol_each = min(reagents.total_volume, 50)
				if(text2num(href_list["many"]))
					amount = min(max(round(input(usr, "Max 10. Buffer content will be split evenly.", "How many pills?", amount) as num|null), 0), 10)
					if(!amount)
						return
					vol_each = min(reagents.total_volume / amount, 50)
				var/name = stripped_input(usr,"Name:","Name your pill!", "[reagents.get_master_reagent_name()] ([vol_each]u)", MAX_NAME_LEN)
				if(!name || !reagents.total_volume)
					return
				var/obj/item/weapon/reagent_containers/pill/P

				for(var/i = 0; i < amount; i++)
					if(bottle && bottle.contents.len < bottle.storage_slots)
						P = new/obj/item/weapon/reagent_containers/pill(bottle)
					else
						P = new/obj/item/weapon/reagent_containers/pill(src.loc)
					P.name = trim("[name] pill")
					P.pixel_x = rand(-7, 7) //random position
					P.pixel_y = rand(-7, 7)
					reagents.trans_to(P,vol_each)
			else
				var/name = stripped_input(usr, "Name:", "Name your pack!", reagents.get_master_reagent_name(), MAX_NAME_LEN)
				if(!name || !reagents.total_volume)
					return
				var/obj/item/weapon/reagent_containers/food/condiment/pack/P = new/obj/item/weapon/reagent_containers/food/condiment/pack(src.loc)

				P.originalname = name
				P.name = trim("[name] pack")
				P.desc = "A small condiment pack. The label says it contains [name]."
				reagents.trans_to(P,10)

		else if(href_list["createpatch"])
			if(reagents.total_volume == 0) return
			var/amount = 1
			var/vol_each = min(reagents.total_volume, 50)
			if(text2num(href_list["many"]))
				amount = min(max(round(input(usr, "Max 10. Buffer content will be split evenly.", "How many patches?", amount) as num|null), 0), 10)
				if(!amount)
					return
				vol_each = min(reagents.total_volume / amount, 50)
			var/name = stripped_input(usr,"Name:","Name your patch!", "[reagents.get_master_reagent_name()] ([vol_each]u)", MAX_NAME_LEN)
			if(!name || !reagents.total_volume)
				return
			var/obj/item/weapon/reagent_containers/pill/P

			for(var/i = 0; i < amount; i++)
				P = new/obj/item/weapon/reagent_containers/pill/patch(src.loc)
				P.name = trim("[name] patch")
				P.pixel_x = rand(-7, 7) //random position
				P.pixel_y = rand(-7, 7)
				reagents.trans_to(P,vol_each)

	src.updateUsrDialog()
	return

/obj/machinery/chem_master/attack_hand(mob/user)
	if(stat & BROKEN)
		return

	user.set_machine(src)
	var/dat = ""
	if(beaker)
		dat += "Beaker \[[beaker.reagents.total_volume]/[beaker.volume]\] <A href='?src=\ref[src];eject=1'>Eject and Clear Buffer</A><BR>"
	else
		dat = "Please insert beaker.<BR>"

	dat += "<HR><B>Add to buffer:</B><UL>"
	if(beaker)
		if(beaker.reagents.total_volume)
			for(var/datum/reagent/G in beaker.reagents.reagent_list)
				dat += "<LI>[G.name], [G.volume] Units - "
				dat += "<A href='?src=\ref[src];analyze=1;reagent=\ref[G]'>Analyze</A> "
				dat += "<A href='?src=\ref[src];add=[G.id];amount=1'>1</A> "
				dat += "<A href='?src=\ref[src];add=[G.id];amount=5'>5</A> "
				dat += "<A href='?src=\ref[src];add=[G.id];amount=10'>10</A> "
				dat += "<A href='?src=\ref[src];add=[G.id];amount=[G.volume]'>All</A> "
				dat += "<A href='?src=\ref[src];addcustom=[G.id]'>Custom</A>"
		else
			dat += "<LI>Beaker is empty."
	else
		dat += "<LI>No beaker."

	dat += "</UL><HR><B>Transfer to <A href='?src=\ref[src];toggle=1'>[(!mode ? "disposal" : "beaker")]</A>:</B><UL>"
	if(reagents.total_volume)
		for(var/datum/reagent/N in reagents.reagent_list)
			dat += "<LI>[N.name], [N.volume] Units - "
			dat += "<A href='?src=\ref[src];analyze=1;reagent=\ref[N]'>Analyze</A> "
			dat += "<A href='?src=\ref[src];remove=[N.id];amount=1'>1</A> "
			dat += "<A href='?src=\ref[src];remove=[N.id];amount=5'>5</A> "
			dat += "<A href='?src=\ref[src];remove=[N.id];amount=10'>10</A> "
			dat += "<A href='?src=\ref[src];remove=[N.id];amount=[N.volume]'>All</A> "
			dat += "<A href='?src=\ref[src];removecustom=[N.id]'>Custom</A>"
	else
		dat += "<LI>Buffer is empty."
	dat += "</UL><HR>"

	if(!condi)
		if(bottle)
			dat += "Pill Bottle \[[bottle.contents.len]/[bottle.storage_slots]\] <A href='?src=\ref[src];ejectp=1'>Eject</A>"
		else
			dat += "No pill bottle inserted."
	else
		dat += "<BR>"

	dat += "<UL>"
	if(!condi)
		if(beaker && reagents.total_volume)
			dat += "<LI><A href='?src=\ref[src];createpill=1;many=0'>Create pill</A> (50 units max)"
			dat += "<LI><A href='?src=\ref[src];createpill=1;many=1'>Create multiple pills</A><BR>"
			dat += "<LI><A href='?src=\ref[src];createpatch=1;many=0'>Create patch</A> (50 units max)"
			dat += "<LI><A href='?src=\ref[src];createpatch=1;many=1'>Create multiple patches</A><BR>"
		else
			dat += "<LI><span class='linkOff'>Create pill</span> (50 units max)"
			dat += "<LI><span class='linkOff'>Create multiple pills</span><BR>"
			dat += "<LI><span class='linkOff'>Create patch</span> (50 units max)"
			dat += "<LI><span class='linkOff'>Create multiple patches</span><BR>"
	else
		if(beaker && reagents.total_volume)
			dat += "<LI><A href='?src=\ref[src];createpill=1'>Create pack</A> (10 units max)<BR>"
		else
			dat += "<LI><span class='linkOff'>Create pack</span> (10 units max)<BR>"
	dat += "<LI><A href='?src=\ref[src];createbottle=1'>Create bottle</A> ([condi ? "50" : "30"] units max)"
	dat += "</UL>"
	dat += "<BR><A href='?src=\ref[src];close=1'>Close</A>"
	var/datum/browser/popup = new(user, "chem_master", name, 470, 500)
	popup.set_content(dat)
	popup.set_title_image(user.browse_rsc_icon(src.icon, src.icon_state))
	popup.open(1)
	return

/obj/machinery/chem_master/proc/isgoodnumber(num)
	if(isnum(num))
		if(num > 200)
			num = 200
		else if(num < 0)
			num = 0
		else
			num = round(num)
		return num
	else
		return 0


/obj/machinery/chem_master/condimaster
	name = "CondiMaster 3000"
	desc = "Used to create condiments and other cooking supplies."
	condi = 1

/obj/machinery/chem_master/constructable
	name = "ChemMaster 2999"
	desc = "Used to seperate chemicals and distribute them in a variety of forms."

/obj/machinery/chem_master/constructable/New()
	..()
	component_parts = list()
	component_parts += new /obj/item/weapon/circuitboard/chem_master(null)
	component_parts += new /obj/item/weapon/stock_parts/manipulator(null)
	component_parts += new /obj/item/weapon/stock_parts/console_screen(null)
	component_parts += new /obj/item/weapon/reagent_containers/glass/beaker(null)
	component_parts += new /obj/item/weapon/reagent_containers/glass/beaker(null)

/obj/machinery/chem_master/constructable/attackby(obj/item/B, mob/user, params)

	if(default_deconstruction_screwdriver(user, "mixer0_nopower", "mixer0", B))
		if(beaker)
			beaker.loc = src.loc
			beaker = null
			reagents.clear_reagents()
		if(bottle)
			bottle.loc = src.loc
			bottle = null
		return

	if(exchange_parts(user, B))
		return

	if(panel_open)
		if(istype(B, /obj/item/weapon/crowbar))
			default_deconstruction_crowbar(B)
			return 1
		else
			user << "<span class='warning'>You can't use the [src.name] while it's panel is opened!</span>"
			return 1

	if(istype(B, /obj/item/weapon/reagent_containers/glass))
		if(beaker)
			user << "<span class='warning'>A beaker is already loaded into the machine!</span>"
			return
		if(!user.drop_item())
			return

		beaker = B
		beaker.loc = src
		user << "<span class='notice'>You add the beaker to the machine.</span>"
		src.updateUsrDialog()
		icon_state = "mixer1"

	else if(!condi && istype(B, /obj/item/weapon/storage/pill_bottle))
		if(bottle)
			user << "<span class='warning'>A pill bottle is already loaded into the machine!</span>"
			return
		if(!user.drop_item())
			return

		src.bottle = B
		B.loc = src
		user << "<span class='notice'>You add the pill bottle into the dispenser slot.</span>"
		src.updateUsrDialog()

	return
