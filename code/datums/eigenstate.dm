GLOBAL_DATUM_INIT(closet_teleport_controller, /datum/closet_teleport_controller, new)

///A singleton used to teleport people to a linked web of itterative entries. If one entry is deleted, the 2 around it will forge a link instead.
/datum/closet_teleport_controller
	///The list of objects that something is linked to indexed by UID
	var/list/eigen_targets = list()
	///UID to object reference
	var/list/eigen_id = list()
	///Unique id counter
	var/id_counter = 1
	///Limit the number of sparks created when teleporting multiple atoms to 1
	var/spark_time = 0
	/// Weakref to an admin spawned eigenlinked closet - the next one spawned will link to it
	var/datum/weakref/admin_link

///Creates a new link of targets unique to their own id
/datum/closet_teleport_controller/proc/create_new_link(targets, subtle = TRUE)
	if(length(targets) <= 1)
		return FALSE
	for(var/atom/target as anything in targets) //Clear out any connected
		var/already_linked = eigen_id[target]
		if(!already_linked)
			continue
		if(length(eigen_targets[already_linked]) > 1) //Eigenstates are notorious for having cliques!
			if(!subtle)
				target.visible_message("[target] fizzes, it's already linked to something else!")
			targets -= target
			continue
		if(!subtle)
			target.visible_message("[target] fizzes, collapsing its unique wavefunction into the others!") //If we're in a eigenlink all on our own and are open to new friends
		remove_eigen_entry(target) //clearup for new stuff
	//Do we still have targets?
	if(!length(targets))
		return FALSE
	var/atom/visible_atom = targets[1] //The object that'll handle the messages
	if(length(targets) == 1)
		if(!subtle)
			visible_atom.visible_message("[targets[1]] fizzes, there's nothing it can link to!")
		return FALSE

	var/subtle_keyword = subtle ? "subtle" : ""
	eigen_targets["[id_counter][subtle_keyword]"] = list() //Add to the master list
	for(var/atom/target as anything in targets)
		eigen_targets["[id_counter][subtle_keyword]"] += target
		eigen_id[target] = "[id_counter][subtle_keyword]"
		RegisterSignal(target, COMSIG_CLOSET_INSERT, PROC_REF(use_eigenlinked_atom))
		RegisterSignal(target, COMSIG_QDELETING, PROC_REF(remove_eigen_entry))
		if(!subtle)
			RegisterSignal(target, COMSIG_ATOM_TOOL_ACT(TOOL_WELDER), PROC_REF(tool_interact))
		ADD_TRAIT(target, TRAIT_BANNED_FROM_CARGO_SHUTTLE, REF(src))
		if(!subtle)
			target.add_atom_colour(COLOR_PERIWINKLEE, FIXED_COLOUR_PRIORITY) //Tint the locker slightly.
			target.alpha = 200
			do_sparks(3, FALSE, target)

	visible_atom.visible_message("The items shimmer and fizzle, turning a shade of violet blue.")
	id_counter++
	return TRUE

///reverts everything back to start
/datum/closet_teleport_controller/eigenstates/Destroy()
	for(var/index in 1 to id_counter)
		for(var/entry in eigen_targets["[index]"])
			remove_eigen_entry(entry)
	eigen_targets = null
	eigen_id = null
	id_counter = 1
	return ..()

///removes an object reference from the master list
/datum/closet_teleport_controller/proc/remove_eigen_entry(atom/entry)
	SIGNAL_HANDLER
	var/id = eigen_id[entry]
	eigen_targets[id] -= entry
	eigen_id -= entry
	entry.remove_atom_colour(FIXED_COLOUR_PRIORITY, COLOR_PERIWINKLEE)
	entry.alpha = 255
	UnregisterSignal(entry, list(
		COMSIG_QDELETING,
		COMSIG_CLOSET_INSERT,
		COMSIG_ATOM_TOOL_ACT(TOOL_WELDER),
	))
	REMOVE_TRAIT(entry, TRAIT_BANNED_FROM_CARGO_SHUTTLE, REF(src))
	///Remove the current entry if we're empty
	for(var/targets in eigen_targets)
		if(!length(eigen_targets[targets]))
			eigen_targets -= targets

///Finds the object within the master list, then sends the thing to the object's location
/datum/closet_teleport_controller/proc/use_eigenlinked_atom(atom/object_sent_from, atom/movable/thing_to_send)
	SIGNAL_HANDLER

	var/id = eigen_id[object_sent_from]
	if(!id)
		stack_trace("[object_sent_from] attempted to eigenlink to something that didn't have a valid id!")
		return FALSE
	var/subtle = findtext(id, "subtle")
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
	if(check_teleport_valid(thing_to_send, eigen_target, TELEPORT_CHANNEL_QUANTUM))
		thing_to_send.forceMove(eigen_target)
	else
		if(!subtle)
			object_sent_from.balloon_alert(thing_to_send, "nothing happens!")
		return FALSE
	//Create ONE set of sparks for ALL times in iteration
	if(!subtle && spark_time != world.time)
		do_sparks(5, FALSE, eigen_target)
		do_sparks(5, FALSE, object_sent_from)
		spark_time = world.time
	return COMPONENT_CLOSET_INSERT_INTERRUPT

///Prevents tool use on the item
/datum/closet_teleport_controller/proc/tool_interact(atom/source, mob/user, obj/item/item)
	SIGNAL_HANDLER
	to_chat(user, span_notice("The unstable nature of [source] makes it impossible to use [item] on [source.p_them()]!"))
	return ITEM_INTERACT_BLOCKING

// For testing purposes, primarily
// Spawns a closet that will auto-link to the next one spawned
/obj/structure/closet/eigenlinked
	/// Whether or not this closet subtle links (no messages/effects)
	var/subtle = FALSE

/obj/structure/closet/eigenlinked/Initialize(mapload)
	. = ..()
	if(mapload)
		// i'm making no effort to ensure these link properly for mappers.
		// add a mapping helper which uses editable ids if you want that
		log_mapping("Don't map in [type], it likely won't link properly as it is intended for debug. \
			If you want this on your map you will need to add a mapping helper.")
		return INITIALIZE_HINT_QDEL

	var/obj/structure/closet/other = GLOB.closet_teleport_controller.admin_link?.resolve()
	if(isnull(other))
		GLOB.closet_teleport_controller.admin_link = WEAKREF(src)
		return

	GLOB.closet_teleport_controller.create_new_link(list(src, other), subtle = src.subtle)

/obj/structure/closet/eigenlinked/stealth
	subtle = TRUE
