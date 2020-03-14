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
		if (!scanned[a] || scanned[a] != required_atoms[a])
			return FALSE

/datum/experiment/scanning/destructive/check_progress()
	var/total_scanned = 0
	var/required = 0
	for (var/a in required_atoms)
		required += required_atoms[a]
		total_scanned += scanned[a] ? scanned[a] : 0
	return "Scanned [total_scanned] of [required] objects towards the goal."

/**
  * Attempts to scan an atom towards the experiment's goal
  *
  * This proc attempts to scan an atom towards the experiment's goal,
  * and returns TRUE/FALSE based on success. It also deletes the item if
  * successfully scanned
  * Arguments:
  * * target - The atom to attempt to scan
  */
/datum/experiment/scanning/destructive/scan_atom(atom/target)
	. = FALSE
	var/idx = get_contributing_index(target)
	if (idx)
		scanned[idx]++
		qdel(target)
		return TRUE

/datum/experiment/scanning/destructive/get_contributing_index(atom/target)
	. = null
	for (var/a in required_atoms)
		if (istype(target, a) && scanned[a] && scanned[a] < required_atoms[a])
			return a

/datum/experiment/scanning/destructive/sabotage()
	. = FALSE
	var/list/valid_targets = list()
	for (var/a in scanned)
		if (scanned[a] > 0)
			valid_targets += a

	if (valid_targets.len > 0)
		scanned[pick(valid_targets)]--
		return TRUE
