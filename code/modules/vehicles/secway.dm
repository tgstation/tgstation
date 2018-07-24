
/obj/vehicle/ridden/secway
	name = "secway"
	desc = "A brave security cyborg gave its life to help you look like a complete tool."
	icon_state = "secway"
	key_type = /obj/item/key/security

/obj/vehicle/ridden/secway/Initialize()
	. = ..()
	var/datum/component/riding/D = LoadComponent(/datum/component/riding)
	D.vehicle_move_delay = 1
	D.set_riding_offsets(RIDING_OFFSET_ALL, list(TEXT_NORTH = list(0, 4), TEXT_SOUTH = list(0, 4), TEXT_EAST = list(0, 4), TEXT_WEST = list( 0, 4)))
