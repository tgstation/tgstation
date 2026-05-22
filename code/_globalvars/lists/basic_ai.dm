///all basic ai subtrees
GLOBAL_LIST_EMPTY(ai_subtrees)
///all singleton behavior tree node instances (composites, decorators) indexed by typepath
GLOBAL_LIST_EMPTY(bt_nodes)

///basic ai controllers based on status
GLOBAL_LIST_INIT(ai_controllers_by_status, list(
	AI_STATUS_ON = list(),
	AI_STATUS_OFF = list(),
	AI_STATUS_IDLE = list(),
))

///basic ai controllers based on their z level
GLOBAL_LIST_EMPTY(ai_controllers_by_zlevel)

///basic ai controllers that are currently performing idled behaviors
GLOBAL_LIST_INIT_TYPED(unplanned_controllers, /list/datum/ai_controller, list(
	AI_STATUS_ON = list(),
	AI_STATUS_IDLE = list(),
))

