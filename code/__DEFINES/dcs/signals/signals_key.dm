///Called when a keycard is sending a department's access. (obj/machinery/keycard_auth/source, list/region_access)
#define COMSIG_ON_DEPARTMENT_ACCESS "on_department_access"

///Called when someone sends a signal to any listening door remotes. (obj/item/card/id/ID_requesting, obj/machinery/door/airlock/requested_door)
#define COMSIG_DOOR_REMOTE_ACCESS_REQUEST "door_remote_access_request"
	#define COMPONENT_REQUEST_LIMIT_REACHED 1
