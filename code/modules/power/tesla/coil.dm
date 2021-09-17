/obj/machinery/power/tesla_coil
	name = "tesla coil"
	desc = "For the union!"
	icon = 'icons/obj/tesla_engine/tesla_coil.dmi'
	icon_state = "coil0"
	anchored = FALSE
	density = TRUE

	// Executing a traitor caught releasing tesla was never this fun!
	can_buckle = TRUE
	buckle_lying = 0
	buckle_requires_restraints = TRUE

	circuit = /obj/item/circuitboard/machine/tesla_coil

	var/zap_flags = ZAP_MOB_DAMAGE | ZAP_OBJ_DAMAGE
	var/input_power_multiplier = 1
	var/zap_cooldown = 100
	var/last_zap = 0

/obj/machinery/power/tesla_coil/Initialize()
	. = ..()
	wires = new /datum/wires/tesla_coil(src)

/obj/machinery/power/tesla_coil/should_have_node()
	return anchored

/obj/machinery/power/tesla_coil/RefreshParts()
	var/power_multiplier = 0
	zap_cooldown = 100
	for(var/obj/item/stock_parts/capacitor/C in component_parts)
		power_multiplier += C.rating
		zap_cooldown -= (C.rating * 20)
	input_power_multiplier = (0.85 * (power_multiplier / 4)) //Max out at 85% efficency.

/obj/machinery/power/tesla_coil/examine(mob/user)
	. = ..()
	if(in_range(user, src) || isobserver(user))
		. += span_notice("The status display reads: Power generation at <b>[input_power_multiplier*100]%</b>.<br>Shock interval at <b>[zap_cooldown*0.1]</b> seconds.")

/obj/machinery/power/tesla_coil/on_construction()
	if(anchored)
		connect_to_network()

/obj/machinery/power/tesla_coil/default_unfasten_wrench(mob/user, obj/item/I, time = 20)
	. = ..()
	if(. == SUCCESSFUL_UNFASTEN)
		if(panel_open)
			icon_state = "coil_open[anchored]"
		else
			icon_state = "coil[anchored]"
		if(anchored)
			connect_to_network()
		else
			disconnect_from_network()
		update_cable_icons_on_turf(get_turf(src))

/obj/machinery/power/tesla_coil/attackby(obj/item/W, mob/user, params)
	if(default_deconstruction_screwdriver(user, "coil_open[anchored]", "coil[anchored]", W))
		return

	if(default_unfasten_wrench(user, W))
		return

	if(default_deconstruction_crowbar(W))
		return

	if(is_wire_tool(W) && panel_open)
		wires.interact(user)
		return

	return ..()

/obj/machinery/power/tesla_coil/zap_act(power, zap_flags)
	if(anchored && !panel_open)
		//don't lose arc power when it's not connected to anything
		//please place tesla coils all around the station to maximize effectiveness
		obj_flags |= BEING_SHOCKED
		addtimer(CALLBACK(src, .proc/reset_shocked), 1 SECONDS)
		zap_buckle_check(power)
		if(zap_flags & ZAP_GENERATES_POWER) //I don't want no tesla revolver making 8GW you hear
			return power / 2
		var/power_produced = powernet ? power * input_power_multiplier : power
		add_avail(power_produced)
		var/datum/bank_account/D = SSeconomy.get_dep_account(ACCOUNT_ENG)
		if(D)
			D.adjust_money(min(power_produced, 1))
		flick("coilhit", src)
		playsound(src.loc, 'sound/magic/lightningshock.ogg', 100, TRUE, extrarange = 5)
		return power - power_produced //You get back the amount we didn't use
	else
		. = ..()

/obj/machinery/power/tesla_coil/proc/zap()
	if((last_zap + zap_cooldown) > world.time || !powernet)
		return FALSE
	last_zap = world.time
	var/power = (powernet.avail) * 0.2 * input_power_multiplier  //Always always always use more then you output for the love of god
	power = min(surplus(), power) //Take the smaller of the two
	add_load(power)
	playsound(src.loc, 'sound/magic/lightningshock.ogg', 100, TRUE, extrarange = 5)
	tesla_zap(src, 10, power, zap_flags)
	zap_buckle_check(power)

/obj/machinery/power/grounding_rod
	name = "grounding rod"
	desc = "Keeps an area from being fried by Edison's Bane."
	icon = 'icons/obj/tesla_engine/tesla_coil.dmi'
	icon_state = "grounding_rod0"
	anchored = FALSE
	density = TRUE

	can_buckle = TRUE
	buckle_lying = 0
	buckle_requires_restraints = TRUE

/obj/machinery/power/grounding_rod/default_unfasten_wrench(mob/user, obj/item/I, time = 20)
	. = ..()
	if(. == SUCCESSFUL_UNFASTEN)
		if(panel_open)
			icon_state = "grounding_rod_open[anchored]"
		else
			icon_state = "grounding_rod[anchored]"

/obj/machinery/power/grounding_rod/attackby(obj/item/W, mob/user, params)
	if(default_deconstruction_screwdriver(user, "grounding_rod_open[anchored]", "grounding_rod[anchored]", W))
		return

	if(default_unfasten_wrench(user, W))
		return

	if(default_deconstruction_crowbar(W))
		return

	return ..()

/obj/machinery/power/grounding_rod/zap_act(power, zap_flags)
	if(anchored && !panel_open)
		flick("grounding_rodhit", src)
		zap_buckle_check(power)
		return 0
	else
		. = ..()
