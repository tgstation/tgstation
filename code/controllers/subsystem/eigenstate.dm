///Subsystem used to teleport people to a linked web of itterative entries. If one entry is deleted, the 2 around it will forge a link instead.
SUBSYSTEM_DEF(eigenstates)
	name = "Eigenstates"
	flags = SS_NO_INIT | SS_NO_FIRE
	///The list of objects that something is linked to indexed by UID
	var/list/eigen_targets = list()
	///UID to object reference
	var/list/eigen_id = list()
	///Unique id counter
	var/id_counter = 1
	///Limit the number of sparks created when teleporting multiple atoms to 1
	var/spark_time = 0

///Creates a new link of targets unique to their own id
/datum/controller/subsystem/eigenstates/proc/create_new_link(targets)
	if(length(targets) <= 1)
		return FALSE
	for(var/atom/target as anything in targets) //Clear out any connected
		var/already_linked = eigen_id[target]
		if(!already_linked)
			continue
		if(length(eigen_targets[already_linked]) > 1) //Eigenstates are notorious for having cliques!
			target.visible_message("[target] fizzes, it's already linked to something else!")
			targets -= target
			continue
		target.visible_message("[target] fizzes, collapsing it's unique wavefunction into the others!") //If we're in a eigenlink all on our own and are open to new friends
		remove_eigen_entry(target) //clearup for new stuff
	//Do we still have targets?
	if(!length(targets))
		return FALSE
	var/atom/visible_atom = targets[1] //The object that'll handle the messages
	if(length(targets) == 1)
		visible_atom.visible_message("[targets[1]] fizzes, there's nothing it can link to!")
		return FALSE

	eigen_targets["[id_counter]"] = list() //Add to the master list
	for(var/atom/target as anything in targets)
		eigen_targets["[id_counter]"] += target
		eigen_id[target] = "[id_counter]"
		RegisterSignal(target, COMSIG_CLOSET_INSERT, PROC_REF(use_eigenlinked_atom))
		RegisterSignal(target, COMSIG_PARENT_QDELETING, PROC_REF(remove_eigen_entry))
		RegisterSignal(target, COMSIG_ATOM_TOOL_ACT(TOOL_WELDER), PROC_REF(tool_interact))
		target.RegisterSignal(target, COMSIG_EIGENSTATE_ACTIVATE, TYPE_PROC_REF(/obj/structure/closet,bust_open))
		ADD_TRAIT(target, TRAIT_BANNED_FROM_CARGO_SHUTTLE, REF(src))
		var/obj/item = target
		if(item)
			item.color = COLOR_PERIWINKLEE //Tint the locker slightly.
			item.alpha = 200
			do_sparks(3, FALSE, item)

	visible_atom.visible_message("The items shimmer and fizzle, turning a shade of violet blue.")
	id_counter++
	return TRUE

///reverts everything back to start
/datum/controller/subsystem/eigenstates/Destroy()
	for(var/index in 1 to id_counter)
		for(var/entry in eigen_targets["[index]"])
			remove_eigen_entry(entry)
	eigen_targets = null
	eigen_id = null
	id_counter = 1
	return ..()

///removes an object reference from the master list
/datum/controller/subsystem/eigenstates/proc/remove_eigen_entry(atom/entry)
	SIGNAL_HANDLER
	var/id = eigen_id[entry]
	eigen_targets[id] -= entry
	eigen_id -= entry
	entry.color = COLOR_WHITE
	entry.alpha = 255
	UnregisterSignal(entry, list(
		COMSIG_PARENT_QDELETING,
		COMSIG_CLOSET_INSERT,
		COMSIG_ATOM_TOOL_ACT(TOOL_WELDER),
	))
	REMOVE_TRAIT(entry, TRAIT_BANNED_FROM_CARGO_SHUTTLE, REF(src))
	entry.UnregisterSignal(entry, COMSIG_EIGENSTATE_ACTIVATE) //This is a signal on the object itself so we have to call it from that
	///Remove the current entry if we're empty
	for(var/targets in eigen_targets)
		if(!length(eigen_targets[targets]))
			eigen_targets -= targets

///Finds the object within the master list, then sends the thing to the object's location
/datum/controller/subsystem/eigenstates/proc/use_eigenlinked_atom(atom/object_sent_from, atom/movable/thing_to_send)
	SIGNAL_HANDLER

	var/id = eigen_id[object_sent_from]
	if(!id)
		stack_trace("[object_sent_from] attempted to eigenlink to something that didn't have a valid id!")
		return FALSE
	var/list/items = eigen_targets[id]
	var/index = (items.Find(object_sent_from))+1 //index + 1
	if(!index)
		stack_trace("[object_sent_from] attempted to eigenlink to something that didn't contain it!")
		return FALSE
	if(index > length(eigen_targets[id]))//If we're at the end of the list (or we're 1 length long)
		index = 1
	var/atom/eigen_target = eigen_targets[id][index]
	if(!eigen_target)
		stack_trace("No eigen target set for the eigenstate component!")
		return FALSE
	thing_to_send.forceMove(get_turf(eigen_target))
	//Create ONE set of sparks for ALL times in iteration
	if(spark_time != world.time)
		do_sparks(5, FALSE, eigen_target)
		do_sparks(5, FALSE, object_sent_from)
	spark_time = world.time
	//Calls a special proc for the atom if needed (closets use bust_open())
	SEND_SIGNAL(eigen_target, COMSIG_EIGENSTATE_ACTIVATE)
	return COMPONENT_CLOSET_INSERT_INTERRUPT

///Prevents tool use on the item
/datum/controller/subsystem/eigenstates/proc/tool_interact(atom/source, mob/user, obj/item/item)
	SIGNAL_HANDLER
	to_chat(user, span_notice("The unstable nature of [source] makes it impossible to use [item] on [source.p_them()]!"))
	return COMPONENT_BLOCK_TOOL_ATTACK
