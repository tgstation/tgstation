/datum/component/soapbox
	/// List of our current soapboxxer(s) who are gaining loud speech
	var/list/soapboxers = list()
	/// Gives atoms moving over us the soapbox speech and takes it away when they leave
	var/static/list/loc_connections = list(
		COMSIG_ATOM_ENTERED = PROC_REF(on_loc_entered),
		COMSIG_ATOM_EXITED = PROC_REF(on_loc_exited),
	)

/datum/component/soapbox/Initialize(...)
	if(!ismovable(parent))
		return COMPONENT_INCOMPATIBLE
	add_connect_loc_behalf_to_parent()
	RegisterSignal(parent, COMSIG_MOVABLE_MOVED, PROC_REF(parent_moved))

///Applies loud speech to our movable when entering the turf our parent is on
/datum/component/soapbox/proc/on_loc_entered(datum/source, mob/living/soapbox_arrive)
	SIGNAL_HANDLER
	if(!isliving(soapbox_arrive))
		return
	if(QDELETED(soapbox_arrive))
		return
	RegisterSignal(soapbox_arrive, COMSIG_MOB_SAY, PROC_REF(soapbox_speech))
	soapboxers += soapbox_arrive

///Takes away loud speech from our movable when it leaves the turf our parent is on
/datum/component/soapbox/proc/on_loc_exited(datum/source, mob/living/soapbox_leave)
	SIGNAL_HANDLER
	if(soapbox_leave in soapboxers)
		UnregisterSignal(soapbox_leave, COMSIG_MOB_SAY)
		soapboxers -= soapbox_leave

///We don't want our soapboxxer to keep their loud say if the parent is moved out from under them
/datum/component/soapbox/proc/parent_moved(datum/source)
	SIGNAL_HANDLER
	for(var/atom/movable/loud as anything in soapboxers)
		UnregisterSignal(loud, COMSIG_MOB_SAY)
	soapboxers.Cut()

///Gives a mob a unique say span
/datum/component/soapbox/proc/soapbox_speech(datum/source, list/speech_args)
	SIGNAL_HANDLER
	speech_args[SPEECH_SPANS] |= SPAN_SOAPBOX

/datum/component/soapbox/proc/add_connect_loc_behalf_to_parent()
	AddComponent(/datum/component/connect_loc_behalf, parent, loc_connections)
