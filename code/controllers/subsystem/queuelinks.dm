/atom/proc/MatchedLinks(id, list/partners)

SUBSYSTEM_DEF(queuelinks)
	name = "Queue Links"
	flags = SS_NO_FIRE
	init_order = INIT_ORDER_QUEUELINKS
	///assoc list of pending queues, id = /datum/queue_link
	var/list/queues = list()

/datum/controller/subsystem/queuelinks/Initialize()
	return SS_INIT_SUCCESS

///Creates or adds to a queue with the id supplied, if the queue is now or above the size of the queue, calls MatchedLinks and clears queue.
/// queues with a size of 0 wait never pop until something is added with an actual queue_max
/datum/controller/subsystem/queuelinks/proc/add_to_queue(atom/what, id, queue_max = 0)
	if(!isatom(what))
		CRASH("Attempted to add a non-atom to queue; [what]!")
	if(isnull(id))
		CRASH("Attempted to add to queue with no ID; [what]")

	var/datum/queue_link/link = queues[id]
	if(isnull(link))
		link = new /datum/queue_link(id)
		queues[id] = link

	if(link.add(what, queue_max))
		queues -= id

/**
 * Pop a queue link without waiting for it to reach its max size.
 * This is useful for those links that do not have a fixed size and thus may not pop.
 */
/datum/controller/subsystem/queuelinks/proc/pop_link(id)
	if(isnull(id))
		CRASH("Attempted to pop a queue with no ID")

	var/datum/queue_link/link = queues[id]
	if(isnull(queues[id]))
		CRASH("Attempted to pop a non-existant queue: [id]")

	link.pop()
	queues -= id


/datum/queue_link
	/// atoms in our queue
	var/list/partners = list()
	/// how much length until we pop, only incrementable, 0 means the queue will not pop until a maximum is set
	var/queue_max = 0
	/// id
	var/id

/datum/queue_link/New(new_id)
	id = new_id
	return ..()

///adds an atom to the queue, if we are popping this returns TRUE
/datum/queue_link/proc/add(atom/what, max = 0)
	. = FALSE
	if(what in partners)
		return
	partners += what
	RegisterSignal(what, COMSIG_QDELETING, PROC_REF(link_object_deleted))

	if(queue_max != 0 && max != 0 && max != queue_max)
		CRASH("Tried to change queue size to [max] from [queue_max]!")
	else if(!queue_max)
		queue_max = max

	if(!queue_max || length(partners) < queue_max)
		return

	pop()
	return TRUE

/datum/queue_link/proc/pop()
	for(var/atom/item as anything in partners)
		item.MatchedLinks(id, partners - item)
	qdel(src)

/datum/queue_link/proc/link_object_deleted(datum/source) // because CI and stuff
	SIGNAL_HANDLER
	partners -= source

/datum/queue_link/Destroy()
	. = ..()
	partners = null
