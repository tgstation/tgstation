/obj/machinery/modular_shield_generator
	name = "modular shield generator"
	desc = "A forcefield generator, it seems more stationary than its cousins. It can't handle G-force and will require frequent reboots when built on mobile craft."
	icon = 'icons/obj/machines/modular_shield_generator.dmi'
	icon_state = "gen_recovering_closed"
	density = TRUE
	circuit = /obj/item/circuitboard/machine/modular_shield_generator
	processing_flags = START_PROCESSING_ON_INIT

	///Doesn't actually control it, just tells us if its running or not, you can control by calling procs activate_shields and deactivate_shields
	var/active = FALSE

	///If the generator is currently spawning the forcefield in
	var/initiating = FALSE

	///Determines if we can turn it on or not, no longer recovering when back to max strength
	var/recovering = TRUE

	///Determines max health of the shield
	var/max_strength = 40

	///Current health of shield
	var/stored_strength = 0 //starts at 0 to prevent rebuild abuse

	///Shield Regeneration when at 100% efficiency
	var/max_regeneration = 3

	///The regeneration that the shield can support
	var/current_regeneration

	///Determines the max radius the shield can support
	var/max_radius = 3

	///Current radius the shield is set to, minimum 3
	var/radius = 3

	///Determines if we only generate a shield on space turfs or not
	var/exterior_only = FALSE

	///The lazy list of shields that are ours
	var/list/deployed_shields

	///The lazy list of turfs that are within the shield
	var/list/inside_shield

	///The lazy list of machines that are connected to and boosting us
	var/list/obj/machinery/modular_shield/module/connected_modules

	///Regeneration gained from machines connected to us
	var/regen_boost = 0

	///Max Radius gained from machines connected to us
	var/radius_boost = 0

	///Max Strength gained from machines connected to us
	var/max_strength_boost = 0

	///Regeneration gained from our own parts
	var/innate_regen = 3

	///Max radius gained from our own parts
	var/innate_radius = 3

	///Max strength gained from our own parts
	var/innate_strength = 40

	///This is the lazy list of perimeter turfs that we grab when making large shields of 10 or more radius
	var/list/list_of_turfs

	///This decides if we get nerfed by projecting on internal turfs with floors and stuff
	var/internal_penalty = TRUE

	///What machine we are for the purpose of updating icon state
	var/icon_type = "gen"

	///The name modular shield console tgui's see us as
	var/display_name = "Shield Generator"

/obj/machinery/modular_shield_generator/power_change()
	. = ..()
	if(!(machine_stat & NOPOWER))
		begin_processing()
		return

	deactivate_shields()
	end_processing()

/obj/machinery/modular_shield_generator/RefreshParts()
	. = ..()

	innate_regen = initial(innate_regen)
	innate_radius = initial(innate_radius)
	innate_strength = initial(innate_strength)

	for(var/datum/stock_part/capacitor/new_capacitor in component_parts)
		innate_strength += new_capacitor.tier * 20

	for(var/datum/stock_part/servo/new_servo in component_parts)
		innate_regen += new_servo.tier * 2

	for(var/datum/stock_part/micro_laser/new_laser in component_parts)
		innate_radius += new_laser.tier * 0.25

	calculate_regeneration()
	calculate_max_strength()
	calculate_radius()

/obj/machinery/modular_shield_generator/Initialize(mapload)
	. = ..()
	set_wires(new /datum/wires/modular_shield_generator(src))
	if(mapload && active && anchored)
		activate_shields()

/datum/wires/modular_shield_generator
	proper_name = "Modular shield generator"
	randomize = FALSE
	holder_type = /obj/machinery/modular_shield_generator

/datum/wires/modular_shield_generator/New(atom/holder)
	wires = list(WIRE_HACK)
	return ..()

/datum/wires/modular_shield_generator/on_pulse(wire)

	var/obj/machinery/modular_shield_generator/shield_gen = holder
	switch(wire)
		if(WIRE_HACK)
			shield_gen.toggle_shields()

	return ..()

///qdels the forcefield and calls calculate regen to update the regen value accordingly
/obj/machinery/modular_shield_generator/proc/deactivate_shields()
	active = FALSE
	QDEL_LIST(deployed_shields)
	deployed_shields = null
	LAZYNULL(list_of_turfs)
	LAZYNULL(inside_shield)
	calculate_regeneration()

/obj/machinery/modular_shield_generator/screwdriver_act(mob/living/user, obj/item/tool)
	. = ..()

	if(default_deconstruction_screwdriver(user,"[icon_type]_[!(machine_stat & NOPOWER) ? "[recovering ? "recovering_" : "ready_"]" : "no_power_"]open",
		"[icon_type]_[!(machine_stat & NOPOWER) ? "[recovering ? "recovering_" : "ready_"]" : "no_power_"]closed",  tool))
		return TRUE

/obj/machinery/modular_shield_generator/crowbar_act(mob/living/user, obj/item/tool)
	. = ..()

	if(default_deconstruction_crowbar(tool))
		return TRUE

/obj/machinery/modular_shield_generator/attackby(obj/item/W, mob/user, list/modifiers)

	if(is_wire_tool(W) && panel_open)
		wires.interact(user)
		return TRUE

	return ..()

/obj/machinery/modular_shield_generator/multitool_act(mob/living/user, obj/item/multitool/multi)
	multi.set_buffer(src)
	balloon_alert(user, "saved to buffer")
	return ITEM_INTERACT_SUCCESS

///toggles the forcefield on and off
/obj/machinery/modular_shield_generator/proc/toggle_shields()
	if(initiating)
		return
	if(active)
		deactivate_shields()
		return
	if (recovering)
		return
	activate_shields()

/obj/machinery/modular_shield_generator/onShuttleMove(turf/newT, turf/oldT, list/movement_force, move_dir, obj/docking_port/stationary/old_dock, obj/docking_port/mobile/moving_dock)
	. = ..()
	if(active)
		deactivate_shields()

///generates the forcefield based on the given radius and calls calculate_regen to update the regen value accordingly
/obj/machinery/modular_shield_generator/proc/activate_shields()
	if(active || (machine_stat & NOPOWER))//bug or did admin call proc on already active shield gen?
		return
	if(radius < 0)//what the fuck are admins doing
		radius = initial(radius)
	active = TRUE
	initiating = TRUE
	var/color_shield = cached_color_filter || color
	if(radius >= 10) //the shield is large so we are going to use the midpoint formula and clamp it to the lowest full number in order to save processing power
		LAZYADD(inside_shield, circle_range_turfs(src, radius - 1))//in the future we might want to apply an effect to turfs inside the shield
		LAZYADD(list_of_turfs, get_perimeter(src, radius))

		if(exterior_only)
			for(var/turf/open/target_tile in list_of_turfs)
				if(isfloorturf(target_tile))
					continue
				if(locate(/obj/structure/emergency_shield/modular) in target_tile)
					continue
				var/obj/structure/emergency_shield/modular/deploying_shield = new(target_tile, src)
				LAZYADD(deployed_shields, deploying_shield)
				if(color_shield)
					deploying_shield.add_atom_colour(color_shield, FIXED_COLOUR_PRIORITY)
			addtimer(CALLBACK(src, PROC_REF(finish_field)), 2 SECONDS)
			calculate_regeneration()
			return

		for(var/turf/open/target_tile in list_of_turfs)
			if(locate(/obj/structure/emergency_shield/modular) in target_tile)
				continue
			var/obj/structure/emergency_shield/modular/deploying_shield = new(target_tile, src)
			LAZYADD(deployed_shields, deploying_shield)
			if(color_shield)
				deploying_shield.add_atom_colour(color_shield, FIXED_COLOUR_PRIORITY)

		addtimer(CALLBACK(src, PROC_REF(finish_field)), 2 SECONDS)
		calculate_regeneration()
		return

	//this code only runs on radius less than 10 and gives us a more accurate circle that is more compatible with decimal values
	LAZYADD(inside_shield, circle_range_turfs(src, radius - 1))//in the future we might want to apply an effect to the turfs inside the shield
	if(exterior_only)
		for(var/turf/open/target_tile in circle_range_turfs(src, radius))
			if(isfloorturf(target_tile))
				continue
			if(target_tile in inside_shield)
				continue
			if(locate(/obj/structure/emergency_shield/modular) in target_tile)
				continue
			var/obj/structure/emergency_shield/modular/deploying_shield = new(target_tile, src)
			LAZYADD(deployed_shields, deploying_shield)
			if(color_shield)
				deploying_shield.add_atom_colour(color_shield, FIXED_COLOUR_PRIORITY)

		addtimer(CALLBACK(src, PROC_REF(finish_field)), 2 SECONDS)
		calculate_regeneration()
		return

	for(var/turf/open/target_tile in circle_range_turfs(src, radius))
		if(target_tile in inside_shield)
			continue
		if(locate(/obj/structure/emergency_shield/modular) in target_tile)
			continue
		var/obj/structure/emergency_shield/modular/deploying_shield = new(target_tile, src)
		LAZYADD(deployed_shields, deploying_shield)
		if(color_shield)
			deploying_shield.add_atom_colour(color_shield, FIXED_COLOUR_PRIORITY)

	addtimer(CALLBACK(src, PROC_REF(finish_field)), 2 SECONDS)
	calculate_regeneration()

///After giving people a grace period to react to we up the alpha value and make the forcefield dense
/obj/machinery/modular_shield_generator/proc/finish_field()

	for(var/obj/structure/emergency_shield/modular/current_shield in deployed_shields)
		current_shield.set_density(TRUE)
		current_shield.alpha = 255
	initiating = FALSE

/obj/machinery/modular_shield_generator/Destroy()
	QDEL_LIST(deployed_shields)
	for(var/obj/machinery/modular_shield/module/disconnecting in connected_modules)
		disconnecting.shield_generator = null
		disconnecting.update_icon_state()
	return ..()

/obj/machinery/modular_shield_generator/update_icon_state()

	icon_state = ("[icon_type]_[!(machine_stat & NOPOWER) ? "[recovering ? "recovering_" : "ready_"]" : "no_power_"][(panel_open)?"open" : "closed"]")
	return ..()

//ui stuff
/obj/machinery/modular_shield_generator/ui_interact(mob/user, datum/tgui/ui)
	. = ..()
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "ModularShieldGen")
		ui.open()

/obj/machinery/modular_shield_generator/ui_data(mob/user)

	var/list/data = list()
	data["max_radius"] = max_radius
	data["current_radius"] = radius
	data["max_strength"] = max_strength
	data["max_regeneration"] = max_regeneration
	data["current_regeneration"] = current_regeneration
	data["current_strength"] = stored_strength
	data["active"] = active
	data["recovering"] = recovering
	data["exterior_only"] = exterior_only
	data["initiating_field"] = initiating
	return data

/obj/machinery/modular_shield_generator/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if(.)
		return
	switch(action)
		if ("set_radius")
			if (active)
				return
			var/change_radius = clamp(text2num(params["new_radius"]), 1, max_radius)
			if(change_radius >= 10)
				radius = round(change_radius)//if its over 10 we don't allow decimals
				return
			radius = change_radius

		if ("toggle_shields")
			toggle_shields()

		if ("toggle_exterior")
			exterior_only = !exterior_only
			calculate_radius()

///calculations for the stats supplied by the network of machines that boost us
/obj/machinery/modular_shield_generator/proc/calculate_boost()

	regen_boost = initial(regen_boost)
	for (var/obj/machinery/modular_shield/module/charger/new_charger in connected_modules)
		regen_boost += new_charger.charge_boost

	calculate_regeneration()

	max_strength_boost = initial(max_strength_boost)
	for (var/obj/machinery/modular_shield/module/well/new_well in connected_modules)
		max_strength_boost += new_well.strength_boost

	calculate_max_strength()

	radius_boost = initial(radius_boost)
	for (var/obj/machinery/modular_shield/module/relay/new_relay in connected_modules)
		radius_boost += new_relay.range_boost

	calculate_radius()

///Calculates the max radius the shield generator can support, modifiers go here
/obj/machinery/modular_shield_generator/proc/calculate_radius()

	max_radius = innate_radius + radius_boost
	if(!exterior_only && internal_penalty)
		max_radius = max(3,max_radius * 0.5)

	if(radius > max_radius)//the generator can no longer function at this capacity
		deactivate_shields()
		radius = round(max_radius, 1)
		return
	calculate_regeneration()

///Calculates the max strength or health of the forcefield, modifiers go here
/obj/machinery/modular_shield_generator/proc/calculate_max_strength()

	max_strength = innate_strength + max_strength_boost
	begin_processing()

///Calculates the regeneration based on the status of the generator and boosts from network, modifiers go here
/obj/machinery/modular_shield_generator/proc/calculate_regeneration()

	max_regeneration = innate_regen + regen_boost

	if(!active)
		if(recovering)
			current_regeneration = max_regeneration * 0.25
			return
		current_regeneration = max_regeneration
		return

	//we lose more than half the regeneration rate when generating a shield that is near the max
	//radius that we can handle but if we generate a shield with a very small fraction
	//of the max radius we can support we get a very small bonus multiplier
	current_regeneration = (max_regeneration / (0.5 + (radius * 2)/max_radius))

	if(!exterior_only && internal_penalty)
		current_regeneration *= 0.5

///Reduces the strength of the shield based on the given integer
/obj/machinery/modular_shield_generator/proc/shield_drain(damage_amount)
	stored_strength -= damage_amount
	begin_processing()
	if (stored_strength < 5)
		recovering = TRUE
		deactivate_shields()
		stored_strength = 0
		update_icon_state()

/obj/machinery/modular_shield_generator/process(seconds_per_tick)
	stored_strength = min((stored_strength + (current_regeneration * seconds_per_tick)),max_strength)
	if(stored_strength == max_strength)
		if (recovering)
			recovering = FALSE
			calculate_regeneration()
			update_icon_state()
		end_processing() //we don't care about continuing to update the alpha, we want to show history of damage to show its unstable
	if (active)
		var/random_num = rand(1,deployed_shields.len)
		var/obj/structure/emergency_shield/modular/random_shield = deployed_shields[random_num]
		random_shield.alpha = max(255 * (stored_strength/max_strength), 40)

/obj/machinery/modular_shield_generator/gate
	name = "modular shield gate"
	desc = "A forcefield generator that can deploy a flat wall, it seems more stationary than its cousins. It can't handle G-force and will require frequent reboots when built on mobile craft."
	icon = 'icons/obj/machines/modular_shield_generator.dmi'
	icon_state = "gate_recovering_closed"
	density = FALSE
	circuit = /obj/item/circuitboard/machine/modular_shield_generator/gate
	internal_penalty = FALSE
	layer = GIB_LAYER
	icon_type = "gate"
	display_name = "Shield Gate"

/obj/machinery/modular_shield_generator/gate/ui_interact(mob/user, datum/tgui/ui)
	return

/obj/machinery/modular_shield_generator/gate/wrench_act(mob/living/user, obj/item/tool)
	. = ..()

	if(!default_change_direction_wrench(user, tool))
		return FALSE
	return TRUE

///we shield a tile and step forward until we either run out of max radius or hit a closed turf, every turf we shield is a penalty towards regen
/obj/machinery/modular_shield_generator/gate/activate_shields()
	if(active || (machine_stat & NOPOWER))//bug or did admin call proc on already active shield gen?
		return
	if(max_radius < 0)//what the fuck are admins doing
		calculate_radius()
	active = TRUE
	initiating = TRUE
	var/color_shield = cached_color_filter || color
	var/turf/target_tile = src.loc
	radius = 0
	for(var/i in 1 to round(max_radius, 1))
		if((!isopenturf(target_tile)) || (locate(/obj/structure/emergency_shield/modular) in target_tile))
			addtimer(CALLBACK(src, PROC_REF(finish_field)), 2 SECONDS)
			calculate_regeneration()
			if(radius == 0)//we couldnt even generate a single tile somehow
				deactivate_shields()
			return
		var/obj/structure/emergency_shield/modular/deploying_shield = new(target_tile, src)
		LAZYADD(deployed_shields, deploying_shield)
		if(color_shield)
			deploying_shield.add_atom_colour(color_shield, FIXED_COLOUR_PRIORITY)
		radius += 1
		target_tile = get_step(target_tile,dir)
	addtimer(CALLBACK(src, PROC_REF(finish_field)), 2 SECONDS)
	calculate_regeneration()

//if we are active we most definitely have something protecting us
/obj/machinery/modular_shield_generator/gate/take_damage()
	if(active)
		return
	. = ..()

//Start of other machines
///The general code used for machines that want to connect to the network
/obj/machinery/modular_shield/module
	name = "modular shield debugger" //Filler name and sprite for testing
	desc = "This is filler for testing you shouldn't see this."
	icon = 'icons/obj/machines/mech_bay.dmi'
	icon_state = "recharge_port"
	density = TRUE

	///This var is what determines if boosters, such as charger or well, can connect to this module
	var/allow_boosters = TRUE

	///This var is what determines if we are a booster or a logistic module
	var/is_booster = FALSE

	///The shield generator we are connected to if we find one or a node provides us one
	var/obj/machinery/modular_shield_generator/shield_generator

	///The node we are connected to if we find one
	var/obj/machinery/modular_shield/module/node/connected_node

	///This is the turf that we are facing and able to search for connections through
	var/turf/connected_turf

/obj/machinery/modular_shield/module/Initialize(mapload)
	. = ..()

	connected_turf = get_step(src, dir)
	try_connect()

/obj/machinery/modular_shield/module/Destroy()

	if(shield_generator)
		LAZYREMOVE(shield_generator.connected_modules, (src))
		shield_generator.calculate_boost()
	if(connected_node)
		LAZYREMOVE(connected_node.connected_through_us, (src))
		connected_node.update_icon_state()
	return ..()

/obj/machinery/modular_shield/module/examine(mob/user)
	. = ..()

	if(isnull(shield_generator) && isnull(connected_node))
		. += "It can be loosened and rotated with a screwdriver and wrench. It can be connected to a node or generator with a multitool."
		return
	. += "It can be loosed and rotated with a screwdriver and wrench, rotating it will sever its connection."

/obj/machinery/modular_shield/module/screwdriver_act(mob/living/user, obj/item/tool)
	. = ..()

	panel_open = !(panel_open)
	tool.play_tool_sound(src, 50)
	update_icon_state()
	if(panel_open)
		balloon_alert(user, "hatch opened")
		return TRUE
	balloon_alert(user, "hatch closed")
	return TRUE

/obj/machinery/modular_shield/module/multitool_act(mob/living/user, obj/item/tool)
	. = ..()

	//rather than automatically checking for connections its probably alot less
	//expensive to just make the players manually multi tool sync each part
	try_connect(user)
	return TRUE

/obj/machinery/modular_shield/module/wrench_act(mob/living/user, obj/item/tool)
	. = ..()

	if(!default_change_direction_wrench(user, tool))
		return FALSE

	if(shield_generator)
		LAZYREMOVE(shield_generator.connected_modules, (src))
		shield_generator.calculate_boost()
		shield_generator = null
		update_icon_state()

	if(connected_node)
		LAZYREMOVE(connected_node.connected_through_us, (src))
		connected_node.update_icon_state()
		connected_node = null

	connected_turf = get_step(src, dir)
	try_connect()
	return TRUE

/obj/machinery/modular_shield/module/crowbar_act(mob/living/user, obj/item/tool)
	. = ..()

	if(default_deconstruction_crowbar(tool))
		return TRUE

/obj/machinery/modular_shield/module/setDir(new_dir)
	. = ..()
	connected_turf = get_step(src, dir)

///checks for a valid machine in front of us and connects to it
/obj/machinery/modular_shield/module/proc/try_connect(user)

	if(shield_generator || connected_node)
		balloon_alert(user, "already connected to something!")
		update_icon_state()
		return

	shield_generator = (locate(/obj/machinery/modular_shield_generator) in connected_turf)

	if(shield_generator)

		LAZYOR(shield_generator.connected_modules, (src))
		balloon_alert(user, "connected to generator")
		update_icon_state()
		shield_generator.calculate_boost()
		return

	connected_node = (locate(/obj/machinery/modular_shield/module/node) in connected_turf)

	if(connected_node)

		//checks if the node allows boosters and if we are a booster
		if(!connected_node.allow_boosters && is_booster)
			connected_node = null
			update_icon_state()
			balloon_alert(user, "cant connect")
			return

		LAZYOR(connected_node.connected_through_us, (src))
		connected_node.update_icon_state()
		shield_generator = connected_node.shield_generator
		if(shield_generator)
			LAZYOR(shield_generator.connected_modules, (src))
			balloon_alert(user, "connected to generator")
			update_icon_state()
			shield_generator.calculate_boost()
			return
		update_icon_state()
		balloon_alert(user, "connected to node")
		return
	update_icon_state()
	balloon_alert(user, "no connection!")

/obj/machinery/modular_shield/module/node
	name = "modular shield node"
	desc = "A waist high mess of humming pipes and wires that extend the modular shield network."
	icon = 'icons/obj/machines/modular_shield_generator.dmi'
	icon_state = "node_off_closed"
	active_power_usage = BASE_MACHINE_ACTIVE_CONSUMPTION * 0.5
	circuit = /obj/item/circuitboard/machine/modular_shield_node
	///The lazy list of machines that are connected to us and want connection to a generator
	var/list/connected_through_us

/obj/machinery/modular_shield/module/node/update_icon_state()
	. = ..()
	if(isnull(shield_generator) || (machine_stat & NOPOWER))
		icon_state = "node_off_[panel_open ? "open" : "closed"]"
		return
	icon_state = "node_on_[panel_open ? "open" : "closed"]"

/obj/machinery/modular_shield/module/node/wrench_act(mob/living/user, obj/item/tool)

	if(!default_change_direction_wrench(user, tool))
		return FALSE

	disconnect_connected_through_us()

	if(shield_generator)
		LAZYREMOVE(shield_generator.connected_modules, (src))
		shield_generator.calculate_boost()
		shield_generator = null
		update_icon_state()

	if(connected_node)
		LAZYREMOVE(connected_node.connected_through_us, (src))
		connected_node.update_icon_state()
		connected_node = null

	connected_turf = get_step(src, dir)
	try_connect()
	return TRUE

//after trying to connect to a machine infront of us, we will try to link anything connected to us to a generator
/obj/machinery/modular_shield/module/node/try_connect(user)
	. = ..()

	if(isnull(shield_generator))
		return
	connect_connected_through_us()
	shield_generator.calculate_boost()

/obj/machinery/modular_shield/module/node/Destroy()
	. = ..()

	disconnect_connected_through_us()
	for(var/obj/machinery/modular_shield/module/connected in connected_through_us)
		connected.connected_node = null
	if(shield_generator)
		shield_generator.calculate_boost()

///If we are connected to a shield generator this proc will connect anything connected to us to that generator
/obj/machinery/modular_shield/module/node/proc/connect_connected_through_us()

	if(shield_generator)
		for(var/obj/machinery/modular_shield/module/connected in connected_through_us)
			LAZYOR(shield_generator.connected_modules, connected)
			connected.shield_generator = shield_generator
			if(istype(connected, /obj/machinery/modular_shield/module/node))
				var/obj/machinery/modular_shield/module/node/connected_node = connected
				connected_node.connect_connected_through_us()
			connected.update_icon_state()


///This proc disconnects modules connected through us from the shield generator in the event that we lose connection
/obj/machinery/modular_shield/module/node/proc/disconnect_connected_through_us()

	for(var/obj/machinery/modular_shield/module/connected in connected_through_us)
		LAZYREMOVE(shield_generator.connected_modules, connected)
		if(istype(connected, /obj/machinery/modular_shield/module/node))
			var/obj/machinery/modular_shield/module/node/connected_node = connected
			connected_node.disconnect_connected_through_us()
		connected.shield_generator = null
		connected.update_icon_state()

/obj/machinery/modular_shield/module/node/cable
	name = "modular shield cable"
	desc = "An ankle high mess of cables packed as low as possible at the cost of lacking connection components necessary for anything other than nodes and the generator itself."
	icon = 'icons/obj/machines/modular_shield_generator.dmi'
	icon_state = "cable_node_closed_r_b_l"
	active_power_usage = BASE_MACHINE_ACTIVE_CONSUMPTION * 0.1
	circuit = /obj/item/circuitboard/machine/modular_shield_cable
	density = FALSE
	allow_boosters = FALSE

/obj/machinery/modular_shield/module/node/cable/update_icon_state()
	. = ..()
	var/turf/right_turf = get_step(src, turn(dir, 270))
	var/obj/machinery/modular_shield/module/node/connected_right = (locate(/obj/machinery/modular_shield/module/node) in right_turf)
	if(!(connected_right in connected_through_us))
		connected_right = null
	var/turf/back_turf = get_step(src, turn(dir, 180))
	var/obj/machinery/modular_shield/module/node/connected_back = (locate(/obj/machinery/modular_shield/module/node) in back_turf)
	if(!(connected_back in connected_through_us))
		connected_back = null
	var/turf/left_turf = get_step(src, turn(dir, 90))
	var/obj/machinery/modular_shield/module/node/connected_left = (locate(/obj/machinery/modular_shield/module/node) in left_turf)
	if(!(connected_left in connected_through_us))
		connected_left = null
	icon_state = "cable_node_[panel_open ? "open" : "closed"]_[connected_right ? "r" : "nr"]_[connected_back ? "b" : "nb"]_[connected_left ? "l" : "nl"]"

/obj/machinery/modular_shield/module/charger
	name = "modular shield charger"
	desc = "A machine that somehow fabricates hardlight using electrons."
	icon = 'icons/obj/machines/modular_shield_generator.dmi'
	icon_state = "charger_off_closed"
	is_booster = TRUE

	circuit = /obj/item/circuitboard/machine/modular_shield_charger

	///Amount of regeneration this machine grants the connected generator
	var/charge_boost = 0

/obj/machinery/modular_shield/module/charger/update_icon_state()
	. = ..()
	if(isnull(shield_generator) || (machine_stat & NOPOWER))
		icon_state = "charger_off_[panel_open ? "open" : "closed"]"
		return
	icon_state = "charger_on_[panel_open ? "open" : "closed"]"

/obj/machinery/modular_shield/module/charger/RefreshParts()
	. = ..()
	charge_boost = initial(charge_boost)
	for(var/datum/stock_part/servo/new_servo in component_parts)
		charge_boost += new_servo.tier * 2

	if(shield_generator)
		shield_generator.calculate_boost()

/obj/machinery/modular_shield/module/relay
	name = "modular shield relay"
	desc = "It helps the shield generator project farther out."
	icon = 'icons/obj/machines/modular_shield_generator.dmi'
	icon_state = "relay_off_closed"
	is_booster = TRUE

	circuit = /obj/item/circuitboard/machine/modular_shield_relay

	///Amount of max range this machine grants the connected generator
	var/range_boost = 0

/obj/machinery/modular_shield/module/relay/update_icon_state()
	. = ..()
	if(isnull(shield_generator) || (machine_stat & NOPOWER))
		icon_state = "relay_off_[panel_open ? "open" : "closed"]"
		return
	icon_state = "relay_on_[panel_open ? "open" : "closed"]"

/obj/machinery/modular_shield/module/relay/RefreshParts()
	. = ..()
	range_boost = initial(range_boost)
	for(var/datum/stock_part/micro_laser/new_laser in component_parts)
		range_boost += new_laser.tier * 0.25

	if(shield_generator)
		shield_generator.calculate_boost()

/obj/machinery/modular_shield/module/well
	name = "modular shield well"
	desc = "A device used to hold more hardlight for the modular shield generator."
	icon = 'icons/obj/machines/modular_shield_generator.dmi'
	icon_state = "well_off_closed"
	is_booster = TRUE

	circuit = /obj/item/circuitboard/machine/modular_shield_well

	///Amount of max strength this machine grants the connected generator
	var/strength_boost = 0

/obj/machinery/modular_shield/module/well/RefreshParts()
	. = ..()
	strength_boost = initial(strength_boost)
	for(var/datum/stock_part/capacitor/new_capacitor in component_parts)
		strength_boost += new_capacitor.tier * 20

	if(shield_generator)
		shield_generator.calculate_boost()

/obj/machinery/modular_shield/module/well/update_icon_state()
	. = ..()
	if(isnull(shield_generator) || (machine_stat & NOPOWER))
		icon_state = "well_off_[panel_open ? "open" : "closed"]"
		return
	icon_state = "well_on_[panel_open ? "open" : "closed"]"

//The shield itself
/obj/structure/emergency_shield/modular
	name = "modular energy shield"
	desc = "An energy shield with varying configurations."
	color = "#00ffff"
	density = FALSE
	alpha = 100
	flags_1 = PREVENT_CLICK_UNDER_1
	explosion_block = 2
	resistance_flags = INDESTRUCTIBLE //the shield itself is indestructible or at least should be
	no_damage_feedback = "weakening the generator sustaining it"
	can_atmos_pass = ATMOS_PASS_NO

	///The shield generator sustaining us
	var/obj/machinery/modular_shield_generator/shield_generator


/obj/structure/emergency_shield/modular/Initialize(mapload, connected_to_generator)
	AddElement(/datum/element/blocks_explosives)
	. = ..()
	if(!connected_to_generator)
		return INITIALIZE_HINT_QDEL
	shield_generator = connected_to_generator
	AddElement(/datum/element/atmos_sensitive, mapload)

/obj/structure/emergency_shield/modular/should_atmos_process(datum/gas_mixture/air, exposed_temperature)
	return exposed_temperature > (T0C + 200)

//Damage from atmos
/obj/structure/emergency_shield/modular/atmos_expose(datum/gas_mixture/air, exposed_temperature)
	if(isnull(shield_generator))
		qdel(src)
		return

	shield_generator.shield_drain(round(air.return_volume() / 400))//400 integer determines how much damage the shield takes from hot atmos (higher value = less damage)


//Damage from direct attacks
/obj/structure/emergency_shield/modular/take_damage(damage_amount, damage_type = BRUTE, damage_flag = 0, sound_effect = 1, attack_dir)
	. = ..()
	if(damage_type == BRUTE || damage_type == BURN)
		if(isnull(shield_generator))
			qdel(src)
			return

		shield_generator.shield_drain(damage_amount)//can add or subtract a flat value to buff or nerf crowd damage

//Damage from emp
/obj/structure/emergency_shield/modular/emp_act(severity)
	. = ..()
	if(isnull(shield_generator))
		qdel(src)
		return

	shield_generator.shield_drain(15 / severity) //Light is 2 heavy is 1, note emp is usually a large aoe, tweak the number if not enough damage

//Damage from explosions, remember we dont use armor
/obj/structure/emergency_shield/modular/ex_act(severity)
	if(isnull(shield_generator))
		qdel(src)
		return

	switch(severity)

		if(EXPLODE_LIGHT)
			shield_generator.shield_drain(20)
			return

		if(EXPLODE_HEAVY)
			shield_generator.shield_drain(50)
			return

		if(EXPLODE_DEVASTATE)
			shield_generator.shield_drain(100)

/obj/structure/emergency_shield/modular/hulk_damage()
	if(isnull(shield_generator))
		qdel(src)
		return 0
	shield_generator.shield_drain(30 + shield_generator.current_regeneration)//shield will eventually go down no matter the regen, flat number is how fast the hulk eats at reserves
	return 0
