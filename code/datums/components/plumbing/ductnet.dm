///We handle the unity part of plumbing. We track who is connected to who.
/datum/ductnet
	///All the ducts that make this network
	var/list/obj/machinery/duct/ducts
	///Stuff that can supply chems used by machines to retrive chems
	var/list/datum/component/plumbing/suppliers
	///Stuff that demands chems keep track of components that need their ducts updated as this net evolves
	VAR_PRIVATE/list/datum/component/plumbing/demanders

/datum/ductnet/New(obj/machinery/duct/parent)
	ducts = parent ? list(parent) : list()
	suppliers = list()
	demanders = list()
	return ..()

/datum/ductnet/Destroy(force)
	ducts.Cut()
	for(var/datum/component/plumbing/P as anything in suppliers + demanders)
		remove_plumber(P)
	suppliers.Cut()
	demanders.Cut()
	return ..()

///add a plumbing object to either demanders or suppliers
/datum/ductnet/proc/add_plumber(datum/component/plumbing/P, dir)
	var/dirtext = num2text(dir)
	if(P.ducts[dirtext] == src)
		return FALSE
	P.ducts[dirtext] = src
	if(dir & P.supply_connects)
		suppliers += P
	if(dir & P.demand_connects)
		demanders += P
	return TRUE

///remove a plumber. we don't delete ourselves because ductnets don't persist through plumbing objects.
/datum/ductnet/proc/remove_plumber(datum/component/plumbing/P)
	for(var/dir in P.ducts)
		if(P.ducts[dir] == src)
			P.ducts -= dir
			dir = text2num(dir)
			if(dir & P.supply_connects)
				suppliers -= P
			if(dir & P.demand_connects)
				demanders -= P

	//return if this net has no ducts like when 2 machines are connected
	return ducts.len == 0

///we combine ductnets. this occurs when someone connects to separate sets of fluid ducts
/datum/ductnet/proc/assimilate(datum/ductnet/D)
	//Take all its suppliers & demanders
	suppliers |= D.suppliers
	demanders |= D.demanders
	for(var/datum/component/plumbing/P as anything in D.suppliers + D.demanders)
		for(var/s in P.ducts)
			if(P.ducts[s] == D)
				P.ducts[s] = src
	D.suppliers.Cut()
	D.demanders.Cut()

	//Take all its ducts
	ducts |= D.ducts
	for(var/obj/machinery/duct/M as anything in D.ducts)
		M.net = src

	//destory it
	qdel(D)
