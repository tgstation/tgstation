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

/datum/ductnet/proc/remove_duct(obj/machinery/duct/ducting)
	destroy_network(FALSE)
	for(var/A in ducting.neighbours)
		var/obj/machinery/duct/D = A
		D.attempt_connect() //we destroyed the network, so now we tell the disconnected ducts neighbours they can start making a new ductnet
	qdel(src)

/datum/ductnet/proc/add_plumber(datum/component/plumbing/P, dir)
	if(!P.can_add(src, dir))
		return
	P.ducts[num2text(dir)] = src
	if(dir & P.supply_connects)
		suppliers += P
	else if(dir & P.demand_connects)
		demanders += P

/datum/ductnet/proc/remove_plumber(datum/component/plumbing/P)
	suppliers.Remove(P) //we're probably only in one of these, but Remove() is inherently sane so this is fine
	demanders.Remove(P)

	for(var/dir in P.ducts)
		if(P.ducts[dir] == src)
			P.ducts -= dir

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

/datum/ductnet/proc/destroy_network(delete=TRUE)
	for(var/A in suppliers + demanders)
		remove_plumber(A)
	for(var/A in ducts)
		var/obj/machinery/duct/D = A
		D.duct = null
	if(delete) //I don't want code to run with qdeleted objects because that can never be good, so keep this in-case the ductnet has some business left to attend to before commiting suicide
		qdel(src)