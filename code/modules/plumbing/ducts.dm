/*
Make adjacency one proc and check conditions in one spot
Sort out active, anchor and possible layers



*/

/obj/machinery/duct
	name = "fluid duct"
	icon = 'icons/obj/fluid_ducts.dmi'
	icon_state = "nduct_n_s"

	var/connects = NORTH | SOUTH
	var/datum/ductnet/duct
	var/capacity = 10

	var/active = TRUE

/obj/machinery/duct/east_west
	icon_state = "nduct_e_w"
	connects = EAST | WEST

/obj/machinery/duct/north_east
	icon_state = "nduct_n_e"
	connects = NORTH | EAST

/obj/machinery/duct/north_west
	icon_state = "nduct_n_w"
	connects = NORTH | WEST

/obj/machinery/duct/south_east
	icon_state = "nduct_s_e"
	connects = SOUTH | EAST

/obj/machinery/duct/south_west
	icon_state = "nduct_s_w"
	connects = SOUTH | WEST

/obj/machinery/duct/north_east
	icon_state = "nduct_n_e"
	connects = NORTH | EAST

/obj/machinery/duct/north_east_west
	icon_state = "nduct_n_e_w"
	connects = NORTH | EAST | WEST

/obj/machinery/duct/north_south_west
	icon_state = "nduct_n_s_w"
	connects = NORTH | SOUTH | WEST

/obj/machinery/duct/south_east_west
	icon_state = "nduct_s_e_w"
	connects = SOUTH | EAST | WEST

/obj/machinery/duct/north_south_east
	icon_state = "nduct_n_s_e"
	connects = NORTH | SOUTH | EAST

/obj/machinery/duct/north_south_east_west
	icon_state = "nduct_n_s_e_w"
	connects = NORTH | SOUTH | EAST | WEST



/obj/machinery/duct/Initialize(mapload, no_anchor, spin)
	. = ..()
	start with updating dirs and shit
	if(no_anchor)
		active = FALSE
		anchor = FALSE
	else if(!can_anchor())
		CRASH("Overlapping ducts detected")
		qdel(src)
	if(active)
		attempt_connect()

/obj/machinery/duct/proc/attempt_connect()
	for(var/D in GLOB.cardinals)
		if(D & connects)
			for(var/A in get_step(src, D))
				connect_network(A, D)

/obj/machinery/duct/proc/connect_network(atom/A, direction)
	var/opposite_dir = angle2dir(dir2angle(direction) + 180)
	if(istype(A, /obj/machinery/duct))
		var/obj/machinery/duct/D = A
		if(!D.active || ((duct == D.duct) && duct)) //check if we're not just comparing two null values
			return
		if(opposite_dir & D.connects)
			if(D.duct)
				if(duct)
					duct.assimilate(D.duct)
				else
					D.duct.add_duct(src)
			else
				if(duct)
					duct.add_duct(D)
				else
					create_duct()
					duct.add_duct(D)

	var/datum/component/plumbing/P = A.GetComponent(/datum/component/plumbing)
	if(!P)
		return
	var/comp_directions = P.supply_connects + P.demand_connects //they should never, ever have supply and demand connects overlap or catastrophic failure
	if(opposite_dir & comp_directions)
		if(duct)
			duct.add_plumber(P, opposite_dir)
		else
			create_duct()
			duct.add_plumber(P, opposite_dir)

/obj/machinery/duct/proc/disconnect_duct()
	active = FALSE
	duct.destroy_network()
	for(var/A in get_adjacent_ducts())
		var/obj/machinery/duct/D = A
		D.attempt_connect()

/obj/machinery/duct/proc/create_duct()
	duct = new()
	duct.add_duct(src)

/obj/machinery/duct/proc/get_adjacent_ducts()
	var/list/adjacents = list()
	for(var/A in GLOB.cardinals)
		if(A & connects)
			for(var/obj/machinery/duct/D in get_step(src, A))
				if((angle2dir(dir2angle(A) + 180) & D.connects) && D.active)
					adjacents += D
	return adjacents

/obj/machinery/duct/wrench_act(mob/living/user, obj/item/wrench/W)
	add_fingerprint(user)
	W.play_tool_sound(src)
	if(anchored)
		anchored = FALSE
		active = FALSE
		user.visible_message( \
		"[user] unfastens \the [src].", \
		"<span class='notice'>You unfasten \the [src].</span>", \
		"<span class='italics'>You hear ratcheting.</span>")
	else if(can_anchor())
		anchored = TRUE
		active = TRUE
		user.visible_message( \
		"[user] fastens \the [src].", \
		"<span class='notice'>You fasten \the [src].</span>", \
		"<span class='italics'>You hear ratcheting.</span>")

/obj/machinery/duct/proc/can_anchor(turf/T)
	if(!T)
		T = get_turf(src)
	for(var/obj/machinery/duct/D in T)
		if(!anchored)
			continue
		for(var/A in GLOB.cardinals)
			if(A & connects && A & D.connects)
				return FALSE
	return TRUE






/datum/component/plumbing
	var/list/datum/ductnet/ducts = list() //Index with "1" = /datum/ductnet/theductpointingnorth etc. "1" being the num2text from NORTH define
	var/datum/reagents/reagents

	var/supply_connects //directions in wich we act as a supplier
	var/demand_connects //direction in wich we act as a demander

/datum/component/plumbing/Initialize()
	if(parent && !ismovableatom(parent))
		return COMPONENT_INCOMPATIBLE
	var/atom/movable/AM = parent
	if(!AM.reagents)
		return COMPONENT_INCOMPATIBLE
	reagents = AM.reagents

	if(demand_connects)
		START_PROCESSING(SSfluids, src)


/datum/component/plumbing/process()
	if(!demand_connects || !reagents)
		STOP_PROCESSING(SSfluids, src)
		return
	if(reagents.total_volume < reagents.maximum_volume)
		for(var/D in GLOB.cardinals)
			if(D & demand_connects)
				send_request(D)

/datum/component/plumbing/proc/can_add(datum/ductnet/D, dir)
	if(!dir || !D)
		return FALSE
	if(num2text(dir) in ducts)
		return FALSE

	//TODO: check AGAIN if the ducts are aligned

	return TRUE

/datum/component/plumbing/proc/send_request(dir) //this should usually be overwritten when dealing with custom pipes
	process_request(amount = 10, reagent = null, dir = dir)

/datum/component/plumbing/proc/process_request(amount, reagent, dir)
	var/list/valid_suppliers = list()
	var/datum/ductnet/net
	if(!ducts.Find(num2text(dir)))
		return
	net = ducts[num2text(dir)]
	for(var/A in net.suppliers)
		var/datum/component/plumbing/supplier = A
		if(supplier.can_give(amount, reagent))
			valid_suppliers += supplier
	for(var/A in valid_suppliers)
		var/datum/component/plumbing/give = A
		give.transfer_to(src, amount / valid_suppliers.len, reagent)

/datum/component/plumbing/proc/can_give(amount, reagent)
	if(!reagents || amount <= 0)
		return

	if(reagent) //only asked for one type of reagent
		for(var/A in reagents.reagent_list)
			var/datum/reagent/R = A
			if(R.id == reagent)
				return TRUE
	else if(reagents.total_volume > 0) //take whatever
		return TRUE

/datum/component/plumbing/proc/transfer_to(datum/component/plumbing/target, amount, reagent)
	if(!reagents || !target || !target.reagents)
		return FALSE
	if(reagent)
		reagents.trans_id_to(target.reagents, reagent, amount)
	else
		reagents.trans_to(target.reagents, amount)

/datum/component/plumbing/simple_demand
	demand_connects = NORTH

/datum/component/plumbing/simple_supply
	supply_connects = NORTH