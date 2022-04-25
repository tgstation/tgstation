GLOBAL_REAL_VAR(obj/effect/zasdbg/assigned/zasdbgovl_assigned) = new
GLOBAL_REAL_VAR(obj/effect/zasdbg/created/zasdbgovl_created) = new
GLOBAL_REAL_VAR(obj/effect/zasdbg/merged/zasdbgovl_merged) = new
GLOBAL_REAL_VAR(obj/effect/zasdbg/invalid_zone/zasdbgovl_invalid_zone) = new
GLOBAL_REAL_VAR(obj/effect/zasdbg/air_blocked/zasdbgovl_air_blocked) = new
GLOBAL_REAL_VAR(obj/effect/zasdbg/zone_blocked/zasdbgovl_zone_blocked) = new
GLOBAL_REAL_VAR(obj/effect/zasdbg/blocked/zasdbgovl_blocked) = new
GLOBAL_REAL_VAR(obj/effect/zasdbg/mark/zasdbgovl_mark) = new

/connection_edge/var/dbg_out = 0

/obj/effect/zasdbg
	icon = 'icons/testing/Zone.dmi'
	invisibility = INVISIBILITY_OBSERVER

/obj/effect/zasdbg/assigned
	icon_state = "assigned"
/obj/effect/zasdbg/created
	icon_state = "created"
/obj/effect/zasdbg/merged
	icon_state = "merged"
/obj/effect/zasdbg/invalid_zone
	icon_state = "invalid"
/obj/effect/zasdbg/air_blocked
	icon_state = "block"
/obj/effect/zasdbg/zone_blocked
	icon_state = "zoneblock"
/obj/effect/zasdbg/blocked
	icon_state = "fullblock"
/obj/effect/zasdbg/mark
	icon_state = "mark"

/turf/var/tmp/dbg_img
/turf/proc/dbg(image/img, d = 0)
	if(d > 0) img.dir = d
	vis_contents -= dbg_img
	vis_contents += img
	dbg_img = img

/proc/soft_assert(thing,fail)
	if(!thing) message_admins(fail)
