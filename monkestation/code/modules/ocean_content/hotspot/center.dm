// this is the ugliest work around to using Signals I could think of, and the reason we don't want signals is because we already have to have a signal for Destroy on ocean turfs,
// if someone changes that please change this to using a turf reference instead of a coordinate retrieval system.
// basically this stores the xyz coords of a turf and has a helper proc that runs locate on the coords, thats it.
// this is super inefficent and i may just create a special signal that gets sent on ocean turf destruction to remove this system entirely
// andways this has been my rambling about random code stuff that no one cares about
/datum/hotspot_center
	var/x
	var/y
	var/z

/datum/hotspot_center/proc/return_turf()
	return locate(x, y, z) // :(

/datum/hotspot_center/proc/relocate(x, y, z)
	src.x = x
	src.y = y
	src.z = z
