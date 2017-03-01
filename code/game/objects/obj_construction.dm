/*
	Obj Construction
	by Cyberboss

	- Interface -

	/datum/construction_state - The datum that holds all properties of an object's unfinished state, these datums are stored in a static list keyed by type. See the datum definition below

	/datum/construction_state/first/New(obj/parent, material_type, material_amount)	- Specify the materials to be dropped after full deconstruction, must be declared first, if at all, in InitConstruction

	/datum/construction_state/last/New(obj/parent, required_type_to_deconstruct, deconstruction_delay, deconstruction_message) - Specify the reqiuired tools and message for the first deconstruction step
																																	Must be declared last, if at all, in InitConstruction

	/obj/var/current_construction_state - A reference to an objects current construction_state, null means fully constructed and can't be deconstructed

	/obj/proc/InitConstruction - Called when the first instance of an object type is initialized to set up it's construction steps. Should not call the base

	/obj/proc/OnConstruction(state_id, mob/user) - Called when a construction step is completed on an object with the new state_id. If state_id is zero, the object has been fully constructed.

	/obj/proc/OnDeconstruction(state_id, mob/user, forced) - Called when a deconstruction step is completed on an object with the new state_id. If state_id is zero, the object has been fully deconstructed
															 forced is if the object was aggressively put into this state. If it's true, user may be null

	/obj/proc/Construct(mob/user) - Call this after creating an obj to have it appear in it's first construction_state

	/obj/proc/ConstructionChecks(datum/construction_state/start_state, obj/item, mob/user, skip) - Called in the do_after of a construction step. Must check the base. Returning FALSE will cancel the step.
																									Setting skip to TRUE requests that no further checks other than the base be made

	Psuedo Example:
		/obj/chair
			icon = 'chair.dmi'
			icon_state = 'built'
			max_integrity = 500
			obj_integrity = 500
			failure_integrity = 200
			anchored = TRUE

		/obj/chair/InitConstruction()	//init the construction steps
			new /datum/construction_state/first(src, /obj/item/wood, 2)
			new /datum/construction_state(src,\
				required_type_to_construct = /obj/item/screwdriver,
				required_type_to_deconstruct = /obj/item/crowbar,
				construction_delay = 4,\
				deconstruction_delay = 4,\
				construction_message = "screwing the legs to",\
				deconstruction_message = "prying the wood from"\
				examine_message = "The legs are unscrewed",\
				icon_state = "unscrewed-legs",\
				max_integrity = 200,\
				failure_integrity = 100,\
				anchored = FALSE,\
				damage_reachable = TRUE\
			)
			new /datum/construction_state/last(src,\
				required_type_to_deconstruct = /obj/item/screwdriver,\
				deconstruction_delay = 4,\
				deconstruction_message = "unscrewing the legs from"\
			)
		
		/obj/chair/OnDeconstruction(state_id, mob/user, forced)
			if(forced)
				user << "You break \the [src] apart"
			if(!state_id)
				qdel(src)
		
		/obj/item/wood/attack_self()	// build the base of the chair
			var/obj/C = new /obj/chair(get_turf(src))
			C.Construct()
		
		
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

	var/construction_delay      //number multiplied by toolspeed, hands and materials have a pseudo-toolspeed of 1
	var/deconstruction_delay

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

/datum/construction_state/first/New(obj/parent, material_type, material_amount)
	..(parent, material_type, material_amount)

/datum/construction_state/last/New(obj/parent, required_type_to_deconstruct, deconstruction_delay = 0, deconstruction_message)
	..(parent, -1 /*don't want to construct with attack_hand/self*/, null, required_type_to_deconstruct, 0, deconstruction_delay, null, deconstruction_message)

/datum/construction_state/New(obj/parent, required_type_to_construct, required_amount_to_construct, required_type_to_deconstruct, construction_delay = 0, deconstruction_delay = 0,\
 								construction_message, deconstruction_message, construction_sound, deconstruction_sound, examine_message, icon, icon_state, max_integrity, failure_integrity,\
								anchored, damage_reachable = FALSE)
	src.required_type_to_construct = required_type_to_construct
	src.required_amount_to_construct = required_amount_to_construct
	src.required_type_to_deconstruct = required_type_to_deconstruct
	src.construction_delay = construction_delay
	src.deconstruction_delay = deconstruction_delay
	src.construction_message = construction_message
	src.deconstruction_message = deconstruction_message
	src.construction_sound = construction_sound
	src.deconstruction_sound = deconstruction_sound
	src.examine_message = examine_message
	src.icon = icon
	src.icon_state = icon_state
	src.max_integrity = max_integrity
	src.failure_integrity = failure_integrity
	src.damage_reachable = damage_reachable
	src.anchored = anchored
	parent.AddConstructionStep(src)

/datum/construction_state/proc/OnLeft(obj/parent, mob/user, constructed)
	if(!constructed && (parent.flags & NODECONSTRUCT))
		return

	var/datum/construction_state/next = constructed ? next_state : prev_state
	var/id
	if(next)
		next.OnReached(parent, user, constructed)
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
		parent.OnDeconstruction(id, user)

/datum/construction_state/proc/OnReached(obj/parent, mob/user, constructed)
	if(!constructed && (parent.flags & NODECONSTRUCT))
		return
	
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
			new required_type_to_construct(get_turf(parent), required_amount_to_construct)
		else
			new required_type_to_construct(get_turf(parent))

/datum/construction_state/last/OnReached(obj/parent, mob/user, constructed)
	if(!constructed)
		stack_trace("Very bad param")
	parent.anchored = initial(parent.anchored)
	parent.icon_state = initial(parent.icon_state)
	parent.modify_max_integrity(initial(parent.max_integrity), TRUE, new_failure_integrity = initial(parent.integrity_failure))

/obj/proc/InitConstruction()
	construction_steps[type] = 0	//null op, no construction steps
	return -1
	
/obj/proc/AddConstructionStep(datum/construction_state/step)
	var/list/our_steps = construction_steps[type]
	if(our_steps.len)
		var/datum/construction_state/prev_step = our_steps[our_steps.len]
		prev_step.next_state = step
		step.prev_state = prev_step
	our_steps += step

//use this proc to make sure there's nothing impossible with the construction chain
//called after InitConstruction
//trust no coder, especially that Cyberboss guy
/obj/proc/ValidateConstructionSteps()
	var/cached_construction_steps = construction_steps[type]
	if(length(cached_construction_steps))
		var/datum/construction_state/current_step = cached_construction_steps[1]
		var/last_max_integrity = current_step.max_integrity ? current_step.max_integrity : max_integrity
		var/last_failure_integrity = current_step.failure_integrity ? current_step.failure_integrity : integrity_failure
		current_step = current_step.next_state
		while(current_step)
			var/error = "Construction Error: [type] step [current_step.id]: "
			if(current_step.max_integrity && current_step.max_integrity < last_max_integrity)
				WARNING(error + "Max integrity lowered after construction")
			if(current_step.failure_integrity && current_step.failure_integrity < last_failure_integrity)
				WARNING(error + "Failure integrity lowered after construction")
			if(current_step.required_type_to_construct)
				if(ispath(current_step.required_type_to_construct, /obj/item/stack))
					if(!current_step.required_amount_to_construct)
						WARNING(error +"No amount set for material construction")
				else if(current_step.required_amount_to_construct > 1)
						WARNING(error + "Invalid material amount for non stack construction")
				if(!ispath(current_step.required_type_to_construct, /obj/item))
					WARNING(error +"Invalid /obj/item type specified for construction: '[current_step.required_type_to_construct]'")
			else if(!current_step.required_type_to_deconstruct)
				WARNING(error + "Hand values for both construction and deconstruction types")
			
			if(current_step.required_type_to_deconstruct && !ispath(current_step.required_type_to_deconstruct, /obj/item))
				WARNING("Invalid /obj/item type specified for deconstruction: '[current_step.required_type_to_deconstruct]'")
	else
		WARNING("Construction Error: InitConstruction for [type] defined but no steps were added")
		construction_steps[type] = 0

/obj/proc/OnConstruction(state_id, mob/user)

/obj/proc/OnDeconstruction(state_id, mob/user, forced)
	if(!state_id)
		qdel(src)

/obj/proc/Construct(mob/user)
	var/cached_construction_steps = construction_steps[type]
	if(cached_construction_steps)
		var/datum/construction_state/first_step = cached_construction_steps[1]
		if(first_step.type == /datum/construction_state/first)
			first_step = first_step.next_state
		if(first_step)
			first_step.OnReached(src, user, TRUE)
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
			
		user << "<span class='notice'>You begin [message] \the [src]...</span>"
		if(do_after(user, wait, target = src))
			user << "<span class='notice'>You finish [message] \the [src].</span>"
			ccs.OnLeft(src, user, constructed)

/obj/attackby(obj/item/I, mob/living/user)
	var/datum/construction_state/ccs = current_construction_state	
	if(ccs)
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

		var/obj/item/stack/Mats = I
		if(istype(Mats) && Mats.amount < ccs.required_amount_to_construct)
			user << "<span class='warning'>You don't have enough [Mats]!</span>"
			return

		playsound(src, I.usesound, 100, 1)	
		
		user << "<span class='notice'>You begin [message] \the [src].</span>"
		if(wait && do_after(user, wait * I.toolspeed, target = src, extra_checks = CALLBACK(src, .proc/ConstructionChecks, ccs, I, user)))
			if(istype(Mats) && !Mats.use(ccs.required_amount_to_construct))
				user << "<span class='warning'>You no longer have enough [Mats]!</span>"
				return
			else
				qdel(Mats)
			user << "<span class='notice'>You finish [message] \the [src].</span>"
			ccs.OnLeft(src, user, constructed)
	else
		return ..()

/obj/proc/ConstructionChecks(datum/construction_state/state_started, obj/item/I, mob/user, skip) 
	if(current_construction_state != state_started)
		user << "<span class='warning'>You were interrupted!</span>"
		return FALSE
	
	var/obj/item/stack/Mats = I
	if(istype(Mats) &&  Mats.amount < state_started.required_amount_to_construct)
		user << "<span class='warning'>You no longer have enough [Mats]!</span>"
		return FALSE
	return TRUE