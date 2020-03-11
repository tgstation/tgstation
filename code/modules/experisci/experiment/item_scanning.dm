/**
  * # Item Experiment
  *
  * This is the base implementation of item scanning experiments.
  *
  * This class should be subclassed for producing actual experiments. The
  * procs should be extended where necessary.
  */
/datum/experiment/item
	name = "Item Scanning Experiment"
	description = "Base experiment for scanning items"
	/// The typepath of the item to scan
	var/item_path = /obj/item
	/// The number of items that have been scanned so far
	var/scanned = 0
	/// The number of items that must be scanned to complete the experiment
	var/goal = 0
	/// Determines if this experiment is destructive, destroying the item
	var/destructive = FALSE
	/// Contains the number of seen objects, used for non-destructive experiments
	var/list/seen_objects = list()

/**
  * Checks if the scanning experiment is complete
  *
  * Returns TRUE/FALSE as to if the necessary number of items have been
  * scanned.
  */
/datum/experiment/item/is_complete()
	return scanned == goal

/**
  * Gets the number of items that have been scanned and the goal
  *
  * This proc returns a string describing the number of items that
  * have been scanned as well as the target number of items.
  */
/datum/experiment/item/check_progress()
	return "Scanned [scanned] of [goal] objects towards the goal."

/**
  * Attempts to scan an item towards the experiment's goal
  *
  * This proc attempts to scan an item towards the experiment's goal,
  * and returns TRUE/FALSE based on success.
  * Arguments:
  * * target - The item to attempt to scan
  */
/datum/experiment/item/proc/scan_item(obj/item/target)
	. = FALSE
	if (scanned >= goal || !istype(target, item_path))
		return
	if (destructive)
		scanned++
		qdel(target)
		return TRUE
	else if (target in seen_objects)
		return
	else
		seen_objects += target
		scanned++
		return TRUE

/datum/experiment/item/can_sabotage()
	..()

/**
  * Attempts to sabotage the experiment
  *
  * This proc attempts to decrease the scanned item count by one, and
  * returns TRUE/FALSE based on the success of this operation.
  */
/datum/experiment/item/sabotage()
	if (scanned <= 0)
		return FALSE
	else
		scanned--
		return TRUE
