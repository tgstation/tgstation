///This component allows us to give a mob access without giving them an ID card.
/datum/component/simple_access
	dupe_mode = COMPONENT_DUPE_ALLOWED
	///list of accesses we are allowed to access via this component
	var/list/access

/datum/component/simple_access/Initialize(list/new_access, atom/donor_atom)
	. = ..()
	if(!ismob(parent))
		return COMPONENT_INCOMPATIBLE
	access = new_access
	RegisterSignal(parent, COMSIG_MOB_TRIED_ACCESS, PROC_REF(on_tried_access))
	if(!donor_atom)
		return
	if(isorgan(donor_atom))
		RegisterSignal(donor_atom, COMSIG_ORGAN_REMOVED, PROC_REF(on_donor_removed))
	else if(istype(donor_atom, /obj/item/implant))
		RegisterSignal(donor_atom, COMSIG_IMPLANT_REMOVED, PROC_REF(on_donor_removed))
	RegisterSignal(donor_atom, COMSIG_PARENT_QDELETING, PROC_REF(on_donor_removed))

/datum/component/simple_access/proc/on_tried_access(datum/source, atom/locked_thing)
	SIGNAL_HANDLER
	if(!isobj(locked_thing))
		return LOCKED_ATOM_INCOMPATIBLE
	var/obj/locked_object = locked_thing
	if(locked_object.check_access_list(access))
		return ACCESS_ALLOWED
	else
		return ACCESS_DISALLOWED

/datum/component/simple_access/proc/on_donor_removed(datum/source)
	SIGNAL_HANDLER
	qdel(src)
