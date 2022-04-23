GLOBAL_REAL(assigned, /image/) = image('modular_pariah/master_files/icons/testing/Zone.dmi', icon_state = "assigned")
GLOBAL_REAL(created, /image/) = image('modular_pariah/master_files/icons/testing/Zone.dmi', icon_state = "created")
GLOBAL_REAL(merged, /image/) = image('modular_pariah/master_files/icons/testing/Zone.dmi', icon_state = "merged")
GLOBAL_REAL(invalid_zone, /image/) = image('modular_pariah/master_files/icons/testing/Zone.dmi', icon_state = "invalid")
GLOBAL_REAL(air_blocked, /image/) = image('modular_pariah/master_files/icons/testing/Zone.dmi', icon_state = "block")
GLOBAL_REAL(zone_blocked, /image/) = image('modular_pariah/master_files/icons/testing/Zone.dmi', icon_state = "zoneblock")
GLOBAL_REAL(blocked, /image/) = image('modular_pariah/master_files/icons/testing/Zone.dmi', icon_state = "fullblock")
GLOBAL_REAL(mark, /image/) = image('modular_pariah/master_files/icons/testing/Zone.dmi', icon_state = "mark")

/connection_edge/var/dbg_out = 0

/turf/var/tmp/dbg_img
/turf/proc/dbg(image/img, d = 0)
	if(d > 0) img.dir = d
	overlays -= dbg_img
	overlays += img
	dbg_img = img

/proc/soft_assert(thing,fail)
	if(!thing) message_admins(fail)
