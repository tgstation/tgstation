/obj/machinery/smoke_machine
	name = "Smoke Machine"
	icon = 'icons/obj/chemical.dmi'
	icon_state = "smoke0"
	density = TRUE
	anchored = TRUE
	circuit = /obj/item/circuitboard/machine/smoke_machine
	var/efficiency = 10
	var/on = FALSE
	var/cooldown = 0
	var/screen = "home"
	var/analyzeVars[0]
	var/useramount = 30 // Last used amount
	var/volume = 1000
	var/setting = 3
	var/list/possible_settings = list(3,6,9,12,15)

/datum/effect_system/smoke_spread/chem/smoke_machine/set_up(datum/reagents/carry = null, setting = 3, efficiency = 10, loc)
	amount = setting
	carry.copy_to(chemholder, 20)
	carry.remove_any(setting * 16 / efficiency)
	location = loc

/obj/machinery/smoke_machine/Initialize()
	create_reagents(volume)
	. = ..()
/obj/machinery/smoke_machine/Destroy()
	STOP_PROCESSING(SSprocessing, src)
	return ..()

/obj/machinery/smoke_machine/RefreshParts()
	efficiency = 6
	for(var/obj/item/stock_parts/matter_bin/B in component_parts)
		efficiency += B.rating
	for(var/obj/item/stock_parts/capacitor/C in component_parts)
		efficiency += C.rating
	for(var/obj/item/stock_parts/manipulator/M in component_parts)
		efficiency += M.rating

/obj/machinery/smoke_machine/process()
	..()
	if(stat & NOPOWER)
		icon_state = "smoke0"
		update_icon()
		return
	if(reagents.total_volume == 0)
		on = FALSE
		icon_state = "smoke0"
		update_icon()
		return
	if(on && (cooldown < world.time))
		icon_state = "smoke1"
		update_icon()
		cooldown = world.time + 180
		var/datum/effect_system/smoke_spread/chem/smoke_machine/smoke = new()
		smoke.set_up(reagents, setting, efficiency, get_turf(src))
		smoke.start()

/obj/machinery/smoke_machine/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/reagent_containers))
		var/obj/item/reagent_containers/RC = I
		var/units = RC.reagents.trans_to(src, RC.amount_per_transfer_from_this)
		if(units)
			to_chat(user, "<span class='notice'>You transfer [units] units of the solution to [src].</span>")
			return
	if(default_unfasten_wrench(user, I))
		return
	.=..()


/obj/machinery/smoke_machine/ui_interact(mob/user, ui_key = "main", datum/tgui/ui = null, force_open = FALSE, \
										datum/tgui/master_ui = null, datum/ui_state/state = GLOB.default_state)
	ui = SStgui.try_update_ui(user, src, ui_key, ui, force_open)
	if(!ui)
		ui = new(user, src, ui_key, "smoke_machine", name, 450, 350, master_ui, state)
		ui.open()


/obj/machinery/smoke_machine/ui_data(mob/user)
	var/data = list()
	var TankContents[0]
	var TankCurrentVolume = 0
	if(reagents.reagent_list.len)
		for(var/datum/reagent/R in reagents.reagent_list)
			TankContents.Add(list(list("name" = R.name, "volume" = R.volume))) // list in a list because Byond merges the first list...
			TankCurrentVolume += R.volume
	data["TankContents"] = TankContents
	data["isTankLoaded"] = reagents.total_volume ? 1 : 0
	data["TankCurrentVolume"] = reagents.total_volume ? reagents.total_volume : null
	data["TankMaxVolume"] = reagents.maximum_volume
	data["active"] = on
	data["setting"] = setting
	data["screen"] = screen
	data["analyzeVars"] = analyzeVars
	return data

/obj/machinery/smoke_machine/ui_act(action, params)
	if(..() || (anchored == FALSE))
		return
	switch(action)
		if("purge")
			reagents.clear_reagents()
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
		if("setting")
			var/amount = text2num(params["amount"])
			if (locate(amount) in possible_settings)
				setting = amount
				. = TRUE
		if("power")
			on = !on
		if("goScreen")
			screen = params["screen"]
			. = TRUE