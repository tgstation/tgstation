/**
 * ## !ONLY BEHAVIORS SHOULD BE SETTING, SUBTREES PLAN ONLY!
 *
 * A subtree is a datum that plans for how the pawn should respond to the world.
 *
 * They come as a list with the first subtree in the list being planned out first, and they can cancel
 * subsequent planning trees by returning `SUBTREE_RETURN_FINISH_PLANNING`. What this means is that we can
 * set priority on conditional responses to the world, letting the AI focus on one thing and saving lower
 * priority subtrees for when there's less action.
 *
 * One good example is the Monkey Combat Subtree. It plans how the Monkey is going to attack their blackboard
 * target (run away, hit them, disposals them, etc), and will cancel further subtrees if it is actually in combat.
 *
 * Arguments:
 * * controller - controller that has just stopped using this subtree
 */
/datum/ai_planning_subtree


///Determines what behaviors should the controller try processing; if this returns SUBTREE_RETURN_FINISH_PLANNING then the controller won't go through the other subtrees should multiple exist in controller.planning_subtrees
/datum/ai_planning_subtree/proc/SelectBehaviors(datum/ai_controller/controller, delta_time)
	return

/**
 * SetupSubtree - Called when an ai_controller is linking to the singleton subtrees.
 *
 * Used for:
 * * Signals! Sometimes the pawn needs to respond to events in the world by setting blackboards
 * * Blackboards! Since this is a "Subtree Initialize" subtrees should initialize their related blackboards to their default values
 *
 * Arguments:
 * * controller - controller that has just started using this subtree- usually on creation of the ai controller.
 */
/datum/ai_planning_subtree/proc/SetupSubtree(datum/ai_controller/controller)
	return

/**
 * SetupSubtree - Called when an ai_controller is unlinking from a singleton subtree
 *
 * Most important usage is to get rid of signals.
 *
 * Arguments:
 * * controller - controller that has just stopped using this subtree
 */
/datum/ai_planning_subtree/proc/ForgetSubtree(datum/ai_controller/controller)
	return
