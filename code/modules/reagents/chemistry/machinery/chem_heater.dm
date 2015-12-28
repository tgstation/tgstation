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
	if(on)
		if(beaker)
			if(beaker.reagents.chem_temp > desired_temp)
				beaker.reagents.chem_temp += min(-1, (desired_temp - beaker.reagents.chem_temp) * heater_coefficient)
			if(beaker.reagents.chem_temp < desired_temp)
				beaker.reagents.chem_temp += max(1, (desired_temp - beaker.reagents.chem_temp) * heater_coefficient)
			beaker.reagents.chem_temp = round(beaker.reagents.chem_temp) //stops stuff like 456.12312312302

			beaker.reagents.handle_reactions()

/obj/machinery/chem_heater/power_change()
	if(powered())
		stat &= ~NOPOWER
	else
		spawn(rand(0, 15))
			stat |= NOPOWER

/obj/machinery/chem_heater/attackby(obj/item/I, mob/user, params)
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

	if(default_deconstruction_screwdriver(user, "mixer0b", "mixer0b", I))
		return

	if(exchange_parts(user, I))
		return

	if(panel_open)
		if(istype(I, /obj/item/weapon/crowbar))
			eject_beaker()
			default_deconstruction_crowbar(I)
			return 1

/obj/machinery/chem_heater/attack_hand(mob/user)
	if (!user)
		return
	interact(user)

/obj/machinery/chem_heater/ui_act(action, params)
	if(..())
		return

	switch(action)
		if("power")
			on = !on
		if("temperature")
			desired_temp = Clamp(input("Please input the target temperature", name) as num, 0, 1000)
		if("eject")
			eject_beaker()
	return 1

/obj/machinery/chem_heater/interact(mob/user)
	if(stat & BROKEN)
		return
	ui_interact(user)

/obj/machinery/chem_heater/ui_interact(mob/user, ui_key = "main", datum/nanoui/ui = null, force_open = 0)
	ui = SSnano.try_update_ui(user, src, ui_key, ui, force_open = force_open)
	if (!ui)
		ui = new(user, src, ui_key, "chem_heater", name, 350, 400)
		ui.open()

/obj/machinery/chem_heater/get_ui_data()
	var/data = list()
	data["targetTemp"] = desired_temp
	data["isActive"] = on
	data["isBeakerLoaded"] = beaker ? 1 : 0

	data["currentTemp"] = beaker ? beaker.reagents.chem_temp : null
	data["beakerCurrentVolume"] = beaker ? beaker.reagents.total_volume : null
	data["beakerMaxVolume"] = beaker ? beaker.volume : null

	var beakerContents[0]
	if(beaker)
		for(var/datum/reagent/R in beaker.reagents.reagent_list)
			beakerContents.Add(list(list("name" = R.name, "volume" = R.volume))) // list in a list because Byond merges the first list...
	data["beakerContents"] = beakerContents
	return data

/obj/machinery/chem_heater/proc/eject_beaker()
	if(beaker)
		beaker.loc = get_turf(src)
		beaker.reagents.handle_reactions()
		beaker = null
		icon_state = "mixer0b"