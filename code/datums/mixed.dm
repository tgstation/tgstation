/datum/powernet
	var/list/cables = list()	// all cables & junctions
	var/list/nodes = list()		// all connected machines

	var/load = 0				// the current load on the powernet, increased by each machine at processing
	var/newavail = 0			// what available power was gathered last tick, then becomes...
	var/avail = 0				//...the current available power in the powernet
	var/viewload = 0			// the load as it appears on the power console (gradually updated)
	var/number = 0				// Unused //TODEL
	var/netexcess = 0			// excess power on the powernet (typically avail-load)

/*Powernet procs :

In modules/power/power.dm :

/datum/powernet/New()
/datum/powernet/Destroy()
/datum/powernet/proc/is_empty()
/datum/powernet/proc/remove_cable(var/obj/structure/cable/C)
/datum/powernet/proc/add_cable(var/obj/structure/cable/C)
/datum/powernet/proc/remove_machine(var/obj/machinery/power/M)
/datum/powernet/proc/add_machine(var/obj/machinery/power/M)
/datum/powernet/proc/reset()
/datum/powernet/proc/get_electrocute_damage()


*/

/datum/debug
	var/list/debuglist