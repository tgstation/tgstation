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
	
	var/stash_construction_item	//boolean: instead of deleting an item when it's used for construction, it'll instead be stored in obj/var/construction items
								//only works for non-stack items

	var/construction_delay      //number multiplied by toolspeed, hands have a pseudo-toolspeed of 1
	var/deconstruction_delay	//note if these are zero, the action will happen instantly and the messages should reflect that
	var/repair_delay

	var/construction_message    //message displayed in the format user.visible_message("[user] [message]", "You [message]")
	var/deconstruction_message
	var/repair_message	//this one defaults to "repairing"

	var/construction_sound	//Sound played once construction step is complete, defaults to the toolsound
	var/deconstruction_sound

	var/examine_message	//null values do not adjust these

	var/icon/icon
	var/icon_state	//having both of these be null will trigger calls to update_icon

	var/anchored

	var/max_integrity   //null values do not adjust these, these should always be smaller for earlier construction steps
	var/failure_integrity

	var/damage_reachable    //if the object can be deconstructed into this state from the next through breaking the object
							//note that if this is TRUE, modify_max_integrity will not be used to change the object's max_integrity
							//when constructed from or deconstructed into this state. The change will be purely additive
							//Having this be TRUE also means that OnConstruction and OnDeconstruction may have null user parameters

	var/always_drop_loot	//Always drop required_type_to_construct, even if damaged

	var/datum/construction_state/next_state		//the state that will be next once constructed
	var/datum/construction_state/prev_state		//the state that will be next once deconstructed

/datum/construction_state/first	//this should only contain construction parameters
	//reaching this state deletes the object
	required_type_to_deconstruct = NO_DECONSTRUCT
	always_drop_loot = TRUE

	var/one_per_turf = FALSE
	var/on_floor = FALSE
	var/buildable = TRUE
	var/construct_fully = FALSE

/datum/construction_state/last	//this should only contain deconstruction parameters
	required_type_to_construct = NO_DECONSTRUCT

	var/transformation_type	//If this is set, the object will transform into this and qdel itself
							//when this state is reached. The state before this one should have all
							//the parameters of the initial object or be manually set to a custom state

/datum/construction_state/proc/OnLeft(obj/parent, mob/living/user, obj/item/tool, constructed, forced)
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
		parent.OnConstruction(id, user, tool)	//run event
		if(required_amount_to_construct)
			var/obj/item/stack/S = tool
			if(istype(S))
				S.use(required_amount_to_construct)
			else if(stash_construction_item)
				user.transferItemToLoc(tool, parent)
				parent.SetItemToLeaveConstructionState(parent, tool)
			else
				qdel(tool)
	else
		if(!forced && deconstruction_sound)	//forced implys hitsounds and stuff
			playsound(parent, deconstruction_sound, CONSTRUCTION_VOLUME, TRUE)

		//Explanation for the following shitty inline checks:
		//If there is loot, and we have not been force deconstructed, pass loot as a parameter to OnDeconstruction
		//If OnDeconstruction returns TRUE or we were force deconstructed and there is loot, qdel it. Only if always_drop_loot is FALSE
		if((parent.OnDeconstruction(id, user, (loot && !forced) ? loot : null, forced) || forced) && loot && (!next || next.always_drop_loot))
			qdel(loot)
		else if(user && user.Adjacent(parent))	//adjacency check for telekinetics
			user.put_in_hands(loot)
		else
			loot.forceMove(parent.drop_location())
		
		if(!id)
			qdel(parent)	//deconstructed fully

/datum/construction_state/proc/DamageDeconstruct(obj/parent)	//called by obj_break
	if(prev_state && prev_state.damage_reachable)
		OnLeft(parent, usr, null, FALSE, TRUE)

/datum/construction_state/proc/OnReached(obj/parent, mob/living/user, constructed)
	parent.current_construction_state = src	//moving on

	if(!isnull(anchored))
		parent.anchored = anchored

	if(icon)
		parent.icon = icon
	if(icon_state)
		parent.icon_state = icon_state
	else if(!icon)
		parent.update_icon()

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
		if(stash_construction_item)	//The treasure was inside you all along!
			. = parent.SetItemToLeaveConstructionState(id, null)
		else
			if(ispath(required_type_to_construct, /obj/item/stack))
				. = new required_type_to_construct(null, required_amount_to_construct)
			else
				. = new required_type_to_construct()
		if(.)
			parent.transfer_fingerprints_to(.)

/datum/construction_state/last/New()
	if(transformation_type)
		required_type_to_deconstruct = NO_DECONSTRUCT

/datum/construction_state/last/OnReached(obj/parent, mob/living/user, constructed)
	if(!constructed)
		stack_trace("Very bad param")
	//return to object defaults
	anchored = initial(parent.anchored)
	icon_state = initial(parent.icon_state)
	max_integrity = initial(parent.max_integrity)
	failure_integrity = initial(parent.integrity_failure)
	..()
	var/TT = transformation_type
	if(TT)
		var/pdir = parent.dir
		var/obj/O
		if(TT != CONSTRUCTION_TRANSFORMATION_TYPE_AT_RUNTIME)
			O = new TT(parent.drop_location())
			parent.transfer_fingerprints_to(O)
			parent.OnConstructionTransform(user, O)
		else
			O = parent.OnConstructionTransform(user, null)
			if(!istype(O))
				var/VE = var_edited
				var/PVE = parent.var_edited
				if(!VE && !PVE)
					to_chat(user, "Something bad just happened. Please report this: OBJCONRUNTIMETYPEFAIL")
				CRASH("OnConstructionTransform with CONSTRUCTION_TRANSFORMATION_TYPE_AT_RUNTIME failed for [parent]([parent.type])! Returned [O]! VE: [VE], PVE: [PVE].")
		O.Construct(user, pdir)
		qdel(parent)

/datum/construction_blueprint
	var/owner_type
	var/root_only
	var/build_root_only

/datum/construction_blueprint/proc/GetBlueprint(obj/obj_type)
	return list()

//See __HELPERS/game.dm for CONSTRUCTION_BLUEPRINT macro

/obj/proc/SetupConstruction()
	var/list/bp_cache = list() //SSatoms.blueprints_cache
	var/list/our_steps = bp_cache[type]
	if(isnull(our_steps))
		our_steps = list()
		if(construction_blueprint)
			var/datum/construction_blueprint/BP = new construction_blueprint
			var/temp = -1
			var/blueprint_root_only = BP.root_only
			if(BP.owner_type == type || (!blueprint_root_only && istype(src, BP.owner_type)))
				temp = BP.GetBlueprint(type)	//get steps for the first time
				if(!islist(temp))
					WARNING("Invalid construction_blueprint for [type]!")
					temp = -1
			if(temp != -1)
				LinkConstructionSteps(temp)	//assign ids and stitch the linked list together
				if(ValidateConstructionSteps(temp))
					our_steps = temp
		bp_cache[type] = our_steps	//cache it
	var/stepslength = our_steps.len
	if(stepslength)
		var/datum/construction_state/last/L = our_steps[stepslength]	//start fully constructed by default
		if(istype(L) && L.transformation_type)
			L = L.prev_state	//make it valid
		current_construction_state = L
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
			var/datum/construction_state/last/L = current_step
			if(istype(L))
				last_found = TRUE
				var/TT = L.transformation_type
				if(TT)
					if(TT != CONSTRUCTION_TRANSFORMATION_TYPE_AT_RUNTIME && !ispath(/atom/movable, TT))
						WARNING(error + "Transformation type is not of atom/movable: [TT]")
						. = FALSE
					if(istype(L.prev_state, /datum/construction_state/first))
						WARNING(error + "`transformation_type` set and only first and last steps exist.")
						. = FALSE
			if(current_step.max_integrity && current_step.max_integrity < last_max_integrity)
				WARNING(error + "Max integrity lowered after construction")
				. = FALSE
			if(current_step.failure_integrity && current_step.failure_integrity < last_failure_integrity)
				WARNING(error + "Failure integrity lowered after construction")
				. = FALSE
			if(current_step.required_type_to_construct)
				if(ispath(current_step.required_type_to_construct, /obj/item/stack))
					if(!current_step.required_amount_to_construct)
						WARNING(error + "No amount set for material construction")
						. = FALSE
					if(current_step.stash_construction_item)
						WARNING(error + "Trying to stash item of type /obj/item/stack: [current_step.required_type_to_construct]")
						. = FALSE
				else if(current_step.required_amount_to_construct > 1)
					WARNING(error + "Invalid material amount for non stack construction")
					. = FALSE
				if(!ispath(current_step.required_type_to_construct, /obj/item) && !istype(current_step, /datum/construction_state/last))
					WARNING(error + "Invalid /obj/item type specified for construction: '[current_step.required_type_to_construct]'")
					. = FALSE
			else 
				if(current_step.stash_construction_item)
					WARNING(error + "Supposed to stash construction item, but no item is set")
					. = FALSE
				if(!current_step.required_type_to_deconstruct)
					WARNING(error + "Hand values for both construction and deconstruction types")
					. = FALSE
				else if(current_step.required_type_to_deconstruct != NO_DECONSTRUCT && !ispath(current_step.required_type_to_deconstruct, /obj/item))
					WARNING(error + "Invalid deconstruction type: [current_step.required_type_to_deconstruct]")
					. = FALSE
				if(current_step.construction_message && findtextEx(current_step.construction_message, CONSTRUCTION_ITEM))
					WARNING(error + "`CONSTRUCTION_ITEM` used in message for hand construction")
					. = FALSE
			if(current_step.required_type_to_repair)
				if(ispath(current_step.required_type_to_repair, /obj/item/stack))
					if(!current_step.required_amount_to_repair)
						WARNING(error + "No amount set for material repairs")
						. = FALSE
				else if(current_step.required_amount_to_repair > 1)
					WARNING(error + "Invalid material amount for non stack repairs")
					. = FALSE
				if(!ispath(current_step.required_type_to_repair, /obj/item))
					WARNING(error + "Invalid /obj/item type specified for repairs: '[current_step.required_type_to_construct]'")
					. = FALSE
			
			if(current_step.required_type_to_deconstruct)
				if(current_step.required_type_to_deconstruct != NO_DECONSTRUCT && !ispath(current_step.required_type_to_deconstruct, /obj/item))
					WARNING("Invalid /obj/item type specified for deconstruction: '[current_step.required_type_to_deconstruct]'")
					. = FALSE
			else if(current_step.deconstruction_message && findtextEx(current_step.deconstruction_message, CONSTRUCTION_ITEM))
				WARNING(error + "`CONSTRUCTION_ITEM` used in message for hand deconstruction")
			current_step = current_step.next_state
	else
		WARNING("Construction Error: InitConstruction for [type] defined but no steps were added")
		. = FALSE

//construction events
/obj/proc/OnConstruction(state_id, mob/living/user, obj/item/used)

/obj/proc/OnConstructionTransform(mob/living/user, obj/created)

/obj/proc/OnDeconstruction(state_id, mob/living/user, obj/item/created, forced)

/obj/proc/OnRepair(mob/living/user, obj/item/used, old_integrity)

/obj/proc/Construct(mob/living/user, ndir)
	var/list/cached_construction_steps = list() //SSatoms.blueprints_cache[type]
	if(cached_construction_steps.len)
		var/datum/construction_state/first_step = cached_construction_steps[1]
		var/datum/construction_state/first/very_first_step = first_step
		if(!istype(very_first_step))
			very_first_step = null
		if(!(very_first_step && very_first_step.construct_fully))
			ClearStoredConstructionItems()
			if(very_first_step)
				first_step = first_step.next_state
			if(first_step)
				first_step.OnReached(src, user, TRUE)
	if(user)
		SSblackbox.add_details("obj_construction",type)
		add_fingerprint(user)
		if(!ndir)
			ndir = user.dir
	if(ndir)
		setDir(ndir)

/obj/proc/Repair(mob/living/user, obj/item/used, amount)
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
	update_icon()

//Stash helpers

/obj/proc/GetItemStoredInConstructionState(id)
	if(!stored_construction_items)
		return
	return stored_construction_items["[id]"]

/obj/proc/GetItemUsedToReachConstructionState(id)
	if(!stored_construction_items)
		return
	return stored_construction_items["[id - 1]"]

/obj/proc/SetItemToLeaveConstructionState(id, obj/item/I)
	if(I)
		if(!istype(I))
			CRASH("Invalid type in SetItemToReachConstructionState: [I.type]")
		if(I.loc != src)
			CRASH("SetItemToReachConstructionState: Item not inside src: [I.loc]")
	LAZYINITLIST(stored_construction_items)
	. = stored_construction_items["[id]"]
	stored_construction_items["[id]"] = I

/obj/proc/SetItemToReachConstructionState(id, obj/item/I)
	if(I)
		if(!istype(I))
			CRASH("Invalid type in SetItemToReachConstructionState: [I.type]")
		if(I.loc != src)
			CRASH("SetItemToReachConstructionState: Item not inside src: [I.loc]")
	LAZYINITLIST(stored_construction_items)
	. = stored_construction_items["[id - 1]"]
	stored_construction_items["[id - 1]"] = I

/obj/proc/ClearStoredConstructionItems()
	for(var/I in stored_construction_items)
		qdel(stored_construction_items[I])
	LAZYCLEARLIST(stored_construction_items)

/obj/examine(mob/user)
	..()
	if(current_construction_state && current_construction_state.examine_message)
		to_chat(user, current_construction_state.examine_message)

/obj/attack_hand(mob/living/user)	//obj/item doesn't call this so we're fine
	if(user.a_intent == INTENT_HELP)
		HandConstruction(user)
	else
		return ..()

/obj/item/attack_self(mob/living/user)
	. = ..()
	HandConstruction(user)

//construct by hand
/obj/proc/HandConstruction(mob/living/user)
	var/datum/construction_state/ccs = current_construction_state
	if(ccs)
		var/action_type
		var/wait
		var/message
		if(!ccs.required_type_to_construct)
			action_type = CONSTRUCTING
			wait = ccs.construction_delay
			message = ccs.construction_message
		else if(!ccs.required_type_to_deconstruct)
			action_type = DECONSTRUCTING
			wait = ccs.deconstruction_delay
			message = ccs.deconstruction_message
		else
			return

		if(!ConstructionChecks(ccs.id, action_type, null, user, TRUE))
			return

		if(wait)			
			user.visible_message("<span class='notice'>[user] begins [message] \the [src].</span>", 
									"<span class='notice'>You begin [message] \the [src].</span>")
			if(!ConstructionDoAfterInternal(user, null, wait, action_type, TRUE))
				return

		user.visible_message("<span class='notice'>[user] [wait ? "finishes [message]" : "[message]\s"] \the [src].</span>",\
								"<span class='notice'>You [wait ? "finish [message]" : message] \the [src].</span>")
		ccs.OnLeft(src, user, null, action_type == CONSTRUCTING, FALSE)

//construct by tool if possible
/obj/attackby(obj/item/I, mob/living/user)
	var/datum/construction_state/ccs = current_construction_state	
	if(ccs && user.a_intent == INTENT_HELP)
		add_fingerprint(user)
		var/action_type
		var/wait
		var/message
		if(istype(I, ccs.required_type_to_construct))
			action_type = CONSTRUCTING
			wait = ccs.construction_delay
			message = ccs.construction_message
		else if(istype(I, ccs.required_type_to_deconstruct))
			action_type = DECONSTRUCTING
			wait = ccs.deconstruction_delay
			message = ccs.deconstruction_message
		else if(istype(I, ccs.required_type_to_repair))
			if(obj_integrity == max_integrity)
				to_chat(user, "<span class='notice'>\The [src] isn't damaged!</span>")
				return
			action_type = REPAIRING
			wait = ccs.repair_delay
			message = ccs.repair_message
			if(!message)
				message = wait ? "repairing" : "repair"
		else
			return ..()

		if(!ConstructionChecks(ccs.id, action_type, I, user, TRUE))
			return	
		
		message = replacetextEx(message, CONSTRUCTION_ITEM, "\the [I]")

		if(wait)
			user.visible_message("<span class='notice'>[user] begins [message] \the [src].</span>",\
								"<span class='notice'>You begin [message] \the [src].</span>")
			if(!ConstructionDoAfterInternal(user, I, wait * I.toolspeed, action_type, TRUE))
				return
		else if(I.usesound)
			playsound(src, I.usesound, CONSTRUCTION_VOLUME, TRUE)	//This is also done in the DoAfter

		user.visible_message("<span class='notice'>[user] [wait ? "finishes [message]" : "[message]\s"] \the [src].</span>",\
								"<span class='notice'>You [wait ? "finish [message]" : message] \the [src].</span>")
		if(action_type != REPAIRING)
			ccs.OnLeft(src, user, I, action_type == CONSTRUCTING, FALSE)
		else
			Repair(user, I)
	else
		return ..()

/obj/proc/ConstructionDoAfterInternal(mob/living/user, obj/item/I, delay, action_type, first_checked)
	var/datum/construction_state/ccs = current_construction_state
	var/ccsid = ccs ? ccs.id : 0

	if(!first_checked && !ConstructionChecks(ccsid, action_type, I, user, TRUE))
		return FALSE

	if(I && I.usesound)
		playsound(src, I.usesound, CONSTRUCTION_VOLUME, TRUE)

	LAZYINITLIST(user.construction_tasks)	//prevent repeats
	user.construction_tasks[src] = world.time
	//Checks will always run because we've verified do_after will last at least 1 tick
	. = do_after(user, delay, target = src, extra_checks = CALLBACK(src, .proc/ConstructionChecks, ccsid, action_type, I, user, FALSE))
	LAZYREMOVE(user.construction_tasks, src)

/obj/proc/ConstructionChecks(state_started_id, action_type, obj/item/I, mob/living/user, first_check) 
	var/list/user_con_tasks = user.construction_tasks
	if(first_check && user_con_tasks && user_con_tasks[src])
		testing("Cancelled [user]'s construction on [src]([type]) due to duplicate action")
		return FALSE	//fail silently

	if(action_type == REPAIRING && obj_integrity >= max_integrity)
		to_chat(user, "<span class='warning'>\The [src] is already in good condition</span>")
		return FALSE

	if(current_construction_state.id != state_started_id)
		to_chat(user, "<span class='warning'>You were interrupted!</span>")
		return FALSE
	
	var/obj/item/weldingtool/WT = I
	if(istype(WT))
		if(!WT.isOn())
			to_chat(user, "<span class='warning'>\The [WT] [first_check ? "needs to be on for this task" : "runs out of fuel"]!</span>")
			return FALSE
		if(first_check || WT.last_flash < user_con_tasks[src])
			WT.remove_fuel(0, user)

	var/obj/item/stack/Mats = I
	if(istype(Mats))
		var/check_against = action_type == REPAIRING ? current_construction_state.required_amount_to_repair : current_construction_state.required_amount_to_construct
		if(Mats.amount < check_against)
			if(first_check)
				to_chat(user, "<span class='warning'>You need [check_against] or more of [Mats] first!</span>")
			else
				to_chat(user, "<span class='warning'>You no longer have enough [Mats]!</span>")
			return FALSE

	if(action_type == CONSTRUCTING && !anchored)
		var/datum/construction_state/next_state = current_construction_state.next_state
		if(next_state && next_state.anchored && !isfloorturf(loc))
			to_chat(user, "<span class='warning'>You cannot do that without a floor underneath \the [src]!</span>")
			return FALSE

	return TRUE
