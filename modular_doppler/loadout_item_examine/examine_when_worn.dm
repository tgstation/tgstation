// This is cheaper than adding to the Topic() of atom
/datum/element/examined_when_worn

/datum/element/examined_when_worn/Attach(datum/target)
	. = ..()
	RegisterSignal(target, COMSIG_TOPIC, PROC_REF(on_topic))
	ADD_TRAIT(target, TRAIT_WORN_EXAMINE, TRAIT_SUBTREE_REQUIRED_OPERATIONAL_DATUM)

/datum/element/examined_when_worn/proc/on_topic(atom/source, mob/user, href_list)
	if(href_list["examine_loadout"])
		user.run_examinate(source)
		return

/datum/element/examined_when_worn/Detach(datum/source, ...)
	. = ..()
	UnregisterSignal(source, COMSIG_TOPIC)
	REMOVE_TRAIT(source, TRAIT_WORN_EXAMINE, TRAIT_SUBTREE_REQUIRED_OPERATIONAL_DATUM)
