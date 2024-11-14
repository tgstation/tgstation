///We handle the unity part of plumbing. We track who is connected to who.
/datum/ductnet
	///Stuff that can supply chems
	var/list/suppliers = list()
	////Stuff that can take chems
	var/list/demanders = list()
	///All the ducts that make this network
	var/list/obj/machinery/duct/ducts = list()

	///Max reagents we can carry per tick
	var/capacity

///Add a duct to our network
/datum/ductnet/proc/add_duct(obj/machinery/duct/D)
	if(!D || (D in ducts))
		return
	ducts += D
	D.duct = src

///Remove a duct from our network and commit suicide, because this is probably easier than to check who that duct was connected to and what part of us was lost
/datum/ductnet/proc/remove_duct(obj/machinery/duct/ducting)
	destroy_network(FALSE)
	for(var/obj/machinery/duct/D in ducting.neighbours)
		addtimer(CALLBACK(D, TYPE_PROC_REF(/obj/machinery/duct,attempt_connect))) //needs to happen after qdel
	qdel(src)

///add a plumbing object to either demanders or suppliers
/datum/ductnet/proc/add_plumber(datum/component/plumbing/P, dir)
	if(!P.can_add(src, dir))
		return FALSE
	P.ducts[num2text(dir)] = src
	if(dir & P.supply_connects)
		suppliers += P
	else if(dir & P.demand_connects)
		demanders += P
	return TRUE

///remove a plumber. we don't delete ourselves because ductnets don't persist through plumbing objects
/datum/ductnet/proc/remove_plumber(datum/component/plumbing/P)
	suppliers.Remove(P) //we're probably only in one of these, but Remove() is inherently sane so this is fine
	demanders.Remove(P)

	for(var/dir in P.ducts)
		if(P.ducts[dir] == src)
			P.ducts -= dir

	if(!ducts.len) //there were no ducts, so it was a direct connection. we destroy ourselves since a ductnet with only one plumber and no ducts is worthless
		destroy_network()

///we combine ductnets. this occurs when someone connects to separate sets of fluid ducts
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

	D.ducts.Cut() //clear this so the other network doesn't clear the ducts along with themselves (this took the life out of me)
	D.destroy_network()

///destroy the network and tell all our ducts and plumbers we are gone
/datum/ductnet/proc/destroy_network(delete=TRUE)
	for(var/A in suppliers + demanders)
		remove_plumber(A)
	for(var/A in ducts)
		var/obj/machinery/duct/D = A
		D.duct = null
	if(delete) //I don't want code to run with qdeleted objects because that can never be good, so keep this in-case the ductnet has some business left to attend to before committing suicide
		qdel(src)
