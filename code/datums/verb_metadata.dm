/datum/verb_metadata
	var/name
	var/description
	var/category
	var/verb_path
	var/body_path

/datum/verb_metadata/proc/assign_to(target)
	add_verb(target, verb_path)

/datum/verb_metadata/proc/unassign_from(target)
	remove_verb(target, verb_path)
