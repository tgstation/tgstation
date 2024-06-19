/*
/datum/verbs/menu/Example/verb/Example()
	set name = "" //if this starts with @ the verb is not created and name becomes the command to invoke.
	set desc = "" //desc is the text given to this entry in the menu
	//You can not use src in these verbs. It will be the menu at compile time, but the client at runtime.
*/

GLOBAL_LIST_EMPTY(menulist)

/datum/verbs/menu
	var/default //default checked type.
	//Set to true to append our children to our parent,
	//Rather then add us as a node (used for having more then one checkgroups in the same menu)

/datum/verbs/menu/GetList()
	return GLOB.menulist

/datum/verbs/menu/HandleVerb(list/entry, verbpath, client/C)
	return list2params(entry)
