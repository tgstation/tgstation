/datum/experiment/scanning/random
	name = "Base random scanning experiment"
	description = "This experiment's contents will be randomized. Good luck!"
	///list of types which that can be included in the experiment. Randomly picked from on New
	var/list/possible_types = list()
	/// The total desired number of atoms to have scanned
	var/total_requirement = 0
	/// Max amount of a requirement per type
	var/max_requirement_per_type = 100

/datum/experiment/scanning/random/New()
	// Generate random contents
	if (possible_types.len)
		var/picked = 0
		while (picked < total_requirement)
			var/r = min(rand(1, total_requirement - picked), max_requirement_per_type)
			required_atoms[pick(possible_types)] += r
			picked += r

	// Fill the experiemnt as per usual
	..()

/datum/experiment/scanning/destructive/random
	name = "Base random destructive scanning experiment"
	description = "This experiment's contents will be randomized. Good luck!"
	/// A weighted key, value list which will generate the atoms to be scanned
	var/list/possible_types = list()
	/// The total desired number of atoms to have scanned
	var/total_requirement = 0
	/// Max amount of a requirement per type
	var/max_requirement_per_type = 100

/datum/experiment/scanning/destructive/random/New()
	// Generate random contents
	if (possible_types.len)
		var/picked = 0
		while (picked < total_requirement)
			var/r = min(rand(1, total_requirement - picked), max_requirement_per_type)
			required_atoms[pick(possible_types)] += r
			picked += r

	// Fill the experiment as per usual
	..()
