/// Component that makes items turn into other items when you use them on a loom (or any other thing really if you change the var)
/datum/component/loomable
	/// What will spawn when the parent is loomed
	var/resulting_item
	/// How much of parent do we need to loom, will be ignored if parent isnt a stack
	var/required_amount
	/// What thing we look for triggering the loom process (usually a loom)
	var/obj/target_thing
	/// What verb best fits the action of processing whatever the item is, for example "spun [thing]"
	var/process_completion_verb
	/// If target_thing needs to be anchored
	var/target_needs_anchoring
	/// How long it takes to loom the parent
	var/loom_time

/datum/component/loomable/Initialize(
	resulting_item,
	required_amount = 4,
	target_thing = /obj/structure/loom,
	process_completion_verb = "spun",
	target_needs_anchoring = TRUE,
	loom_time = 1 SECONDS
	)

	src.resulting_item = resulting_item
	src.required_amount = required_amount
	src.target_thing = target_thing
	src.process_completion_verb = process_completion_verb
	src.target_needs_anchoring = target_needs_anchoring
	src.loom_time = loom_time

/datum/component/loomable/RegisterWithParent()
	RegisterSignal(parent, COMSIG_ITEM_ATTACK_OBJ, PROC_REF(try_and_loom_me))
	RegisterSignal(parent, COMSIG_PARENT_EXAMINE, PROC_REF(on_examine))

/datum/component/loomable/UnregisterFromParent()
	UnregisterSignal(parent, list(COMSIG_ITEM_ATTACK_OBJ, COMSIG_PARENT_EXAMINE))

/// Checks if the thing we clicked on can be used as a loom, and if we can actually loom the parent at present (an example being does the stack have enough in it (if its a stack))
/datum/component/loomable/proc/try_and_loom_me(datum/source, obj/target, mob/living/user)
	SIGNAL_HANDLER

	if(!istype(target, target_thing))
		return

	if(target_needs_anchoring && !(target.anchored))
		user.balloon_alert(user, "[target] must be secured!")
		return

	if((required_amount > 1) && istype(parent, /obj/item/stack))
		var/obj/item/stack/parent_stack = parent
		if(parent_stack.amount < required_amount)
			user.balloon_alert(user, "need [required_amount] of [parent]!")
			return

	INVOKE_ASYNC(src, PROC_REF(loom_me), user, target)
	return COMPONENT_CANCEL_ATTACK_CHAIN

/// If a do_after of the specified loom_time passes, will create a new one of resulting_item and either delete the parent, or .use the required amount if its a stack
/datum/component/loomable/proc/loom_me(mob/living/user, obj/structure/loom/target)
	if(!do_after(user, loom_time, target))
		return

	var/new_thing = new resulting_item(target.drop_location())
	user.balloon_alert_to_viewers("[process_completion_verb] [new_thing]")
	if(isstack(parent))
		var/obj/item/stack/stack_we_use = parent
		stack_we_use.use(required_amount)
	else
		qdel(parent)

/// Adds an examine blurb to the description of any item that can be loomed
/datum/component/loomable/proc/on_examine(mob/living/source, mob/examiner, list/examine_list)
	SIGNAL_HANDLER

	examine_list += span_notice("You could probably process [parent] at a <b>[initial(target_thing.name)]</b>.")
