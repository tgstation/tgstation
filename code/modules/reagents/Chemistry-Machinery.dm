#define SOLID 1
#define LIQUID 2
#define GAS 3

/obj/machinery/chem_dispenser
	name = "chem dispenser"
	desc = "Creates and dispenses chemicals."
	density = 1
	anchored = 1
	icon = 'icons/obj/chemical.dmi'
	icon_state = "dispenser"
	use_power = 1
	idle_power_usage = 40
	var/energy = 100
	var/max_energy = 100
	var/amount = 30
	var/beaker = null
	var/recharged = 0
	var/recharge_delay = 5  //Time it game ticks between recharges
	var/image/icon_beaker = null //cached overlay
	var/uiname = "Chem Dispenser 5000"
	var/list/dispensable_reagents = list("hydrogen","lithium","carbon","nitrogen","oxygen","fluorine",
	"sodium","aluminium","silicon","phosphorus","sulfur","chlorine","potassium","iron",
	"copper","mercury","radium","water","ethanol","sugar","sacid","welding_fuel","silver","iodine","bromine","stable_plasma")

/obj/machinery/chem_dispenser/proc/recharge()
	if(stat & (BROKEN|NOPOWER)) return
	var/addenergy = 1
	var/oldenergy = energy
	energy = min(energy + addenergy, max_energy)
	if(energy != oldenergy)
		use_power(1500) // This thing uses up alot of power (this is still low as shit for creating reagents from thin air)
		SSnano.update_uis(src) // update all UIs attached to src

/obj/machinery/chem_dispenser/power_change()
	if(powered())
		stat &= ~NOPOWER
	else
		spawn(rand(0, 15))
			stat |= NOPOWER
	SSnano.update_uis(src) // update all UIs attached to src

/obj/machinery/chem_dispenser/process()

	if(recharged < 0)
		recharge()
		recharged = recharge_delay
	else
		recharged -= 1

/obj/machinery/chem_dispenser/New()
	..()
	recharge()
	dispensable_reagents = sortList(dispensable_reagents)

/obj/machinery/chem_dispenser/ex_act(severity, target)
	if(severity < 3)
		..()

/obj/machinery/chem_dispenser/blob_act()
	if(prob(50))
		qdel(src)

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
/obj/machinery/chem_dispenser/ui_interact(mob/user, ui_key = "main", var/datum/nanoui/ui = null)
	if(stat & (BROKEN)) return
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

	// update the ui if it exists, returns null if no ui is passed/found
	ui = SSnano.try_update_ui(user, src, ui_key, ui, data)
	if (!ui)
		// the ui does not exist, so we'll create a new() one
        // for a list of parameters and their descriptions see the code docs in \code\modules\nano\nanoui.dm
		ui = new(user, src, ui_key, "chem_dispenser.tmpl", "[uiname]", 490, 710)
		// when the ui is first opened this is the data it will use
		ui.set_initial_data(data)
		// open the new ui window
		ui.open()

/obj/machinery/chem_dispenser/Topic(href, href_list)
	if(stat & (BROKEN))
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
			overlays.Cut()

	add_fingerprint(usr)
	return 1 // update UIs attached to this object

/obj/machinery/chem_dispenser/attackby(var/obj/item/weapon/reagent_containers/glass/B as obj, var/mob/user as mob, params)
	if(isrobot(user))
		return

	if(!istype(B, /obj/item/weapon/reagent_containers/glass))
		return

	if(src.beaker)
		user << "<span class='warning'>A beaker is already loaded into the machine!</span>"
		return

	src.beaker =  B
	user.drop_item()
	B.loc = src
	user << "<span class='notice'>You add the beaker to the machine.</span>"
	SSnano.update_uis(src) // update all UIs attached to src

	if(!icon_beaker)
		icon_beaker = image('icons/obj/chemical.dmi', src, "disp_beaker") //randomize beaker overlay position.
	icon_beaker.pixel_x = rand(-10,5)
	overlays += icon_beaker

/obj/machinery/chem_dispenser/attack_ai(mob/user as mob)
	return src.attack_hand(user)

/obj/machinery/chem_dispenser/attack_paw(mob/user as mob)
	return src.attack_hand(user)

/obj/machinery/chem_dispenser/attack_hand(mob/user as mob)
	if(stat & BROKEN)
		return

	ui_interact(user)

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

/obj/machinery/chem_dispenser/constructable
	name = "portable chem dispenser"
	icon = 'icons/obj/chemical.dmi'
	icon_state = "minidispenser"
	energy = 5
	max_energy = 5
	amount = 5
	recharge_delay = 30
	dispensable_reagents = list()
	var/list/special_reagents = list(list("hydrogen", "oxygen", "silicon", "phosphorus", "sulfur", "carbon", "nitrogen", "water"),
						 		list("lithium", "sugar", "sacid", "copper", "mercury", "sodium","iodine","bromine"),
								list("ethanol", "chlorine", "potassium", "aluminium", "radium", "fluorine", "iron", "welding_fuel","silver","stable_plasma"))

/obj/machinery/chem_dispenser/constructable/New()
	..()
	component_parts = list()
	component_parts += new /obj/item/weapon/circuitboard/chem_dispenser(null)
	component_parts += new /obj/item/weapon/stock_parts/matter_bin(null)
	component_parts += new /obj/item/weapon/stock_parts/matter_bin(null)
	component_parts += new /obj/item/weapon/stock_parts/manipulator(null)
	component_parts += new /obj/item/weapon/stock_parts/capacitor(null)
	component_parts += new /obj/item/weapon/stock_parts/console_screen(null)
	component_parts += new /obj/item/weapon/stock_parts/cell/high(null)
	RefreshParts()

/obj/machinery/chem_dispenser/constructable/RefreshParts()
	var/time = 0
	var/temp_energy = 0
	var/i
	for(var/obj/item/weapon/stock_parts/matter_bin/M in component_parts)
		temp_energy += M.rating
	temp_energy--
	max_energy = temp_energy * 5  //max energy = (bin1.rating + bin2.rating - 1) * 5, 5 on lowest 25 on highest
	for(var/obj/item/weapon/stock_parts/capacitor/C in component_parts)
		time += C.rating
	for(var/obj/item/weapon/stock_parts/cell/P in component_parts)
		time += round(P.maxcharge, 10000) / 10000
	recharge_delay /= time/2         //delay between recharges, double the usual time on lowest 50% less than usual on highest
	for(var/obj/item/weapon/stock_parts/manipulator/M in component_parts)
		for(i=1, i<=M.rating, i++)
			dispensable_reagents = sortList(dispensable_reagents | special_reagents[i])

/obj/machinery/chem_dispenser/constructable/attackby(var/obj/item/I, var/mob/user, params)
	..()
	if(default_deconstruction_screwdriver(user, "minidispenser-o", "minidispenser", I))
		return

	if(exchange_parts(user, I))
		return

	if(panel_open)
		if(istype(I, /obj/item/weapon/crowbar))
			if(beaker)
				var/obj/item/weapon/reagent_containers/glass/B = beaker
				B.loc = loc
				beaker = null
			default_deconstruction_crowbar(I)
			return 1


//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

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
	var/obj/item/weapon/storage/pill_bottle/loaded_pill_bottle = null
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


/obj/machinery/chem_master/attackby(var/obj/item/B as obj, var/mob/user as mob, params)

	if(default_unfasten_wrench(user, B))
		return

	if(istype(B, /obj/item/weapon/reagent_containers/glass))
		if(src.beaker)
			user << "<span class='warning'>A beaker is already loaded into the machine!</span>"
			return
		src.beaker = B
		user.drop_item()
		B.loc = src
		user << "<span class='notice'>You add the beaker to the machine.</span>"
		src.updateUsrDialog()
		icon_state = "mixer1"

	else if(!condi && istype(B, /obj/item/weapon/storage/pill_bottle))
		if(src.loaded_pill_bottle)
			user << "<span class='warning'>A pill bottle is already loaded into the machine!</span>"
			return
		src.loaded_pill_bottle = B
		user.drop_item()
		B.loc = src
		user << "<span class='notice'>You add the pill bottle into the dispenser slot.</span>"
		src.updateUsrDialog()

	return

/obj/machinery/chem_master/Topic(href, href_list)
	if(..())
		return

	usr.set_machine(src)

	if(href_list["ejectp"])
		if(loaded_pill_bottle)
			loaded_pill_bottle.loc = src.loc
			loaded_pill_bottle = null

	else if(href_list["close"])
		usr << browse(null, "window=chem_master")
		usr.unset_machine()
		return

	else if(href_list["toggle"])
		mode = !mode

	else if(href_list["createbottle"])
		if(!condi)
			var/name = stripped_input(usr, "Name:","Name your bottle!", (reagents.total_volume ? reagents.get_master_reagent_name() : " "), MAX_NAME_LEN)
			if(!name)
				return
			var/obj/item/weapon/reagent_containers/glass/bottle/P = new/obj/item/weapon/reagent_containers/glass/bottle(src.loc)
			P.name = trim("[name] bottle")
			P.pixel_x = rand(-7, 7) //random position
			P.pixel_y = rand(-7, 7)
			reagents.trans_to(P, 30)
		else
			var/obj/item/weapon/reagent_containers/food/condiment/P = new/obj/item/weapon/reagent_containers/food/condiment(src.loc)
			reagents.trans_to(P, 50)

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
					if(loaded_pill_bottle && loaded_pill_bottle.contents.len < loaded_pill_bottle.storage_slots)
						P = new/obj/item/weapon/reagent_containers/pill(loaded_pill_bottle)
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

/obj/machinery/chem_master/attack_ai(mob/user as mob)
	return src.attack_hand(user)

/obj/machinery/chem_master/attack_paw(mob/user as mob)
	return src.attack_hand(user)

/obj/machinery/chem_master/attack_hand(mob/user as mob)
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
		if(src.loaded_pill_bottle)
			dat += "Pill Bottle \[[loaded_pill_bottle.contents.len]/[loaded_pill_bottle.storage_slots]\] <A href='?src=\ref[src];ejectp=1'>Eject</A>"
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

/obj/machinery/chem_master/proc/isgoodnumber(var/num)
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

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

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

/obj/machinery/chem_master/constructable/attackby(var/obj/item/B as obj, var/mob/user as mob, params)

	if(default_deconstruction_screwdriver(user, "mixer0_nopower", "mixer0", B))
		if(beaker)
			beaker.loc = src.loc
			beaker = null
			reagents.clear_reagents()
		if(loaded_pill_bottle)
			loaded_pill_bottle.loc = src.loc
			loaded_pill_bottle = null
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
		if(src.beaker)
			user << "<span class='warning'>A beaker is already loaded into the machine!</span>"
			return
		src.beaker = B
		user.drop_item()
		B.loc = src
		user << "<span class='notice'>You add the beaker to the machine.</span>"
		src.updateUsrDialog()
		icon_state = "mixer1"

	else if(!condi && istype(B, /obj/item/weapon/storage/pill_bottle))
		if(src.loaded_pill_bottle)
			user << "<span class='warning'>A pill bottle is already loaded into the machine!</span>"
			return
		src.loaded_pill_bottle = B
		user.drop_item()
		B.loc = src
		user << "<span class='notice'>You add the pill bottle into the dispenser slot.</span>"
		src.updateUsrDialog()

	return

////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////

/obj/machinery/computer/pandemic
	name = "PanD.E.M.I.C 2200"
	desc = "Used to work with viruses."
	density = 1
	anchored = 1
	icon = 'icons/obj/chemical.dmi'
	icon_state = "mixer0"
	circuit = /obj/item/weapon/circuitboard/pandemic
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
		playsound(src.loc, 'sound/machines/ping.ogg', 30, 1)

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
				B.pixel_x = rand(-3, 3)
				B.pixel_y = rand(-3, 3)
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
			var/name = stripped_input(usr,"Name:","Name the culture",D.name,MAX_NAME_LEN)
			if(name == null || wait)
				return
			var/obj/item/weapon/reagent_containers/glass/bottle/B = new/obj/item/weapon/reagent_containers/glass/bottle(src.loc)
			B.icon_state = "bottle3"
			B.pixel_x = rand(-3, 3)
			B.pixel_y = rand(-3, 3)
			replicator_cooldown(50)
			var/list/data = list("viruses"=list(D))
			B.name = "[name] culture bottle"
			B.desc = "A small bottle. Contains [D.agent] culture in synthblood medium."
			B.reagents.add_reagent("blood",20,data)
			src.updateUsrDialog()
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
		if(!new_name)
			return
		if(..())
			return
		var/id = GetVirusTypeByIndex(text2num(href_list["name_disease"]))
		if(archive_diseases[id])
			var/datum/disease/advance/A = archive_diseases[id]
			A.AssignName(new_name)
			for(var/datum/disease/advance/AD in SSdisease.processing)
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
			dat += "No blood sample found in beaker."
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
						if(!(D.visibility_flags & HIDDEN_PANDEMIC))

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
							dat += "<b>Spread:</b> [(D.spread_text||"none")]<BR>"
							dat += "<b>Possible cure:</b> [(D.cure_text||"none")]<BR><BR>"

							if(istype(D, /datum/disease/advance))
								var/datum/disease/advance/A = D
								dat += "<b>Symptoms:</b> "
								var/english_symptoms = list()
								for(var/datum/symptom/S in A.symptoms)
									english_symptoms += S.name
								dat += english_list(english_symptoms)

						else
							dat += "No detectable virus in the sample."
			else
				dat += "No detectable virus in the sample."

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


/obj/machinery/computer/pandemic/attackby(var/obj/I as obj, var/mob/user as mob, params)
	if(istype(I, /obj/item/weapon/reagent_containers/glass))
		if(stat & (NOPOWER|BROKEN)) return
		if(src.beaker)
			user << "<span class='warning'>A beaker is already loaded into the machine!</span>"
			return

		src.beaker =  I
		user.drop_item()
		I.loc = src
		user << "<span class='notice'>You add the beaker to the machine.</span>"
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
		desc = "Used to grind things up into raw materials."
		icon = 'icons/obj/kitchen.dmi'
		icon_state = "juicer1"
		layer = 2.9
		anchored = 1
		use_power = 1
		idle_power_usage = 5
		active_power_usage = 100
		pass_flags = PASSTABLE
		var/operating = 0
		var/obj/item/weapon/reagent_containers/beaker = null
		var/limit = 10
		var/list/blend_items = list (

				//Sheets
				/obj/item/stack/sheet/mineral/plasma = list("plasma" = 20),
				/obj/item/stack/sheet/metal = list("iron" = 20),
				/obj/item/stack/sheet/plasteel = list("iron" = 20, "plasma" = 20),
				/obj/item/stack/sheet/mineral/wood = list("carbon" = 20),
				/obj/item/stack/sheet/glass = list("silicon" = 20),
				/obj/item/stack/sheet/rglass = list("silicon" = 20, "iron" = 20),
				/obj/item/stack/sheet/mineral/uranium = list("uranium" = 20),
				/obj/item/stack/sheet/mineral/bananium = list("banana" = 20),
				/obj/item/stack/sheet/mineral/silver = list("silver" = 20),
				/obj/item/stack/sheet/mineral/gold = list("gold" = 20),
				/obj/item/weapon/grown/nettle/basic = list("sacid" = 0),
				/obj/item/weapon/grown/nettle/death = list("facid" = 0),
				/obj/item/weapon/grown/novaflower = list("capsaicin" = 0, "condensedcapsaicin" = 0),

				//Crayons (for overriding colours)
				/obj/item/toy/crayon/red = list("redcrayonpowder" = 10),
				/obj/item/toy/crayon/orange = list("orangecrayonpowder" = 10),
				/obj/item/toy/crayon/yellow = list("yellowcrayonpowder" = 10),
				/obj/item/toy/crayon/green = list("greencrayonpowder" = 10),
				/obj/item/toy/crayon/blue = list("bluecrayonpowder" = 10),
				/obj/item/toy/crayon/purple = list("purplecrayonpowder" = 10),
				/obj/item/toy/crayon/mime = list("invisiblecrayonpowder" = 50),

				//Blender Stuff
				/obj/item/weapon/reagent_containers/food/snacks/grown/soybeans = list("soymilk" = 0),
				/obj/item/weapon/reagent_containers/food/snacks/grown/tomato = list("ketchup" = 0),
				/obj/item/weapon/reagent_containers/food/snacks/grown/corn = list("cornoil" = 0),
				/obj/item/weapon/reagent_containers/food/snacks/grown/wheat = list("flour" = -5),
				/obj/item/weapon/reagent_containers/food/snacks/grown/oat = list("flour" = -5),
				/obj/item/weapon/reagent_containers/food/snacks/grown/cherries = list("cherryjelly" = 0),
				/obj/item/weapon/reagent_containers/food/snacks/grown/bluecherries = list("bluecherryjelly" = 0),
				/obj/item/weapon/reagent_containers/food/snacks/egg = list("eggyolk" = -5),

				//Grinder stuff, but only if dry
				/obj/item/weapon/reagent_containers/food/snacks/grown/coffee/arabica = list("coffeepowder" = 0),
				/obj/item/weapon/reagent_containers/food/snacks/grown/coffee/robusta = list("coffeepowder" = 0, "morphine" = 0),
				/obj/item/weapon/reagent_containers/food/snacks/grown/tea/aspera = list("teapowder" = 0),
				/obj/item/weapon/reagent_containers/food/snacks/grown/tea/astra = list("teapowder" = 0, "salglu_solution" = 0),



				//All types that you can put into the grinder to transfer the reagents to the beaker. !Put all recipes above this.!
				/obj/item/weapon/reagent_containers/pill = list(),
				/obj/item/weapon/reagent_containers/food = list()
		)

		var/list/juice_items = list (

				//Juicer Stuff
				/obj/item/weapon/reagent_containers/food/snacks/grown/corn = list("corn_starch" = 0),
				/obj/item/weapon/reagent_containers/food/snacks/grown/tomato = list("tomatojuice" = 0),
				/obj/item/weapon/reagent_containers/food/snacks/grown/carrot = list("carrotjuice" = 0),
				/obj/item/weapon/reagent_containers/food/snacks/grown/berries = list("berryjuice" = 0),
				/obj/item/weapon/reagent_containers/food/snacks/grown/banana = list("banana" = 0),
				/obj/item/weapon/reagent_containers/food/snacks/grown/potato = list("potato" = 0),
				/obj/item/weapon/reagent_containers/food/snacks/grown/citrus/lemon = list("lemonjuice" = 0),
				/obj/item/weapon/reagent_containers/food/snacks/grown/citrus/orange = list("orangejuice" = 0),
				/obj/item/weapon/reagent_containers/food/snacks/grown/citrus/lime = list("limejuice" = 0),
				/obj/item/weapon/reagent_containers/food/snacks/grown/watermelon = list("watermelonjuice" = 0),
				/obj/item/weapon/reagent_containers/food/snacks/watermelonslice = list("watermelonjuice" = 0),
				/obj/item/weapon/reagent_containers/food/snacks/grown/berries/poison = list("poisonberryjuice" = 0),
				/obj/item/weapon/reagent_containers/food/snacks/grown/pumpkin = list("pumpkinjuice" = 0),
				/obj/item/weapon/reagent_containers/food/snacks/grown/blumpkin = list("blumpkinjuice" = 0),
		)

		var/list/dried_items = list(

				//Grinder stuff, but only if dry
				/obj/item/weapon/reagent_containers/food/snacks/grown/coffee/arabica = list("coffeepowder" = 0),
				/obj/item/weapon/reagent_containers/food/snacks/grown/coffee/robusta = list("coffeepowder" = 0, "morphine" = 0),
				/obj/item/weapon/reagent_containers/food/snacks/grown/tea/aspera = list("teapowder" = 0),
				/obj/item/weapon/reagent_containers/food/snacks/grown/tea/astra = list("teapowder" = 0, "salglu_solution" = 0),
		)

		var/list/holdingitems = list()

/obj/machinery/reagentgrinder/New()
		..()
		beaker = new /obj/item/weapon/reagent_containers/glass/beaker/large(src)
		return

/obj/machinery/reagentgrinder/update_icon()
		icon_state = "juicer"+num2text(!isnull(beaker))
		return


/obj/machinery/reagentgrinder/attackby(var/obj/item/O as obj, var/mob/user as mob, params)

		if(default_unfasten_wrench(user, O))
				return

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

		if(is_type_in_list(O, dried_items))
				if(istype(O, /obj/item/weapon/reagent_containers/food/snacks/grown))
						var/obj/item/weapon/reagent_containers/food/snacks/grown/G = O
						if(!G.dry)
								user << "<span class='warning'>You must dry that first!</span>"
								return 1

		if(holdingitems && holdingitems.len >= limit)
				usr << "The machine cannot hold anymore items."
				return 1

		//Fill machine with a bag!
		if(istype(O, /obj/item/weapon/storage/bag))
				var/obj/item/weapon/storage/bag/B = O

				for (var/obj/item/weapon/reagent_containers/food/snacks/grown/G in B.contents)
						B.remove_from_storage(G, src)
						holdingitems += G
						if(holdingitems && holdingitems.len >= limit) //Sanity checking so the blender doesn't overfill
								user << "<span class='notice'>You fill the All-In-One grinder to the brim.</span>"
								break

				if(!O.contents.len)
						user << "<span class='notice'>You empty the plant bag into the All-In-One grinder.</span>"

				src.updateUsrDialog()
				return 0

		if (!is_type_in_list(O, blend_items) && !is_type_in_list(O, juice_items))
				user << "<span class='warning'>Cannot refine into a reagent!</span>"
				return 1

		user.unEquip(O)
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

		if(!operating)
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

		var/datum/browser/popup = new(user, "reagentgrinder", "All-In-One Grinder")
		popup.set_content(dat)
		popup.set_title_image(user.browse_rsc_icon(src.icon, src.icon_state))
		popup.open(1)
		return

/obj/machinery/reagentgrinder/Topic(href, href_list)
	if(..())
		return
	usr.set_machine(src)
	if(operating)
		updateUsrDialog()
		return
	switch(href_list["action"])
		if ("grind")
			grind()
		if("juice")
			juice()
		if("eject")
			eject()
		if ("detach")
			detach()

/obj/machinery/reagentgrinder/proc/detach()

		if (usr.stat != 0)
				return
		if (!beaker)
				return
		beaker.loc = src.loc
		beaker = null
		update_icon()
		updateUsrDialog()

/obj/machinery/reagentgrinder/proc/eject()

		if (usr.stat != 0)
				return
		if (holdingitems && holdingitems.len == 0)
				return

		for(var/obj/item/O in holdingitems)
				O.loc = src.loc
				holdingitems -= O
		holdingitems = list()
		updateUsrDialog()

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
		qdel(O)

/obj/machinery/reagentgrinder/proc/juice()
		power_change()
		if(stat & (NOPOWER|BROKEN))
				return
		if (!beaker || (beaker && beaker.reagents.total_volume >= beaker.reagents.maximum_volume))
				return
		playsound(src.loc, 'sound/machines/juicer.ogg', 20, 1)
		operating = 1
		updateUsrDialog()
		spawn(50)
				operating = 0
				updateUsrDialog()

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
		operating = 1
		updateUsrDialog()
		spawn(60)
				operating = 0
				updateUsrDialog()

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
////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////
/obj/machinery/chem_heater
	name = "chemical heater"
	density = 1
	anchored = 1
	icon = 'icons/obj/chemical.dmi'
	icon_state = "mixer0b"
	use_power = 1
	idle_power_usage = 40
	var/obj/item/weapon/reagent_containers/beaker = null
	var/desired_temp = 300
	var/heater_coefficient = 0.10
	var/on = FALSE

/obj/machinery/chem_heater/New()
	..()
	component_parts = list()
	component_parts += new /obj/item/weapon/circuitboard/chem_heater(null)
	component_parts += new /obj/item/weapon/stock_parts/micro_laser(null)
	component_parts += new /obj/item/weapon/stock_parts/console_screen(null)
	RefreshParts()

/obj/machinery/chem_heater/RefreshParts()
	heater_coefficient = 0.10
	for(var/obj/item/weapon/stock_parts/micro_laser/M in component_parts)
		heater_coefficient *= M.rating

/obj/machinery/chem_heater/process()
	..()
	if(stat & NOPOWER)
		return
	var/state_change = 0
	if(on)
		if(beaker)
			if(beaker.reagents.chem_temp > desired_temp)
				beaker.reagents.chem_temp += min(-1, (desired_temp - beaker.reagents.chem_temp) * heater_coefficient)
			if(beaker.reagents.chem_temp < desired_temp)
				beaker.reagents.chem_temp += max(1, (desired_temp - beaker.reagents.chem_temp) * heater_coefficient)
			beaker.reagents.chem_temp = round(beaker.reagents.chem_temp) //stops stuff like 456.12312312302

			beaker.reagents.handle_reactions()
			state_change = 1

	if(state_change)
		SSnano.update_uis(src)

/obj/machinery/chem_heater/proc/eject_beaker()
	if(beaker)
		beaker.loc = get_turf(src)
		beaker.reagents.handle_reactions()
		beaker = null
		icon_state = "mixer0b"
		SSnano.update_uis(src)

/obj/machinery/chem_heater/power_change()
	if(powered())
		stat &= ~NOPOWER
	else
		spawn(rand(0, 15))
			stat |= NOPOWER
	SSnano.update_uis(src)

/obj/machinery/chem_heater/attackby(var/obj/item/I as obj, var/mob/user as mob, params)
	if(isrobot(user))
		return

	if(istype(I, /obj/item/weapon/reagent_containers/glass))
		if(beaker)
			user << "<span class='warning'>A beaker is already loaded into the machine!</span>"
			return

		if(user.drop_item())
			beaker = I
			I.loc = src
			user << "<span class='notice'>You add the beaker to the machine.</span>"
			icon_state = "mixer1b"
			SSnano.update_uis(src)

	if(default_deconstruction_screwdriver(user, "mixer0b", "mixer0b", I))
		return

	if(exchange_parts(user, I))
		return

	if(panel_open)
		if(istype(I, /obj/item/weapon/crowbar))
			eject_beaker()
			default_deconstruction_crowbar(I)
			return 1

/obj/machinery/chem_heater/attack_hand(var/mob/user as mob)
	ui_interact(user)

/obj/machinery/chem_heater/Topic(href, href_list)
	if(..())
		return 0

	if(href_list["toggle_on"])
		on = !on
		. = 1

	if(href_list["adjust_temperature"])
		var/val = href_list["adjust_temperature"]
		if(isnum(val))
			desired_temp = Clamp(desired_temp+val, 0, 1000)
		else if(val == "input")
			desired_temp = Clamp(input("Please input the target temperature", name) as num, 0, 1000)
		else
			return 0
		. = 1

	if(href_list["eject_beaker"])
		eject_beaker()
		. = 0 //updated in eject_beaker() already

/obj/machinery/chem_heater/ui_interact(var/mob/user, ui_key = "main", var/datum/nanoui/ui = null)
	if(user.stat || user.restrained()) return

	var/data[0]
	data["targetTemp"] = desired_temp
	data["isActive"] = on
	data["isBeakerLoaded"] = beaker ? 1 : 0

	data["currentTemp"] = beaker ? beaker.reagents.chem_temp : null
	data["beakerCurrentVolume"] = beaker ? beaker.reagents.total_volume : null
	data["beakerMaxVolume"] = beaker ? beaker.volume : null

	//copy-pasted from chem dispenser
	var beakerContents[0]
	if(beaker)
		for(var/datum/reagent/R in beaker.reagents.reagent_list)
			beakerContents.Add(list(list("name" = R.name, "volume" = R.volume))) // list in a list because Byond merges the first list...
	data["beakerContents"] = beakerContents

	// update the ui if it exists, returns null if no ui is passed/found
	ui = SSnano.try_update_ui(user, src, ui_key, ui, data)
	if (!ui)
		ui = new(user, src, ui_key, "chem_heater.tmpl", "ChemHeater", 350, 270)
		ui.set_initial_data(data)
		ui.open()

///////////////////////////////////////////////////////////////////////////

/obj/machinery/chem_dispenser/drinks
	name = "soda dispenser"
	anchored = 1
	icon = 'icons/obj/chemical.dmi'
	icon_state = "soda_dispenser"
	energy = 100
	max_energy = 100
	amount = 30
	recharge_delay = 5
	uiname = "Soda Dispenser"
	dispensable_reagents = list("water","ice","coffee","cream","tea","icetea","cola","spacemountainwind","dr_gibb","space_up","tonic","sodawater","lemon_lime","sugar","orangejuice","limejuice","tomatojuice")

/obj/machinery/chem_dispenser/drinks/attackby(var/obj/item/O as obj, var/mob/user as mob)

		if(default_unfasten_wrench(user, O))
				return

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



/obj/machinery/chem_dispenser/drinks/beer
	name = "booze dispenser"
	anchored = 1
	icon = 'icons/obj/chemical.dmi'
	icon_state = "booze_dispenser"
	uiname = "Booze Dispenser"
	dispensable_reagents = list("lemon_lime","sugar","orangejuice","limejuice","sodawater","tonic","beer","kahlua","whiskey","wine","vodka","gin","rum","tequila","vermouth","cognac","ale")

