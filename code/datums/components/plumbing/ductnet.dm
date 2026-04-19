///We handle the unity part of plumbing. We track who is connected to who.
/datum/ductnet
	///All the ducts that make this network
	var/list/obj/machinery/duct/ducts
	///Stuff that can supply chems used by machines to retrive chems
	var/list/datum/component/plumbing/suppliers
	///Stuff that demands chems keep track of components that need their ducts updated as this net evolves
	var/list/datum/component/plumbing/demanders

/datum/ductnet/New(obj/machinery/duct/parent)
	ducts = parent ? list(parent) : list()
	suppliers = list()
	demanders = list()
	return ..()

/datum/ductnet/Destroy(force)
	ducts.Cut()
	for(var/datum/component/plumbing/plumbing as anything in suppliers + demanders)
		remove_plumber(plumbing)
	suppliers.Cut()
	demanders.Cut()
	return ..()

///add a plumbing object to either demanders or suppliers
/datum/ductnet/proc/add_plumber(datum/component/plumbing/plumbing, dir)
	var/dirtext = num2text(dir)
	if(plumbing.ducts[dirtext] == src)
		return FALSE
	plumbing.ducts[dirtext] = src
	if(dir & plumbing.supply_connects)
		suppliers += plumbing
	if(dir & plumbing.demand_connects)
		demanders += plumbing
	return TRUE

///remove a plumber. we don't delete ourselves because ductnets don't persist through plumbing objects.
/datum/ductnet/proc/remove_plumber(datum/component/plumbing/plumbing)
	for(var/dir in plumbing.ducts)
		if(plumbing.ducts[dir] == src)
			plumbing.ducts -= dir
			dir = text2num(dir)
			if(dir & plumbing.supply_connects)
				suppliers -= plumbing
			if(dir & plumbing.demand_connects)
				demanders -= plumbing

	//return if this net has no ducts like when 2 machines are connected
	return ducts.len == 0
