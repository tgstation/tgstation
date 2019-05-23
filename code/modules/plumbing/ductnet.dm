/datum/ductnet
	var/list/suppliers = list()
	var/list/demanders = list()
	var/list/obj/machinery/duct/ducts = list()

	var/capacity

/datum/ductnet/proc/add_duct(obj/machinery/duct/D)
	if(!D || D in ducts)
		return
	ducts += D
	D.duct = src

/datum/ductnet/proc/add_plumber(datum/component/plumbing/P, dir)
	if(!P.can_add(src, dir))
		return
	P.ducts[num2text(dir)] = src
	if(dir & P.supply_connects)
		suppliers += P
	else if(dir & P.demand_connects)
		demanders += P

/datum/ductnet/proc/assimilate(datum/ductnet/D)
	ducts.Add(D.ducts)
	suppliers.Add(D.suppliers)
	demanders.Add(D.demanders)
	for(var/A in D.suppliers + D.demanders)
		var/datum/component/plumbing/P = A
		for(var/s in P.ducts)
			if(P.ducts[s] != D)
				continue
			P.ducts[s] = src  //all your ducts are belong to us
	for(var/A in D.ducts)
		var/obj/machinery/duct/M = A
		M.duct = src //forget your old master
	qdel(D)

/datum/ductnet/proc/destroy_network()
	for(var/A in suppliers + demanders)
		qdel(A)
	for(var/A in ducts)
		var/obj/machinery/duct/D = A
		D.duct = null
	qdel(src)