/obj/machinery/chem_master
	name = "ChemMaster 3000"
	desc = "Used to seperate chemicals and distribute them in a variety of forms."
	density = 1
	anchored = 1
	icon = 'icons/obj/chemical.dmi'
	icon_state = "mixer0"
	use_power = 1
	idle_power_usage = 20
	resistance_flags = FIRE_PROOF | ACID_PROOF
	var/obj/item/weapon/reagent_containers/beaker = null
	var/obj/item/weapon/storage/pill_bottle/bottle = null
	var/mode = 1
	var/condi = 0
	var/screen = "home"
	var/analyzeVars[0]
	var/useramount = 30 // Last used amount
	layer = BELOW_OBJ_LAYER

/obj/machinery/chem_master/Initialize()
	create_reagents(100)
	add_overlay("waitlight")
	var/obj/item/weapon/circuitboard/machine/B = new /obj/item/weapon/circuitboard/machine/chem_master(null)
	B.apply_default_parts(src)
	. = ..()

/obj/item/weapon/circuitboard/machine/chem_master
	name = "ChemMaster 3000 (Machine Board)"
	build_path = /obj/machinery/chem_master
	origin_tech = "materials=3;programming=2;biotech=3"
	req_components = list(
							/obj/item/weapon/reagent_containers/glass/beaker = 2,
							/obj/item/weapon/stock_parts/manipulator = 1,
							/obj/item/weapon/stock_parts/console_screen = 1)

/obj/item/weapon/circuitboard/machine/chem_master/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/weapon/screwdriver))
		var/new_name = "ChemMaster"
		var/new_path = /obj/machinery/chem_master

		if(build_path == /obj/machinery/chem_master)
			new_name = "CondiMaster"
			new_path = /obj/machinery/chem_master/condimaster

		build_path = new_path
		name = "[new_name] 3000 (Machine Board)"
		to_chat(user, "<span class='notice'>You change the circuit board setting to \"[new_name]\".</span>")
	else
		return ..()

/obj/machinery/chem_master/RefreshParts()
	reagents.maximum_volume = 0
	for(var/obj/item/weapon/reagent_containers/glass/beaker/B in component_parts)
		reagents.maximum_volume += B.reagents.maximum_volume

/obj/machinery/chem_master/ex_act(severity, target)
	if(severity < 3)
		..()

/obj/machinery/chem_master/contents_explosion(severity, target)
	..()
	if(beaker)
		beaker.ex_act(severity, target)
	if(bottle)
		bottle.ex_act(severity, target)

/obj/machinery/chem_master/handle_atom_del(atom/A)
	..()
	if(A == beaker)
		beaker = null
		reagents.clear_reagents()
		icon_state = "mixer0"
	else if(A == bottle)
		bottle = null


/obj/machinery/chem_master/blob_act(obj/structure/blob/B)
	if (prob(50))
		qdel(src)

/obj/machinery/chem_master/power_change()
	if(powered())
		stat &= ~NOPOWER
	else
		spawn(rand(0, 15))
			stat |= NOPOWER

/obj/machinery/chem_master/attackby(obj/item/I, mob/user, params)
	if(default_deconstruction_screwdriver(user, "mixer0_nopower", "mixer0", I))
		if(beaker)
			beaker.loc = src.loc
			beaker = null
			reagents.clear_reagents()
		if(bottle)
			bottle.loc = src.loc
			bottle = null
		return

	else if(exchange_parts(user, I))
		return
	else if(default_deconstruction_crowbar(I))
		return

	if(default_unfasten_wrench(user, I))
		return

	if(istype(I, /obj/item/weapon/reagent_containers) && (I.container_type & OPENCONTAINER))
		. = 1 // no afterattack
		if(panel_open)
			to_chat(user, "<span class='warning'>You can't use the [src.name] while its panel is opened!</span>")
			return
		if(beaker)
			to_chat(user, "<span class='warning'>A container is already loaded in the machine!</span>")
			return
		if(!user.drop_item())
			return

		beaker = I
		beaker.loc = src
		to_chat(user, "<span class='notice'>You add the beaker to the machine.</span>")
		src.updateUsrDialog()
		icon_state = "mixer1"

	else if(!condi && istype(I, /obj/item/weapon/storage/pill_bottle))
		if(bottle)
			to_chat(user, "<span class='warning'>A pill bottle is already loaded into the machine!</span>")
			return
		if(!user.drop_item())
			return

		bottle = I
		bottle.loc = src
		to_chat(user, "<span class='notice'>You add the pill bottle into the dispenser slot.</span>")
		src.updateUsrDialog()
	else
		return ..()


/obj/machinery/chem_master/ui_interact(mob/user, ui_key = "main", datum/tgui/ui = null, force_open = 0, \
										datum/tgui/master_ui = null, datum/ui_state/state = GLOB.default_state)
	ui = SStgui.try_update_ui(user, src, ui_key, ui, force_open)
	if(!ui)
		ui = new(user, src, ui_key, "chem_master", name, 500, 550, master_ui, state)
		ui.open()


/obj/machinery/chem_master/ui_data(mob/user)
	var/list/data = list()
	data["isBeakerLoaded"] = beaker ? 1 : 0
	data["beakerCurrentVolume"] = beaker ? beaker.reagents.total_volume : null
	data["beakerMaxVolume"] = beaker ? beaker.volume : null
	data["mode"] = mode
	data["condi"] = condi
	data["screen"] = screen
	data["analyzeVars"] = analyzeVars

	data["isPillBottleLoaded"] = bottle ? 1 : 0
	if(bottle)
		data["pillBotContent"] = bottle.contents.len
		data["pillBotMaxContent"] = bottle.storage_slots


	var beakerContents[0]
	if(beaker)
		for(var/datum/reagent/R in beaker.reagents.reagent_list)
			beakerContents.Add(list(list("name" = R.name, "id" = R.id, "volume" = R.volume))) // list in a list because Byond merges the first list...
		data["beakerContents"] = beakerContents

	var bufferContents[0]
	if(reagents.total_volume)
		for(var/datum/reagent/N in reagents.reagent_list)
			bufferContents.Add(list(list("name" = N.name, "id" = N.id, "volume" = N.volume))) // ^
		data["bufferContents"] = bufferContents


	return data

/obj/machinery/chem_master/ui_act(action, params)
	if(..())
		return
	switch(action)
		if("eject")
			if(beaker)
				beaker.loc = src.loc
				beaker = null
				reagents.clear_reagents()
				icon_state = "mixer0"
				. = TRUE

		if("ejectp")
			if(bottle)
				bottle.loc = src.loc
				bottle = null
				. = TRUE

		if("transferToBuffer")
			if(beaker)
				var/id = params["id"]
				var/amount = text2num(params["amount"])
				if (amount > 0)
					beaker.reagents.trans_id_to(src, id, amount)
					. = TRUE
				else if (amount == -1) // -1 means custom amount
					useramount = input("Enter the Amount you want to transfer:", name, useramount) as num|null
					if (useramount > 0)
						beaker.reagents.trans_id_to(src, id, useramount)
						. = TRUE

		if("transferFromBuffer")
			var/id = params["id"]
			var/amount = text2num(params["amount"])
			if (amount > 0)
				if(mode)
					reagents.trans_id_to(beaker, id, amount)
					. = TRUE
				else
					reagents.remove_reagent(id, amount)
					. = TRUE

		if("toggleMode")
			mode = !mode
			. = TRUE

		if("createPill")
			var/many = params["many"]
			if(reagents.total_volume == 0)
				return
			if(!condi)
				var/amount = 1
				var/vol_each = min(reagents.total_volume, 50)
				if(text2num(many))
					amount = Clamp(round(input(usr, "Max 10. Buffer content will be split evenly.", "How many pills?", amount) as num|null), 0, 10)
					if(!amount)
						return
					vol_each = min(reagents.total_volume / amount, 50)
				var/name = stripped_input(usr,"Name:","Name your pill!", "[reagents.get_master_reagent_name()] ([vol_each]u)", MAX_NAME_LEN)
				if(!name || !reagents.total_volume || !src || QDELETED(src) || !usr.canUseTopic(src, be_close=TRUE))
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
				if(!name || !reagents.total_volume || !src || QDELETED(src) || !usr.canUseTopic(src, be_close=TRUE))
					return
				var/obj/item/weapon/reagent_containers/food/condiment/pack/P = new/obj/item/weapon/reagent_containers/food/condiment/pack(src.loc)

				P.originalname = name
				P.name = trim("[name] pack")
				P.desc = "A small condiment pack. The label says it contains [name]."
				reagents.trans_to(P,10)
			. = TRUE

		if("createPatch")
			var/many = params["many"]
			if(reagents.total_volume == 0)
				return
			var/amount = 1
			var/vol_each = min(reagents.total_volume, 40)
			if(text2num(many))
				amount = Clamp(round(input(usr, "Max 10. Buffer content will be split evenly.", "How many patches?", amount) as num|null), 0, 10)
				if(!amount)
					return
				vol_each = min(reagents.total_volume / amount, 40)
			var/name = stripped_input(usr,"Name:","Name your patch!", "[reagents.get_master_reagent_name()] ([vol_each]u)", MAX_NAME_LEN)
			if(!name || !reagents.total_volume || !src || QDELETED(src) || !usr.canUseTopic(src, be_close=TRUE))
				return
			var/obj/item/weapon/reagent_containers/pill/P

			for(var/i = 0; i < amount; i++)
				P = new/obj/item/weapon/reagent_containers/pill/patch(src.loc)
				P.name = trim("[name] patch")
				P.pixel_x = rand(-7, 7) //random position
				P.pixel_y = rand(-7, 7)
				reagents.trans_to(P,vol_each)
			. = TRUE

		if("createBottle")
			var/many = params["many"]
			if(reagents.total_volume == 0)
				return

			if(condi)
				var/name = stripped_input(usr, "Name:","Name your bottle!", (reagents.total_volume ? reagents.get_master_reagent_name() : " "), MAX_NAME_LEN)
				if(!name || !reagents.total_volume || !src || QDELETED(src) || !usr.canUseTopic(src, be_close=TRUE))
					return
				var/obj/item/weapon/reagent_containers/food/condiment/P = new(src.loc)
				P.originalname = name
				P.name = trim("[name] bottle")
				reagents.trans_to(P, P.volume)
			else
				var/amount_full = 0
				var/vol_part = min(reagents.total_volume, 30)
				if(text2num(many))
					amount_full = round(reagents.total_volume / 30)
					vol_part = reagents.total_volume % 30
				var/name = stripped_input(usr, "Name:","Name your bottle!", (reagents.total_volume ? reagents.get_master_reagent_name() : " "), MAX_NAME_LEN)
				if(!name || !reagents.total_volume || !src || QDELETED(src) || !usr.canUseTopic(src, be_close=TRUE))
					return

				var/obj/item/weapon/reagent_containers/glass/bottle/P
				for(var/i = 0; i < amount_full; i++)
					P = new/obj/item/weapon/reagent_containers/glass/bottle(src.loc)
					P.pixel_x = rand(-7, 7) //random position
					P.pixel_y = rand(-7, 7)
					P.name = trim("[name] bottle")
					reagents.trans_to(P, 30)

				if(vol_part)
					P = new/obj/item/weapon/reagent_containers/glass/bottle(src.loc)
					P.name = trim("[name] bottle")
					reagents.trans_to(P, vol_part)
			. = TRUE

		if("analyze")
			var/datum/reagent/R = GLOB.chemical_reagents_list[params["id"]]
			if(R)
				var/state = "Unknown"
				if(initial(R.reagent_state) == 1)
					state = "Solid"
				else if(initial(R.reagent_state) == 2)
					state = "Liquid"
				else if(initial(R.reagent_state) == 3)
					state = "Gas"
				var/const/P = 3 //The number of seconds between life ticks
				var/T = initial(R.metabolization_rate) * (60 / P)
				analyzeVars = list("name" = initial(R.name), "state" = state, "color" = initial(R.color), "description" = initial(R.description), "metaRate" = T, "overD" = initial(R.overdose_threshold), "addicD" = initial(R.addiction_threshold))
				screen = "analyze"
				return

		if("goScreen")
			screen = params["screen"]
			. = TRUE




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

/obj/item/weapon/circuitboard/machine/chem_master/condi
	name = "CondiMaster 3000 (Machine Board)"
	build_path = /obj/machinery/chem_master/condimaster
