/obj/machinery/smoke_machine
	name = "smoke machine"
	desc = "A machine with a centrifuge installed into it. It produces smoke with any reagents you put into the machine."
	icon = 'icons/obj/chemical.dmi'
	icon_state = "smoke0"
	density = TRUE
	anchored = TRUE
	circuit = /obj/item/circuitboard/machine/smoke_machine
	var/efficiency = 10
	var/on = FALSE
	var/cooldown = 0
	var/screen = "home"
	var/useramount = 30 // Last used amount
	var/volume = 300
	var/setting = 3
	var/list/possible_settings = list(3,6,9)

/datum/effect_system/smoke_spread/chem/smoke_machine/set_up(datum/reagents/carry, setting = 3, efficiency = 10, loc)
	amount = setting
	carry.copy_to(chemholder, 20)
	carry.remove_any(setting * 16 / efficiency)
	location = loc

/datum/effect_system/smoke_spread/chem/smoke_machine
	effect_type = /obj/effect/particle_effect/smoke/chem/smoke_machine

/obj/effect/particle_effect/smoke/chem/smoke_machine
	opaque = FALSE
	alpha = 100


/obj/machinery/smoke_machine/Initialize()
	. = ..()
	create_reagents(volume)

/obj/machinery/smoke_machine/update_icon()
	if((!is_operational()) || (!on) || (reagents.total_volume == 0))
		icon_state = "smoke0"
	else
		icon_state = "smoke1"
	. = ..()

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
	update_icon()
	if(!is_operational())
		return
	if(reagents.total_volume == 0)
		on = FALSE
		return
	var/turf/T = get_turf(src)
	var/smoke_test = locate(/obj/effect/particle_effect/smoke) in T
	if(on && !smoke_test)
		var/datum/effect_system/smoke_spread/chem/smoke_machine/smoke = new()
		smoke.set_up(reagents, setting, efficiency, T)
		smoke.start()

/obj/machinery/smoke_machine/attackby(obj/item/I, mob/user, params)
	add_fingerprint(user)
	if(istype(I, /obj/item/reagent_containers) && I.is_open_container())
		var/obj/item/reagent_containers/RC = I
		var/units = RC.reagents.trans_to(src, RC.amount_per_transfer_from_this)
		if(units)
			to_chat(user, "<span class='notice'>You transfer [units] units of the solution to [src].</span>")
			add_logs(usr, src, "has added [english_list(RC.reagents.reagent_list)] to [src]")
			return
	if(default_unfasten_wrench(user, I, 40))
		on = FALSE
		return
	return ..()

/obj/machinery/smoke_machine/ui_interact(mob/user, ui_key = "main", datum/tgui/ui = null, force_open = FALSE, \
										datum/tgui/master_ui = null, datum/ui_state/state = GLOB.default_state)
	ui = SStgui.try_update_ui(user, src, ui_key, ui, force_open)
	if(!ui)
		ui = new(user, src, ui_key, "smoke_machine", name, 450, 350, master_ui, state)
		ui.open()

/obj/machinery/smoke_machine/ui_data(mob/user)
	var/data = list()
	var/TankContents[0]
	var/TankCurrentVolume = 0
	for(var/datum/reagent/R in reagents.reagent_list)
		TankContents.Add(list(list("name" = R.name, "volume" = R.volume))) // list in a list because Byond merges the first list...
		TankCurrentVolume += R.volume
	data["TankContents"] = TankContents
	data["isTankLoaded"] = reagents.total_volume ? TRUE : FALSE
	data["TankCurrentVolume"] = reagents.total_volume ? reagents.total_volume : null
	data["TankMaxVolume"] = reagents.maximum_volume
	data["active"] = on
	data["setting"] = setting
	data["screen"] = screen
	return data

/obj/machinery/smoke_machine/ui_act(action, params)
	if(..() || !anchored)
		return
	switch(action)
		if("purge")
			reagents.clear_reagents()
			. = TRUE
		if("setting")
			var/amount = text2num(params["amount"])
			if (locate(amount) in possible_settings)
				setting = amount
				. = TRUE
		if("power")
			on = !on
			if(on)
				message_admins("[key_name_admin(usr)] activated a smoke machine that contains [english_list(reagents.reagent_list)] at [ADMIN_COORDJMP(src)].")
				log_game("[key_name(usr)] activated a smoke machine that contains [english_list(reagents.reagent_list)] at [COORD(src)].")
				add_logs(usr, src, "has activated [src] which contains [english_list(reagents.reagent_list)].")
		if("goScreen")
			screen = params["screen"]
			. = TRUE
