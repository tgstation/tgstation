/datum/antagonist/blob_minion
	name = "\improper Blob Minion"
	antagpanel_category = ANTAG_GROUP_BIOHAZARDS
	show_name_in_check_antagonists = TRUE
	show_to_ghosts = TRUE
	show_in_antagpanel = FALSE
	/// The blob core that this minion is attached to
	var/datum/weakref/overmind

/datum/antagonist/blob_minion/New(mob/camera/blob/overmind)
	. = ..()
	src.overmind = WEAKREF(overmind)

/datum/antagonist/blob_minion/on_gain()
	forge_objectives()
	. = ..()

/datum/antagonist/blob_minion/greet()
	. = ..()
	owner.announce_objectives()

/datum/antagonist/blob_minion/forge_objectives()
	var/datum/objective/protect/objective = new
	objective.owner = owner
	objective.target = overmind
	objectives += objective

/datum/antagonist/blob_minion/blobbernaut
	name = "\improper Blobbernaut"

/datum/antagonist/blob_minion/blob_zombie
	name = "\improper Blob Zombie"
