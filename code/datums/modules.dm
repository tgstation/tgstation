// module datum.
// this is per-object instance, and shows the condition of the modules in the object
// actual modules needed is referenced through modulestypes and the object type

/datum/module
	var/status				// bits set if working, 0 if broken
	var/installed			// bits set if installed, 0 if missing

// moduletypes datum
// this is per-object type, and shows the modules needed for a type of object

/datum/moduletypes
	var/list/modcount = list()	// assoc list of the count of modules for a type


var/list/modules = list(			// global associative list
"/obj/machinery/power/apc" = "card_reader,power_control,id_auth,cell_power,cell_charge")


/datum/module/New(var/obj/O)

	var/type = O.type		// the type of the creating object

	var/mneed = mods.inmodlist(type)		// find if this type has modules defined

	if(!mneed)		// not found in module list?
		del(src)	// delete self, thus ending proc

	var/needed = mods.getbitmask(type)		// get a bitmask for the number of modules in this object
	status = needed
	installed = needed

/datum/moduletypes/proc/addmod(var/type, var/modtextlist)
	modules += type	// index by type text
	modules[type] = modtextlist

/datum/moduletypes/proc/inmodlist(var/type)
	return ("[type]" in modules)

/datum/moduletypes/proc/getbitmask(var/type)
	var/count = modcount["[type]"]
	if(count)
		return 2**count-1

	var/modtext = modules["[type]"]
	var/num = 1
	var/pos = 1

	while(1)
		pos = findtext(modtext, ",", pos, 0)
		if(!pos)
			break
		else
			pos++
			num++

	modcount += "[type]"
	modcount["[type]"] = num

	return 2**num-1


