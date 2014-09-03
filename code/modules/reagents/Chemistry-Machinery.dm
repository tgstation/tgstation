#define SOLID 1
#define LIQUID 2
#define GAS 3

/obj/machinery/chem_dispenser
	name = "chem dispenser"
	density = 1
	anchored = 1
	icon = 'icons/obj/chemical.dmi'
	icon_state = "dispenser"
	use_power = 0
	idle_power_usage = 40
	var/energy = 100
	var/max_energy = 100
	var/amount = 30
	var/obj/item/weapon/reagent_containers/glass/beaker = null
	var/recharged = 0
	var/opened = 0
	var/custom = 0
	var/list/dispensable_reagents = list("hydrogen","lithium","carbon","nitrogen","oxygen","fluorine",
	"sodium","aluminum","silicon","phosphorus","sulfur","chlorine","potassium","iron",
	"copper","mercury","radium","water","ethanol","sugar","sacid","tungsten")

/********************************************************************
**   Adding Stock Parts to VV so preconstructed shit has its candy **
********************************************************************/
/obj/machinery/chem_dispenser/New()
	. = ..()

	component_parts = newlist(
		/obj/item/weapon/circuitboard/chem_dispenser,
		/obj/item/weapon/stock_parts/scanning_module,
		/obj/item/weapon/stock_parts/scanning_module,
		/obj/item/weapon/stock_parts/manipulator,
		/obj/item/weapon/stock_parts/manipulator,
		/obj/item/weapon/stock_parts/micro_laser,
		/obj/item/weapon/stock_parts/micro_laser,
		/obj/item/weapon/stock_parts/micro_laser,
		/obj/item/weapon/stock_parts/console_screen
	)

	RefreshParts()

/obj/machinery/chem_dispenser/proc/recharge()
	if(stat & (BROKEN|NOPOWER)) return
	var/addenergy = 2
	var/oldenergy = energy
	energy = min(energy + addenergy, max_energy)
	if(energy != oldenergy)
		use_power(3000) // This thing uses up alot of power (this is still low as shit for creating reagents from thin air)
		nanomanager.update_uis(src) // update all UIs attached to src

/obj/machinery/chem_dispenser/power_change()
	if(powered())
		stat &= ~NOPOWER
	else
		spawn(rand(0, 15))
			stat |= NOPOWER
	nanomanager.update_uis(src) // update all UIs attached to src

/obj/machinery/chem_dispenser/process()

	if(recharged < 0)
		recharge()
		recharged = 15
	else
		recharged -= 1

/obj/machinery/chem_dispenser/New()
	..()
	recharge()
	dispensable_reagents = sortList(dispensable_reagents)

/obj/machinery/chem_dispenser/ex_act(severity)
	switch(severity)
		if(1.0)
			qdel(src)
			return
		if(2.0)
			if (prob(50))
				qdel(src)
				return

/obj/machinery/chem_dispenser/blob_act()
	if (prob(50))
		del(src)

/obj/machinery/chem_dispenser/meteorhit()
	del(src)
	return

 /**
  * The ui_interact proc is used to open and update Nano UIs
  * If ui_interact is not used then the UI will not update correctly
  * ui_interact is currently defined for /atom/movable
  *
  * @param user /mob The mob who is interacting with this ui
  * @param ui_key string A string key to use for this ui. Allows for multiple unique uis on one obj/mob (defaut value "main")
  * @param ui /datum/nanoui This parameter is passed by the nanoui process() proc when updating an open ui
  *
  * @return nothing
  */
/obj/machinery/chem_dispenser/ui_interact(mob/user, ui_key = "main", var/datum/nanoui/ui = null)
	if(stat & (BROKEN|NOPOWER)) return
	if((user.stat && !isobserver(user)) || user.restrained()) return

	// this is the data which will be sent to the ui
	var/data[0]
	data["amount"] = amount
	data["energy"] = energy
	data["maxEnergy"] = max_energy
	data["isBeakerLoaded"] = beaker ? 1 : 0
	data["custom"] = custom

	var beakerContents[0]
	var beakerCurrentVolume = 0
	if(beaker && beaker.reagents && beaker.reagents.reagent_list.len)
		for(var/datum/reagent/R in beaker.reagents.reagent_list)
			beakerContents.Add(list(list("name" = R.name, "volume" = R.volume))) // list in a list because Byond merges the first list...
			beakerCurrentVolume += R.volume
	data["beakerContents"] = beakerContents

	if (beaker)
		data["beakerCurrentVolume"] = beakerCurrentVolume
		data["beakerMaxVolume"] = beaker.volume
	else
		data["beakerCurrentVolume"] = null
		data["beakerMaxVolume"] = null

	var chemicals[0]
	for (var/re in dispensable_reagents)
		var/datum/reagent/temp = chemical_reagents_list[re]
		if(temp)
			chemicals.Add(list(list("title" = temp.name, "id" = temp.id, "commands" = list("dispense" = temp.id)))) // list in a list because Byond merges the first list...
	data["chemicals"] = chemicals

	// update the ui if it exists, returns null if no ui is passed/found
	ui = nanomanager.try_update_ui(user, src, ui_key, ui, data)
	if (!ui)
		// the ui does not exist, so we'll create a new() one
        // for a list of parameters and their descriptions see the code docs in \code\modules\nano\nanoui.dm
		ui = new(user, src, ui_key, "chem_dispenser.tmpl", "Chem Dispenser 5000", 370, 605)
		// when the ui is first opened this is the data it will use
		ui.set_initial_data(data)
		// open the new ui window
		ui.open()

/obj/machinery/chem_dispenser/Topic(href, href_list)
	if(stat & (NOPOWER|BROKEN))
		return 0 // don't update UIs attached to this object

	if(href_list["amount"])
		if(href_list["amount"] == "0")
			var/num = input("Enter desired output amount", "Amount", "30") as num
			if (num)
				amount = round(text2num(num), 5)
				custom = 1
		else
			custom = 0
			amount = round(text2num(href_list["amount"]), 5) // round to nearest 5
		if (amount < 0) // Since the user can actually type the commands himself, some sanity checking
			amount = 0
		if (amount > 100)
			amount = 100

	if(href_list["dispense"])
		if (dispensable_reagents.Find(href_list["dispense"]) && beaker != null)
			var/obj/item/weapon/reagent_containers/glass/B = src.beaker
			var/datum/reagents/R = B.reagents
			var/space = R.maximum_volume - R.total_volume

			R.add_reagent(href_list["dispense"], min(amount, energy * 10, space))
			energy = max(energy - min(amount, energy * 10, space) / 10, 0)

	if(href_list["ejectBeaker"])
		if(beaker)
			var/obj/item/weapon/reagent_containers/glass/B = beaker
			B.loc = loc
			beaker = null

	add_fingerprint(usr)
	return 1 // update UIs attached to this object


/obj/machinery/chem_dispenser/attackby(var/obj/item/weapon/D as obj, var/mob/user as mob) //to be worked on

	if(!istype(D, /obj/item/weapon/reagent_containers/glass))
		if(istype(D, /obj/item/weapon/screwdriver))
			if(!opened)
				src.opened = 1
				//src.icon_state = "chem_dispenser_t"
				user << "You open the maintenance hatch of [src]"
			else
				src.opened = 0
				//src.icon_state = "chem_dispenser"
				user << "You close the maintenance hatch of [src]"
			return 1
		if(opened)
			if(istype(D, /obj/item/weapon/crowbar))
				playsound(get_turf(src), 'sound/items/Crowbar.ogg', 50, 1)
				var/obj/machinery/constructable_frame/machine_frame/M = new /obj/machinery/constructable_frame/machine_frame(src.loc)
				M.state = 2
				M.icon_state = "box_1"
				for(var/obj/I in component_parts)
					if(I.reliability != 100 && crit_fail)
						I.crit_fail = 1
					I.loc = src.loc
				del(src)
				return 1
			else // this might need rework
				user.set_machine(user)
				interact(user)
				return 1
		else
			return

	if(isrobot(user))
		// UNLESS MoMMI or medbutt.
		var/mob/living/silicon/robot/R=user
		if(!isMoMMI(user) && !istype(R.module,/obj/item/weapon/robot_module/medical))
			return

	if(src.beaker)
		user << "A beaker is already loaded into the machine."
		return

	src.beaker =  D
	user.drop_item()
	D.loc = src
	user << "You add the beaker to the machine!"
	nanomanager.update_uis(src) // update all UIs attached to src

/obj/machinery/chem_dispenser/attack_ai(mob/user as mob)
	src.add_hiddenprint(user)
	return src.attack_hand(user)

/obj/machinery/chem_dispenser/attack_paw(mob/user as mob)
	return src.attack_hand(user)

/obj/machinery/chem_dispenser/attack_hand(mob/user as mob)
	if(stat & BROKEN)
		return

	ui_interact(user)

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

/obj/machinery/chem_master
	name = "ChemMaster 3000"
	density = 1
	anchored = 1
	icon = 'icons/obj/chemical.dmi'
	icon_state = "mixer0"
	use_power = 1
	idle_power_usage = 20
	var/obj/item/weapon/reagent_containers/glass/beaker = null
	var/obj/item/weapon/storage/pill_bottle/loaded_pill_bottle = null
	var/mode = 0
	var/condi = 0
	var/opened = 0
	var/useramount = 30 // Last used amount
	var/pillamount = 10
	var/bottlesprite = "1" //yes, strings
	var/pillsprite = "1"
	var/client/has_sprites = list()

	l_color = "#0000FF"

/********************************************************************
**   Adding Stock Parts to VV so preconstructed shit has its candy **
********************************************************************/
/obj/machinery/chem_master/New()
	. = ..()

	var/datum/reagents/R = new/datum/reagents(100)
	reagents = R
	R.my_atom = src

	component_parts = newlist(
		/obj/item/weapon/stock_parts/manipulator,
		/obj/item/weapon/stock_parts/scanning_module,
		/obj/item/weapon/stock_parts/scanning_module,
		/obj/item/weapon/stock_parts/scanning_module,
		/obj/item/weapon/stock_parts/micro_laser,
		/obj/item/weapon/stock_parts/micro_laser,
		/obj/item/weapon/stock_parts/console_screen,
		/obj/item/weapon/stock_parts/console_screen
	)

	if(istype(src, /obj/machinery/chem_master/condimaster))
		component_parts += new /obj/item/weapon/circuitboard/condimaster()
	else
		component_parts += new /obj/item/weapon/circuitboard/chemmaster3000()


	RefreshParts()

	var/image/overlay = image('icons/obj/chemical.dmi', src, "[icon_state]_overlay")
	overlays += overlay

/obj/machinery/chem_master/ex_act(severity)
	switch(severity)
		if(1.0)
			qdel(src)
			return
		if(2.0)
			if (prob(50))
				qdel(src)
				return

/obj/machinery/chem_master/blob_act()
	if (prob(50))
		qdel(src)

/obj/machinery/chem_master/meteorhit()
	qdel(src)
	return

/obj/machinery/chem_master/power_change()
	if(powered())
		stat &= ~NOPOWER
	else
		spawn(rand(0, 15))
			stat |= NOPOWER

/obj/machinery/chem_master/attackby(var/obj/item/weapon/B as obj, var/mob/user as mob)

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

	else if(istype(B, /obj/item/weapon/storage/pill_bottle))

		if(src.loaded_pill_bottle)
			user << "A pill bottle is already loaded into the machine."
			return

		src.loaded_pill_bottle = B
		user.drop_item()
		B.loc = src
		user << "You add the pill bottle into the dispenser slot!"
		src.updateUsrDialog()
	else if(istype(B, /obj/item/weapon/screwdriver))
		if(src.beaker)
			user << "\red A beaker is loaded in [src]."
			return
		if(src.loaded_pill_bottle)
			user << "\red A pill bottle is loaded in [src]."
			return
		if(!opened)
			src.opened = 1
			//src.icon_state = "freezer_t"
			user << "You open the maintenance hatch of [src]."
		else
			src.opened = 0
			//src.icon_state = "freezer"
			user << "You close the maintenance hatch of [src]."
		return 1
	if(opened)
		if(istype(B, /obj/item/weapon/crowbar))
			if(src.beaker)
				user << "\red A beaker is loaded in [src]."
				return
			if(src.loaded_pill_bottle)
				user << "\red A pill bottle is loaded in [src]."
				return
			user << "You begin to remove the circuits from the [src]."
			playsound(get_turf(src), 'sound/items/Crowbar.ogg', 50, 1)
			if(do_after(user, 50))
				var/obj/machinery/constructable_frame/machine_frame/M = new /obj/machinery/constructable_frame/machine_frame(src.loc)
				M.state = 2
				M.icon_state = "box_1"
				for(var/obj/I in component_parts)
					if(I.reliability != 100 && crit_fail)
						I.crit_fail = 1
					I.loc = src.loc
				del(src)
				return 1
	return

/obj/machinery/chem_master/Topic(href, href_list)
	if(stat & (BROKEN|NOPOWER)) 		return
	if(usr.stat || usr.restrained())	return
	if(!in_range(src, usr)) 			return

	src.add_fingerprint(usr)
	usr.set_machine(src)


	if (href_list["ejectp"])
		if(loaded_pill_bottle)
			loaded_pill_bottle.loc = src.loc
			loaded_pill_bottle = null
	else if(href_list["close"])
		usr << browse(null, "window=chemmaster")
		usr.unset_machine()
		return

	if(beaker)
		var/datum/reagents/R = beaker.reagents
		if (href_list["analyze"])
			var/dat = ""
			if(!condi)
				if(href_list["name"] == "Blood")
					var/datum/reagent/blood/G
					for(var/datum/reagent/F in R.reagent_list)
						if(F.name == href_list["name"])
							G = F
							break
					var/A = G.name
					var/B = G.data["blood_type"]
					var/C = G.data["blood_DNA"]
					dat += "<TITLE>Chemmaster 3000</TITLE>Chemical infos:<BR><BR>Name:<BR>[A]<BR><BR>Description:<BR>Blood Type: [B]<br>DNA: [C]<BR><BR><BR><A href='?src=\ref[src];main=1'>(Back)</A>"
				else
					dat += "<TITLE>Chemmaster 3000</TITLE>Chemical infos:<BR><BR>Name:<BR>[href_list["name"]]<BR><BR>Description:<BR>[href_list["desc"]]<BR><BR><BR><A href='?src=\ref[src];main=1'>(Back)</A>"
			else
				dat += "<TITLE>Condimaster 3000</TITLE>Condiment infos:<BR><BR>Name:<BR>[href_list["name"]]<BR><BR>Description:<BR>[href_list["desc"]]<BR><BR><BR><A href='?src=\ref[src];main=1'>(Back)</A>"
			usr << browse(dat, "window=chem_master;size=575x400")
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
				beaker.loc = src.loc
				beaker = null
				reagents.clear_reagents()
				update_icon()
		else if (href_list["createpill"] || href_list["createpill_multiple"])
			var/count = 1
			if (href_list["createpill_multiple"]) count = isgoodnumber(input("Select the number of pills to make.", 10, pillamount) as num)
			if (count > 20) count = 20	//Pevent people from creating huge stacks of pills easily. Maybe move the number to defines?
			var/amount_per_pill = reagents.total_volume/count
			if (amount_per_pill > 50) amount_per_pill = 50
			var/name = reject_bad_text(input(usr,"Name:","Name your pill!","[reagents.get_master_reagent_name()] ([amount_per_pill] units)"))
			while (count--)
				var/obj/item/weapon/reagent_containers/pill/P = new/obj/item/weapon/reagent_containers/pill(src.loc)
				if(!name) name = "[reagents.get_master_reagent_name()] ([amount_per_pill] units)"
				P.name = "[name] pill"
				P.pixel_x = rand(-7, 7) //random position
				P.pixel_y = rand(-7, 7)
				P.icon_state = "pill"+pillsprite
				reagents.trans_to(P,amount_per_pill)
				if(src.loaded_pill_bottle)
					if(loaded_pill_bottle.contents.len < loaded_pill_bottle.storage_slots)
						P.loc = loaded_pill_bottle
						src.updateUsrDialog()
		else if (href_list["createbottle"] || href_list["createbottle_multiple"])
			if(!condi)
				var/name = reject_bad_text(input(usr,"Name:","Name your bottle!",reagents.get_master_reagent_name()))
				if(!name) name = reagents.get_master_reagent_name()
				var/count = 1
				if (href_list["createbottle_multiple"])
					count = isgoodnumber(input("Select the number of bottles to make.", 10, count) as num)
				if (count > 4) count = 4
				var/amount_per_bottle = reagents.total_volume/count
				if (amount_per_bottle > 30) amount_per_bottle = 30
				while (count--)
					var/obj/item/weapon/reagent_containers/glass/bottle/P = new/obj/item/weapon/reagent_containers/glass/bottle(src.loc)
					P.name = "[name] bottle"
					P.pixel_x = rand(-7, 7) //random position
					P.pixel_y = rand(-7, 7)
					P.icon_state = "bottle"+bottlesprite
					reagents.trans_to(P,amount_per_bottle)
			else
				var/obj/item/weapon/reagent_containers/food/condiment/P = new/obj/item/weapon/reagent_containers/food/condiment(src.loc)
				reagents.trans_to(P,50)
		else if(href_list["change_pill"])
			#define MAX_PILL_SPRITE 20 //max icon state of the pill sprites
			var/dat = "<table>"
			for(var/i = 1 to MAX_PILL_SPRITE)
				if ( i%4==1 )
					dat += "<tr>"

				dat += "<td><a href=\"?src=\ref[src]&pill_sprite=[i]\"><img src=\"pill[i].png\" /></a></td>"

				if ( i%4==0 )
					dat +="</tr>"

			dat += "</table>"
			usr << browse(dat, "window=chem_master")
			return
		else if(href_list["change_bottle"])
			#define MAX_BOTTLE_SPRITE 20 //max icon state of the bottle sprites
			var/dat = "<table>"
			for(var/i = 1 to MAX_BOTTLE_SPRITE)
				if ( i%4==1 )
					dat += "<tr>"

				dat += "<td><a href=\"?src=\ref[src]&bottle_sprite=[i]\"><img src=\"bottle[i].png\" /></a></td>"

				if ( i%4==0 )
					dat +="</tr>"

			dat += "</table>"
			usr << browse(dat, "window=chem_master")
			return
		else if(href_list["pill_sprite"])
			pillsprite = href_list["pill_sprite"]
		else if(href_list["bottle_sprite"])
			bottlesprite = href_list["bottle_sprite"]

	src.updateUsrDialog()
	return

/obj/machinery/chem_master/attack_ai(mob/user as mob)
	src.add_hiddenprint(user)
	return src.attack_hand(user)

/obj/machinery/chem_master/attack_paw(mob/user as mob)
	return src.attack_hand(user)

/obj/machinery/chem_master/attack_hand(mob/user as mob)
	if(stat & BROKEN)
		return
	user.set_machine(src)
	if(!(user.client in has_sprites))
		spawn()
			has_sprites += user.client
			for(var/i = 1 to MAX_PILL_SPRITE)
				usr << browse_rsc(icon('icons/obj/chemical.dmi', "pill" + num2text(i)), "pill[i].png")
			for(var/i = 1 to MAX_BOTTLE_SPRITE)
				usr << browse_rsc(icon('icons/obj/chemical.dmi', "bottle" + num2text(i)), "bottle[i].png")
	var/dat = ""
	if(!beaker)
		dat = "Please insert beaker.<BR>"
		if(!condi)
			if(src.loaded_pill_bottle)
				dat += "<A href='?src=\ref[src];ejectp=1'>Eject Pill Bottle \[[loaded_pill_bottle.contents.len]/[loaded_pill_bottle.storage_slots]\]</A><BR><BR>"
			else
				dat += "No pill bottle inserted.<BR><BR>"
		dat += "<A href='?src=\ref[src];close=1'>Close</A>"
	else
		var/datum/reagents/R = beaker.reagents
		dat += "<A href='?src=\ref[src];eject=1'>Eject beaker and Clear Buffer</A><BR>"
		if(src.loaded_pill_bottle)
			dat += "<A href='?src=\ref[src];ejectp=1'>Eject Pill Bottle \[[loaded_pill_bottle.contents.len]/[loaded_pill_bottle.storage_slots]\]</A><BR><BR>"
		else
			dat += "No pill bottle inserted.<BR><BR>"
		if(!R.total_volume)
			dat += "Beaker is empty."
		else
			dat += "Add to buffer:<BR>"
			for(var/datum/reagent/G in R.reagent_list)

				// AUTOFIXED BY fix_string_idiocy.py
				// C:\Users\Rob\Documents\Projects\vgstation13\code\modules\reagents\Chemistry-Machinery.dm:518: dat += "[G.name] , [G.volume] Units - "
				dat += {"[G.name] , [G.volume] Units -
					<A href='?src=\ref[src];analyze=1;desc=[G.description];name=[G.name]'>(Analyze)</A>
					<A href='?src=\ref[src];add=[G.id];amount=1'>(1)</A>
					<A href='?src=\ref[src];add=[G.id];amount=5'>(5)</A>
					<A href='?src=\ref[src];add=[G.id];amount=10'>(10)</A>
					<A href='?src=\ref[src];add=[G.id];amount=[G.volume]'>(All)</A>
					<A href='?src=\ref[src];addcustom=[G.id]'>(Custom)</A><BR>"}
				// END AUTOFIX

		dat += "<HR>Transfer to <A href='?src=\ref[src];toggle=1'>[(!mode ? "disposal" : "beaker")]:</A><BR>"
		if(reagents.total_volume)
			for(var/datum/reagent/N in reagents.reagent_list)

				// AUTOFIXED BY fix_string_idiocy.py
				// C:\Users\Rob\Documents\Projects\vgstation13\code\modules\reagents\Chemistry-Machinery.dm:529: dat += "[N.name] , [N.volume] Units - "
				dat += {"[N.name] , [N.volume] Units -
					<A href='?src=\ref[src];analyze=1;desc=[N.description];name=[N.name]'>(Analyze)</A>
					<A href='?src=\ref[src];remove=[N.id];amount=1'>(1)</A>
					<A href='?src=\ref[src];remove=[N.id];amount=5'>(5)</A>
					<A href='?src=\ref[src];remove=[N.id];amount=10'>(10)</A>
					<A href='?src=\ref[src];remove=[N.id];amount=[N.volume]'>(All)</A>
					<A href='?src=\ref[src];removecustom=[N.id]'>(Custom)</A><BR>"}
				// END AUTOFIX
		else
			dat += "Buffer is empty.<BR>"
		if(!condi)

			// AUTOFIXED BY fix_string_idiocy.py
			// C:\Users\Rob\Documents\Projects\vgstation13\code\modules\reagents\Chemistry-Machinery.dm:539: dat += "<HR><BR><A href='?src=\ref[src];createpill=1'>Create pill (50 units max)</A><a href=\"?src=\ref[src]&change_pill=1\"><img src=\"pill[pillsprite].png\" /></a><BR>"
			dat += {"<a href=\"?src=\ref[src]&change_pill=1\"><img src=\"pill[pillsprite].png\" /></a><a href=\"?src=\ref[src]&change_bottle=1\"><img src=\"bottle[bottlesprite].png\" /></a><BR>"}
			dat += {"<HR><BR><A href='?src=\ref[src];createpill=1'>Create single pill (50 units max)</A><BR><A href='?src=\ref[src];createpill_multiple=1'>Create multiple pills (50 units max each; 20 max)</A><BR>
				<A href='?src=\ref[src];createbottle=1'>Create bottle (30 units max)</A><BR><A href='?src=\ref[src];createbottle_multiple=1'>Create multiple bottles (30 units max each; 4 max)</A><BR>"}
			// END AUTOFIX
		else
			dat += "<A href='?src=\ref[src];createbottle=1'>Create bottle (50 units max)</A>"
	if(!condi)
		user << browse("<TITLE>Chemmaster 3000</TITLE>Chemmaster menu:<BR><BR>[dat]", "window=chem_master;size=575x400")
	else
		user << browse("<TITLE>Condimaster 3000</TITLE>Condimaster menu:<BR><BR>[dat]", "window=chem_master;size=575x400")
	onclose(user, "chem_master")
	return

/obj/machinery/chem_master/proc/isgoodnumber(var/num)
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

/obj/machinery/chem_master/condimaster
	name = "CondiMaster 3000"
	condi = 1

/obj/machinery/chem_master/update_icon()
	if(beaker)
		icon_state = "mixer1"
	else
		icon_state = "mixer0"

	var/image/overlay = image('icons/obj/chemical.dmi', src, "[icon_state]_overlay")
	if(reagents.total_volume)
		overlay.icon += mix_color_from_reagents(reagents.reagent_list)
	overlays.Cut()
	overlays += overlay

/obj/machinery/chem_master/on_reagent_change()
	update_icon()

////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////

/obj/machinery/computer/pandemic
	name = "PanD.E.M.I.C 2200"
	density = 1
	anchored = 1
	icon = 'icons/obj/chemical.dmi'
	icon_state = "mixer0"
	use_power = 1
	idle_power_usage = 20
	var/temphtml = ""
	var/wait = null
	var/obj/item/weapon/reagent_containers/glass/beaker = null

	l_color = "#0000FF"

/********************************************************************
**   Adding Stock Parts to VV so preconstructed shit has its candy **
********************************************************************/
/obj/machinery/computer/pandemic/New()
	. = ..()

	component_parts = newlist(
		/obj/item/weapon/circuitboard/pandemic
	)

	RefreshParts()


/obj/machinery/computer/pandemic/set_broken()
	icon_state = (src.beaker?"mixer1_b":"mixer0_b")
	stat |= BROKEN


/obj/machinery/computer/pandemic/power_change()

	if(stat & BROKEN)
		icon_state = (src.beaker?"mixer1_b":"mixer0_b")

	else if(powered())
		icon_state = (src.beaker?"mixer1":"mixer0")
		stat &= ~NOPOWER

	else
		spawn(rand(0, 15))
			src.icon_state = (src.beaker?"mixer1_nopower":"mixer0_nopower")
			stat |= NOPOWER


/obj/machinery/computer/pandemic/Topic(href, href_list)
	if(stat & (NOPOWER|BROKEN)) return
	if(usr.stat || usr.restrained()) return
	if(!in_range(src, usr)) return

	usr.set_machine(src)
	if(!beaker) return

	if (href_list["create_vaccine"])
		if(!src.wait)
			var/obj/item/weapon/reagent_containers/glass/bottle/B = new/obj/item/weapon/reagent_containers/glass/bottle(src.loc)
			if(B)
				var/path = href_list["create_vaccine"]
				var/vaccine_type = text2path(path)
				var/datum/disease/D = null

				if(!vaccine_type)
					D = archive_diseases[path]
					vaccine_type = path
				else
					if(vaccine_type in diseases)
						D = new vaccine_type(0, null)

				if(D)
					B.name = "[D.name] vaccine bottle"
					B.reagents.add_reagent("vaccine",15,vaccine_type)
					wait = 1
					var/datum/reagents/R = beaker.reagents
					var/datum/reagent/blood/Blood = null
					for(var/datum/reagent/blood/L in R.reagent_list)
						if(L)
							Blood = L
							break
					var/list/res = Blood.data["resistances"]
					spawn(res.len*200)
						src.wait = null
		else
			src.temphtml = "The replicator is not ready yet."
		src.updateUsrDialog()
		return
	else if (href_list["create_virus_culture"])
		if(!wait)
			var/obj/item/weapon/reagent_containers/glass/bottle/B = new/obj/item/weapon/reagent_containers/glass/bottle(src.loc)
			B.icon_state = "bottle3"
			var/type = text2path(href_list["create_virus_culture"])//the path is received as string - converting
			var/datum/disease/D = null
			if(!type)
				var/datum/disease/advance/A = archive_diseases[href_list["create_virus_culture"]]
				if(A)
					D = new A.type(0, A)
			else
				if(type in diseases) // Make sure this is a disease
					D = new type(0, null)
			var/list/data = list("viruses"=list(D))
			var/name = sanitize(input(usr,"Name:","Name the culture",D.name))
			if(!name || name == " ") name = D.name
			B.name = "[name] culture bottle"
			B.desc = "A small bottle. Contains [D.agent] culture in synthblood medium."
			B.reagents.add_reagent("blood",20,data)
			src.updateUsrDialog()
			wait = 1
			spawn(1000)
				src.wait = null
		else
			src.temphtml = "The replicator is not ready yet."
		src.updateUsrDialog()
		return
	else if (href_list["empty_beaker"])
		beaker.reagents.clear_reagents()
		src.updateUsrDialog()
		return
	else if (href_list["eject"])
		beaker.loc = src.loc
		beaker = null
		icon_state = "mixer0"
		src.updateUsrDialog()
		return
	else if(href_list["clear"])
		src.temphtml = ""
		src.updateUsrDialog()
		return
	else if(href_list["name_disease"])
		var/new_name = stripped_input(usr, "Name the Disease", "New Name", "", MAX_NAME_LEN)
		if(stat & (NOPOWER|BROKEN)) return
		if(usr.stat || usr.restrained()) return
		if(!in_range(src, usr)) return
		var/id = href_list["name_disease"]
		if(archive_diseases[id])
			var/datum/disease/advance/A = archive_diseases[id]
			A.AssignName(new_name)
			for(var/datum/disease/advance/AD in active_diseases)
				AD.Refresh()
		src.updateUsrDialog()


	else
		usr << browse(null, "window=pandemic")
		src.updateUsrDialog()
		return

	src.add_fingerprint(usr)
	return

/obj/machinery/computer/pandemic/attack_ai(mob/user as mob)
	src.add_hiddenprint(user)
	return src.attack_hand(user)

/obj/machinery/computer/pandemic/attack_paw(mob/user as mob)
	return src.attack_hand(user)

/obj/machinery/computer/pandemic/attack_hand(mob/user as mob)
	if(stat & (NOPOWER|BROKEN))
		return
	user.set_machine(src)
	var/dat = ""
	if(src.temphtml)
		dat = "[src.temphtml]<BR><BR><A href='?src=\ref[src];clear=1'>Main Menu</A>"
	else if(!beaker)

		// AUTOFIXED BY fix_string_idiocy.py
		// C:\Users\Rob\Documents\Projects\vgstation13\code\modules\reagents\Chemistry-Machinery.dm:722: dat += "Please insert beaker.<BR>"
		dat += {"Please insert beaker.<BR>
			<A href='?src=\ref[user];mach_close=pandemic'>Close</A>"}
		// END AUTOFIX
	else
		var/datum/reagents/R = beaker.reagents
		var/datum/reagent/blood/Blood = null
		for(var/datum/reagent/blood/B in R.reagent_list)
			if(B)
				Blood = B
				break
		if(!R.total_volume||!R.reagent_list.len)
			dat += "The beaker is empty<BR>"
		else if(!Blood)
			dat += "No blood sample found in beaker"
		else if(!Blood.data)
			dat += "No blood data found in beaker."
		else

			// AUTOFIXED BY fix_string_idiocy.py
			// C:\Users\Rob\Documents\Projects\vgstation13\code\modules\reagents\Chemistry-Machinery.dm:738: dat += "<h3>Blood sample data:</h3>"
			dat += {"<h3>Blood sample data:</h3>
				<b>Blood DNA:</b> [(Blood.data["blood_DNA"]||"none")]<BR>
				<b>Blood Type:</b> [(Blood.data["blood_type"]||"none")]<BR>"}
			// END AUTOFIX
			if(Blood.data["viruses"])
				var/list/vir = Blood.data["viruses"]
				if(vir.len)
					for(var/datum/disease/D in Blood.data["viruses"])
						if(!D.hidden[PANDEMIC])


							var/disease_creation = D.type
							if(istype(D, /datum/disease/advance))

								var/datum/disease/advance/A = D
								D = archive_diseases[A.GetDiseaseID()]
								disease_creation = A.GetDiseaseID()
								if(D.name == "Unknown")
									dat += "<b><a href='?src=\ref[src];name_disease=[A.GetDiseaseID()]'>Name Disease</a></b><BR>"

							if(!D)
								CRASH("We weren't able to get the advance disease from the archive.")


							// AUTOFIXED BY fix_string_idiocy.py
							// C:\Users\Rob\Documents\Projects\vgstation13\code\modules\reagents\Chemistry-Machinery.dm:762: dat += "<b>Disease Agent:</b> [D?"[D.agent] - <A href='?src=\ref[src];create_virus_culture=[disease_creation]'>Create virus culture bottle</A>":"none"]<BR>"
							dat += {"<b>Disease Agent:</b> [D?"[D.agent] - <A href='?src=\ref[src];create_virus_culture=[disease_creation]'>Create virus culture bottle</A>":"none"]<BR>
								<b>Common name:</b> [(D.name||"none")]<BR>
								<b>Description: </b> [(D.desc||"none")]<BR>
								<b>Spread:</b> [(D.spread||"none")]<BR>
								<b>Possible cure:</b> [(D.cure||"none")]<BR><BR>"}
							// END AUTOFIX
							if(istype(D, /datum/disease/advance))
								var/datum/disease/advance/A = D
								dat += "<b>Symptoms:</b> "
								var/english_symptoms = list()
								for(var/datum/symptom/S in A.symptoms)
									english_symptoms += S.name
								dat += english_list(english_symptoms)


			dat += "<BR><b>Contains antibodies to:</b> "
			if(Blood.data["resistances"])
				var/list/res = Blood.data["resistances"]
				if(res.len)
					dat += "<ul>"
					for(var/type in Blood.data["resistances"])
						var/disease_name = "Unknown"

						if(!ispath(type))
							var/datum/disease/advance/A = archive_diseases[type]
							if(A)
								disease_name = A.name
						else
							var/datum/disease/D = new type(0, null)
							disease_name = D.name

						dat += "<li>[disease_name] - <A href='?src=\ref[src];create_vaccine=[type]'>Create vaccine bottle</A></li>"
					dat += "</ul><BR>"
				else
					dat += "nothing<BR>"
			else
				dat += "nothing<BR>"

		// AUTOFIXED BY fix_string_idiocy.py
		// C:\Users\Rob\Documents\Projects\vgstation13\code\modules\reagents\Chemistry-Machinery.dm:799: dat += "<BR><A href='?src=\ref[src];eject=1'>Eject beaker</A>[((R.total_volume&&R.reagent_list.len) ? "-- <A href='?src=\ref[src];empty_beaker=1'>Empty beaker</A>":"")]<BR>"
		dat += {"<BR><A href='?src=\ref[src];eject=1'>Eject beaker</A>[((R.total_volume&&R.reagent_list.len) ? "-- <A href='?src=\ref[src];empty_beaker=1'>Empty beaker</A>":"")]<BR>
			<A href='?src=\ref[user];mach_close=pandemic'>Close</A>"}
		// END AUTOFIX
	user << browse("<TITLE>[src.name]</TITLE><BR>[dat]", "window=pandemic;size=575x400")
	onclose(user, "pandemic")
	return


/obj/machinery/computer/pandemic/attackby(var/obj/I as obj, var/mob/user as mob)
	if(istype(I, /obj/item/weapon/screwdriver))
		playsound(get_turf(src), 'sound/items/Screwdriver.ogg', 50, 1)
		if(do_after(user, 20))
			if (src.stat & BROKEN)
				user << "\blue The broken glass falls out."
				var/obj/structure/computerframe/A = new /obj/structure/computerframe(src.loc)
				getFromPool(/obj/item/weapon/shard, loc)
				var/obj/item/weapon/circuitboard/pandemic/M = new /obj/item/weapon/circuitboard/pandemic(A)
				for (var/obj/C in src)
					C.loc = src.loc
				A.circuit = M
				A.state = 3
				A.icon_state = "3"
				A.anchored = 1
				del(src)
			else
				user << "\blue You disconnect the monitor."
				var/obj/structure/computerframe/A = new /obj/structure/computerframe( src.loc )
				var/obj/item/weapon/circuitboard/pandemic/M = new /obj/item/weapon/circuitboard/pandemic(A)
				for (var/obj/C in src)
					C.loc = src.loc
				A.circuit = M
				A.state = 4
				A.icon_state = "4"
				A.anchored = 1
				del(src)
	else if(istype(I, /obj/item/weapon/reagent_containers/glass))
		if(stat & (NOPOWER|BROKEN)) return
		if(src.beaker)
			user << "A beaker is already loaded into the machine."
			return

		src.beaker =  I
		user.drop_item()
		I.loc = src
		user << "You add the beaker to the machine!"
		src.updateUsrDialog()
		icon_state = "mixer1"

	else
		..()
	return
////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////
/obj/machinery/reagentgrinder

	name = "All-In-One Grinder"
	icon = 'icons/obj/kitchen.dmi'
	icon_state = "juicer1"
	layer = 2.9
	density = 1
	anchored = 1
	use_power = 1
	idle_power_usage = 5
	active_power_usage = 100
	var/inuse = 0
	var/obj/item/weapon/reagent_containers/beaker = null
	var/limit = 10
	var/opened = 0.0
	var/list/blend_items = list (

		//Sheets
		/obj/item/stack/sheet/mineral/plasma  = list("plasma" = 20),
		/obj/item/stack/sheet/mineral/uranium = list("uranium" = 20),
		/obj/item/stack/sheet/mineral/clown   = list("banana" = 20),
		/obj/item/stack/sheet/mineral/silver  = list("silver" = 20),
		/obj/item/stack/sheet/mineral/gold    = list("gold" = 20),
		/obj/item/weapon/grown/nettle         = list("sacid" = 0),
		/obj/item/weapon/grown/deathnettle    = list("pacid" = 0),
		/obj/item/stack/sheet/charcoal        = list("charcoal" = 20),

		//Blender Stuff
		/obj/item/weapon/reagent_containers/food/snacks/grown/soybeans = list("soymilk" = 0),
		/obj/item/weapon/reagent_containers/food/snacks/grown/tomato = list("ketchup" = 0),
		/obj/item/weapon/reagent_containers/food/snacks/grown/corn = list("cornoil" = 0),
		/obj/item/weapon/reagent_containers/food/snacks/grown/wheat = list("flour" = -5),
		/obj/item/weapon/reagent_containers/food/snacks/grown/ricestalk = list("rice" = -5),
		/obj/item/weapon/reagent_containers/food/snacks/grown/cherries = list("cherryjelly" = 0),
		/obj/item/weapon/reagent_containers/food/snacks/grown/plastellium = list("plasticide" = 5),


		//archaeology!
		/obj/item/weapon/rocksliver = list("ground_rock" = 50),

		//All types that you can put into the grinder to transfer the reagents to the beaker. !Put all recipes above this.!
		/obj/item/weapon/reagent_containers/pill = list(),
		/obj/item/weapon/reagent_containers/food = list()
	)

	var/list/juice_items = list (

		//Juicer Stuff
		/obj/item/weapon/reagent_containers/food/snacks/grown/tomato = list("tomatojuice" = 0),
		/obj/item/weapon/reagent_containers/food/snacks/grown/carrot = list("carrotjuice" = 0),
		/obj/item/weapon/reagent_containers/food/snacks/grown/berries = list("berryjuice" = 0),
		/obj/item/weapon/reagent_containers/food/snacks/grown/banana = list("banana" = 0),
		/obj/item/weapon/reagent_containers/food/snacks/grown/potato = list("potato" = 0),
		/obj/item/weapon/reagent_containers/food/snacks/grown/lemon = list("lemonjuice" = 0),
		/obj/item/weapon/reagent_containers/food/snacks/grown/orange = list("orangejuice" = 0),
		/obj/item/weapon/reagent_containers/food/snacks/grown/lime = list("limejuice" = 0),
		/obj/item/weapon/reagent_containers/food/snacks/watermelonslice = list("watermelonjuice" = 0),
		/obj/item/weapon/reagent_containers/food/snacks/grown/poisonberries = list("poisonberryjuice" = 0),
	)


	var/list/holdingitems = list()

/********************************************************************
**   Adding Stock Parts to VV so preconstructed shit has its candy **
********************************************************************/
//Leaving large beakers out of the component part list to try and dodge beaker cloning.
/obj/machinery/reagentgrinder/New()
	. = ..()
	beaker = new /obj/item/weapon/reagent_containers/glass/beaker/large(src)

	component_parts = newlist(
		/obj/item/weapon/circuitboard/reagentgrinder,
		/obj/item/weapon/stock_parts/matter_bin,
		/obj/item/weapon/stock_parts/matter_bin,
		/obj/item/weapon/stock_parts/micro_laser,
		/obj/item/weapon/stock_parts/scanning_module
	)

	RefreshParts()

	return

/obj/machinery/reagentgrinder/update_icon()
	icon_state = "juicer"+num2text(!isnull(beaker))
	return


/obj/machinery/reagentgrinder/attackby(var/obj/item/O as obj, var/mob/user as mob)


	if (istype(O,/obj/item/weapon/reagent_containers/glass) || \
		istype(O,/obj/item/weapon/reagent_containers/food/drinks/drinkingglass) || \
		istype(O,/obj/item/weapon/reagent_containers/food/drinks/shaker))

		if (beaker)
			return 1
		else
			src.beaker =  O
			user.drop_item()
			O.loc = src
			update_icon()
			src.updateUsrDialog()
			return 0

	if(holdingitems && holdingitems.len >= limit)
		usr << "The machine cannot hold any more items."
		return 1

	//Fill machine with the plantbag!
	if(istype(O, /obj/item/weapon/storage/bag/plants))

		for (var/obj/item/weapon/reagent_containers/food/snacks/grown/G in O.contents)
			O.contents -= G
			G.loc = src
			holdingitems += G
			if(holdingitems && holdingitems.len >= limit) //Sanity checking so the blender doesn't overfill
				user << "You fill the All-In-One grinder to the brim."
				break

		if(!O.contents.len)
			user << "You empty the plant bag into the All-In-One grinder."

		src.updateUsrDialog()
		return 0
	else if (istype(O, /obj/item/weapon/screwdriver))
		if (!opened)
			user << "You open the maintenance hatch of [src]."
			//src.icon_state = "autolathe_t"
		else
			user << "You close the maintenance hatch of [src]."
			//src.icon_state = "autolathe"
		opened = !opened
		return 1
	else if(istype(O, /obj/item/weapon/crowbar))
		if (opened)
			if(beaker)
				user << "\red A beaker is loaded, you cannot deconstruct [src]."
				return 1
			playsound(get_turf(src), 'sound/items/Crowbar.ogg', 50, 1)
			var/obj/machinery/constructable_frame/machine_frame/M = new /obj/machinery/constructable_frame/machine_frame(src.loc)
			M.state = 2
			M.icon_state = "box_1"
			for(var/obj/I in component_parts)
				if(I.reliability != 100 && crit_fail)
					I.crit_fail = 1
				I.loc = src.loc
			del(src)
			return 1

	if (!is_type_in_list(O, blend_items) && !is_type_in_list(O, juice_items))
		user << "Cannot refine into a reagent."
		return 1

	user.before_take_item(O)
	O.loc = src
	holdingitems += O
	src.updateUsrDialog()
	return 0

/obj/machinery/reagentgrinder/attack_paw(mob/user as mob)
	return src.attack_hand(user)

/obj/machinery/reagentgrinder/attack_ai(mob/user as mob)
	return 0

/obj/machinery/reagentgrinder/attack_hand(mob/user as mob)
	user.set_machine(src)
	interact(user)

/obj/machinery/reagentgrinder/interact(mob/user as mob) // The microwave Menu
	var/is_chamber_empty = 0
	var/is_beaker_ready = 0
	var/processing_chamber = ""
	var/beaker_contents = ""
	var/dat = ""

	if(!inuse)
		for (var/obj/item/O in holdingitems)
			processing_chamber += "\A [O.name]<BR>"

		if (!processing_chamber)
			is_chamber_empty = 1
			processing_chamber = "Nothing."
		if (!beaker)
			beaker_contents = "<B>No beaker attached.</B><br>"
		else
			is_beaker_ready = 1
			beaker_contents = "<B>The beaker contains:</B><br>"
			var/anything = 0
			for(var/datum/reagent/R in beaker.reagents.reagent_list)
				anything = 1
				beaker_contents += "[R.volume] - [R.name]<br>"
			if(!anything)
				beaker_contents += "Nothing<br>"


		dat = {"
	<b>Processing chamber contains:</b><br>
	[processing_chamber]<br>
	[beaker_contents]<hr>
	"}
		if (is_beaker_ready && !is_chamber_empty && !(stat & (NOPOWER|BROKEN)))

			// AUTOFIXED BY fix_string_idiocy.py
			// C:\Users\Rob\Documents\Projects\vgstation13\code\modules\reagents\Chemistry-Machinery.dm:1016: dat += "<A href='?src=\ref[src];action=grind'>Grind the reagents</a><BR>"
			dat += {"<A href='?src=\ref[src];action=grind'>Grind the reagents</a><BR>
				<A href='?src=\ref[src];action=juice'>Juice the reagents</a><BR><BR>"}
			// END AUTOFIX
		if(holdingitems && holdingitems.len > 0)
			dat += "<A href='?src=\ref[src];action=eject'>Eject the reagents</a><BR>"
		if (beaker)
			dat += "<A href='?src=\ref[src];action=detach'>Detach the beaker</a><BR>"
	else
		dat += "Please wait..."
	user << browse("<HEAD><TITLE>All-In-One Grinder</TITLE></HEAD><TT>[dat]</TT>", "window=reagentgrinder")
	onclose(user, "reagentgrinder")
	return


/obj/machinery/reagentgrinder/Topic(href, href_list)
	if(..())
		return
	usr.set_machine(src)
	switch(href_list["action"])
		if ("grind")
			grind()
		if("juice")
			juice()
		if("eject")
			eject()
		if ("detach")
			detach()
	src.updateUsrDialog()
	return

/obj/machinery/reagentgrinder/proc/detach()

	if (usr.stat != 0)
		return
	if (!beaker)
		return
	beaker.loc = src.loc
	beaker = null
	update_icon()

/obj/machinery/reagentgrinder/proc/eject()

	if (usr.stat != 0)
		return
	if (holdingitems && holdingitems.len == 0)
		return

	for(var/obj/item/O in holdingitems)
		O.loc = src.loc
		holdingitems -= O
	holdingitems = list()

/obj/machinery/reagentgrinder/proc/is_allowed(var/obj/item/weapon/reagent_containers/O)
	for (var/i in blend_items)
		if(istype(O, i))
			return 1
	return 0

/obj/machinery/reagentgrinder/proc/get_allowed_by_id(var/obj/item/weapon/grown/O)
	for (var/i in blend_items)
		if (istype(O, i))
			return blend_items[i]

/obj/machinery/reagentgrinder/proc/get_allowed_snack_by_id(var/obj/item/weapon/reagent_containers/food/snacks/O)
	for(var/i in blend_items)
		if(istype(O, i))
			return blend_items[i]

/obj/machinery/reagentgrinder/proc/get_allowed_juice_by_id(var/obj/item/weapon/reagent_containers/food/snacks/O)
	for(var/i in juice_items)
		if(istype(O, i))
			return juice_items[i]

/obj/machinery/reagentgrinder/proc/get_grownweapon_amount(var/obj/item/weapon/grown/O)
	if (!istype(O))
		return 5
	else if (O.potency == -1)
		return 5
	else
		return round(O.potency)

/obj/machinery/reagentgrinder/proc/get_juice_amount(var/obj/item/weapon/reagent_containers/food/snacks/grown/O)
	if (!istype(O))
		return 5
	else if (O.potency == -1)
		return 5
	else
		return round(5*sqrt(O.potency))

/obj/machinery/reagentgrinder/proc/remove_object(var/obj/item/O)
	holdingitems -= O
	del(O)

/obj/machinery/reagentgrinder/proc/juice()
	power_change()
	if(stat & (NOPOWER|BROKEN))
		return
	if (!beaker || (beaker && beaker.reagents.total_volume >= beaker.reagents.maximum_volume))
		return
	playsound(get_turf(src), 'sound/machines/juicer.ogg', 20, 1)
	inuse = 1
	spawn(50)
		inuse = 0
		interact(usr)
	//Snacks
	for (var/obj/item/weapon/reagent_containers/food/snacks/O in holdingitems)
		if (beaker.reagents.total_volume >= beaker.reagents.maximum_volume)
			break

		var/allowed = get_allowed_juice_by_id(O)
		if(isnull(allowed))
			break

		for (var/r_id in allowed)

			var/space = beaker.reagents.maximum_volume - beaker.reagents.total_volume
			var/amount = get_juice_amount(O)

			beaker.reagents.add_reagent(r_id, min(amount, space))

			if (beaker.reagents.total_volume >= beaker.reagents.maximum_volume)
				break

		remove_object(O)

/obj/machinery/reagentgrinder/proc/grind()

	power_change()
	if(stat & (NOPOWER|BROKEN))
		return
	if (!beaker || (beaker && beaker.reagents.total_volume >= beaker.reagents.maximum_volume))
		return
	playsound(get_turf(src), 'sound/machines/blender.ogg', 50, 1)
	inuse = 1
	spawn(60)
		inuse = 0
		interact(usr)
	//Snacks and Plants
	for (var/obj/item/weapon/reagent_containers/food/snacks/O in holdingitems)
		if (beaker.reagents.total_volume >= beaker.reagents.maximum_volume)
			break

		var/allowed = get_allowed_snack_by_id(O)
		if(isnull(allowed))
			break

		for (var/r_id in allowed)

			var/space = beaker.reagents.maximum_volume - beaker.reagents.total_volume
			var/amount = allowed[r_id]
			if(amount <= 0)
				if(amount == 0)
					if (O.reagents != null && O.reagents.has_reagent("nutriment"))
						beaker.reagents.add_reagent(r_id, min(O.reagents.get_reagent_amount("nutriment"), space))
						O.reagents.remove_reagent("nutriment", min(O.reagents.get_reagent_amount("nutriment"), space))
				else
					if (O.reagents != null && O.reagents.has_reagent("nutriment"))
						beaker.reagents.add_reagent(r_id, min(round(O.reagents.get_reagent_amount("nutriment")*abs(amount)), space))
						O.reagents.remove_reagent("nutriment", min(O.reagents.get_reagent_amount("nutriment"), space))

			else
				O.reagents.trans_id_to(beaker, r_id, min(amount, space))

			if (beaker.reagents.total_volume >= beaker.reagents.maximum_volume)
				break

		if(O.reagents.reagent_list.len == 0)
			remove_object(O)

	//Sheets
	for (var/obj/item/stack/sheet/O in holdingitems)
		var/allowed = get_allowed_by_id(O)
		if (beaker.reagents.total_volume >= beaker.reagents.maximum_volume)
			break
		for(var/i = 1; i <= round(O.amount, 1); i++)
			for (var/r_id in allowed)
				var/space = beaker.reagents.maximum_volume - beaker.reagents.total_volume
				var/amount = allowed[r_id]
				beaker.reagents.add_reagent(r_id,min(amount, space))
				if (space < amount)
					break
			if (i == round(O.amount, 1))
				remove_object(O)
				break
	//Plants
	for (var/obj/item/weapon/grown/O in holdingitems)
		if (beaker.reagents.total_volume >= beaker.reagents.maximum_volume)
			break
		var/allowed = get_allowed_by_id(O)
		for (var/r_id in allowed)
			var/space = beaker.reagents.maximum_volume - beaker.reagents.total_volume
			var/amount = allowed[r_id]
			if (amount == 0)
				if (O.reagents != null && O.reagents.has_reagent(r_id))
					beaker.reagents.add_reagent(r_id,min(O.reagents.get_reagent_amount(r_id), space))
			else
				beaker.reagents.add_reagent(r_id,min(amount, space))

			if (beaker.reagents.total_volume >= beaker.reagents.maximum_volume)
				break
		remove_object(O)

	//xenoarch
	for(var/obj/item/weapon/rocksliver/O in holdingitems)
		if (beaker.reagents.total_volume >= beaker.reagents.maximum_volume)
			break
		var/allowed = get_allowed_by_id(O)
		for (var/r_id in allowed)
			var/space = beaker.reagents.maximum_volume - beaker.reagents.total_volume
			var/amount = allowed[r_id]
			beaker.reagents.add_reagent(r_id,min(amount, space), O.geological_data)

			if (beaker.reagents.total_volume >= beaker.reagents.maximum_volume)
				break
		remove_object(O)

	//Everything else - Transfers reagents from it into beaker
	for (var/obj/item/weapon/reagent_containers/O in holdingitems)
		if (beaker.reagents.total_volume >= beaker.reagents.maximum_volume)
			break
		var/amount = O.reagents.total_volume
		O.reagents.trans_to(beaker, amount)
		if(!O.reagents.total_volume)
			remove_object(O)
