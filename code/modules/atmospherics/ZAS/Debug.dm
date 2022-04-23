GLOBAL_REAL_VAR(image/assigned) = image('modular_pariah/master_files/icons/testing/Zone.dmi', icon_state = "assigned")
GLOBAL_REAL_VAR(image/created) = image('modular_pariah/master_files/icons/testing/Zone.dmi', icon_state = "created")
GLOBAL_REAL_VAR(image/merged) = image('modular_pariah/master_files/icons/testing/Zone.dmi', icon_state = "merged")
GLOBAL_REAL_VAR(image/invalid_zone) = image('modular_pariah/master_files/icons/testing/Zone.dmi', icon_state = "invalid")
GLOBAL_REAL_VAR(image/air_blocked) = image('modular_pariah/master_files/icons/testing/Zone.dmi', icon_state = "block")
GLOBAL_REAL_VAR(image/zone_blocked) = image('modular_pariah/master_files/icons/testing/Zone.dmi', icon_state = "zoneblock")
GLOBAL_REAL_VAR(image/blocked) = image('modular_pariah/master_files/icons/testing/Zone.dmi', icon_state = "fullblock")
GLOBAL_REAL_VAR(image/mark) = image('modular_pariah/master_files/icons/testing/Zone.dmi', icon_state = "mark")

/connection_edge/var/dbg_out = 0

/turf/var/tmp/dbg_img
/turf/proc/dbg(image/img, d = 0)
	if(d > 0) img.dir = d
	overlays -= dbg_img
	overlays += img
	dbg_img = img

/proc/soft_assert(thing,fail)
	if(!thing) message_admins(fail)
