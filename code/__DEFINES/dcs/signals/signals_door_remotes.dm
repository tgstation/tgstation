///Called when someone sends a signal to any listening door remotes. (obj/item/card/id/ID_requesting, obj/machinery/door/airlock/requested_door)
#define COMSIG_DOOR_REMOTE_ACCESS_REQUEST "door_remote_access_request"
	#define COMPONENT_REQUEST_RECEIVED (1<<0)
	#define COMPONENT_REQUEST_DENIED (1<<1)
	#define COMPONENT_REQUEST_BLOCKED (1<<2)
	#define COMPONENT_REQUEST_AUTO_HANDLED (1<<3)
	#define COMPONENT_REQUEST_HANDLED (1<<4)
///Called when someone else with a door remote approves or denies an access request (CE and RD butting heads over bolting AI upload door in response to the clown)
#define COMSIG_DOOR_REMOTE_ACCESS_REQUEST_RESOLVED "door_remote_access_request_resolved"
