/// Element that makes items turn into other items when you use them on a loom (or any other thing really if you change the var)
/datum/element/loomable
	element_flags = ELEMENT_BESPOKE
	argument_hash_start_idx = 2
	/// What will spawn when the item is loomed
	var/resulting_atom
	/// How much of item do we need to loom, will be ignored if item isnt a stack
	var/required_amount
	/// What thing we look for triggering the loom process (usually a loom)
	var/atom/loom_type
	/// What verb best fits the action of processing whatever the item is, for example "spun [thing]"
	var/process_completion_verb
	/// If the target needs to be anchored
	var/target_needs_anchoring
	/// How long it takes to loom the item
	var/loom_time

/datum/element/loomable/Attach(
	obj/item/target,
	resulting_atom = /obj/item/stack/sheet/cloth,
	required_amount = 4,
	loom_type = /obj/structure/loom,
	process_completion_verb = "spun",
	target_needs_anchoring = TRUE,
	loom_time = 1 SECONDS
)
	. = ..()
	//currently this element only works for items as we need to call /obj/item/attack_atom()
	if(!isitem(target))
		return ELEMENT_INCOMPATIBLE
	src.resulting_atom = resulting_atom
	src.required_amount = required_amount
	src.loom_type = loom_type
	src.process_completion_verb = process_completion_verb
	src.target_needs_anchoring = target_needs_anchoring
	src.loom_time = loom_time
	RegisterSignal(target, COMSIG_ITEM_ATTACK_ATOM, PROC_REF(try_and_loom_me))
	RegisterSignal(target, COMSIG_ATOM_EXAMINE, PROC_REF(on_examine))

/datum/element/loomable/Detach(obj/item/source)
	. = ..()
	UnregisterSignal(source, list(COMSIG_ITEM_ATTACK_ATOM, COMSIG_ATOM_EXAMINE))

/// Adds an examine blurb to the description of any item that can be loomed
/datum/element/loomable/proc/on_examine(obj/item/source, mob/examiner, list/examine_list)
	SIGNAL_HANDLER

	examine_list += span_notice("You could probably process [source] at \a <b>[initial(loom_type.name)]</b>.")

/// Checks if the thing we clicked on can be used as a loom, and if we can actually loom the source at present (an example being does the stack have enough in it (if its a stack))
/datum/element/loomable/proc/try_and_loom_me(obj/item/source, atom/target, mob/living/user)
	SIGNAL_HANDLER

	if(!istype(target, loom_type))
		return

	if(ismovable(target))
		var/atom/movable/movable_target = target
		if(target_needs_anchoring && !movable_target.anchored)
			user.balloon_alert(user, "[movable_target] must be secured!")
			return

	if((required_amount > 1) && istype(source, /obj/item/stack))
		var/obj/item/stack/source_stack = source
		if(source_stack.amount < required_amount)
			user.balloon_alert(user, "need [required_amount] of [source]!")
			return

	INVOKE_ASYNC(src, PROC_REF(loom_me), source, user, target)
	return COMPONENT_CANCEL_ATTACK_CHAIN

/// If a do_after of the specified loom_time passes, will create a new one of resulting_atom and either delete the item, or .use the required amount if its a stack
/datum/element/loomable/proc/loom_me(obj/item/source, mob/living/user, atom/target)
	//this allows us to count the amount of times it has successfully used the stack's required amount
	var/spawning_amount = 0
	if(isstack(source))
		var/obj/item/stack/stack_we_use = source
		while(stack_we_use.amount >= required_amount)
			if(!do_after(user, loom_time, target))
				break

			if(!stack_we_use.use(required_amount))
				user.balloon_alert(user, "need [required_amount] of [source]!")
				break

			spawning_amount++

	else
		if(!do_after(user, loom_time, target))
			user.balloon_alert(user, "interrupted!")
			return

		qdel(source)
		spawning_amount++

	if(spawning_amount == 0)
		return

	var/new_thing
	for(var/repeated in 1 to spawning_amount)
		new_thing = new resulting_atom(target.drop_location())

	user.balloon_alert_to_viewers("[process_completion_verb] [new_thing]")
