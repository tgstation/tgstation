GLOBAL_LIST_EMPTY(elevator_doors)

/obj/machinery/door/window/elevator
	name = "elevator door"
	desc = "Keeps idiots like you from walking into an open elevator shaft."
	icon_state = "left"
	base_state = "left"
	can_atmos_pass = ATMOS_PASS_DENSITY // elevator shaft is airtight when closed
	req_access = list(ACCESS_TCOMMS)

/obj/machinery/door/window/elevator/right
	icon_state = "right"
	base_state = "right"

MAPPING_DIRECTIONAL_HELPERS(/obj/machinery/door/window/elevator/left, 0)
MAPPING_DIRECTIONAL_HELPERS(/obj/machinery/door/window/elevator/right, 0)
