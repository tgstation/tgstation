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
	var/energy = 50
	var/max_energy = 50
	var/amount = 30
	var/beaker = null
	var/recharged = 0
	var/list/dispensable_reagents = list("hydrogen","lithium","carbon","nitrogen","oxygen","fluorine",
	"sodium","aluminum","silicon","phosphorus","sulfur","chlorine","potassium","iron",
	"copper","mercury","radium","water","ethanol","sugar","sacid")

/obj/machinery/chem_dispenser/proc/recharge()
	if(stat & (BROKEN|NOPOWER)) return
	var/addenergy = 1
	var/oldenergy = energy
	energy = min(energy + addenergy, max_energy)
	if(energy != oldenergy)
		use_power(1500) // This thing uses up alot of power (this is still low as shit for creating reagents from thin air)
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
			del(src)
			return
		if(2.0)
			if (prob(50))
				del(src)
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
  *
  * @return nothing
  */
/obj/machinery/chem_dispenser/ui_interact(mob/user, ui_key = "main")
	if(stat & (BROKEN|NOPOWER)) return
	if(user.stat || user.restrained()) return

	// this is the data which will be sent to the ui
	var/data[0]
	data["amount"] = amount
	data["energy"] = energy
	data["maxEnergy"] = max_energy
	data["isBeakerLoaded"] = beaker ? 1 : 0

	var beakerContents[0]
	var beakerCurrentVolume = 0
	if(beaker && beaker:reagents && beaker:reagents.reagent_list.len)
		for(var/datum/reagent/R in beaker:reagents.reagent_list)
			beakerContents.Add(list(list("name" = R.name, "volume" = R.volume))) // list in a list because Byond merges the first list...
			beakerCurrentVolume += R.volume
	data["beakerContents"] = beakerContents

	if (beaker)
		data["beakerCurrentVolume"] = beakerCurrentVolume
		data["beakerMaxVolume"] = beaker:volume
	else
		data["beakerCurrentVolume"] = null
		data["beakerMaxVolume"] = null

	var chemicals[0]
	for (var/re in dispensable_reagents)
		var/datum/reagent/temp = chemical_reagents_list[re]
		if(temp)
			chemicals.Add(list(list("title" = temp.name, "id" = temp.id, "commands" = list("dispense" = temp.id)))) // list in a list because Byond merges the first list...
	data["chemicals"] = chemicals

	var/datum/nanoui/ui = nanomanager.get_open_ui(user, src, ui_key)
	if (!ui)
		// the ui does not exist, so we'll create a new one
		ui = new(user, src, ui_key, "chem_dispenser.tmpl", "Chem Dispenser 5000", 370, 585)
		// When the UI is first opened this is the data it will use
		ui.set_initial_data(data)
		ui.open()
	else
		// The UI is already open so push the new data to it
		ui.push_data(data)
		return

/obj/machinery/chem_dispenser/Topic(href, href_list)
	if(stat & (NOPOWER|BROKEN))
		return 0 // don't update UIs attached to this object

	if(href_list["amount"])
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

/obj/machinery/chem_dispenser/attackby(var/obj/item/weapon/reagent_containers/glass/B as obj, var/mob/user as mob)
	if(isrobot(user))
		return

	if(!istype(B, /obj/item/weapon/reagent_containers/glass))
		return

	if(src.beaker)
		user << "A beaker is already loaded into the machine."
		return

	src.beaker =  B
	user.drop_item()
	B.loc = src
	user << "You add the beaker to the machine!"
	nanomanager.update_uis(src) // update all UIs attached to src

/obj/machinery/chem_dispenser/attack_ai(mob/user as mob)
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
	var/beaker = null
	var/obj/item/weapon/storage/pill_bottle/loaded_pill_bottle = null
	var/mode = 0
	var/condi = 0
	var/useramount = 30 // Last used amount

/obj/machinery/chem_master/New()
	create_reagents(100)

/obj/machinery/chem_master/ex_act(severity)
	switch(severity)
		if(1.0)
			del(src)
			return
		if(2.0)
			if (prob(50))
				del(src)
				return

/obj/machinery/chem_master/blob_act()
	if (prob(50))
		del(src)

/obj/machinery/chem_master/meteorhit()
	del(src)
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
		icon_state = "mixer1"

	else if(istype(B, /obj/item/weapon/storage/pill_bottle))

		if(src.loaded_pill_bottle)
			user << "A pill bottle is already loaded into the machine."
			return

		src.loaded_pill_bottle = B
		user.drop_item()
		B.loc = src
		user << "You add the pill bottle into the dispenser slot!"
		src.updateUsrDialog()
	return

/obj/machinery/chem_master/Topic(href, href_list)
	if(..())
		return

	usr.set_machine(src)


	if (href_list["ejectp"])
		if(loaded_pill_bottle)
			loaded_pill_bottle.loc = src.loc
			loaded_pill_bottle = null
	else if(href_list["close"])
		usr << browse(null, "window=chem_master")
		usr.unset_machine()
		return

	if(beaker)
		var/datum/reagents/R = beaker:reagents
		if (href_list["analyze"])
			var/dat = ""
			if(!condi)
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
				beaker:loc = src.loc
				beaker = null
				reagents.clear_reagents()
				icon_state = "mixer0"
		else if (href_list["createpill"])
			var/name = reject_bad_text(input(usr,"Name:","Name your pill!",reagents.get_master_reagent_name()))
			var/obj/item/weapon/reagent_containers/pill/P

			if(loaded_pill_bottle && loaded_pill_bottle.contents.len < loaded_pill_bottle.storage_slots)
				P = new/obj/item/weapon/reagent_containers/pill(loaded_pill_bottle)
			else
				P = new/obj/item/weapon/reagent_containers/pill(src.loc)

			if(!name) name = reagents.get_master_reagent_name()
			P.name = "[name] pill"
			P.pixel_x = rand(-7, 7) //random position
			P.pixel_y = rand(-7, 7)
			reagents.trans_to(P,50)

		else if (href_list["createbottle"])
			if(!condi)
				var/name = reject_bad_text(input(usr,"Name:","Name your bottle!",reagents.get_master_reagent_name()))
				var/obj/item/weapon/reagent_containers/glass/bottle/P = new/obj/item/weapon/reagent_containers/glass/bottle(src.loc)
				if(!name) name = reagents.get_master_reagent_name()
				P.name = "[name] bottle"
				P.pixel_x = rand(-7, 7) //random position
				P.pixel_y = rand(-7, 7)
				reagents.trans_to(P,30)
			else
				var/obj/item/weapon/reagent_containers/food/condiment/P = new/obj/item/weapon/reagent_containers/food/condiment(src.loc)
				reagents.trans_to(P,50)

	src.updateUsrDialog()
	return

/obj/machinery/chem_master/attack_ai(mob/user as mob)
	return src.attack_hand(user)

/obj/machinery/chem_master/attack_paw(mob/user as mob)
	return src.attack_hand(user)

/obj/machinery/chem_master/attack_hand(mob/user as mob)
	if(stat & BROKEN)
		return
	user.set_machine(src)
	var/dat = ""
	if(!beaker)
		dat = "Please insert beaker.<BR>"
		if(src.loaded_pill_bottle)
			dat += "<A href='?src=\ref[src];ejectp=1'>Eject Pill Bottle \[[loaded_pill_bottle.contents.len]/[loaded_pill_bottle.storage_slots]\]</A><BR><BR>"
		else
			dat += "No pill bottle inserted.<BR><BR>"
		dat += "<A href='?src=\ref[src];close=1'>Close</A>"
	else
		var/datum/reagents/R = beaker:reagents
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
		if(!condi)
			dat += "<HR><BR><A href='?src=\ref[src];createpill=1'>Create pill (50 units max)</A><BR>"
			dat += "<A href='?src=\ref[src];createbottle=1'>Create bottle (30 units max)</A>"
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

////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////

/obj/machinery/computer/pandemic
	name = "PanD.E.M.I.C 2200"
	density = 1
	anchored = 1
	icon = 'icons/obj/chemical.dmi'
	icon_state = "mixer0"
	circuit = "/obj/item/weapon/circuitboard/pandemic"
	use_power = 1
	idle_power_usage = 20
	var/temp_html = ""
	var/wait = null
	var/obj/item/weapon/reagent_containers/glass/beaker = null

obj/machinery/computer/pandemic/New()
	..()
	update_icon()

/obj/machinery/computer/pandemic/set_broken()
	icon_state = (src.beaker?"mixer1_b":"mixer0_b")
	overlays.Cut()
	stat |= BROKEN

/obj/machinery/computer/pandemic/proc/GetVirusByIndex(var/index)
	if(beaker && beaker.reagents)
		if(beaker.reagents.reagent_list.len)
			var/datum/reagent/blood/BL = locate() in beaker.reagents.reagent_list
			if(BL)
				if(BL.data && BL.data["viruses"])
					var/list/viruses = BL.data["viruses"]
					return viruses[index]
	return null

/obj/machinery/computer/pandemic/proc/GetResistancesByIndex(var/index)
	if(beaker && beaker.reagents)
		if(beaker.reagents.reagent_list.len)
			var/datum/reagent/blood/BL = locate() in beaker.reagents.reagent_list
			if(BL)
				if(BL.data && BL.data["resistances"])
					var/list/resistances = BL.data["resistances"]
					return resistances[index]
	return null

/obj/machinery/computer/pandemic/proc/GetVirusTypeByIndex(var/index)
	var/datum/disease/D = GetVirusByIndex(index)
	if(D)
		return D.GetDiseaseID()
	return null

obj/machinery/computer/pandemic/proc/replicator_cooldown(var/waittime)
	wait = 1
	update_icon()
	spawn(waittime)
		src.wait = null
		update_icon()
		playsound(src.loc, 'sound/items/timer.ogg', 30, 1)

/obj/machinery/computer/pandemic/update_icon()
	if(stat & BROKEN)
		icon_state = (src.beaker?"mixer1_b":"mixer0_b")
		return

	icon_state = "mixer[(beaker)?"1":"0"][(powered()) ? "" : "_nopower"]"

	if(wait)
		overlays.Cut()
	else
		overlays += "waitlight"

/obj/machinery/computer/pandemic/Topic(href, href_list)
	if(..())
		return

	usr.set_machine(src)
	if(!beaker) return

	if (href_list["create_vaccine"])
		if(!src.wait)
			var/obj/item/weapon/reagent_containers/glass/bottle/B = new/obj/item/weapon/reagent_containers/glass/bottle(src.loc)
			if(B)

				var/path = GetResistancesByIndex(text2num(href_list["create_vaccine"]))
				var/vaccine_type = path
				var/vaccine_name = "Unknown"

				if(!ispath(vaccine_type))
					if(archive_diseases[path])
						var/datum/disease/D = archive_diseases[path]
						if(D)
							vaccine_name = D.name
							vaccine_type = path
				else if(vaccine_type)
					var/datum/disease/D = new vaccine_type(0, null)
					if(D)
						vaccine_name = D.name

				if(vaccine_type)

					B.name = "[vaccine_name] vaccine bottle"
					B.reagents.add_reagent("vaccine", 15, list(vaccine_type))
					replicator_cooldown(200)
		else
			src.temp_html = "The replicator is not ready yet."
		src.updateUsrDialog()
		return
	else if (href_list["create_virus_culture"])
		if(!wait)
			var/obj/item/weapon/reagent_containers/glass/bottle/B = new/obj/item/weapon/reagent_containers/glass/bottle(src.loc)
			B.icon_state = "bottle3"
			var/type = GetVirusTypeByIndex(text2num(href_list["create_virus_culture"]))//the path is received as string - converting
			var/datum/disease/D = null
			if(!ispath(type))
				D = GetVirusByIndex(text2num(href_list["create_virus_culture"]))
				var/datum/disease/advance/A = archive_diseases[D.GetDiseaseID()]
				if(A)
					D = new A.type(0, A)
			else if(type)
				if(type in diseases) // Make sure this is a disease
					D = new type(0, null)
			if(!D)
				return
			var/list/data = list("viruses"=list(D))
			var/name = sanitize(input(usr,"Name:","Name the culture",D.name))
			if(!name || name == " ") name = D.name
			B.name = "[name] culture bottle"
			B.desc = "A small bottle. Contains [D.agent] culture in synthblood medium."
			B.reagents.add_reagent("blood",20,data)
			src.updateUsrDialog()
			replicator_cooldown(1000)
		else
			src.temp_html = "The replicator is not ready yet."
		src.updateUsrDialog()
		return
	else if (href_list["empty_beaker"])
		beaker.reagents.clear_reagents()
		src.updateUsrDialog()
		return
	else if (href_list["eject"])
		beaker:loc = src.loc
		beaker = null
		icon_state = "mixer0"
		src.updateUsrDialog()
		return
	else if(href_list["clear"])
		src.temp_html = ""
		src.updateUsrDialog()
		return
	else if(href_list["name_disease"])
		var/new_name = stripped_input(usr, "Name the Disease", "New Name", "", MAX_NAME_LEN)
		if(..())
			return
		var/id = GetVirusTypeByIndex(text2num(href_list["name_disease"]))
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

/obj/machinery/computer/pandemic/attack_hand(mob/user as mob)
	if(..())
		return
	user.set_machine(src)
	var/dat = ""
	if(src.temp_html)
		dat = "[src.temp_html]<BR><BR><A href='?src=\ref[src];clear=1'>Main Menu</A>"
	else if(!beaker)
		dat += "Please insert beaker.<BR>"
		dat += "<A href='?src=\ref[user];mach_close=pandemic'>Close</A>"
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
			dat += "<h3>Blood sample data:</h3>"
			dat += "<b>Blood DNA:</b> [(Blood.data["blood_DNA"]||"none")]<BR>"
			dat += "<b>Blood Type:</b> [(Blood.data["blood_type"]||"none")]<BR>"


			if(Blood.data["viruses"])
				var/list/vir = Blood.data["viruses"]
				if(vir.len)
					var/i = 0
					for(var/datum/disease/D in Blood.data["viruses"])
						i++
						if(!D.hidden[PANDEMIC])

							if(istype(D, /datum/disease/advance))

								var/datum/disease/advance/A = D
								D = archive_diseases[A.GetDiseaseID()]
								if(D && D.name == "Unknown")
									dat += "<b><a href='?src=\ref[src];name_disease=[i]'>Name Disease</a></b><BR>"

							if(!D)
								CRASH("We weren't able to get the advance disease from the archive.")

							dat += "<b>Disease Agent:</b> [D?"[D.agent] - <A href='?src=\ref[src];create_virus_culture=[i]'>Create virus culture bottle</A>":"none"]<BR>"
							dat += "<b>Common name:</b> [(D.name||"none")]<BR>"
							dat += "<b>Description: </b> [(D.desc||"none")]<BR>"
							dat += "<b>Spread:</b> [(D.spread||"none")]<BR>"
							dat += "<b>Possible cure:</b> [(D.cure||"none")]<BR><BR>"

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
					var/i = 0
					for(var/type in Blood.data["resistances"])
						i++
						var/disease_name = "Unknown"

						if(!ispath(type))
							var/datum/disease/advance/A = archive_diseases[type]
							if(A)
								disease_name = A.name
						else
							var/datum/disease/D = new type(0, null)
							disease_name = D.name

						dat += "<li>[disease_name] - <A href='?src=\ref[src];create_vaccine=[i]'>Create vaccine bottle</A></li>"
					dat += "</ul><BR>"
				else
					dat += "nothing<BR>"
			else
				dat += "nothing<BR>"
		dat += "<BR><A href='?src=\ref[src];eject=1'>Eject beaker</A>[((R.total_volume&&R.reagent_list.len) ? "-- <A href='?src=\ref[src];empty_beaker=1'>Empty beaker</A>":"")]<BR>"
		dat += "<A href='?src=\ref[user];mach_close=pandemic'>Close</A>"

	user << browse("<TITLE>[src.name]</TITLE><BR>[dat]", "window=pandemic;size=575x400")
	onclose(user, "pandemic")
	return


/obj/machinery/computer/pandemic/attackby(var/obj/I as obj, var/mob/user as mob)
	if(istype(I, /obj/item/weapon/reagent_containers/glass))
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

	else if(istype(I, /obj/item/weapon/screwdriver))
		if(src.beaker)
			beaker.loc = get_turf(src)
		..()
		return
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
		var/list/blend_items = list (

				//Sheets
				/obj/item/stack/sheet/mineral/plasma = list("plasma" = 20),
				/obj/item/stack/sheet/metal = list("iron" = 20),
				/obj/item/stack/sheet/plasteel = list("iron" = 20, "plasma" = 20),
				/obj/item/stack/sheet/wood = list("carbon" = 20),
				/obj/item/stack/sheet/glass = list("silicon" = 20),
				/obj/item/stack/sheet/rglass = list("silicon" = 20, "iron" = 20),
				/obj/item/stack/sheet/mineral/uranium = list("uranium" = 20),
				/obj/item/stack/sheet/mineral/clown = list("banana" = 20),
				/obj/item/stack/sheet/mineral/silver = list("silver" = 20),
				/obj/item/stack/sheet/mineral/gold = list("gold" = 20),
				/obj/item/weapon/grown/nettle = list("sacid" = 0),
				/obj/item/weapon/grown/deathnettle = list("pacid" = 0),
				/obj/item/weapon/grown/novaflower = list("capsaicin" = 0),

				//Crayons (for overriding colours)
				/obj/item/toy/crayon/red = list("redcrayonpowder" = 10),
				/obj/item/toy/crayon/orange = list("orangecrayonpowder" = 10),
				/obj/item/toy/crayon/yellow = list("yellowcrayonpowder" = 10),
				/obj/item/toy/crayon/green = list("greencrayonpowder" = 10),
				/obj/item/toy/crayon/blue = list("bluecrayonpowder" = 10),
				/obj/item/toy/crayon/purple = list("purplecrayonpowder" = 10),

				//Blender Stuff
				/obj/item/weapon/reagent_containers/food/snacks/grown/soybeans = list("soymilk" = 0),
				/obj/item/weapon/reagent_containers/food/snacks/grown/tomato = list("ketchup" = 0),
				/obj/item/weapon/reagent_containers/food/snacks/grown/corn = list("cornoil" = 0),
				/obj/item/weapon/reagent_containers/food/snacks/grown/wheat = list("flour" = -5),
				/obj/item/weapon/reagent_containers/food/snacks/grown/cherries = list("cherryjelly" = 0),



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

/obj/machinery/reagentgrinder/New()
		..()
		beaker = new /obj/item/weapon/reagent_containers/glass/beaker/large(src)
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
				usr << "The machine cannot hold anymore items."
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
						dat += "<A href='?src=\ref[src];action=grind'>Grind the reagents</a><BR>"
						dat += "<A href='?src=\ref[src];action=juice'>Juice the reagents</a><BR><BR>"
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

/obj/machinery/reagentgrinder/proc/get_allowed_by_id(var/obj/item/O)
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
		playsound(src.loc, 'sound/machines/juicer.ogg', 20, 1)
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
		playsound(src.loc, 'sound/machines/blender.ogg', 50, 1)
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


		//Crayons
		//With some input from aranclanos, now 30% less shoddily copypasta
		for (var/obj/item/toy/crayon/O in holdingitems)
				if (beaker.reagents.total_volume >= beaker.reagents.maximum_volume)
						break
				var/allowed = get_allowed_by_id(O)
				for (var/r_id in allowed)
						var/space = beaker.reagents.maximum_volume - beaker.reagents.total_volume
						var/amount = allowed[r_id]
						beaker.reagents.add_reagent(r_id,min(amount, space))
						if (space < amount)
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
