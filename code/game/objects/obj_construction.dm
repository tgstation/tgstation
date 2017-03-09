/*
	Obj Construction
	by Cyberboss

	- Interface -

	/datum/construction_state - The datum that holds all properties of an object's unfinished states. See the datum definition below

	/obj/var/datum/construction_state/current_construction_state - A reference to an objects current construction_state, null means no construction steps defined

	CONSTRUCTION_BLUEPRINT(<full object path>) - Called to list out the construction steps of the object path given. This is a proc definition for an internal datum.
												Should return a list of construction_state datums. See ai_core.dm or barsigns.dm for good examples

	/obj/proc/OnConstruction(state_id, mob/user, obj/item/used) - Called when a construction step is completed on an object with the new state_id
																If state_id is zero, the object has been fully constructed and can't be deconstructed.
																used is the material object if any used for construction and it will be deleted/deducted from on return

	/obj/proc/OnDeconstruction(state_id, mob/user, obj/item/created, forced) - Called when a deconstruction step is completed on an object with the new state_id. 
															 If state_id is zero, the object has been fully deconstructed
															 created is the item that has been dropped, if any.
															 forced is if the object was aggressively put into this state. If it's true, user MAY be null, created WILL be null.
															 Returning TRUE from this function will cause created to be deleted before it is dropped

	/obj/proc/OnRepair(mob/user, obj/item/used, old_integrity) - Called when an object is repaired (to it's max_integrity unless otherwise modified). It is safe to modify obj_integrity in this function
																used is the material object if any used for repairing and it will be deleted/deducted from on return

	/obj/proc/Construct(mob/user) - Call this after creating an obj to have it appear in it's first construction_state. This will be called automatically if obj/var/always_construct is set to TRUE.
									Calling this after a current_construction_state has been assigned (which this does) has no effect

	/obj/proc/ConstructionChecks(state_started_id, constructing, obj/item, mob/user, skip) - Called in the do_after of a construction step. Must check the base. Returning FALSE will cancel the step.
																							Setting skip to TRUE for parent calls requests that no further checks other than the base be made. 
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
	var/required_type_to_repair	//null type does NOT mean hand here

	var/required_amount_to_construct
	var/required_amount_to_repair

	var/construction_delay      //number multiplied by toolspeed, hands have a pseudo-toolspeed of 1
	var/deconstruction_delay	//note if these are zero, the action will happen instantly and the messages should reflect that
	var/repair_delay

	var/construction_message    //message displayed in the format user.visible_message("[user] [message]", "You [message]")
	var/deconstruction_message
	var/repair_message	//this one defaults to "repairing"

	var/construction_sound	//Sound played once construction step is complete, defaults to the toolsound
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

/datum/construction_state/first	//this should only contain construction parameters
	//reaching this state deletes the object
	required_type_to_deconstruct = NO_DECONSTRUCT

/datum/construction_state/last	//this should only contain deconstruction parameters
	required_type_to_construct = NO_DECONSTRUCT

/datum/construction_state/proc/OnLeft(obj/parent, mob/user, obj/item/tool, constructed, forced)
	var/datum/construction_state/next = constructed ? next_state : prev_state
	var/id
	var/obj/loot
	if(next)
		loot = next.OnReached(parent, user, constructed)	//let the next state know
		id = next.id	//id cached for next step
	else
		id = 0	//unrecoverable step (destroyed/locked in)
		parent.current_construction_state = null

	if(constructed)
		if(construction_sound)
			playsound(parent, construction_sound, CONSTRUCTION_VOLUME, TRUE)
		if(!required_amount_to_construct)
			tool = null
		parent.OnConstruction(id, user, tool)	//run event
		var/obj/item/stack/S = tool
		if(istype(S))
			S.use(required_amount_to_construct)
		else
			qdel(tool)
	else
		if(!forced && deconstruction_sound)	//forced implys hitsounds and stuff
			playsound(parent, deconstruction_sound, CONSTRUCTION_VOLUME, TRUE)

		if((parent.OnDeconstruction(id, user, forced, (loot && !forced) ? loot : null) || forced) && loot)	//no loot for vandals or if we're told not to
			qdel(loot)
		
		if(!id)
			qdel(parent)	//deconstructed fully

/datum/construction_state/proc/DamageDeconstruct(obj/parent)	//called by obj_break
	if(prev_state && prev_state.damage_reachable)
		OnLeft(parent, usr, null, FALSE, TRUE)

/datum/construction_state/proc/OnReached(obj/parent, mob/user, constructed)
	parent.current_construction_state = src	//moving on

	if(!isnull(anchored))
		parent.anchored = anchored

	if(icon)
		parent.icon = icon

	if(icon_state)
		parent.icon_state = icon_state

	if(!constructed && damage_reachable)
		var/cached_max_integrity = max_integrity
		var/cached_failure_integrity = failure_integrity	//modify damage additively
		if(cached_max_integrity)
			parent.max_integrity = cached_max_integrity
			parent.obj_integrity = min(parent.obj_integrity, cached_max_integrity)
		if(cached_failure_integrity)
			parent.integrity_failure = cached_failure_integrity

	else if(max_integrity || failure_integrity)	//modify damage by percentage
		parent.modify_max_integrity(max_integrity ? max_integrity : parent.max_integrity, FALSE, new_failure_integrity = failure_integrity)

	if(!constructed && required_amount_to_construct)	//spawn loot
		if(ispath(required_type_to_construct, /obj/item/stack))
			. = new required_type_to_construct(get_turf(parent), required_amount_to_construct)
		else
			. = new required_type_to_construct(get_turf(parent))
		parent.transfer_fingerprints_to(.)

/datum/construction_state/last/OnReached(obj/parent, mob/user, constructed)
	if(!constructed)
		stack_trace("Very bad param")
	//return to object defaults
	parent.current_construction_state = src
	parent.anchored = initial(parent.anchored)
	parent.icon_state = initial(parent.icon_state)
	parent.modify_max_integrity(initial(parent.max_integrity), TRUE, new_failure_integrity = initial(parent.integrity_failure))

/datum/construction_blueprint
	var/owner_type

/datum/construction_blueprint/proc/GetBlueprint()
	return list()

//See __HELPERS/game.dm for CONSTRUCTION_BLUEPRINT macro

/obj/proc/SetupConstruction()
	var/list/bp_cache = SSatoms.blueprints_cache
	var/list/our_steps = bp_cache[type]
	if(isnull(our_steps))
		our_steps = list()
		if(construction_blueprint)
			var/datum/construction_blueprint/BP = new construction_blueprint
			var/temp
			if(BP.owner_type == type)
				temp = BP.GetBlueprint()	//get steps for the first time
			if(!islist(temp))
				WARNING("Invalid construction_blueprint for [type]!")
				temp = -1
			if(temp != -1)
				LinkConstructionSteps(temp)	//assign ids and stitch the linked list together
				if(ValidateConstructionSteps(temp))
					our_steps = temp
		bp_cache[type] = our_steps	//cache it
	if(our_steps.len)
		var/stepslength = our_steps.len
		current_construction_state = our_steps[stepslength]	//start fully constructed by default
	return our_steps

/proc/LinkConstructionSteps(list/steps)
	var/offset = 0
	for(var/I in 1 to steps.len)
		var/datum/construction_state/curr_step = steps[I]
		if(I != 1)
			var/datum/construction_state/prev_step = steps[I - 1]
			prev_step.next_state = curr_step
			curr_step.prev_state = prev_step
		if(istype(curr_step, /datum/construction_state/first))
			offset = 1	//entering the first state counts as full deconstruction
		curr_step.id = I - offset

//use this proc to make sure there's nothing impossible with the construction chain
//called after InitConstruction
//trust no coder, especially that Cyberboss guy
/obj/proc/ValidateConstructionSteps(cached_construction_steps)
	. = TRUE
	if(length(cached_construction_steps))
		var/datum/construction_state/current_step = cached_construction_steps[1]
		if(!istype(current_step))
			WARNING("Construction Error: [type]: Found non construction state in list: [current_step]")
			return FALSE
		var/last_max_integrity = current_step.max_integrity ? current_step.max_integrity : max_integrity
		var/last_failure_integrity = current_step.failure_integrity ? current_step.failure_integrity : integrity_failure
		current_step = current_step.next_state
		if(!current_step)
			WARNING("Construction Error: [type]: Only one construction state")
			return FALSE
		var/last_found = FALSE
		while(current_step)
			if(!istype(current_step))
				WARNING("Construction Error: [type]: Found non construction state in list: [current_step]")
				return FALSE
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
			
			if(current_step.required_type_to_repair)
				if(ispath(current_step.required_type_to_repair, /obj/item/stack))
					if(!current_step.required_amount_to_repair)
						WARNING(error +"No amount set for material repairs")
						. = FALSE
				else if(current_step.required_amount_to_repair > 1)
					WARNING(error + "Invalid material amount for non stack repairs")
					. = FALSE
				if(!ispath(current_step.required_type_to_repair, /obj/item))
					WARNING(error +"Invalid /obj/item type specified for repairs: '[current_step.required_type_to_construct]'")
					. = FALSE
			
			if(current_step.required_type_to_deconstruct && !ispath(current_step.required_type_to_deconstruct, /obj/item))
				WARNING("Invalid /obj/item type specified for deconstruction: '[current_step.required_type_to_deconstruct]'")
				. = FALSE
			current_step = current_step.next_state
	else
		WARNING("Construction Error: InitConstruction for [type] defined but no steps were added")
		. = FALSE

//construction events
/obj/proc/OnConstruction(state_id, mob/user, obj/item/used)

/obj/proc/OnDeconstruction(state_id, mob/user, obj/item/created)

/obj/proc/OnRepair(mob/user, obj/item/used, old_integrity)

//called after Initialize if the obj was constructed from scratch
/obj/proc/Construct(mob/user)
	if(current_construction_state)
		return
	var/list/cached_construction_steps = SSatoms.blueprints_cache[type]
	if(cached_construction_steps.len)
		var/datum/construction_state/first_step = cached_construction_steps[1]
		if(first_step.type == /datum/construction_state/first)
			first_step = first_step.next_state
		if(first_step)
			first_step.OnReached(src, user, TRUE)
	setDir(user.dir)
	add_fingerprint(user)
	feedback_add_details("obj_construction","[type]")

/obj/proc/Repair(mob/user, obj/item/used, amount)
	var/old_integrity = obj_integrity
	var/max_integ = max_integrity
	if(!amount)
		amount = max_integ - old_integrity
	obj_integrity += amount
	OnRepair(user, used, old_integrity)
	var/ratr = current_construction_state.required_amount_to_repair
	if(ratr)
		var/obj/item/stack/S = used
		if(istype(S))
			S.use(ratr)
		else
			qdel(used)

/obj/examine(mob/user)
	..()
	if(current_construction_state && current_construction_state.examine_message)
		user << current_construction_state.examine_message

/obj/attack_hand(mob/user)	//obj/item doesn't call this so we're fine
	if(user.a_intent == INTENT_HELP)
		HandConstruction(user)
	else
		return ..()

/obj/item/attack_self(mob/user)
	. = ..()
	HandConstruction(user)

//construct by hand
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
		
		if(!ConstructionChecks(ccs.id, constructed, null, user, FALSE))
			return

			
		if(wait)			
			user.visible_message("<span class='notice'>You begin [message] \the [src].</span>",
									"<span class='notice'>[user] begins [message] \the [src].</span>")
			if(!do_after(user, wait, target = src,, extra_checks = CALLBACK(src, .proc/ConstructionChecks, ccs.id, constructed, null, user, FALSE)))
				return

		user.visible_message("<span class='notice'>You [wait ? "finish [message]" : message] \the [src].</span>",
								"<span class='notice'>[user] [wait ? "finishes [message]" : message] \the [src].</span>")
		ccs.OnLeft(src, user, null, constructed, FALSE)

//construct by tool if possible
/obj/attackby(obj/item/I, mob/living/user)
	var/datum/construction_state/ccs = current_construction_state	
	if(ccs && user.a_intent == INTENT_HELP)
		if(src in user.construction_tasks)
			return

		var/constructed
		var/repairing
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
		else if(istype(I, ccs.required_type_to_repair))
			if(obj_integrity == max_integrity)
				user << "<span class='notice'>\The src isn't damaged!</span>"
				return
			repairing = TRUE
			wait = ccs.repair_delay
			message = ccs.repair_message
			if(!message)
				message = "repairing"
		else
			return ..()

		//snowflakish stuff here
		if(istype(I, /obj/item/weapon/weldingtool))
			var/obj/item/weapon/weldingtool/WT = I
			if(!WT.isOn())
				user << "<span class='warning'>The welder must be on for this task!</span>"
				return
			else
				WT.remove_fuel(M = user)

		var/obj/item/stack/Mats = I
		if(istype(Mats))
			var/check_against = repairing ? ccs.required_amount_to_repair : ccs.required_type_to_construct
			if(Mats.amount < check_against)
				user << "<span class='warning'>You need [ccs.required_amount_to_construct] or more of [Mats] first!</span>"
				return

		LAZYADD(user.construction_tasks, src)	//prevent repeats
		var/cont = ConstructionChecks(ccs.id, constructed, I, user, FALSE)
		if(!cont)
			return

		if(I.usesound)
			playsound(src, I.usesound, CONSTRUCTION_VOLUME, TRUE)	

		if(wait)
			user.visible_message("<span class='notice'>You begin [message] \the [src].</span>",
									"<span class='notice'>[user] begins [message] \the [src].</span>")
			//Checks will always run because we've verified do_after will last at least 1 tick
			cont = do_after(user, wait * I.toolspeed, target = src, extra_checks = CALLBACK(src, .proc/ConstructionChecks, ccs.id, constructed, I, user, FALSE))
		LAZYREMOVE(user.construction_tasks, src)

		if(cont)
			user.visible_message("<span class='notice'>You [wait ? "finish [message]" : message] \the [src].</span>",
									"<span class='notice'>[user] [wait ? "finishes [message]" : message] \the [src].</span>")
			if(!repairing)
				ccs.OnLeft(src, user, I, constructed, FALSE)
			else
				Repair(user, I)
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
		user << "<span class='warning'>You no longer have enough [Mats]!</span>"
		return FALSE
	return TRUE