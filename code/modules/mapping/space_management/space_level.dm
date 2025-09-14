/datum/space_level
	var/name = "NAME MISSING"
	var/list/neigbours = list()
	var/list/traits
	var/z_value = 1 //actual z placement
	var/linkage = SELFLOOPING
	/// The x position on a grid that links the z-levels together
	var/xi
	/// The y position on a grid that links the z-levels together
	var/yi

/datum/space_level/New(new_z, new_name, list/new_traits = list())
	z_value = new_z
	name = new_name
	traits = new_traits

	if (islist(new_traits))
		for (var/trait in new_traits)
			SSmapping.z_trait_levels[trait] += list(new_z)
	else // in case a single trait is passed in
		SSmapping.z_trait_levels[new_traits] += list(new_z)

	if(new_traits["xi"] && new_traits["yi"])
		xi = new_traits["xi"]
		yi = new_traits["yi"]

	set_linkage(new_traits[ZTRAIT_LINKAGE])
