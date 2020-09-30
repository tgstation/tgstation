/**
  * # Destructive Scanning Experiment
  *
  * This is the base implementation of destructive scanning experiments.
  *
  * This class should be subclassed for producing actual experiments. The
  * procs should be extended where necessary.
  */
/datum/experiment/scanning/destructive
	name = "Destructive Scanning Experiment"
	description = "Base experiment for destructively scanning atoms"
	exp_tag = "Destructive Scan"

/**
  * Initializes the scanned atoms lists
  *
  * Initializes the internal scanned atoms list to keep a counter for each atom
  * Note we do not keep track of items scanned as they are destroyed after scanning
  */
/datum/experiment/scanning/destructive/New()
	for (var/a in required_atoms)
		scanned[a] = 0

/datum/experiment/scanning/destructive/is_complete()
	. = TRUE
	for (var/a in required_atoms)
		if (!(a in scanned) || scanned[a] != required_atoms[a])
			return FALSE

/datum/experiment/scanning/destructive/check_progress()
	. = list()
	for (var/a_type in required_atoms)
		var/atom/a = a_type
		. += list(EXP_INT_STAGE, "Scan samples of \a [initial(a.name)]", scanned[a] ? scanned[a] : 0, required_atoms[a])

/**
  * Attempts to scan an atom towards the experiment's goal
  *
  * This proc attempts to scan an atom towards the experiment's goal,
  * and returns TRUE/FALSE based on success. It also deletes the item if
  * successfully scanned
  * Arguments:
  * * target - The atom to attempt to scan
  */
/datum/experiment/scanning/destructive/perform_experiment_actions(datum/component/experiment_handler/experiment_handler, atom/target)
	var/idx = get_contributing_index(target)
	if (idx)
		scanned[idx]++
		qdel(target)
		return TRUE

/datum/experiment/scanning/destructive/get_contributing_index(atom/target)
	for (var/a in required_atoms)
		if (istype(target, a) && (a in scanned) && scanned[a] < required_atoms[a])
			return a
