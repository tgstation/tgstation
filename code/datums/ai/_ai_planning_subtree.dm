///A subtree is attached to a controller and is occasionally called by /ai_controller/select_behaviors(), this mainly exists to act as a way to subtype and modify select_behaviors() without needing to subtype the ai controller itself
/datum/ai_planning_subtree

///Generic setup() proc for subtrees, could be used for signal registration
/datum/ai_planning_subtree/proc/setup(datum/ai_controller/controller)

///Determines what behaviors should the controller try processing; if this returns SUBTREE_RETURN_FINISH_PLANNING then the controller won't go through the other subtrees should multiple exist in controller.planning_subtrees
/datum/ai_planning_subtree/proc/select_behaviors(datum/ai_controller/controller, seconds_per_tick)
	return
