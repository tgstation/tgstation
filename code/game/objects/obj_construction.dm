/*
	Obj Construction
	by Cyberboss

	- Interface -

	/datum/construction_state - The datum that holds all properties of an object's unfinished state, these datums are stored in a static list keyed by type. See the datum definition below

	/datum/construction_state/first/New(obj/parent, material_type, material_amount)	- Specify the materials to be dropped after full deconstruction, must be declared first in InitConstruction if at all

	/datum/construction_state/last/New(obj/parent, required_type_to_deconstruct, deconstruction_delay, deconstruction_message) - Specify the reqiuired tools and message for the first deconstruction step
																																	Must be declared last in InitConstruction

	/obj/var/current_construction_state - A reference to an objects current construction_state, null means fully constructed and can't be deconstructed

	/obj/proc/InitConstruction - Called when the first instance of an object type is initialized to set up it's construction steps. Should not call the base

	/obj/proc/OnConstruction(state_id, mob/user) - Called when a construction step is completed on an object with the new state_id. If state_id is zero, the object has been fully constructed.

	/obj/proc/OnDeconstruction(state_id, mob/user, forced) - Called when a deconstruction step is completed on an object with the new state_id. If state_id is zero, the object has been fully deconstructed
															 forced is if the object was aggressively put into this state. If it's true, user may be null. Returning TRUE from this function will prevent loot
															 from being spawned by the upcoming construction state

	/obj/proc/Construct(mob/user) - Call this after creating an obj to have it appear in it's first construction_state

	/obj/proc/ConstructionChecks(state_started_id, constructing, obj/item, mob/user, skip) - Called in the do_after of a construction step. Must check the base. Returning FALSE will cancel the step.
																							Setting skip to TRUE requests that no further checks other than the base be made. This is not used for hand construction

	See ai_core.dm for a good example		
		
*/

/datum/construction_state
	var/id  //states are sequenced from deconstructed -> 1 -> 2 -> 3 -> fully constructed

	/*
		These can be:
			null for requiring attack_self/attack_hand on help intent
			An /obj/item path for a required tool/material

		If it's a consumed material, required_amount_to_construct is the amount of that material required to reach the next state
		null amounts act as a tool. No more than 1 can be specified if the material is not a stack
		Used materials will be extracted when the object is deconstructed to this state or if the user attack_hand's on help intent
	*/
	var/required_type_to_construct
	var/required_type_to_deconstruct

	var/required_amount_to_construct

	var/construction_delay      //number multiplied by toolspeed, hands have a pseudo-toolspeed of 1
	var/deconstruction_delay	//note if these are zero, the action will happen instantly and the messages should reflect that

	var/construction_message    //message displayed in the format user.visible_message("[user] [message]", "You [message]")
	var/deconstruction_message

	var/construction_sound	//Sound played once construction step is complete
	var/deconstruction_sound

	var/examine_message	//null values do not adjust these
	var/icon
	var/icon_state
	var/anchored

	var/max_integrity   //null values do not adjust these, these should always be smaller for earlier construction steps
	var/failure_integrity

	var/damage_reachable    //if the object can be deconstructed into this state from the next through breaking the object
							//note that if this is TRUE, modify_max_integrity will not be used to change the object's max_integrity
							//when constructed from or deconstructed into this state. The change will be purely additive
							//Having this be TRUE also means that OnConstruction and OnDeconstruction may have null user parameters

	var/datum/construction_state/next_state		//the state that will be next once constructed
	var/datum/construction_state/prev_state		//the state that will be next once deconstructed

/datum/construction_state/first	//this should only contain required_type_to_construct and required_amount_to_construct for the final materials

/datum/construction_state/last
	required_type_to_construct = -1

/datum/construction_state/proc/OnLeft(obj/parent, mob/user, constructed)
	if(!constructed && (parent.flags & NODECONSTRUCT))
		return

	var/datum/construction_state/next = constructed ? next_state : prev_state
	var/id
	var/obj/loot
	if(next)
		loot = next.OnReached(parent, user, constructed)
		id = next.id
	else
		id = 0

	if(constructed)
		if(construction_sound)
			playsound(parent, construction_sound, 100, TRUE)
		parent.OnConstruction(id, user)
	else
		if(deconstruction_sound)
			playsound(parent, deconstruction_sound, 100, TRUE)
		if(parent.OnDeconstruction(id, user) && loot)
			qdel(loot)

/datum/construction_state/proc/OnReached(obj/parent, mob/user, constructed)
	if(!constructed && (parent.flags & NODECONSTRUCT))
		return
	parent.current_construction_state = src
	
	if(!isnull(anchored))
		parent.anchored = anchored

	if(icon)
		parent.icon = icon

	if(icon_state)
		parent.icon_state = icon_state

	if(!constructed && damage_reachable)
		var/cached_max_integrity = max_integrity
		var/cached_failure_integrity = failure_integrity
		if(cached_max_integrity)
			parent.max_integrity = cached_max_integrity
			parent.obj_integrity = min(parent.obj_integrity, cached_max_integrity)
		if(cached_failure_integrity)
			parent.integrity_failure = cached_failure_integrity

	else if(max_integrity || failure_integrity)
		parent.modify_max_integrity(max_integrity ? max_integrity : parent.max_integrity, FALSE, new_failure_integrity = failure_integrity)

	if(!constructed && required_amount_to_construct)
		if(ispath(required_type_to_construct, /obj/item/stack))
			. = new required_type_to_construct(parent.loc, required_amount_to_construct)
		else
			. = new required_type_to_construct(parent.loc)
		parent.transfer_fingerprints_to(.)

/datum/construction_state/first/OnReached(obj/parent, mob/user, constructed)
	. = ..()
	qdel(parent)

/datum/construction_state/last/OnReached(obj/parent, mob/user, constructed)
	if(!constructed)
		stack_trace("Very bad param")
	parent.current_construction_state = src
	parent.anchored = initial(parent.anchored)
	parent.icon_state = initial(parent.icon_state)
	parent.modify_max_integrity(initial(parent.max_integrity), TRUE, new_failure_integrity = initial(parent.integrity_failure))

/obj/proc/SetupConstruction()
	if(isnull(construction_steps[type]))
		var/Result = InitConstruction()
		if(Result != -1)
			LinkConstructionSteps(Result)
			if(!ValidateConstructionSteps(Result))
				Result = list()
		else
			Result = list()
		construction_steps[type] = Result

/obj/proc/InitConstruction() //null op, no construction steps
	//derivatives return a proper list
	return -1
	
/proc/LinkConstructionSteps(list/steps)
	for(var/I in 1 to steps.len)
		var/datum/construction_state/curr_step = steps[I]
		if(I != 1)
			var/datum/construction_state/prev_step = steps[I - 1]
			prev_step.next_state = curr_step
			curr_step.prev_state = prev_step
		curr_step.id = I - 1

//use this proc to make sure there's nothing impossible with the construction chain
//called after InitConstruction
//trust no coder, especially that Cyberboss guy
/obj/proc/ValidateConstructionSteps(cached_construction_steps)
	. = TRUE
	if(length(cached_construction_steps))
		var/datum/construction_state/current_step = cached_construction_steps[1]
		var/last_max_integrity = current_step.max_integrity ? current_step.max_integrity : max_integrity
		var/last_failure_integrity = current_step.failure_integrity ? current_step.failure_integrity : integrity_failure
		current_step = current_step.next_state
		var/last_found = FALSE
		while(current_step)
			var/error = "Construction Error: [type] step [current_step.id]: "
			if(istype(current_step, /datum/construction_state/first))
				WARNING(error + "construction_state/first not first")
				. = FALSE
			if(last_found)
				WARNING(error + "construction_state/last not last")
				last_found = FALSE
				. = FALSE
			if(istype(current_step, /datum/construction_state/last))
				last_found = TRUE
			if(current_step.max_integrity && current_step.max_integrity < last_max_integrity)
				WARNING(error + "Max integrity lowered after construction")
				. = FALSE
			if(current_step.failure_integrity && current_step.failure_integrity < last_failure_integrity)
				WARNING(error + "Failure integrity lowered after construction")
				. = FALSE
			if(current_step.required_type_to_construct)
				if(ispath(current_step.required_type_to_construct, /obj/item/stack))
					if(!current_step.required_amount_to_construct)
						WARNING(error +"No amount set for material construction")
						. = FALSE
				else if(current_step.required_amount_to_construct > 1)
					WARNING(error + "Invalid material amount for non stack construction")
					. = FALSE
				if(!ispath(current_step.required_type_to_construct, /obj/item) && !istype(current_step, /datum/construction_state/last))
					WARNING(error +"Invalid /obj/item type specified for construction: '[current_step.required_type_to_construct]'")
					. = FALSE
			else if(!current_step.required_type_to_deconstruct)
				WARNING(error + "Hand values for both construction and deconstruction types")
				. = FALSE
			
			if(current_step.required_type_to_deconstruct && !ispath(current_step.required_type_to_deconstruct, /obj/item))
				WARNING("Invalid /obj/item type specified for deconstruction: '[current_step.required_type_to_deconstruct]'")
				. = FALSE
			current_step = current_step.next_state
	else
		WARNING("Construction Error: InitConstruction for [type] defined but no steps were added")
		. = FALSE

/obj/proc/OnConstruction(state_id, mob/user)

/obj/proc/OnDeconstruction(state_id, mob/user, forced)

/obj/proc/Construct(mob/user)
	var/list/cached_construction_steps = construction_steps[type]
	if(cached_construction_steps.len)
		var/datum/construction_state/first_step = cached_construction_steps[1]
		if(first_step.type == /datum/construction_state/first)
			first_step = first_step.next_state
		if(first_step)
			first_step.OnReached(src, user, TRUE)
		current_construction_state = first_step
	setDir(user.dir)
	add_fingerprint(user)
	//nothing to do otherwise

/obj/examine(mob/user)
	..()
	if(current_construction_state && current_construction_state.examine_message)
		user << current_construction_state.examine_message

/obj/attack_hand(mob/user)	//obj/item doesn't call this so we're fine
	HandConstruction(user)

/obj/item/attack_self(mob/user)
	. = ..()
	HandConstruction(user)

/obj/proc/HandConstruction(mob/user)
	var/datum/construction_state/ccs = current_construction_state	
	if(ccs)
		var/constructed
		var/wait
		var/message
		if(!ccs.required_type_to_construct)
			constructed = TRUE
			wait = ccs.construction_delay
			message = ccs.construction_message
		else if(!ccs.required_type_to_deconstruct)
			constructed = FALSE
			wait = ccs.deconstruction_delay
			message = ccs.deconstruction_message
		else
			return
			
		if(wait)
			user << "<span class='notice'>You begin [message] \the [src]...</span>"
			if(!do_after(user, wait, target = src))
				return
		user << "<span class='notice'>You [wait ? "finish [message]" : message] \the [src].</span>"
		ccs.OnLeft(src, user, constructed)

/obj/attackby(obj/item/I, mob/living/user)
	var/datum/construction_state/ccs = current_construction_state	
	if(ccs)
		if(src in user.construction_tasks)
			return

		var/constructed
		var/wait
		var/message
		if(istype(I, ccs.required_type_to_construct))
			constructed = TRUE
			wait = ccs.construction_delay
			message = ccs.construction_message
		else if(istype(I, ccs.required_type_to_deconstruct))
			constructed = FALSE
			wait = ccs.deconstruction_delay
			message = ccs.deconstruction_message
		else
			return ..()

		//snowflake stuff here
		if(istype(I, /obj/item/weapon/weldingtool))
			var/obj/item/weapon/weldingtool/WT = I
			if(!WT.isOn())
				user << "<span class='warning'>The welder must be on for this task!</span>"
				return
			else
				WT.remove_fuel(M = user)

		var/obj/item/stack/Mats = I
		if(istype(Mats) && Mats.amount < ccs.required_amount_to_construct)
			user << "<span class='warning'>You need [ccs.required_amount_to_construct] or more of [Mats] first!</span>"
			return


		var/cont
		LAZYADD(user.construction_tasks, src)
		if(wait)
			if(I.usesound)
				playsound(src, I.usesound, 100, TRUE)	
			user << "<span class='notice'>You begin [message] \the [src].</span>"
			cont = do_after(user, wait * I.toolspeed, target = src, extra_checks = CALLBACK(src, .proc/ConstructionChecks, ccs.id, constructed, I, user, FALSE))
		else
			cont = ConstructionChecks(ccs.id, constructed, I, user, FALSE)
			if(cont && I.usesound)
				playsound(src, I.usesound, 100, TRUE)	
		LAZYREMOVE(user.construction_tasks, src)

		if(cont)
			if(constructed && ccs.required_amount_to_construct)
				if(istype(Mats))
					if(!Mats.use(ccs.required_amount_to_construct))
						user << "<span class='warning'>You no longer have enough of [Mats]!</span>"
						return
				else
					qdel(Mats)

			user << "<span class='notice'>You [wait ? "finish [message]" : message] \the [src].</span>"
			ccs.OnLeft(src, user, constructed)
	else
		return ..()

/obj/proc/ConstructionChecks(state_started_id, constructing, obj/item/I, mob/user, skip) 
	if(current_construction_state.id != state_started_id)
		user << "<span class='warning'>You were interrupted!</span>"
		return FALSE
	
	var/obj/item/weapon/weldingtool/WT = I
	if(istype(WT) && !WT.isOn())
		user << "<span class='warning'>\The [WT] runs out of fuel!</span>"
		return FALSE
	
	var/obj/item/stack/Mats = I
	if(istype(Mats) && Mats.amount < current_construction_state.required_amount_to_construct)
		user << "<span class='warning'>You no longer have enough of [Mats]!</span>"
		return FALSE
	return TRUE