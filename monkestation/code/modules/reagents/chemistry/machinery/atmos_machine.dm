#define REAGENTS_BASE_VOLUME 100 // actual volume is REAGENTS_BASE_VOLUME plus REAGENTS_BASE_VOLUME * rating for each matterbin

///dont tell anyone this but this is literally just smoke machine code but with names replaced and smoke replaced with gas -Borbop

/obj/machinery/atmos_machine
	name = "evaporation machine"
	desc = "A machine with a centrifuge installed into it. It produces gas with any reagents you put into the machine."
	icon = 'icons/obj/chemical.dmi'
	icon_state = "smoke0"
	density = TRUE
	circuit = /obj/item/circuitboard/machine/atmos_machine



	var/efficiency = 10
	var/on = FALSE
	var/cooldown = 0
	var/useramount = 30 // Last used amount
	var/setting = 1 // displayed range is 3 * setting
	var/max_range = 3 // displayed max range is 3 * max range

	var/multiplier = 1


/obj/machinery/atmos_machine/Initialize(mapload)
	. = ..()
	create_reagents(REAGENTS_BASE_VOLUME)
	AddComponent(/datum/component/plumbing/simple_demand)
	for(var/obj/item/stock_parts/matter_bin/B in component_parts)
		reagents.maximum_volume += REAGENTS_BASE_VOLUME * B.rating
	if(is_operational)
		begin_processing()
	AddComponent(/datum/component/simple_rotation, ROTATION_ALTCLICK | ROTATION_CLOCKWISE | ROTATION_COUNTERCLOCKWISE | ROTATION_VERBS, null, CALLBACK(src, .proc/can_be_rotated))

/obj/machinery/atmos_machine/proc/can_be_rotated(mob/user,rotation_type)
	return !anchored

/obj/machinery/atmos_machine/update_icon()
	if((!is_operational) || (!on) || (reagents.total_volume == 0))
		if (panel_open)
			icon_state = "smoke0-o"
		else
			icon_state = "smoke0"
	else
		icon_state = "smoke1"
	return ..()

/obj/machinery/atmos_machine/RefreshParts()
	. = ..()
	var/new_volume = REAGENTS_BASE_VOLUME
	for(var/obj/item/stock_parts/matter_bin/installed_bin in component_parts)
		new_volume += REAGENTS_BASE_VOLUME * installed_bin.rating
	if(!reagents)
		create_reagents(new_volume)
	reagents.maximum_volume = new_volume
	if(new_volume < reagents.total_volume)
		reagents.reaction(loc, TOUCH) // if someone manages to downgrade it without deconstructing
		reagents.clear_reagents()
	efficiency = 9
	for(var/obj/item/stock_parts/capacitor/installed_cap in component_parts)
		efficiency += installed_cap.rating
	max_range = 1
	for(var/obj/item/stock_parts/manipulator/installed_manip in component_parts)
		max_range += installed_manip.rating
	max_range = max(3, max_range)
	multiplier = 0
	for(var/obj/item/stock_parts/capacitor/installed_cap in component_parts)
		multiplier += installed_cap.rating

/obj/machinery/atmos_machine/on_set_is_operational(old_value)
	if(old_value) //Turned off
		end_processing()
	else //Turned on
		begin_processing()

/obj/machinery/atmos_machine/process()
	..()
	if(reagents.total_volume == 0)
		on = FALSE
		update_icon()
		return
	if(on)
		update_icon()
		var/datum/reagents/chemholder = new(1000)
		reagents.trans_to(chemholder, ((setting * 3) * 16) / efficiency)

		for(var/datum/reagent/contained_reagent in chemholder.reagent_list)
			var/turf/turf = get_turf(src.loc)
			turf.atmos_spawn_air("[contained_reagent.get_gas()]=[(contained_reagent.volume * multiplier) /contained_reagent.molarity];TEMP=[T20C]") //yes yes i know this is more chemicals than was inputed but like this would be slow as fuck otherwise
			reagents.reagent_list -= contained_reagent
		qdel(chemholder)

/obj/machinery/atmos_machine/attackby(obj/item/I, mob/user, params)
	add_fingerprint(user)
	if(istype(I, /obj/item/reagent_containers) && I.is_open_container())
		var/obj/item/reagent_containers/RC = I
		var/units = RC.reagents.trans_to(src, RC.amount_per_transfer_from_this, transfered_by = user)
		if(units)
			if(on)
				log_combat(usr, src, "has added [units] to the [src] at [AREACOORD(src)] while the machine is running.")
			to_chat(user, "<span class='notice'>You transfer [units] units of the solution to [src].</span>")
			return
	if(default_unfasten_wrench(user, I, 40))
		on = FALSE
		return
	if(default_deconstruction_screwdriver(user, "smoke0-o", "smoke0", I))
		return
	if(default_deconstruction_crowbar(I))
		return
	return ..()

/obj/machinery/atmos_machine/deconstruct()
	reagents.reaction(loc, TOUCH)
	reagents.clear_reagents()
	return ..()


/obj/machinery/atmos_machine/ui_state(mob/user)
	return GLOB.default_state

/obj/machinery/atmos_machine/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "SmokeMachine")
		ui.open()
		ui.set_autoupdate(TRUE) // Tank contents, particularly plumbing

/obj/machinery/atmos_machine/ui_data(mob/user)
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
	data["maxSetting"] = max_range
	return data

/obj/machinery/atmos_machine/ui_act(action, params)
	if(..() || !anchored)
		return
	switch(action)
		if("purge")
			reagents.clear_reagents()
			update_icon()
			. = TRUE
		if("setting")
			var/amount = text2num(params["amount"])
			if(amount in 1 to max_range)
				setting = amount
				. = TRUE
		if("power")
			on = !on
			update_icon()
			. = TRUE
			if(on)
				message_admins("[ADMIN_LOOKUPFLW(usr)] activated an evaporation machine that contains [english_list(reagents.reagent_list)] at [ADMIN_VERBOSEJMP(src)].")
				log_game("[key_name(usr)] activated an evaporation machine that contains [english_list(reagents.reagent_list)] at [AREACOORD(src)].")
				log_combat(usr, src, "has activated [src] which contains [english_list(reagents.reagent_list)] at [AREACOORD(src)].")

#undef REAGENTS_BASE_VOLUME
