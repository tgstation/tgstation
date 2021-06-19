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
			var/randum = min(rand(1, total_requirement - picked), max_requirement_per_type) //Short for "random num" and not "this is dum that I have to rename 100 different variable names"
			required_atoms[pick(possible_types)] += randum
			picked += randum

	// Fill the experiment as per usual
	..()
