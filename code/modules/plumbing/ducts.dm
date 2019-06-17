/*
Make adjacency one proc and check conditions in one spot
Sort out active, anchor and possible layers



*/

/obj/machinery/duct
	name = "fluid duct"
	icon = 'icons/obj/plumbing/fluid_ducts.dmi'
	icon_state = "nduct"

	var/connects = NORTH | SOUTH
	var/datum/ductnet/duct
	var/capacity = 10

	var/active = TRUE //wheter to even bother with plumbing code or not

/obj/machinery/duct/bent
	icon_state = "nduct_bent"
	connects = NORTH | EAST

/obj/machinery/duct/joined
	icon_state = "nduct_joined"
	connects = NORTH | WEST | SOUTH

/obj/machinery/duct/cross
	icon_state = "nduct_crossed"
	connects = NORTH | SOUTH | EAST | WEST

/obj/machinery/duct/Initialize(mapload, no_anchor, spin=SOUTH)
	. = ..()

	setDir(spin)
	if(no_anchor)
		active = FALSE
		anchored = FALSE
	else if(!can_anchor())
		CRASH("Overlapping ducts detected")
		qdel(src)
	if(active)
		attempt_connect()

/obj/machinery/duct/ComponentInitialize()
	AddComponent(/datum/component/simple_rotation, ROTATION_ALTCLICK | ROTATION_CLOCKWISE)

/obj/machinery/duct/setDir(newdir) //This shouldn't ever happen, but someone is bound to make a wizard spell that spins everything and let's not do that
	if(anchored || active)
		return FALSE

/obj/machinery/duct/proc/update_dir()
	//Note that the use of the SOUTH define as default is because it's the initial direction of the ducts and it's connects
	var/new_connects
	var/angle = 180 - dir2angle(dir)
	if(dir == SOUTH)
		connects = initial(connects)
	else
		for(var/D in GLOB.cardinals)
			if(D & initial(connects))
				new_connects += turn(D, angle)
		connects = new_connects

/obj/machinery/duct/proc/attempt_connect()
	update_dir()
	for(var/D in GLOB.cardinals)
		if(D & connects)
			for(var/A in get_step(src, D))
				connect_network(A, D)

/obj/machinery/duct/proc/connect_network(atom/A, direction)
	var/opposite_dir = turn(direction, 180)
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
	if(!duct)
		return
	duct.remove_duct(src)

/obj/machinery/duct/proc/create_duct()
	duct = new()
	duct.add_duct(src)

/obj/machinery/duct/proc/get_adjacent_ducts()
	var/list/adjacents = list()
	for(var/A in GLOB.cardinals)
		if(A & connects)
			for(var/obj/machinery/duct/D in get_step(src, A))
				if((turn(A, 180) & D.connects) && D.active)
					adjacents += D
	return adjacents

/obj/machinery/duct/wrench_act(mob/living/user, obj/item/I) //I can also be the RPD
	add_fingerprint(user)
	I.play_tool_sound(src)
	if(anchored)
		anchored = FALSE
		active = FALSE
		user.visible_message( \
		"[user] unfastens \the [src].", \
		"<span class='notice'>You unfasten \the [src].</span>", \
		"<span class='italics'>You hear ratcheting.</span>")
		disconnect_duct()
	else if(can_anchor())
		anchored = TRUE
		active = TRUE
		user.visible_message( \
		"[user] fastens \the [src].", \
		"<span class='notice'>You fasten \the [src].</span>", \
		"<span class='italics'>You hear ratcheting.</span>")
		attempt_connect()
	return TRUE

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
	var/use_overlays = TRUE //TRUE if we wanna add proper pipe outless under our parent object
	var/list/image/ducterlays //We can't just cut all of the parents' overlays, so we'll track them here

	var/supply_connects //directions in wich we act as a supplier
	var/demand_connects //direction in wich we act as a demander

	var/active = TRUE //FALSE to pretty much just not exist in the plumbing world
	var/turn_connects = TRUE

/datum/component/plumbing/Initialize(start=TRUE, _turn_connects=TRUE) //turn_connects for wheter or not we spin with the object to change our pipes
	if(parent && !ismovableatom(parent))
		return COMPONENT_INCOMPATIBLE
	var/atom/movable/AM = parent
	if(!AM.reagents)
		return COMPONENT_INCOMPATIBLE
	reagents = AM.reagents
	turn_connects = _turn_connects

	if(start)
		start()

	if(use_overlays)
		create_overlays()


/datum/component/plumbing/process()
	if(!demand_connects || !reagents)
		STOP_PROCESSING(SSfluids, src)
		return
	if(reagents.total_volume < reagents.maximum_volume)
		for(var/D in GLOB.cardinals)
			if(D & demand_connects)
				send_request(D)

/datum/component/plumbing/proc/can_add(datum/ductnet/D, dir)
	if(!active)
		return
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

/datum/component/plumbing/proc/create_overlays()
	var/atom/movable/AM = parent
	for(var/image/I in ducterlays)
		AM.overlays.Remove(I)
		qdel(I)
	ducterlays = list()
	for(var/D in GLOB.cardinals)
		var/color
		var/direction
		if(D & demand_connects)
			color = "red" //red because red is mean and it takes
		if(D & supply_connects)
			color = "blue" //blue is nice and gives
		switch(D)
			if(NORTH)
				direction = "north"
			if(SOUTH)
				direction = "south"
			if(EAST)
				direction = "east"
			if(WEST)
				direction = "west"
		var/image/I = image('icons/obj/plumbing/plumbers.dmi', "[direction]-[color]", layer = AM.layer - 1)
		AM.overlays += I
		ducterlays += I

/datum/component/plumbing/proc/disable() //we stop acting like a plumbing thing and disconnect if we are, so we can safely be moved and stuff
	STOP_PROCESSING(SSfluids, src)
	for(var/A in ducts)
		var/datum/ductnet/D = A
		D.remove_plumber(src)

	active = FALSE

/datum/component/plumbing/proc/start() //settle wherever we are, and start behaving like a piece of plumbing
	update_dir()
	active = TRUE

	if(demand_connects)
		START_PROCESSING(SSfluids, src)

	for(var/D in GLOB.cardinals)
		if(D in demand_connects + supply_connects)
			for(var/obj/machinery/duct/duct in get_step(src, D))
				if(turn(D, 180) & duct.connects)
					duct.connect_network(parent, turn(D, 180))

	//TODO: Let plumbers directly plumb into one another without ducts if placed adjacent to each other

/datum/component/plumbing/proc/update_dir() //note that this is only called when we settle down. If someone wants it to fucking spin while connected to something go actually knock yourself out
	if(!turn_connects)
		return
	var/atom/movable/AM = parent
	var/new_demand_connects
	var/new_supply_connects
	var/new_dir = AM.dir
	var/angle = 180 - dir2angle(new_dir)
	if(new_dir == SOUTH)
		demand_connects = initial(demand_connects)
		supply_connects = initial(supply_connects)
	else
		for(var/D in GLOB.cardinals)
			if(D & initial(demand_connects))
				new_demand_connects += turn(D, angle)
			if(D & initial(supply_connects))
				new_supply_connects += turn(D, angle)
		demand_connects = new_demand_connects
		supply_connects = new_supply_connects


/datum/component/plumbing/simple_demand
	demand_connects = NORTH

/datum/component/plumbing/simple_supply
	supply_connects = NORTH

/datum/component/plumbing/tank
	demand_connects = WEST
	supply_connects = EAST


