/obj/machinery/atmospherics/components/unary/cryo_cell
	name = "cryo cell"
	icon = 'icons/obj/cryogenics.dmi'
	icon_state = "cell-off"
	density = 1
	anchored = 1
	obj_integrity = 350
	max_integrity = 350
	armor = list(melee = 0, bullet = 0, laser = 0, energy = 100, bomb = 0, bio = 100, rad = 100, fire = 30, acid = 30)

	var/on = FALSE
	state_open = FALSE
	var/autoeject = FALSE
	var/volume = 100

	var/efficiency = 1
	var/sleep_factor = 750
	var/paralyze_factor = 1000
	var/heat_capacity = 20000
	var/conduction_coefficient = 0.30

	var/obj/item/weapon/reagent_containers/glass/beaker = null
	var/reagent_transfer = 0

	var/obj/item/device/radio/radio
	var/radio_key = /obj/item/device/encryptionkey/headset_med
	var/radio_channel = "Medical"

/obj/machinery/atmospherics/components/unary/cryo_cell/New()
	..()
	initialize_directions = dir
	var/obj/item/weapon/circuitboard/machine/B = new /obj/item/weapon/circuitboard/machine/cryo_tube(null)
	B.apply_default_parts(src)

	radio = new(src)
	radio.keyslot = new radio_key
	radio.subspace_transmission = 1
	radio.canhear_range = 0
	radio.recalculateChannels()

/obj/item/weapon/circuitboard/machine/cryo_tube
	name = "Cryotube (Machine Board)"
	build_path = /obj/machinery/atmospherics/components/unary/cryo_cell
	origin_tech = "programming=4;biotech=3;engineering=4;plasmatech=3"
	req_components = list(
							/obj/item/weapon/stock_parts/matter_bin = 1,
							/obj/item/stack/cable_coil = 1,
							/obj/item/weapon/stock_parts/console_screen = 1,
							/obj/item/stack/sheet/glass = 2)

/obj/machinery/atmospherics/components/unary/cryo_cell/on_construction()
	..(dir, dir)

/obj/machinery/atmospherics/components/unary/cryo_cell/RefreshParts()
	var/C
	for(var/obj/item/weapon/stock_parts/matter_bin/M in component_parts)
		C += M.rating

	efficiency = initial(efficiency) * C
	sleep_factor = initial(sleep_factor) * C
	paralyze_factor = initial(paralyze_factor) * C
	heat_capacity = initial(heat_capacity) / C
	conduction_coefficient = initial(conduction_coefficient) * C

/obj/machinery/atmospherics/components/unary/cryo_cell/Destroy()
	qdel(radio)
	radio = null
	if(beaker)
		qdel(beaker)
		beaker = null
	return ..()

/obj/machinery/atmospherics/components/unary/cryo_cell/contents_explosion(severity, target)
	..()
	if(beaker)
		beaker.ex_act(severity, target)

/obj/machinery/atmospherics/components/unary/cryo_cell/handle_atom_del(atom/A)
	..()
	if(A == beaker)
		beaker = null
		updateUsrDialog()

/obj/machinery/atmospherics/components/unary/cryo_cell/on_deconstruction()
	if(beaker)
		beaker.forceMove(loc)
		beaker = null

/obj/machinery/atmospherics/components/unary/cryo_cell/update_icon()
	if(panel_open)
		icon_state = "cell-o"
	else if(state_open)
		icon_state = "cell-open"
	else if(on && is_operational())
		if(occupant)
			icon_state = "cell-occupied"
		else
			icon_state = "cell-on"
	else
		icon_state = "cell-off"

/obj/machinery/atmospherics/components/unary/cryo_cell/process()
	..()

	if(!on)
		return
	if(!is_operational())
		on = FALSE
		update_icon()
		return
	var/datum/gas_mixture/air1 = AIR1
	var/turf/T = get_turf(src)
	if(occupant)
		if(occupant.health >= 100) // Don't bother with fully healed people.
			on = FALSE
			update_icon()
			playsound(T, 'sound/machines/cryo_warning.ogg', volume) // Bug the doctors.
			radio.talk_into(src, "Patient fully restored", radio_channel)
			if(autoeject) // Eject if configured.
				radio.talk_into(src, "Auto ejecting patient now", radio_channel)
				open_machine()
			return
		else if(occupant.stat == DEAD) // We don't bother with dead people.
			return
			if(autoeject) // Eject if configured.
				open_machine()
			return
		if(air1.gases.len)
			if(occupant.bodytemperature < T0C) // Sleepytime. Why? More cryo magic.
				occupant.Sleeping((occupant.bodytemperature / sleep_factor) * 100)
				occupant.Paralyse((occupant.bodytemperature / paralyze_factor) * 100)

			if(beaker)
				if(reagent_transfer == 0) // Magically transfer reagents. Because cryo magic.
					beaker.reagents.trans_to(occupant, 1, 10 * efficiency) // Transfer reagents, multiplied because cryo magic.
					beaker.reagents.reaction(occupant, VAPOR)
					air1.gases["o2"][MOLES] -= 2 / efficiency // Lets use gas for this.
				if(++reagent_transfer >= 10 * efficiency) // Throttle reagent transfer (higher efficiency will transfer the same amount but consume less from the beaker).
					reagent_transfer = 0
	return 1

/obj/machinery/atmospherics/components/unary/cryo_cell/process_atmos()
	..()
	if(!on)
		return
	var/datum/gas_mixture/air1 = AIR1
	if(!NODE1 || !AIR1 || !air1.gases.len || air1.gases["o2"][MOLES] < 5) // Turn off if the machine won't work.
		on = FALSE
		update_icon()
		return
	if(occupant)
		var/cold_protection = 0
		var/mob/living/carbon/human/H = occupant
		if(istype(H))
			cold_protection = H.get_cold_protection(air1.temperature)

		var/temperature_delta = air1.temperature - occupant.bodytemperature // The only semi-realistic thing here: share temperature between the cell and the occupant.
		if(abs(temperature_delta) > 1)
			var/air_heat_capacity = air1.heat_capacity()
			var/heat = ((1 - cold_protection) / 10 + conduction_coefficient) \
						* temperature_delta * \
						(air_heat_capacity * heat_capacity / (air_heat_capacity + heat_capacity))
			air1.temperature = max(air1.temperature - heat / air_heat_capacity, TCMB)
			occupant.bodytemperature = max(occupant.bodytemperature + heat / heat_capacity, TCMB)

		air1.gases["o2"][MOLES] -= 0.5 / efficiency // Magically consume gas? Why not, we run on cryo magic.

/obj/machinery/atmospherics/components/unary/cryo_cell/power_change()
	..()
	update_icon()

/obj/machinery/atmospherics/components/unary/cryo_cell/relaymove(mob/user)
	container_resist(user)

/obj/machinery/atmospherics/components/unary/cryo_cell/open_machine(drop = 0)
	if(!state_open && !panel_open)
		on = FALSE
		..()
	for(var/mob/M in contents) //only drop mobs
		M.forceMove(get_turf(src))
		if(isliving(M))
			var/mob/living/L = M
			L.update_canmove()
	occupant = null

/obj/machinery/atmospherics/components/unary/cryo_cell/close_machine(mob/living/carbon/user)
	if((isnull(user) || istype(user)) && state_open && !panel_open)
		..(user)
		return occupant

/obj/machinery/atmospherics/components/unary/cryo_cell/container_resist(mob/living/user)
	to_chat(user, "<span class='notice'>You struggle inside the cryotube, kicking the release with your foot... (This will take around 30 seconds.)</span>")
	audible_message("<span class='notice'>You hear a thump from [src].</span>")
	if(do_after(user, 300))
		if(occupant == user) // Check they're still here.
			open_machine()

/obj/machinery/atmospherics/components/unary/cryo_cell/examine(mob/user)
	..()
	if(occupant)
		if(on)
			to_chat(user, "Someone's inside [src]!")
		else
			to_chat(user, "You can barely make out a form floating in [src].")
	else
		to_chat(user, "[src] seems empty.")

/obj/machinery/atmospherics/components/unary/cryo_cell/MouseDrop_T(mob/target, mob/user)
	if(user.stat || user.lying || !Adjacent(user) || !user.Adjacent(target) || !iscarbon(target) || !user.IsAdvancedToolUser())
		return
	close_machine(target)

/obj/machinery/atmospherics/components/unary/cryo_cell/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/weapon/reagent_containers/glass))
		. = 1 //no afterattack
		if(beaker)
			to_chat(user, "<span class='warning'>A beaker is already loaded into [src]!</span>")
			return
		if(!user.drop_item())
			return
		beaker = I
		I.loc = src
		user.visible_message("[user] places [I] in [src].", \
							"<span class='notice'>You place [I] in [src].</span>")
		var/reagentlist = pretty_string_from_reagent_list(I.reagents.reagent_list)
		log_game("[key_name(user)] added an [I] to cyro containing [reagentlist]")
		return
	if(!on && !occupant && !state_open)
		if(default_deconstruction_screwdriver(user, "cell-o", "cell-off", I))
			return
		if(exchange_parts(user, I))
			return
	if(default_change_direction_wrench(user, I))
		return
	if(default_pry_open(I))
		return
	if(default_deconstruction_crowbar(I))
		return
	return ..()

/obj/machinery/atmospherics/components/unary/cryo_cell/ui_interact(mob/user, ui_key = "main", datum/tgui/ui = null, force_open = 0, \
																	datum/tgui/master_ui = null, datum/ui_state/state = notcontained_state)
	ui = SStgui.try_update_ui(user, src, ui_key, ui, force_open)
	if(!ui)
		ui = new(user, src, ui_key, "cryo", name, 400, 550, master_ui, state)
		ui.open()

/obj/machinery/atmospherics/components/unary/cryo_cell/ui_data()
	var/list/data = list()
	data["isOperating"] = on
	data["hasOccupant"] = occupant ? 1 : 0
	data["isOpen"] = state_open
	data["autoEject"] = autoeject

	var/list/occupantData = list()
	if(occupant)
		occupantData["name"] = occupant.name
		occupantData["stat"] = occupant.stat
		occupantData["health"] = occupant.health
		occupantData["maxHealth"] = occupant.maxHealth
		occupantData["minHealth"] = HEALTH_THRESHOLD_DEAD
		occupantData["bruteLoss"] = occupant.getBruteLoss()
		occupantData["oxyLoss"] = occupant.getOxyLoss()
		occupantData["toxLoss"] = occupant.getToxLoss()
		occupantData["fireLoss"] = occupant.getFireLoss()
		occupantData["bodyTemperature"] = occupant.bodytemperature
	data["occupant"] = occupantData


	var/datum/gas_mixture/air1 = AIR1
	data["cellTemperature"] = round(air1.temperature)

	data["isBeakerLoaded"] = beaker ? 1 : 0
	var beakerContents = list()
	if(beaker && beaker.reagents && beaker.reagents.reagent_list.len)
		for(var/datum/reagent/R in beaker.reagents.reagent_list)
			beakerContents += list(list("name" = R.name, "volume" = R.volume))
	data["beakerContents"] = beakerContents
	return data

/obj/machinery/atmospherics/components/unary/cryo_cell/ui_act(action, params)
	if(..())
		return
	switch(action)
		if("power")
			if(on)
				on = FALSE
			else if(!state_open)
				on = TRUE
			. = TRUE
		if("door")
			if(state_open)
				close_machine()
			else
				open_machine()
			. = TRUE
		if("autoeject")
			autoeject = !autoeject
			. = TRUE
		if("ejectbeaker")
			if(beaker)
				beaker.forceMove(loc)
				beaker = null
				. = TRUE
	update_icon()

/obj/machinery/atmospherics/components/unary/cryo_cell/update_remote_sight(mob/living/user)
	return //we don't see the pipe network while inside cryo.

/obj/machinery/atmospherics/components/unary/cryo_cell/get_remote_view_fullscreens(mob/user)
	user.overlay_fullscreen("remote_view", /obj/screen/fullscreen/impaired, 1)

/obj/machinery/atmospherics/components/unary/cryo_cell/can_crawl_through()
	return //can't ventcrawl in or out of cryo.

/obj/machinery/atmospherics/components/unary/cryo_cell/can_see_pipes()
	return 0 //you can't see the pipe network when inside a cryo cell.
