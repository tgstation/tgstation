// Don't eat off the floor or hold parent object with dirty hands, you'll get sick

/// Time needed for bacteria to infect the parent object
#define FIVE_SECOND_RULE (5 SECONDS)
/// Max number of symptoms on the random disease
#define MAX_DISEASE_SYMPTOMS 2
/// Max strength of the random disease
#define MAX_DISEASE_STRENTH 3

/datum/component/bacteria_carrier
	/// Timer for counting delay before becoming infective
	var/timer_id
	/// Whether it is already infective
	var/infective = FALSE

/datum/component/bacteria_carrier/Initialize(mapload)
	if(!isobj(parent))
		return COMPONENT_INCOMPATIBLE

	RegisterSignal(parent, COMSIG_ATOM_EXAMINE, PROC_REF(examine))
	RegisterSignal(parent, COMSIG_MOVABLE_MOVED, PROC_REF(handle_movement))
	RegisterSignals(parent, list(
		COMSIG_ITEM_DROPPED, //Dropped into the world
		COMSIG_ATOM_EXITED), //Object exits a storage object (tables, boxes, etc)
		PROC_REF(dropped))
	RegisterSignals(parent, list(
		COMSIG_ITEM_PICKUP, //Picked up by mob
		COMSIG_ATOM_ENTERED), //Object enters a storage object (tables, boxes, etc.)
		PROC_REF(picked_up))
	handle_movement()

/datum/component/bacteria_carrier/UnregisterFromParent()
	UnregisterSignal(parent, list(
		COMSIG_ATOM_EXAMINE,
		COMSIG_MOVABLE_MOVED,
		COMSIG_ITEM_DROPPED,
		COMSIG_ATOM_EXITED,
		COMSIG_ITEM_PICKUP,
		COMSIG_ATOM_ENTERED,
	))

/datum/component/bacteria_carrier/Destroy()
	remove_timer()
	return ..()

/datum/component/bacteria_carrier/proc/remove_timer()
	if(!timer_id)
		return
	deltimer(timer_id)
	timer_id = null

/datum/component/bacteria_carrier/proc/handle_movement()
	SIGNAL_HANDLER

	if(infective)
		return

	var/obj/parent_object = parent
	var/turf/open/open_turf = parent_object.loc

	// Is parent on valid open turf?
	if(!istype(open_turf) || islava(open_turf) || isasteroidturf(open_turf))
		remove_timer()
		return

	// Is parent on an elevated structure?
	for(var/atom/movable/content as anything in open_turf.contents)
		if(GLOB.typecache_elevated_structures[content.type])
			remove_timer()
			return

	// Exposed to bacteria, start countdown until becoming infected
	timer_id = addtimer(CALLBACK(src, PROC_REF(infect_parent)), FIVE_SECOND_RULE, TIMER_STOPPABLE | TIMER_UNIQUE)

/datum/component/bacteria_carrier/proc/picked_up()
	SIGNAL_HANDLER
	if(infective)
		return
	remove_timer()

/datum/component/bacteria_carrier/proc/dropped()
	SIGNAL_HANDLER
	if(infective)
		return
	handle_movement()

/datum/component/bacteria_carrier/proc/examine(datum/source, mob/user, list/examine_list)
	SIGNAL_HANDLER
	if(infective)
		examine_list += span_notice("[parent] looks dirty and not safe to consume.")

/datum/component/bacteria_carrier/proc/infect_parent()
	infective = TRUE
	var/datum/disease/advance/random/random_disease = new(max_symptoms = rand(MAX_DISEASE_SYMPTOMS), max_level = rand(MAX_DISEASE_STRENTH))
	random_disease.name = "Unknown"
	parent.AddComponent(/datum/component/infective, list(random_disease), weak = TRUE)

#undef FIVE_SECOND_RULE
#undef MAX_DISEASE_SYMPTOMS
#undef MAX_DISEASE_STRENTH
