/*
AI controllers are a datumized form of AI that simulates the input a player would otherwise give to a mob. What this means is that these datums
have ways of interacting with a specific mob and control it.
*/
///OOK OOK OOK

/datum/ai_controller/dog
	blackboard = list(BB_DOG_FETCHING = FALSE,\
	BB_DOG_CARRY_ITEM = null,\
	BB_DOG_THROW_LISTENERS = list(),\
	BB_DOG_THROWN_ITEMS = list(),\
	BB_DOG_FETCH_TARGET_IGNORE = list(),\
	BB_DOG_FETCH_TARGET = null,\
	BB_DOG_FETCH_THROWER = null,\
	BB_DOG_DELIVERING = FALSE)


/datum/ai_controller/dog/TryPossessPawn(atom/new_pawn)
	if(!isliving(new_pawn))
		return AI_CONTROLLER_INCOMPATIBLE

	return ..() //Run parent at end

/datum/ai_controller/dog/UnpossessPawn(destroy)
	UnregisterSignal(pawn, list(COMSIG_PARENT_ATTACKBY, COMSIG_ATOM_ATTACK_HAND, COMSIG_ATOM_ATTACK_PAW, COMSIG_ATOM_BULLET_ACT, COMSIG_ATOM_HITBY, COMSIG_MOVABLE_CROSSED, COMSIG_LIVING_START_PULL,\
	COMSIG_LIVING_TRY_SYRINGE, COMSIG_ATOM_HULK_ATTACK, COMSIG_CARBON_CUFF_ATTEMPTED))
	return ..() //Run parent at end

/datum/ai_controller/dog/able_to_run()
	var/mob/living/living_pawn = pawn

	if(IS_DEAD_OR_INCAP(living_pawn))
		return FALSE
	return ..()

/datum/ai_controller/dog/SelectBehaviors(delta_time)
	current_behaviors = list()
	var/mob/living/living_pawn = pawn

	var/list/old_throw_listeners = blackboard[BB_DOG_THROW_LISTENERS]
	var/list/new_throw_listeners = list()
	for(var/i in range(AI_DOG_THROW_LISTEN_RANGE, get_turf(living_pawn)))
		if(!iscarbon(i))
			continue
		var/mob/living/carbon/iter_carbon = i
		if(!(iter_carbon in old_throw_listeners))
			testing("now listening to [iter_carbon]")
			RegisterSignal(iter_carbon, COMSIG_MOB_THROW, .proc/listened_throw)
		new_throw_listeners += iter_carbon
		old_throw_listeners -= iter_carbon // we're still in, so remove them from the drop list

	for(var/i in old_throw_listeners)
		var/mob/living/carbon/lost_listener = i
		testing("no longer listening to [lost_listener]")
		UnregisterSignal(lost_listener, COMSIG_MOB_THROW)
	blackboard[BB_DOG_THROW_LISTENERS] = new_throw_listeners

	if(blackboard[BB_DOG_FETCHING] && blackboard[BB_DOG_FETCH_TARGET] != current_movement_target)
		var/obj/item/fetch_target = blackboard[BB_DOG_FETCH_TARGET]
		current_movement_target = fetch_target
		current_behaviors += GET_AI_BEHAVIOR(/datum/ai_behavior/dog_equip)
	else if(blackboard[BB_DOG_CARRY_ITEM] && blackboard[BB_DOG_FETCH_THROWER] && !blackboard[BB_DOG_DELIVERING])
		var/mob/living/return_target = blackboard[BB_DOG_FETCH_THROWER]
		if(!(return_target in view(7, pawn)))
			blackboard[BB_DOG_FETCH_THROWER] = null
			return
		current_movement_target = return_target
		current_behaviors += GET_AI_BEHAVIOR(/datum/ai_behavior/dog_deliver)
		blackboard[BB_DOG_DELIVERING] = TRUE
		testing("add deliver to [return_target]")

//When idle just kinda fuck around.
/datum/ai_controller/dog/PerformIdleBehavior(delta_time)
	var/mob/living/living_pawn = pawn

	if(DT_PROB(25, delta_time) && (living_pawn.mobility_flags & MOBILITY_MOVE) && isturf(living_pawn.loc) && !living_pawn.pulledby)
		var/move_dir = pick(GLOB.alldirs)
		living_pawn.Move(get_step(living_pawn, move_dir), move_dir)


/datum/ai_controller/dog/proc/listened_throw(mob/living/carbon/carbon_thrower)
	if(blackboard[BB_DOG_FETCHING] || blackboard[BB_DOG_DELIVERING])
		testing("too busy to listen to [carbon_thrower] throw")
		return
	var/obj/item/thrown_thing = carbon_thrower.get_active_held_item()
	testing("listen for [carbon_thrower] threw [thrown_thing]")
	if(!isitem(thrown_thing) || get_dist(carbon_thrower, pawn) > AI_DOG_THROW_LISTEN_RANGE)
		return
	var/list/thrown_ignorelist = blackboard[BB_DOG_FETCH_TARGET_IGNORE]
	if(thrown_thing in thrown_ignorelist)
		testing("already in ignorelist")
		return
	//blackboard[BB_DOG_THROWN_ITEMS] += thrown_thing
	testing("heard [thrown_thing] throw by [carbon_thrower]")
	RegisterSignal(thrown_thing, COMSIG_MOVABLE_THROW_LANDED, .proc/listen_throw_land)

/datum/ai_controller/dog/proc/listen_throw_land(obj/thrown_thing, datum/thrownthing/throwing_datum)
	testing("heard [thrown_thing] land")
	UnregisterSignal(thrown_thing, COMSIG_MOVABLE_THROW_LANDED)
	if(!isitem(thrown_thing) || !isturf(thrown_thing.loc))
		UnregisterSignal(thrown_thing, list(COMSIG_PARENT_QDELETING, COMSIG_MOVABLE_THROW_LANDED))
		return
	if(!(thrown_thing in view(pawn, AI_DOG_THROW_LISTEN_RANGE)))
		UnregisterSignal(thrown_thing, list(COMSIG_PARENT_QDELETING, COMSIG_MOVABLE_THROW_LANDED))
		return
	current_movement_target = thrown_thing
	blackboard[BB_DOG_FETCH_TARGET] = thrown_thing
	blackboard[BB_DOG_FETCH_THROWER] = throwing_datum.thrower
	current_behaviors += GET_AI_BEHAVIOR(/datum/ai_behavior/dog_fetch)
	testing("now fetching [thrown_thing] for [throwing_datum.thrower]")


