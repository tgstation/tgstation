/// It's just connect_mob_behalf but the other way baby
/// Does not REALLY need to be COMPONENT_DUPE_UNIQUE_PASSARGS but if it's not it breaks real bad in plane master code (as of now)
/// And in theory this is more "correct"
/datum/component/connect_client_behalf
	dupe_mode = COMPONENT_DUPE_UNIQUE_PASSARGS

	/// list in the form mob -> list(signal -> procpath to register to the client our mob "owns")
	var/list/mob_to_connections = list()
	/// list of tracked mob -> client (if any)
	var/list/mob_to_client = list()

/datum/component/connect_client_behalf/Initialize(mob/tracked, list/connections)
	. = ..()
	if (!istype(tracked))
		return COMPONENT_INCOMPATIBLE
	src.mob_to_connections[tracked] = connections
	src.mob_to_client[tracked] = tracked.client

/datum/component/connect_client_behalf/RegisterWithParent()
	for(var/mob/tracked as anything in mob_to_connections)
		RegisterSignal(tracked, COMSIG_QDELETING, PROC_REF(handle_tracked_qdel))
		RegisterSignal(tracked, COMSIG_MOB_LOGIN, PROC_REF(on_login))
		RegisterSignal(tracked, COMSIG_MOB_LOGOUT, PROC_REF(on_logout))
		update_signals(tracked)

/datum/component/connect_client_behalf/UnregisterFromParent()
	for(var/mob/tracked as anything in mob_to_connections)
		unregister_signals(tracked)
		UnregisterSignal(tracked, COMSIG_QDELETING)
	mob_to_connections = null
	mob_to_client = null

/datum/component/connect_client_behalf/InheritComponent(datum/component/C, i_am_original, mob/tracked, list/connections)
	for(var/connection in connections)
		src.mob_to_connections[tracked][connection] = connections[connection]
	if(tracked in src.mob_to_client)
		update_signals(tracked)
		return
	src.mob_to_client[tracked] = tracked.client
	RegisterSignal(tracked, COMSIG_QDELETING, PROC_REF(handle_tracked_qdel))
	RegisterSignal(tracked, COMSIG_MOB_LOGIN, PROC_REF(on_login))
	RegisterSignal(tracked, COMSIG_MOB_LOGOUT, PROC_REF(on_logout))
	update_signals(tracked)

/datum/component/connect_client_behalf/proc/handle_tracked_qdel(mob/source)
	SIGNAL_HANDLER
	unregister_signals(source)
	UnregisterSignal(source, COMSIG_QDELETING)
	mob_to_connections -= source
	mob_to_client -= source
	if(!length(mob_to_connections))
		qdel(src)

/datum/component/connect_client_behalf/proc/update_signals(mob/tracked)
	unregister_signals(tracked)
	// Yes this is a runtime silencer
	// It's rare, and the same check in connect_loc_behalf is more fruitful, but it's still worth doing
	if(QDELETED(tracked?.client))
		return
	mob_to_client[tracked] = tracked.client
	var/list/connections = mob_to_connections[tracked]
	for (var/signal in connections)
		parent.RegisterSignal(tracked.client, signal, connections[signal])

/datum/component/connect_client_behalf/proc/unregister_signals(mob/tracked)
	if(isnull(mob_to_client[tracked]))
		return

	parent.UnregisterSignal(mob_to_client[tracked], mob_to_connections[tracked])
	mob_to_client[tracked] = null

/datum/component/connect_client_behalf/proc/on_login(mob/source)
	SIGNAL_HANDLER
	update_signals(source)

/datum/component/connect_client_behalf/proc/on_logout(mob/source)
	SIGNAL_HANDLER
	update_signals(source)
