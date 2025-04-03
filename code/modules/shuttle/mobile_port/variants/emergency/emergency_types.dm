/// Fallback shuttle
/obj/docking_port/mobile/emergency/backup
	name = "backup shuttle"
	shuttle_id = "backup"
	dir = EAST

/obj/docking_port/mobile/emergency/backup/Initialize(mapload)
	// We want to be a valid emergency shuttle
	// but not be the main one, keep whatever's set
	// valid.
	// backup shuttle ignores `timid` because THERE SHOULD BE NO TOUCHING IT
	var/current_emergency = SSshuttle.emergency
	. = ..()
	SSshuttle.emergency = current_emergency
	SSshuttle.backup_shuttle = src

/obj/docking_port/mobile/emergency/backup/Destroy(force)
	if(SSshuttle.backup_shuttle == src)
		SSshuttle.backup_shuttle = null
	return ..()

/// Monastery shuttle
/obj/docking_port/mobile/monastery
	name = "monastery pod"
	shuttle_id = "mining_common" //set so mining can call it down
	launch_status = UNLAUNCHED //required for it to launch as a pod.

/obj/docking_port/mobile/monastery/on_emergency_dock()
	if(launch_status == ENDGAME_LAUNCHED)
		initiate_docking(SSshuttle.getDock("pod_away")) //docks our shuttle as any pod would
		mode = SHUTTLE_ENDGAME

/// Build Your Own Shuttle (BYOS) kit
/obj/docking_port/mobile/emergency/shuttle_build

/obj/docking_port/mobile/emergency/shuttle_build/postregister()
	. = ..()
	initiate_docking(SSshuttle.getDock("emergency_home"))

