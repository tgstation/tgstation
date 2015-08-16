/datum/rcd_schematic
	var/name			= "whomp"	//Obvious.
	var/category		= ""		//More obvious. Yes you need a category.
	var/energy_cost		= 0			//Energy cost of this schematic.
	var/flags			= 0			//Bitflags.

	var/obj/item/device/rcd/master	//Okay all of the vars here are obvious...

/datum/rcd_schematic/New(var/obj/item/device/rcd/n_master)
	master = n_master
	. = ..()


/*
Called when the RCD this thing belongs to attacks an atom.
params:
	- var/atom/A:	The atom being attacked.
	- var/mob/user:	The mob using the RCD.

return value:
	- !0:		Non-descriptive error.
	- string:	Error with reason.
	- 0:		No errors.
*/

/datum/rcd_schematic/proc/attack(var/atom/A, var/mob/user)
	return 0


/*
Called when the RCD's schematic changes away from this one.
params:
	- var/mob/user:								The user, duh...
	- var/datum/rcd_schematic/old_schematic:	The new schematic.

return value:
	- !0:	Switch allowed.
	- 0:	Switch not allowed
*/

/datum/rcd_schematic/proc/deselect(var/mob/user, var/datum/rcd_schematic/new_schematic)
	return 1


/*
Called when the RCD's schematic changes to this one
Note: this is called AFTER deselect().
params:
	- var/mob/user:								The user, duh...
	- var/datum/rcd_schematic/old_schematic:	The schematic before this one.

return value:
	- !0:	Switch allowed.
	- 0:	Switch not allowed
*/

/datum/rcd_schematic/proc/select(var/mob/user, var/datum/rcd_schematic/old_schematic)
	return 1


/*
Called to get the HTML for things like the direction menu on an RPD.
Note:
	- Do not do hrefs to the src, any hrefs should direct at the HTML interface, Topic() calls are passed down if not used by the RCD itself.
	- Always return something here ("" is not enough), else there will be a Jscript error for clients.

params:
	- I don't need to explain this.
*/

/datum/rcd_schematic/proc/get_HTML()
	return " "

/*
Called when a client logs in and the required resources need to be sent to the cache.
Use client << browse_rsc() to sent the files.

params:
	- var/client/client: client to send to.
*/

/datum/rcd_schematic/proc/send_icons(var/client/client)
	return