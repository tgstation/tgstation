///The cooldown period between last_boomerang_throw and it's methods of implementing a rebound proc.
#define BOOMERANG_REBOUND_INTERVAL (1 SECONDS)
/**
 * If an ojvect is given the boomerang component, it should be thrown back to the thrower after either hitting it's target, or landing on the thrown tile.
 * Thrown objects should be thrown back to the original thrower with this component, a number of tiles defined by boomerang_throw_range.
 */
/datum/component/boomerang
	///How far should the boomerang try to travel to return to the thrower?
	var/boomerang_throw_range = 3
	///"Thrownthing" datum for the most recent throw.
	//var/datum/weakref/thrown_boomerang
	///If this boomerang is thrown, does it re-enable the throwers throw mode?
	var/thrower_easy_catch_enabled = FALSE
	///This cooldown prevents our 2 throwing signals from firing too often based on how we implement those signals within thrown impacts.
	COOLDOWN_DECLARE(last_boomerang_throw)

/datum/component/boomerang/Initialize(boomerang_throw_range, thrower_easy_catch_enabled)
	. = ..()
	if(!isitem(parent)) //Only items support being thrown around like a boomerang, feel free to make this apply to humans later on.
		return COMPONENT_INCOMPATIBLE

	//Assignments
	if(boomerang_throw_range)
		src.boomerang_throw_range = boomerang_throw_range
	if(thrower_easy_catch_enabled)
		src.thrower_easy_catch_enabled = thrower_easy_catch_enabled

/datum/component/boomerang/RegisterWithParent()
	RegisterSignal(parent, COMSIG_MOVABLE_POST_THROW, .proc/prepare_throw) ///Collect data on current thrower and the throwing datum
	RegisterSignal(parent, COMSIG_MOVABLE_THROW_LANDED, .proc/return_missed_throw)
	RegisterSignal(parent, COMSIG_MOVABLE_IMPACT, .proc/return_hit_throw)

/datum/component/boomerang/UnregisterFromParent()
	UnregisterSignal(parent, list(COMSIG_MOVABLE_POST_THROW, COMSIG_MOVABLE_THROW_LANDED, COMSIG_MOVABLE_IMPACT))

/**
 * Proc'd before the thrown is performed in order to gather information regarding each throw as well as handle throw_mode as necessary.
 * * source: Datum src from original signal call.
 * * thrown_thing: The atom that has had the boomerang component added to it. Updates thrown_boomerang.
 * * spin: Carry over from POST_THROW, the speed of rotation on the boomerang when thrown.
 */
/datum/component/boomerang/proc/prepare_throw(datum/source, datum/thrownthing/thrown_thing, spin)
	SIGNAL_HANDLER
	//thrown_boomerang = thrown_thing //Here we update our "thrownthing" datum with that of the original throw for each boomerang. We save it for the return throw.
	if(thrower_easy_catch_enabled && thrown_thing?.thrower)
		if(iscarbon(thrown_thing.thrower))
			var/mob/living/carbon/Carbon = thrown_thing.thrower
			Carbon.throw_mode_on(THROW_MODE_TOGGLE)
	return

/**
 * Proc that triggers when the thrown boomerang hits an object, then rebounds the boomerang.
 * * source: Datum src from original signal call.
 * * hit_atom: The atom that has been hit by the boomerang component.
 * * init_throwing_datum: The thrownthing datum that originally impacted the object, that we use to build the new throwing datum for the rebound.
 */
/datum/component/boomerang/proc/return_hit_throw(datum/source, atom/hit_atom, datum/thrownthing/init_throwing_datum)
	SIGNAL_HANDLER
	if (!COOLDOWN_FINISHED(src, last_boomerang_throw))
		return
	var/obj/item/true_parent = parent
	var/mob/thrown_by = true_parent.thrownby?.resolve()
	aerodynamic_swing(init_throwing_datum)
	if(thrown_by)
		addtimer(CALLBACK(true_parent, /atom/movable.proc/throw_at, thrown_by, boomerang_throw_range, init_throwing_datum.speed, null, TRUE), 1)
		COOLDOWN_START(src, last_boomerang_throw, BOOMERANG_REBOUND_INTERVAL)
	return

/**
 * Proc that triggers when the thrown boomerang does not hit a target, then rebounds the boomerang.
 * * source: Datum src from original signal call.
 * * throwing_datum: The thrownthing datum that originally impacted the object, that we use to build the new throwing datum for the rebound.
 */
/datum/component/boomerang/proc/return_missed_throw(datum/source, datum/thrownthing/throwing_datum)
	SIGNAL_HANDLER
	if(!COOLDOWN_FINISHED(src, last_boomerang_throw))
		return
	var/obj/item/true_parent = parent
	var/mob/thrown_by = true_parent.thrownby?.resolve()
	aerodynamic_swing(throwing_datum)
	if(thrown_by)
		addtimer(CALLBACK(true_parent, /atom/movable.proc/throw_at, thrown_by, boomerang_throw_range, throwing_datum.speed, null, TRUE), 1)
		COOLDOWN_START(src, last_boomerang_throw, BOOMERANG_REBOUND_INTERVAL)
	return

/**
 * Proc that triggers when the thrown boomerang has rebounded, for visual_input.
 * * throwing_datum: The thrownthing datum that originally impacted the object, that we use to build the new throwing datum for the rebound.
 */
/datum/component/boomerang/proc/aerodynamic_swing(datum/thrownthing/throwing_datum)
	var/obj/item/true_parent = parent
	true_parent.visible_message(span_danger("[true_parent] is flying back at [throwing_datum.thrower]!"), \
						span_danger("You see [true_parent] fly back at you!"), \
						span_hear("You hear an aerodynamic woosh!"))
