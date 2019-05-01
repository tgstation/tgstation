/obj/machinery/duct
	name = "fluid duct"
	icon = 'icons/obj/fluid_ducts.dmi'
	icon_state = "nduct_n_s"

	var/connects = NORTH | SOUTH
	var/datum/ductnet/duct
	var/capacity = 10

	var/active = TRUE

/obj/machinery/duct/Initialize()
	. = ..()
	if(active)
		attempt_connect()

/obj/machinery/duct/proc/attempt_connect()
	if(!duct) //we're already in a net
		return
	for(var/D in GLOB.cardinals)
		if(D in connects)
			for(var/A in get_step(src, D)
				connect_network(A, D)

/obj/machinery/duct/proc/connect_network(atom/A, direction)
	var/opposite_dir = angle2dir(dir2angle(direction) + 180)
	if(istype(A, /obj/machinery/duct))
		var/obj/machinery/duct/D = A
		if(!D.active)
			return
		if(opposite_dir & D.connects)
			rewr\r


	var/datum/component/plumbing/P = A.GetComponent(/datum/component/plumbing)
	if(!P)
		return
	var/comp_directions = P.supply_connects + P.demand_connects //they should never, ever have supply and demand connects overlap or catastrophic failure
	if(opposite_dir & comp_directions)
		return TRUE





/datum/ductnet
	var/list/suppliers = list()
	var/list/demanders = list()

	var/capacity





/datum/component/plumbing
	var/datum/ductnet/duct
	var/datum/reagents/reagents

	var/supply_connects //directions in wich we act as a supplier
	var/demand_connects //direction in wich we act as a demander

/datum/component/plumbing/proc/join_duct()
	parent



/datum/component/plumbing/proc/send_request(amount=10, reagent)
	if(!ductnet || !ductnet.suppliers.len) //using len instead of LAZYLEN because it's cheaper and the list 'should' be there
		return FALSE
	var/list/valid_suppliers = list()
	amount = min(amount, ductnet.capacity)
	for(var/A in ductnet.suppliers)
		var/datum/component/plumbing/supplier = A
		if(A.can_give(amount, reagent)
			valid_suppliers += A
	for(var/A in valid_suppliers)
		var/datum/plumbing/give = A
		A.transfer_to(src, amount / valid_suppliers.len, reagent)

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
	if(!reagents || !target || !target.reagents))
		return FALSE
	if(reagent)
		reagents.trans_id_to(target.reagents, reagent, amount)
	else
		reagents.trans_to(target.reagents, amount)

