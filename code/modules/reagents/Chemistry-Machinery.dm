#define SOLID 1
#define LIQUID 2
#define GAS 3
#define FORMAT_DISPENSER_NAME 15

/obj/machinery/chem_dispenser
	name = "\improper Chem Dispenser"
	density = 1
	anchored = 1
	icon = 'icons/obj/chemical.dmi'
	icon_state = "dispenser"
	use_power = 1
	idle_power_usage = 40
	var/energy = 0
	var/max_energy = 50
	var/rechargerate = 2
	var/amount = 30
	var/obj/item/weapon/reagent_containers/glass/beaker = null
	var/recharged = 0
	var/custom = 0
	var/useramount = 30 // Last used amount
	var/list/dispensable_reagents = list("hydrogen","lithium","carbon","nitrogen","oxygen","fluorine",
	"sodium","aluminum","silicon","phosphorus","sulfur","chlorine","potassium","iron",
	"copper","mercury","radium","water","ethanol","sugar","sacid","tungsten")

	machine_flags = SCREWTOGGLE | CROWDESTROY | WRENCHMOVE | FIXED2WORK

	var/targetMoveKey = null //To prevent borgs from leaving without their beakers.


/*
USE THIS CHEMISTRY DISPENSER FOR MAPS SO THEY START AT 100 ENERGY
*/

/obj/machinery/chem_dispenser/mapping
	max_energy = 100
	energy = 100

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
	dispensable_reagents = sortList(dispensable_reagents)

/obj/machinery/chem_dispenser/RefreshParts()
	var/T = 0
	for(var/obj/item/weapon/stock_parts/manipulator/M in component_parts)
		T += M.rating-1
	max_energy = initial(max_energy)+(T * 50 / 4)

	T = 0
	for(var/obj/item/weapon/stock_parts/micro_laser/Ma in component_parts)
		T += Ma.rating-1
	rechargerate = initial(rechargerate) + (T / 2)

/*
	for(var/obj/item/weapon/stock_parts/scanning_module/Ml in component_parts)
		T += Ml.rating
	//Who even knows what to use the scanning module for
*/

/obj/machinery/chem_dispenser/proc/user_moved(var/list/args)
	var/event/E = args["event"]
	if(!targetMoveKey)
		E.handlers.Remove("\ref[src]:user_moved")
		return

	var/turf/T = args["loc"]

	if(!Adjacent(T))
		if(E.holder)
			E.holder.on_moved.Remove(targetMoveKey)
		detach()

/obj/machinery/chem_dispenser/proc/recharge()
	if(stat & (BROKEN|NOPOWER)) return
	var/oldenergy = energy
	energy = min(energy + rechargerate, max_energy)
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

/obj/machinery/chem_dispenser/proc/can_use(var/mob/living/silicon/robot/R)
	if(!isMoMMI(R) && !istype(R.module,/obj/item/weapon/robot_module/medical)) //default chem dispenser can only be used by MoMMIs and Mediborgs
		return 0
	else
		if(!isMoMMI(R))
			targetMoveKey =  R.on_moved.Add(src, "user_moved")
		return 1

/obj/machinery/chem_dispenser/process()
	if(recharged < 0)
		recharge()
		recharged = 15
	else
		recharged -= 1

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
	if(!chemical_reagents_list || !chemical_reagents_list.len) return
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
		if(temp) //formats name because Space Mountain Wind and theoretically others in the future are too long
			chemicals.Add(list(list("title" = copytext(temp.name,1,FORMAT_DISPENSER_NAME), "id" = temp.id, "commands" = list("dispense" = temp.id)))) // list in a list because Byond merges the first list...
	data["chemicals"] = chemicals
	// update the ui if it exists, returns null if no ui is passed/found
	ui = nanomanager.try_update_ui(user, src, ui_key, ui, data)
	if (!ui)
		// the ui does not exist, so we'll create a new() one
        // for a list of parameters and their descriptions see the code docs in \code\\modules\nano\nanoui.dm
		ui = new(user, src, ui_key, "chem_dispenser.tmpl", "[src.name] 5000", 390, 630)
		// when the ui is first opened this is the data it will use
		ui.set_initial_data(data)
		// open the new ui window
		ui.open()

/obj/machinery/chem_dispenser/Topic(href, href_list)
	if(..())
		return
	if(href_list["close"])
		if(usr.machine == src) usr.unset_machine()
		return 1
	if(stat & (NOPOWER|BROKEN))
		return 0 // don't update UIs attached to this object

	if(href_list["amount"])
		if(href_list["amount"] == "0")
			var/num = input("Enter desired output amount", "Amount", useramount) as num
			if (num)
				amount = round(text2num(num), 5)
				custom = 1
		else
			custom = 0
			amount = round(text2num(href_list["amount"]), 5) // round to nearest 5
		amount = Clamp(amount, 5, 100) // Since the user can actually type the commands himself, some sanity checking
		if (custom)
			useramount = amount

	if(href_list["dispense"])
		if (dispensable_reagents.Find(href_list["dispense"]) && beaker != null)
			var/obj/item/weapon/reagent_containers/glass/B = src.beaker
			var/datum/reagents/R = B.reagents
			if(!R)
				if(!B.gcDestroyed)
					B.create_reagents(B.volume)
				else
					del(B)
					return
			var/space = R.maximum_volume - R.total_volume

			R.add_reagent(href_list["dispense"], min(amount, energy * 10, space))
			energy = max(energy - min(amount, energy * 10, space) / 10, 0)

	if(href_list["ejectBeaker"])
		if(beaker)
			detach()

	add_fingerprint(usr)
	return 1 // update UIs attached to this object

/obj/machinery/chem_dispenser/proc/detach()
	targetMoveKey=null

	if(beaker)
		var/obj/item/weapon/reagent_containers/glass/B = beaker
		B.loc = loc
		if(istype(beaker, /obj/item/weapon/reagent_containers/glass/beaker/large/cyborg))
			var/mob/living/silicon/robot/R = beaker:holder:loc
			if(R.module_state_1 == beaker || R.module_state_2 == beaker || R.module_state_3 == beaker)
				beaker.loc = R
			else
				beaker.loc = beaker:holder
		beaker = null

/obj/machinery/chem_dispenser/togglePanelOpen(var/obj/toggleitem, mob/user)
	if(beaker)
		to_chat(user, "You can't reach the maintenance panel with a beaker in the way!")
		return
	return ..()

/obj/machinery/chem_dispenser/attackby(var/obj/item/weapon/D as obj, var/mob/user as mob) //to be worked on

	if(..())
		return 1

	if(isrobot(user))
		if(!can_use(user))
			return

	if(istype(D, /obj/item/weapon/reagent_containers/glass))
		if(src.beaker)
			to_chat(user, "A beaker is already loaded into the machine.")
			return
		else if(!panel_open)
			src.beaker =  D
			if(user.type == /mob/living/silicon/robot)
				var/mob/living/silicon/robot/R = user
				R.uneq_active()
			user.drop_item(D, src)
			to_chat(user, "You add the beaker to the machine!")
			nanomanager.update_uis(src) // update all UIs attached to src
			return 1
		else
			to_chat(user, "You can't add a beaker to the machine while the panel is open.")
			return

/obj/machinery/chem_dispenser/attack_ai(mob/user as mob)
	src.add_hiddenprint(user)
	return src.attack_hand(user)

/obj/machinery/chem_dispenser/attack_paw(mob/user as mob)
	return src.attack_hand(user)

/obj/machinery/chem_dispenser/attack_hand(mob/user as mob)
	if(stat & BROKEN)
		return

	ui_interact(user)
//Cafe stuff

/obj/machinery/chem_dispenser/brewer/
	name = "Space-Brewery"
	icon_state = "brewer"
	dispensable_reagents = list("tea","greentea","redtea", "coffee","milk","cream","water","hot_coco", "soymilk")
/obj/machinery/chem_dispenser/brewer/New()
	. = ..()
	component_parts = newlist(
		/obj/item/weapon/circuitboard/chem_dispenser/brewer,
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

/obj/machinery/chem_dispenser/brewer/mapping
	max_energy = 100
	energy = 100

/obj/machinery/chem_dispenser/brewer/can_use(var/mob/living/silicon/robot/R)
	if(!isMoMMI(R) && istype(R.module,/obj/item/weapon/robot_module/butler)) //bartending dispensers can be used only by service borgs
		targetMoveKey =  R.on_moved.Add(src, "user_moved")
		return 1
	else
		return 0

//Soda/booze dispensers.

/obj/machinery/chem_dispenser/soda_dispenser/
	name = "Soda Dispenser"
	icon_state = "soda_dispenser"
	dispensable_reagents = list("spacemountainwind", "sodawater", "lemon_lime", "dr_gibb", "cola", "ice", "tonic")
/obj/machinery/chem_dispenser/soda_dispenser/New()
	. = ..()
	component_parts = newlist(
		/obj/item/weapon/circuitboard/chem_dispenser/soda_dispenser,
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

/obj/machinery/chem_dispenser/soda_dispenser/mapping
	max_energy = 100
	energy = 100

/obj/machinery/chem_dispenser/soda_dispenser/can_use(var/mob/living/silicon/robot/R)
	if(!isMoMMI(R) && istype(R.module,/obj/item/weapon/robot_module/butler)) //bartending dispensers can be used only by service borgs
		targetMoveKey =  R.on_moved.Add(src, "user_moved")
		return 1
	else
		return 0

/obj/machinery/chem_dispenser/booze_dispenser/
	name = "Booze Dispenser"
	icon_state = "booze_dispenser"
	dispensable_reagents = list("beer", "whiskey", "tequila", "vodka", "vermouth", "rum", "cognac", "wine", "kahlua", "ale", "ice", "water", "gin", "sodawater", "cola", "cream","tomatojuice","orangejuice","limejuice","tonic")
/obj/machinery/chem_dispenser/booze_dispenser/New()
	. = ..()
	component_parts = newlist(
		/obj/item/weapon/circuitboard/chem_dispenser/booze_dispenser,
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

/obj/machinery/chem_dispenser/booze_dispenser/mapping
	max_energy = 100
	energy = 100

/obj/machinery/chem_dispenser/booze_dispenser/can_use(var/mob/living/silicon/robot/R)
	if(!isMoMMI(R) && istype(R.module,/obj/item/weapon/robot_module/butler)) //bartending dispensers can be used only by service borgs
		targetMoveKey =  R.on_moved.Add(src, "user_moved")
		return 1
	else
		return 0

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

/obj/machinery/chem_master
	name = "\improper ChemMaster 3000"
	density = 1
	anchored = 1
	icon = 'icons/obj/chemical.dmi'
	icon_state = "mixer"
	use_power = 1
	idle_power_usage = 20
	var/obj/item/weapon/reagent_containers/glass/beaker = null
	var/obj/item/weapon/storage/pill_bottle/loaded_pill_bottle = null
	var/mode = 0
	var/condi = 0
	var/windowtype = "chem_master" //For the browser windows
	var/useramount = 30 // Last used amount
	//var/bottlesprite = "1" //yes, strings
	var/pillsprite = "1"

	var/client/has_sprites = list()
	var/chem_board = /obj/item/weapon/circuitboard/chemmaster3000
	var/max_bottle_size = 30
	var/max_pill_count = 20

	light_color = LIGHT_COLOR_BLUE
	light_range_on = 3
	light_power_on = 2
	use_auto_lights = 1

	machine_flags = SCREWTOGGLE | CROWDESTROY | WRENCHMOVE | FIXED2WORK

	var/targetMoveKey

/********************************************************************
**   Adding Stock Parts to VV so preconstructed shit has its candy **
********************************************************************/

/obj/machinery/chem_master/New()
	. = ..()

	create_reagents(100)

	component_parts = newlist(
		/obj/item/weapon/stock_parts/manipulator,
		/obj/item/weapon/stock_parts/scanning_module,
		/obj/item/weapon/stock_parts/scanning_module,
		/obj/item/weapon/stock_parts/micro_laser,
		/obj/item/weapon/stock_parts/micro_laser,
		/obj/item/weapon/stock_parts/console_screen,
		/obj/item/weapon/stock_parts/console_screen
	)

	component_parts += new chem_board

	RefreshParts()
	update_icon() //Needed to add the prongs cleanly

/obj/machinery/chem_master/RefreshParts()
	var/scancount = 0
	var/lasercount = 0
	var/manipcount = 0
	for(var/obj/item/weapon/stock_parts/SP in component_parts)
		if(istype(SP, /obj/item/weapon/stock_parts/manipulator)) manipcount += SP.rating-1
		if(istype(SP, /obj/item/weapon/stock_parts/scanning_module)) scancount += SP.rating-1
		if(istype(SP, /obj/item/weapon/stock_parts/micro_laser)) lasercount += SP.rating-1
	max_bottle_size = initial(max_bottle_size) + lasercount*5
	max_pill_count = initial(max_pill_count) + manipcount*5
	handle_new_reservoir(scancount*25+100)

/obj/machinery/chem_master/proc/handle_new_reservoir(var/newvol)
	if(reagents.maximum_volume == newvol) return //Volume did not change
	if(reagents.maximum_volume>newvol)
		reagents.remove_any(reagents.maximum_volume-newvol) //If we have more than our new max, remove equally until we reach new max
	reagents.maximum_volume = newvol

/obj/machinery/chem_master/proc/user_moved(var/list/args)
	var/event/E = args["event"]
	if(!targetMoveKey)
		E.handlers.Remove("\ref[src]:user_moved")
		return

	var/turf/T = args["loc"]

	if(!Adjacent(T))
		if(E.holder)
			E.holder.on_moved.Remove(targetMoveKey)
		detach()

/obj/machinery/chem_master/ex_act(severity)
	switch(severity)
		if(1.0)
			qdel(src)
			return
		if(2.0)
			if(prob(50))
				qdel(src)
				return

/obj/machinery/chem_master/blob_act()
	if(prob(50))
		qdel(src)

/obj/machinery/chem_master/attackby(var/obj/item/weapon/B as obj, var/mob/user as mob)
	if(..())
		return 1

	else if(istype(B, /obj/item/weapon/reagent_containers/glass))

		if(src.beaker)
			to_chat(user, "<span class='warning'>There already is a beaker loaded in the machine.</span>")
			return
		src.beaker = B
		if(user.type == /mob/living/silicon/robot)
			var/mob/living/silicon/robot/R = user
			R.uneq_active()
			targetMoveKey =  R.on_moved.Add(src, "user_moved")

		user.drop_item(B, src)
		to_chat(user, "<span class='notice'>You add the beaker into \the [src]!</span>")
		src.updateUsrDialog()
		update_icon()
		return 1

	else if(istype(B, /obj/item/weapon/storage/pill_bottle))
		if(windowtype != "chem_master") //Only the chemmaster will accept pill bottles
			to_chat(user, "<span class='warning'>This [name] does not come with a pill dispenser unit built-in.</span>")
			return
		if(src.loaded_pill_bottle)
			to_chat(user, "<span class='warning'>There already is a pill bottle loaded in the machine.</span>")
			return

		src.loaded_pill_bottle = B
		user.drop_item(B, src)
		to_chat(user, "<span class='notice'>You add the pill bottle into \the [src]'s dispenser slot!</span>")
		src.updateUsrDialog()
		return 1

/obj/machinery/chem_master/Topic(href, href_list)

	if(..())
		return 1

	usr.set_machine(src)

	if(href_list["ejectp"])
		if(loaded_pill_bottle)
			loaded_pill_bottle.loc = src.loc
			loaded_pill_bottle = null
		src.updateUsrDialog()
		return 1

	else if(href_list["close"])
		usr << browse(null, "window=[windowtype]")
		usr.unset_machine()
		return 1

	if(beaker)
		var/datum/reagents/R = beaker.reagents
		if(href_list["analyze"])
			var/dat = list()
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
					dat += "Chemical infos:<BR><BR>Name:<BR>[A]<BR><BR>Description:<BR>Blood Type: [B]<br>DNA: [C]<BR><BR><BR><A href='?src=\ref[src];main=1'>(Back)</A>"
				else
					dat += "Chemical infos:<BR><BR>Name:<BR>[href_list["name"]]<BR><BR>Description:<BR>[href_list["desc"]]<BR><BR><BR><A href='?src=\ref[src];main=1'>(Back)</A>"
			else
				dat += "Condiment infos:<BR><BR>Name:<BR>[href_list["name"]]<BR><BR>Description:<BR>[href_list["desc"]]<BR><BR><BR><A href='?src=\ref[src];main=1'>(Back)</A>"
			//usr << browse(dat, "window=chem_master;size=575x400")
			dat = list2text(dat)
			var/datum/browser/popup = new(usr, "[windowtype]", "[name]", 585, 400, src)
			popup.set_content(dat)
			popup.open()
			onclose(usr, "[windowtype]")
			return 1

		else if(href_list["add"])

			if(href_list["amount"])
				var/id = href_list["add"]
				var/amount = text2num(href_list["amount"])
				if(amount < 0)
					return
				R.trans_id_to(src, id, amount)
			src.updateUsrDialog()
			return 1

		else if(href_list["addcustom"])

			var/id = href_list["addcustom"]
			useramount = input("Select the amount to transfer.", 30, useramount) as num
			useramount = isgoodnumber(useramount)
			src.Topic(null, list("amount" = "[useramount]", "add" = "[id]"))
			src.updateUsrDialog()
			return 1

		else if(href_list["remove"])

			if(href_list["amount"])
				var/id = href_list["remove"]
				var/amount = text2num(href_list["amount"])
				if(amount < 0)
					return
				if(mode)
					reagents.trans_id_to(beaker, id, amount)
				else
					reagents.remove_reagent(id, amount)
			src.updateUsrDialog()
			return 1

		else if(href_list["removecustom"])

			var/id = href_list["removecustom"]
			useramount = input("Select the amount to transfer.", 30, useramount) as num
			useramount = isgoodnumber(useramount)
			src.Topic(null, list("amount" = "[useramount]", "remove" = "[id]"))
			src.updateUsrDialog()
			return 1

		else if(href_list["toggle"])
			mode = !mode
			src.updateUsrDialog()
			return 1

		else if(href_list["main"])
			attack_hand(usr)
			src.updateUsrDialog()
			return 1

		else if(href_list["eject"])
			if(beaker)
				detach()
			src.updateUsrDialog()
			return 1

		else if(href_list["createpill"] || href_list["createpill_multiple"])
			var/count = 1
			if(href_list["createpill_multiple"]) count = isgoodnumber(input("Select the number of pills to make.", 10, max_pill_count) as num)
			count = min(max_pill_count, count)
			if(!count)
				return

			var/amount_per_pill = reagents.total_volume/count
			if(amount_per_pill > 50)
				amount_per_pill = 50
			if(href_list["createempty"])
				amount_per_pill = 0 //If "createempty" is 1, pills are empty and no reagents are used.

			var/name = reject_bad_text(input(usr,"Name:","Name your pill!","[reagents.get_master_reagent_name()] ([amount_per_pill] units)") as null|text)
			if(!name)
				return
			while(count--)
				if((amount_per_pill == 0 || reagents.total_volume == 0) && !href_list["createempty"]) //Don't create empty pills unless "createempty" is 1!
					break

				var/obj/item/weapon/reagent_containers/pill/P = new/obj/item/weapon/reagent_containers/pill(src.loc)
				if(!name)
					name = "[reagents.get_master_reagent_name()] ([amount_per_pill] units)"
				P.name = "[name] pill"
				P.pixel_x = rand(-7, 7) //Random position
				P.pixel_y = rand(-7, 7)
				P.icon_state = "pill"+pillsprite
				reagents.trans_to(P,amount_per_pill)
				if(src.loaded_pill_bottle)
					if(loaded_pill_bottle.contents.len < loaded_pill_bottle.storage_slots)
						P.loc = loaded_pill_bottle

			src.updateUsrDialog()
			return 1

		else if (href_list["createbottle"] || href_list["createbottle_multiple"])
			if(!condi)
				var/name = reject_bad_text(input(usr,"Name:", "Name your bottle!", reagents.get_master_reagent_name()))
				if(!name)
					name = reagents.get_master_reagent_name()
				var/count = 1
				if(href_list["createbottle_multiple"])
					count = isgoodnumber(input("Select the number of bottles to make.", 10, count) as num)
				if(count > 4)
					count = 4
				if(count < 1)
					count = 1
				var/amount_per_bottle = reagents.total_volume > 0 ? reagents.total_volume/count : 0
				amount_per_bottle = min(amount_per_bottle,max_bottle_size)
				while(count--)
					var/obj/item/weapon/reagent_containers/glass/bottle/P = new/obj/item/weapon/reagent_containers/glass/bottle(src.loc,max_bottle_size)
					P.name = "[name] bottle"
					P.pixel_x = rand(-7, 7) //random position
					P.pixel_y = rand(-7, 7)
					//P.icon_state = "bottle"+bottlesprite
					reagents.trans_to(P,amount_per_bottle)
				src.updateUsrDialog()
				return 1
			else
				var/obj/item/weapon/reagent_containers/food/condiment/P = new/obj/item/weapon/reagent_containers/food/condiment(src.loc)
				reagents.trans_to(P, 50)
				src.updateUsrDialog()
				return 1

		else if(href_list["change_pill"])
			#define MAX_PILL_SPRITE 20 //Max icon state of the pill sprites
			var/dat = list()
			dat += "<table>"
			for(var/i = 1 to MAX_PILL_SPRITE)
				if(i%4 == 1)
					dat += "<tr>"

				dat += "<td><a href=\"?src=\ref[src]&pill_sprite=[i]\"><img src=\"pill[i].png\" /></a></td>"

				if (i%4 == 0)
					dat +="</tr>"

			dat += "</table>"
			dat = list2text(dat)
			var/datum/browser/popup = new(usr, "[windowtype]", "[name]", 585, 400, src)
			popup.set_content(dat)
			popup.open()
			onclose(usr, "[windowtype]")
			//usr << browse(dat, "window=[windowtype]")
			return 1

		/*
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
		*/

		else if(href_list["pill_sprite"])
			pillsprite = href_list["pill_sprite"]
			src.updateUsrDialog()
			return 1

		/*
		else if(href_list["bottle_sprite"])
			bottlesprite = href_list["bottle_sprite"]
		*/

	return

/obj/machinery/chem_master/proc/detach()
	if(beaker)
		beaker.loc = src.loc
		beaker.pixel_x = 0 //We fucked with the beaker for overlays, so reset that
		beaker.pixel_y = 0 //We fucked with the beaker for overlays, so reset that
		if(istype(beaker, /obj/item/weapon/reagent_containers/glass/beaker/large/cyborg))
			var/mob/living/silicon/robot/R = beaker:holder:loc
			if(R.module_state_1 == beaker || R.module_state_2 == beaker || R.module_state_3 == beaker)
				beaker.loc = R
			else
				beaker.loc = beaker:holder
		beaker = null
		reagents.clear_reagents()
		update_icon()

/obj/machinery/chem_master/attack_ai(mob/user as mob)
	src.add_hiddenprint(user)
	return src.attack_hand(user)

/obj/machinery/chem_master/attack_paw(mob/user as mob)
	return src.attack_hand(user)

/obj/machinery/chem_master/attack_hand(mob/user as mob)

	. = ..()
	if(.)
		return

	user.set_machine(src)
	if(!(user.client in has_sprites))
		spawn()
			has_sprites += user.client
			for(var/i = 1 to MAX_PILL_SPRITE)
				usr << browse_rsc(icon('icons/obj/chemical.dmi', "pill" + num2text(i)), "pill[i].png")
			/*
			for(var/i = 1 to MAX_BOTTLE_SPRITE)
				usr << browse_rsc(icon('icons/obj/chemical.dmi', "bottle" + num2text(i)), "bottle[i].png")
			*/

	var/dat = list()
	if(!beaker)
		dat += "Please insert a beaker.<BR>"
		if(!condi)
			if(src.loaded_pill_bottle)
				dat += "<A href='?src=\ref[src];ejectp=1'>Eject Pill Bottle \[[loaded_pill_bottle.contents.len]/[loaded_pill_bottle.storage_slots]\]</A><BR><BR>"
			else
				dat += "No pill bottle inserted.<BR><BR>"
		//dat += "<A href='?src=\ref[src];close=1'>Close</A>"
	else
		var/datum/reagents/R = beaker.reagents
		dat += "<A href='?src=\ref[src];eject=1'>Eject beaker and Clear Buffer</A><BR>"
		if(src.loaded_pill_bottle)
			dat += "<A href='?src=\ref[src];ejectp=1'>Eject Pill Bottle \[[loaded_pill_bottle.contents.len]/[loaded_pill_bottle.storage_slots]\]</A><BR><BR>"
		else if(windowtype == "chem_master")
			dat += "No pill bottle inserted.<BR><BR>"
		if(!R.total_volume)
			dat += "Beaker is empty."
		else
			dat += "Add to buffer:<BR>"
			for(var/datum/reagent/G in R.reagent_list)

				// AUTOFIXED BY fix_string_idiocy.py
				// C:\Users\Rob\\documents\\\projects\vgstation13\code\\modules\reagents\Chemistry-Machinery.dm:518: dat += "[G.name] , [G.volume] Units - "
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
				// C:\Users\Rob\\documents\\\projects\vgstation13\code\\modules\reagents\Chemistry-Machinery.dm:529: dat += "[N.name] , [N.volume] Units - "
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
			// C:\Users\Rob\\documents\\\projects\vgstation13\code\\modules\reagents\Chemistry-Machinery.dm:539: dat += "<HR><BR><A href='?src=\ref[src];createpill=1'>Create pill (50 units max)</A><a href=\"?src=\ref[src]&change_pill=1\"><img src=\"pill[pillsprite].png\" /></a><BR>"
			//dat += {"<a href=\"?src=\ref[src]&change_pill=1\"><img src=\"pill[pillsprite].png\" /></a><a href=\"?src=\ref[src]&change_bottle=1\"><img src=\"bottle[bottlesprite].png\" /></a><BR>"}
			dat += {"<a href=\"?src=\ref[src]&change_pill=1\"><img src=\"pill[pillsprite].png\" /></a><BR>"}
			dat += {"<HR><BR><A href='?src=\ref[src];createpill=1'>Create single pill (50 units max)</A><BR>
					<A href='?src=\ref[src];createpill_multiple=1'>Create multiple pills (50 units max each; [max_pill_count] max)</A><BR>
					<A href='?src=\ref[src];createpill_multiple=1;createempty=1'>Create empty pills</A><BR>
					<A href='?src=\ref[src];createbottle=1'>Create bottle ([max_bottle_size] units max)</A><BR>
					<A href='?src=\ref[src];createbottle_multiple=1'>Create multiple bottles ([max_bottle_size] units max each; 4 max)</A><BR>"}
			// END AUTOFIX
		else
			dat += "<A href='?src=\ref[src];createbottle=1'>Create bottle (50 units max)</A>"
	dat = list2text(dat)
	var/datum/browser/popup = new(user, "[windowtype]", "[name]", 575, 400, src)
	popup.set_content(dat)
	popup.open()
	onclose(user, "[windowtype]")
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

/obj/machinery/chem_master/update_icon()

	overlays.len = 0

	if(beaker)
		beaker.pixel_x = -9 //Move it far to the left
		beaker.pixel_y = 5 //Move it up
		beaker.update_icon() //Forcefully update the beaker
		overlays += beaker //Set it as an overlay

	if(reagents.total_volume && !(stat & (BROKEN|NOPOWER))) //If we have reagents in here, and the machine is powered and functional
		var/image/overlay = image('icons/obj/chemical.dmi', src, "mixer_overlay")
		overlay.icon += mix_color_from_reagents(reagents.reagent_list)
		overlays += overlay

	var/image/mixer_prongs = image('icons/obj/chemical.dmi', src, "mixer_prongs")
	overlays += mixer_prongs //Add prongs on top of all of this

/obj/machinery/chem_master/on_reagent_change()
	update_icon()

/obj/machinery/chem_master/condimaster
	name = "\improper CondiMaster 3000"
	condi = 1
	chem_board = /obj/item/weapon/circuitboard/condimaster
	windowtype = "condi_master"

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

	light_color = LIGHT_COLOR_BLUE
	var/targetMoveKey

/********************************************************************
**   Adding Stock Parts to VV so preconstructed shit has its candy **
********************************************************************/
/obj/machinery/computer/pandemic/New()
	. = ..()

	component_parts = newlist(
		/obj/item/weapon/circuitboard/pandemic
	)

	RefreshParts()

/obj/machinery/computer/pandemic/proc/user_moved(var/list/args)
	var/event/E = args["event"]
	if(!targetMoveKey)
		E.handlers.Remove("\ref[src]:user_moved")
		return

	var/turf/T = args["loc"]

	if(!Adjacent(T))
		if(E.holder)
			E.holder.on_moved.Remove(targetMoveKey)
		detach()


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
		detach()
		return
	else if(href_list["clear"])
		src.temphtml = ""
		src.updateUsrDialog()
		return
	else if(href_list["name_disease"])
		var/norange = (usr.mutations && usr.mutations.len && (M_TK in usr.mutations))
		var/new_name = stripped_input(usr, "Name the Disease", "New Name", "", MAX_NAME_LEN)
		if(stat & (NOPOWER|BROKEN)) return
		if(usr.stat || usr.restrained()) return
		if(!in_range(src, usr) && !norange) return
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

/obj/machinery/computer/pandemic/proc/detach()
	beaker.loc = src.loc
	if(istype(beaker, /obj/item/weapon/reagent_containers/glass/beaker/large/cyborg))
		var/mob/living/silicon/robot/R = beaker:holder:loc
		if(R.module_state_1 == beaker || R.module_state_2 == beaker || R.module_state_3 == beaker)
			beaker.loc = R
		else
			beaker.loc = beaker:holder
	beaker = null
	icon_state = "mixer0"
	src.updateUsrDialog()
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
		// C:\Users\Rob\\documents\\\projects\vgstation13\code\\modules\reagents\Chemistry-Machinery.dm:722: dat += "Please insert beaker.<BR>"
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
			// C:\Users\Rob\\documents\\\projects\vgstation13\code\\modules\reagents\Chemistry-Machinery.dm:738: dat += "<h3>Blood sample data:</h3>"
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
							// C:\Users\Rob\\documents\\\projects\vgstation13\code\\modules\reagents\Chemistry-Machinery.dm:762: dat += "<b>Disease Agent:</b> [D?"[D.agent] - <A href='?src=\ref[src];create_virus_culture=[disease_creation]'>Create virus culture bottle</A>":"none"]<BR>"
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
		// C:\Users\Rob\\documents\\\projects\vgstation13\code\\modules\reagents\Chemistry-Machinery.dm:799: dat += "<BR><A href='?src=\ref[src];eject=1'>Eject beaker</A>[((R.total_volume&&R.reagent_list.len) ? "-- <A href='?src=\ref[src];empty_beaker=1'>Empty beaker</A>":"")]<BR>"
		dat += {"<BR><A href='?src=\ref[src];eject=1'>Eject beaker</A>[((R.total_volume&&R.reagent_list.len) ? "-- <A href='?src=\ref[src];empty_beaker=1'>Empty beaker</A>":"")]<BR>
			<A href='?src=\ref[user];mach_close=pandemic'>Close</A>"}
		// END AUTOFIX
	user << browse("<TITLE>[src.name]</TITLE><BR>[dat]", "window=pandemic;size=575x400")
	onclose(user, "pandemic")
	return


/obj/machinery/computer/pandemic/attackby(var/obj/I as obj, var/mob/user as mob)
	if(..())
		return 1
	else if(istype(I, /obj/item/weapon/reagent_containers/glass))
		if(stat & (NOPOWER|BROKEN)) return
		if(src.beaker)
			to_chat(user, "A beaker is already loaded into the machine.")
			return

		src.beaker =  I
		if(user.type == /mob/living/silicon/robot)
			var/mob/living/silicon/robot/R = user
			R.uneq_active()
			targetMoveKey =  R.on_moved.Add(src, "user_moved")

		user.drop_item(I, src)
		to_chat(user, "You add the beaker to the machine!")
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
	machine_flags = SCREWTOGGLE | CROWDESTROY | WRENCHMOVE | FIXED2WORK | EJECTNOTDEL
	pass_flags = PASSTABLE
	var/inuse = 0
	var/obj/item/weapon/reagent_containers/beaker = null
	var/limit = 10
	var/speed_multiplier = 1
	var/list/blend_items = list (

		//Sheets
		/obj/item/stack/sheet/metal           = list("iron" = 20),
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

		/obj/item/seeds = list("blackpepper" = 5),


		//archaeology!
		/obj/item/weapon/rocksliver = list("ground_rock" = 30),

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
		/obj/item/weapon/reagent_containers/food/snacks/grown/apple = list("applejuice" = 0),
		/obj/item/weapon/reagent_containers/food/snacks/grown/lemon = list("lemonjuice" = 0),
		/obj/item/weapon/reagent_containers/food/snacks/grown/orange = list("orangejuice" = 0),
		/obj/item/weapon/reagent_containers/food/snacks/grown/lime = list("limejuice" = 0),
		/obj/item/weapon/reagent_containers/food/snacks/grown/watermelon = list("watermelonjuice" = 0),
		/obj/item/weapon/reagent_containers/food/snacks/watermelonslice = list("watermelonjuice" = 0),
		/obj/item/weapon/reagent_containers/food/snacks/grown/poisonberries = list("poisonberryjuice" = 0),
	)


	var/list/holdingitems = list()
	var/targetMoveKey

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

/obj/machinery/reagentgrinder/proc/user_moved(var/list/args)
	var/event/E = args["event"]
	if(!targetMoveKey)
		E.handlers.Remove("\ref[src]:user_moved")
		return

	var/turf/T = args["loc"]

	if(!Adjacent(T))
		if(E.holder)
			E.holder.on_moved.Remove(targetMoveKey)
		detach()


/obj/machinery/reagentgrinder/RefreshParts()
	var/T = 0
	for(var/obj/item/weapon/stock_parts/matter_bin/M in component_parts)
		T += M.rating-1
	limit = initial(limit)+(T * 5)

	T = 0
	for(var/obj/item/weapon/stock_parts/micro_laser/M in component_parts)
		T += M.rating-1
	speed_multiplier = initial(speed_multiplier)+(T * 0.50)

/obj/machinery/reagentgrinder/update_icon()
	icon_state = "juicer"+num2text(!isnull(beaker))
	return

/obj/machinery/reagentgrinder/togglePanelOpen(var/obj/toggleitem, mob/user)
	if(beaker)
		to_chat(user, "You can't reach \the [src]'s maintenance panel with the beaker in the way!")
		return -1
	return ..()

/obj/machinery/reagentgrinder/crowbarDestroy(mob/user)
	if(beaker)
		to_chat(user, "You can't do that while \the [src] has a beaker loaded!")
		return -1
	return ..()

/obj/machinery/reagentgrinder/attackby(var/obj/item/O as obj, var/mob/user as mob)

	if(..())
		return 1

	if (istype(O,/obj/item/weapon/reagent_containers/glass) || \
		istype(O,/obj/item/weapon/reagent_containers/food/drinks/drinkingglass) || \
		istype(O,/obj/item/weapon/reagent_containers/food/drinks/shaker))

		if (beaker)
			return 0
		if (panel_open)
			to_chat(user, "You can't load a beaker while the maintenance panel is open.")
			return 0
		else
			src.beaker =  O
			if(user.type == /mob/living/silicon/robot)
				var/mob/living/silicon/robot/R = user
				R.uneq_active()
				targetMoveKey =  R.on_moved.Add(src, "user_moved")

			user.drop_item(O, src)
			update_icon()
			src.updateUsrDialog()
			return 1

	if(holdingitems && holdingitems.len >= limit)
		to_chat(usr, "The machine cannot hold any more items.")
		return 1

	//Fill machine with bags
	if(istype(O, /obj/item/weapon/storage/bag/plants)||istype(O, /obj/item/weapon/storage/bag/chem))
		var/obj/item/weapon/storage/bag/B = O
		for (var/obj/item/G in O.contents)
			B.remove_from_storage(G,src)
			holdingitems += G
			if(holdingitems && holdingitems.len >= limit) //Sanity checking so the blender doesn't overfill
				to_chat(user, "You fill the All-In-One grinder to the brim.")
				break

		if(!O.contents.len)
			to_chat(user, "You empty the [O] into the All-In-One grinder.")

		src.updateUsrDialog()
		return 0

	if (!is_type_in_list(O, blend_items) && !is_type_in_list(O, juice_items))
		to_chat(user, "Cannot refine into a reagent.")
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

/obj/machinery/reagentgrinder/attack_robot(mob/user as mob)
	return attack_hand(user)

/obj/machinery/reagentgrinder/interact(mob/user as mob) // The microwave Menu
	var/is_chamber_empty = 0
	var/is_beaker_ready = 0
	var/processing_chamber = ""
	var/beaker_contents = ""
	var/dat = list()

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


		dat += {"
	<b>Processing chamber contains:</b><br>
	[processing_chamber]<br>
	[beaker_contents]<hr>
	"}
		if (is_beaker_ready && !is_chamber_empty && !(stat & (NOPOWER|BROKEN)))

			// AUTOFIXED BY fix_string_idiocy.py
			// C:\Users\Rob\\documents\\\projects\vgstation13\code\\modules\reagents\Chemistry-Machinery.dm:1016: dat += "<A href='?src=\ref[src];action=grind'>Grind the reagents</a><BR>"
			dat += {"<A href='?src=\ref[src];action=grind'>Grind the reagents</a><BR>
				<A href='?src=\ref[src];action=juice'>Juice the reagents</a><BR><BR>"}
			// END AUTOFIX
		if(holdingitems && holdingitems.len > 0)
			dat += "<A href='?src=\ref[src];action=eject'>Eject the reagents</a><BR>"
		if (beaker)
			dat += "<A href='?src=\ref[src];action=detach'>Detach the beaker</a><BR>"
	else
		dat += "Please wait..."
	dat = list2text(dat)
	var/datum/browser/popup = new(user, "reagentgrinder", "All-In-One Grinder", src)
	popup.set_content(dat)
	popup.open()
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
	if(istype(beaker, /obj/item/weapon/reagent_containers/glass/beaker/large/cyborg))
		var/mob/living/silicon/robot/R = beaker:holder:loc
		if(R.module_state_1 == beaker || R.module_state_2 == beaker || R.module_state_3 == beaker)
			beaker.loc = R
		else
			beaker.loc = beaker:holder
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
	playsound(get_turf(src), speed_multiplier < 2 ? 'sound/machines/juicer.ogg' : 'sound/machines/juicerfast.ogg', 30, 1)
	inuse = 1
	spawn(50/speed_multiplier)
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
	playsound(get_turf(src), speed_multiplier < 2 ? 'sound/machines/blender.ogg' : 'sound/machines/blenderfast.ogg', 50, 1)
	inuse = 1
	spawn(60/speed_multiplier)
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

	//All other generics
	for (var/obj/item/O in holdingitems)
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

//*************************************************************************************
//
//
//It just felt right to put the ghetto chemistry tools here with chemistry machinery.
//
//
//*************************************************************************************
/obj/item/weapon/electrolyzer
	name = "Electrolyzer"
	icon = 'icons/obj/chemical.dmi'
	icon_state = "chemg_wired"
	item_state = "chemg_wired"
	desc = "A refurbished grenade-casing jury rigged to split simple chemicals."
	w_class = 2.0
	force = 2.0
	var/list/beakers = new/list()
	var/list/allowed_containers = list(/obj/item/weapon/reagent_containers/glass, /obj/item/weapon/reagent_containers/food/drinks/soda_cans/)
	var/list/allowed_reactions = list(/datum/chemical_reaction/water, /datum/chemical_reaction/creatine,
	/datum/chemical_reaction/discount, /datum/chemical_reaction/peptobismol, /datum/chemical_reaction/phalanximine,
	/datum/chemical_reaction/stoxin, /datum/chemical_reaction/sterilizine, /datum/chemical_reaction/inaprovaline,
	/datum/chemical_reaction/anti_toxin, /datum/chemical_reaction/mutagen, /datum/chemical_reaction/tramadol,
	/datum/chemical_reaction/oxycodone, /datum/chemical_reaction/sacid, /datum/chemical_reaction/thermite,
	/datum/chemical_reaction/lexorin, /datum/chemical_reaction/space_drugs, /datum/chemical_reaction/lube,
	/datum/chemical_reaction/pacid, /datum/chemical_reaction/synaptizine, /datum/chemical_reaction/hyronalin,
	/datum/chemical_reaction/arithrazine, /datum/chemical_reaction/impedrezene, /datum/chemical_reaction/kelotane,
	/datum/chemical_reaction/virus_food, /datum/chemical_reaction/leporazine, /datum/chemical_reaction/cryptobiolin,
	/datum/chemical_reaction/tricordrazine, /datum/chemical_reaction/alkysine, /datum/chemical_reaction/dexalin,
	/datum/chemical_reaction/dermaline, /datum/chemical_reaction/dexalinp, /datum/chemical_reaction/bicaridine,
	/datum/chemical_reaction/hyperzine, /datum/chemical_reaction/ryetalyn, /datum/chemical_reaction/cryoxadone,
	/datum/chemical_reaction/clonexadone, /datum/chemical_reaction/spaceacillin, /datum/chemical_reaction/imidazoline,
	/datum/chemical_reaction/inacusiate, /datum/chemical_reaction/ethylredoxrazine, /datum/chemical_reaction/glycerol,
	/datum/chemical_reaction/sodiumchloride, /datum/chemical_reaction/chloralhydrate, /datum/chemical_reaction/zombiepowder,
	/datum/chemical_reaction/rezadone, /datum/chemical_reaction/mindbreaker, /datum/chemical_reaction/lipozine,
	/datum/chemical_reaction/condensedcapsaicin, /datum/chemical_reaction/surfactant, /datum/chemical_reaction/foaming_agent,
	/datum/chemical_reaction/ammonia, /datum/chemical_reaction/diethylamine, /datum/chemical_reaction/space_cleaner,
	/datum/chemical_reaction/plantbgone, /datum/chemical_reaction/doctor_delight, /datum/chemical_reaction/neurotoxin,
	/datum/chemical_reaction/toxins_special, /datum/chemical_reaction/goldschlager, /datum/chemical_reaction/patron,
	/datum/chemical_reaction/Cream, /datum/chemical_reaction/soysauce)


/obj/item/weapon/electrolyzer/attack_self(mob/user as mob)
	if(beakers.len)
		for(var/obj/B in beakers)
			if(istype(B))
				beakers -= B
				user.put_in_hands(B)

/obj/item/weapon/electrolyzer/attackby(obj/item/weapon/W as obj, mob/user as mob)
	if(iswirecutter(W))
		if(beakers.len)
			to_chat(user, "<span class='warning'>The electrolyzer contains beakers!</span>")
			return
		else
			to_chat(user, "<span class='notice'>You disassemble the electrolyzer.</span>")
			var/turf/T = get_turf(src)
			new /obj/item/stack/cable_coil(T,2)
			new /obj/item/weapon/grenade/chem_grenade(T)
			del(src)
			return
	else if(is_type_in_list(W, allowed_containers))
		var/obj/item/weapon/reagent_containers/glass/G = W
		if(G.reagents.reagent_list.len > 1)
			to_chat(user, "<span class='warning'>That mixture is too complex!</span>")
			return
		if(beakers.len == 2)
			to_chat(user, "<span class='warning'>The grenade can not hold more containers.</span>")
			return
		else if(beakers.len == 1)
			var/obj/item/weapon/reagent_containers/glass/other = beakers[1]
			if(other.reagents.total_volume && !G.reagents.total_volume) //We already have one inserted beaker. It must occupy slot 1. Is it empty or active?
				to_chat(user, "<span class='notice'>You add \the [G] to the electrolyzer as the empty container.</span>")
				insert_beaker(G,user)
			else if(!other.reagents.total_volume && G.reagents.total_volume)
				to_chat(user, "<span class='notice'>You add \the [G] to the electrolyzer as the active container.</span>")
				insert_beaker(G,user)
			else
				to_chat(user, "<span class='warning'>The electrolyzer requires one active beaker and one empty beaker!</span>")
				return
		else
			to_chat(user, "<span class='notice'>You add \the [G] to the electrolyzer as the [G.reagents.total_volume ? "active" : "empty"] container.</span>")
			insert_beaker(G,user)
	else if(istype(W, /obj/item/weapon/cell))
		if(beakers.len < 2)
			to_chat(user, "<span class='warning'>The electrolyzer requires one active beaker and one empty beaker!</span>")
			return
		var/obj/item/weapon/cell/C = W
		var/obj/item/weapon/reagent_containers/active = null
		var/obj/item/weapon/reagent_containers/empty = null
		var/datum/chemical_reaction/unreaction = null
		for(var/obj/item/weapon/reagent_containers/B in beakers)
			if(B.reagents.reagent_list.len > 1) //This only fires if their power ran out with a first cell and they try electrolyzing again without removing the old mix
				to_chat(user, "<span class='warning'>That mixture is too complex!</span>")
				return
			else if(B.reagents.reagent_list.len == 1)
				active = B
			else if (!B.reagents.reagent_list.len)
				empty = B
			else
				to_chat(user, "<span class='warning'>An error has occured. Your beaker had between 0 and 1 reagents. Please report this message.</span>")
		if(!active || !empty)
			to_chat(user, "<span class='warning'>There must be both an empty and active beaker.</span>")
			return
		var/datum/reagent/target = active.reagents.reagent_list[1] //Should only have one thing anyway
		for(var/R in allowed_reactions)
			var/datum/chemical_reaction/check = new R
			if(check.id == target.id)
				unreaction = check
				break
		if(!unreaction)
			to_chat(user, "<span class='notice'>The system didn't react...</span>")
			return
		var/total_reactions = round(active.reagents.total_volume / unreaction.result_amount)
		var/primary = 1
		if(C.charge<30*total_reactions)
			total_reactions = round(C.charge/30) //In the case that we don't have ENOUGH charge, this will react us as often as we can
		C.charge -= (30*total_reactions)
		active.reagents.remove_reagent(unreaction.result,total_reactions*unreaction.result_amount) //This moves over the reactive bulk, and leaves behind the amount too small to react
		for(var/E in unreaction.required_reagents)
			if(primary)
				active.reagents.add_reagent(E, unreaction.required_reagents[E]*total_reactions) //Put component amount * reaction count back in primary
				primary = 0
			else
				empty.reagents.add_reagent(E, unreaction.required_reagents[E]*total_reactions)
		to_chat(user, "<span class='warning'>The system electrolyzes!</span>")
	else
		..()

/obj/item/weapon/electrolyzer/proc/insert_beaker(obj/item/weapon/W as obj, mob/user as mob)
	W.loc = src
	beakers += W
	user.drop_item(W, src)


/obj/structure/centrifuge
	name = "suspicious toilet"
	desc = "This toilet is a cleverly disguised improvised centrifuge."
	icon = 'icons/obj/watercloset.dmi'
	icon_state = "toilet11"
	density = 0
	anchored = 1
	var/list/cans = new/list() //These are the empty containers.
	var/obj/item/weapon/reagent_containers/beaker = null // This is the active container

	var/targetMoveKey

/obj/structure/centrifuge/examine(mob/user)
	..()
	to_chat(user, "<span class='info'>It contains [cans.len] empty containers[beaker ? " and an active container!" : "."]</span>")

/obj/structure/centrifuge/attackby(obj/item/weapon/reagent_containers/W as obj, mob/user as mob)
	if(iscrowbar(W))
		var/obj/structure/toilet/T = new /obj/structure/toilet(src.loc)
		T.open = 1
		T.cistern = 1
		T.dir = src.dir
		T.update_icon()
		new /obj/item/stack/rods(get_turf(src), 2)
		to_chat(user, "<span class='notice'>You pry out the rods, destroying the filter.</span>")
		qdel(src)
	if(W.is_open_container())
		if(!W.reagents.total_volume)
			W.loc = src
			cans += W
			user.drop_item(W, src)
			to_chat(user, "<span class='notice'>You add a passive container. It now contains [cans.len].</span>")
		else
			if(!beaker)
				to_chat(user, "<span class='notice'>You insert an active container.</span>")
				src.beaker =  W
				if(user.type == /mob/living/silicon/robot)
					var/mob/living/silicon/robot/R = user
					R.uneq_active()
					targetMoveKey =  R.on_moved.Add(src, "user_moved")

				user.drop_item(W, src)
			else
				to_chat(user, "<span class='warning'>There is already an active container.</span>")
		return
	else
		..()
/obj/structure/centrifuge/proc/user_moved(var/list/args)
	var/event/E = args["event"]
	if(!targetMoveKey)
		E.handlers.Remove("\ref[src]:user_moved")
		return

	var/turf/T = args["loc"]

	if(!Adjacent(T))
		if(E.holder)
			E.holder.on_moved.Remove(targetMoveKey)
		detach()

/obj/structure/centrifuge/attack_hand(mob/user as mob)
	add_fingerprint(user)
	if(cans.len || beaker)
		for(var/obj/item/O in cans)
			O.loc = src.loc
			cans -= O
		if(beaker)
			detach()
		to_chat(user, "<span class='notice'>You remove everything from the centrifuge.</span>")
	else
		to_chat(user, "<span class='warning'>There is nothing to eject!</span>")

/obj/structure/centrifuge/verb/flush()
	set name = "Flush"
	set category = "Object"
	set src in view(1)
	add_fingerprint(usr)
	to_chat(usr, "<span class='notice'>\The [src] groans as it spits out containers.</span>")
	while(cans.len>0 && beaker.reagents.reagent_list.len>0)
		var/obj/item/weapon/reagent_containers/C = cans[1]
		var/datum/reagent/R = beaker.reagents.reagent_list[1]
		beaker.reagents.trans_id_to(C,R.id,50)
		C.loc = src.loc
		cans -= C
	if(!cans.len&&beaker.reagents.reagent_list.len)
		to_chat(usr, "<span class='warning'>With no remaining containers, the rest of the concoction swirls down the drain...</span>")
		beaker.reagents.clear_reagents()
	if(!beaker.reagents.reagent_list.len)
		to_chat(usr, "<span class='notice'>The now-empty active container plops out.</span>")
		detach()
		return

/obj/structure/centrifuge/proc/detach()
	if(beaker)
		beaker.loc = src.loc
		if(istype(beaker, /obj/item/weapon/reagent_containers/glass/beaker/large/cyborg))
			var/mob/living/silicon/robot/R = beaker:holder:loc
			if(R.module_state_1 == beaker || R.module_state_2 == beaker || R.module_state_3 == beaker)
				beaker.loc = R
			else
				beaker.loc = beaker:holder
		beaker = null
		return

/obj/item/weapon/reagent_containers/mortar
	name = "mortar"
	desc = "This is a reinforced bowl, used for crushing reagents. Ooga booga Rockstop."
	icon = 'icons/obj/food.dmi'
	icon_state = "mortar"
	flags = FPRINT  | OPENCONTAINER
	volume = 50
	amount_per_transfer_from_this = 5
	//We want the all-in-one grinder audience

	var/list/blend_items = list (
		/obj/item/stack/sheet/metal           = list("iron",20),
		/obj/item/stack/sheet/mineral/plasma  = list("plasma",20),
		/obj/item/stack/sheet/mineral/uranium = list("uranium",20),
		/obj/item/stack/sheet/mineral/clown   = list("banana",20),
		/obj/item/stack/sheet/mineral/silver  = list("silver",20),
		/obj/item/stack/sheet/mineral/gold    = list("gold",20),
		/obj/item/weapon/grown/nettle         = list("sacid",0),
		/obj/item/weapon/grown/deathnettle    = list("pacid",0),
		/obj/item/stack/sheet/charcoal        = list("charcoal",20),
		/obj/item/weapon/reagent_containers/food/snacks/grown/soybeans = list("soymilk",1),
		/obj/item/weapon/reagent_containers/food/snacks/grown/tomato = list("ketchup",2),
		/obj/item/weapon/reagent_containers/food/snacks/grown/corn = list("cornoil",3),
		/obj/item/weapon/reagent_containers/food/snacks/grown/wheat = list("flour",5),
		/obj/item/weapon/reagent_containers/food/snacks/grown/ricestalk = list("rice",5),
		/obj/item/weapon/reagent_containers/food/snacks/grown/cherries = list("cherryjelly",1),
		/obj/item/seeds = list("blackpepper",5),
		/obj/item/device/flashlight/flare     = list("sulfur",10),
		/obj/item/stack/cable_coil            = list("copper", 10),
		/obj/item/weapon/cell                 = list("lithium", 10),
		/obj/item/clothing/head/butt          = list("mercury", 10),
		/obj/item/weapon/rocksliver           = list("ground_rock",30),

		//Recipes must include both variables!
		/obj/item/weapon/reagent_containers/food = list("generic",0)
	)

	var/list/juice_items = list (
		/obj/item/weapon/reagent_containers/food/snacks/grown/tomato = list("tomatojuice",0),
		/obj/item/weapon/reagent_containers/food/snacks/grown/carrot = list("carrotjuice",0),
		/obj/item/weapon/reagent_containers/food/snacks/grown/berries = list("berryjuice",0),
		/obj/item/weapon/reagent_containers/food/snacks/grown/banana = list("banana",0),
		/obj/item/weapon/reagent_containers/food/snacks/grown/potato = list("potato",0),
		/obj/item/weapon/reagent_containers/food/snacks/grown/lemon = list("lemonjuice",0),
		/obj/item/weapon/reagent_containers/food/snacks/grown/orange = list("orangejuice",0),
		/obj/item/weapon/reagent_containers/food/snacks/grown/lime = list("limejuice",0),
		/obj/item/weapon/reagent_containers/food/snacks/grown/watermelon = list("watermelonjuice",0),
		/obj/item/weapon/reagent_containers/food/snacks/watermelonslice = list("watermelonjuice",0),
		/obj/item/weapon/reagent_containers/food/snacks/grown/poisonberries = list("poisonberryjuice",0),
	)


	var/obj/item/crushable = null


/obj/item/weapon/reagent_containers/mortar/afterattack(var/obj/target, var/mob/user, var/adjacency_flag)
	if (!adjacency_flag)
		return

	transfer(target, user, can_send = TRUE, can_receive = TRUE, splashable_units = -1)

/obj/item/weapon/reagent_containers/mortar/attackby(var/obj/item/O as obj, var/mob/user as mob)
	if (isscrewdriver(O))
		if(crushable)
			crushable.loc = src.loc
		new /obj/item/stack/sheet/metal(user.loc)
		new /obj/item/trash/bowl(user.loc)
		return
	if (crushable)
		to_chat(user, "<span class ='warning'>There's already something inside!</span>")
		return 1
	if (!is_type_in_list(O, blend_items) && !is_type_in_list(O, juice_items))
		to_chat(user, "<span class ='warning'>You can't grind that!</span>")
		return ..()
	if(istype(O, /obj/item/stack/))
		var/obj/item/stack/N = new O.type(src, amount=1)
		var/obj/item/stack/S = O
		S.use(1)
		crushable = N
		return 0
	user.drop_item(O, src)
	crushable = O
	return 0

/obj/item/weapon/reagent_containers/mortar/attack_hand(mob/user as mob)
	add_fingerprint(user)
	if(user.get_inactive_hand() != src) return ..()
	if(crushable)
		crushable.loc = src.loc
		user.put_in_active_hand(crushable)
		crushable = null
	return

/obj/item/weapon/reagent_containers/mortar/attack_self(mob/user as mob)
	if(!crushable)
		to_chat(user, "<span class='notice'>There is nothing to be crushed.</span>")
		return
	if (reagents.total_volume >= volume)
		to_chat(user, "<span class='warning'>There is no more space inside!</span>")
		return
	if(is_type_in_list(crushable, juice_items))
		to_chat(user, "<span class='notice'>You smash the contents into juice!</span>")
		var/id = null
		for(var/i in juice_items)
			if(istype(crushable, i))
				id = juice_items[i]
		if(!id)
			return
		var/obj/item/weapon/reagent_containers/food/snacks/grown/juiceable = crushable
		if(juiceable.potency == -1)
			juiceable.potency = 0
		reagents.add_reagent(id[1], min(round(5*sqrt(juiceable.potency)), volume - reagents.total_volume))
	else if(is_type_in_list(crushable, blend_items))
		to_chat(user, "<span class='notice'>You grind the contents into dust!</span>")
		var/id = null
		var/space = volume - reagents.total_volume
		for(var/i in blend_items)
			if(istype(crushable, i))
				id = blend_items[i]
				break
		if(!id)
			return
		if(istype(crushable, /obj/item/weapon/reagent_containers/food/snacks)) //Most growable food
			if(id[1] == "generic")
				crushable.reagents.trans_to(src,crushable.reagents.total_volume)
			else
				reagents.add_reagent(id[1],min(id[2], space))
		else if(istype(crushable, /obj/item/stack/sheet) || istype(crushable, /obj/item/seeds) || /obj/item/device/flashlight/flare || /obj/item/stack/cable_coil || /obj/item/weapon/cell || /obj/item/clothing/head/butt) //Generic processes
			reagents.add_reagent(id[1],min(id[2], space))
		else if(istype(crushable, /obj/item/weapon/grown)) //Nettle and death nettle
			crushable.reagents.trans_to(src,crushable.reagents.total_volume)
		else if(istype(crushable, /obj/item/weapon/rocksliver)) //Xenoarch
			var/obj/item/weapon/rocksliver/R = crushable
			reagents.add_reagent(id[1],min(id[2], space), R.geological_data)
		else
			to_chat(user, "<span class ='warning'>An error was encountered. Report this message.</span>")
			return
	else
		to_chat(user, "<span class='notice'>You smash the contents into nothingness.</span>")
	qdel(crushable)
	crushable = null
	return

/obj/item/weapon/reagent_containers/mortar/examine(mob/user)
	..()
	to_chat(user, "<span class='info'>It has [crushable ? "an unground \the [crushable] inside." : "nothing to be crushed."]</span>")
