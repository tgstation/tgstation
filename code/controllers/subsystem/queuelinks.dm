/atom/proc/MatchedLinks(id, list/partners)

/datum/queue_link
	/// atoms in our queue
	var/list/partners = list()
	/// how much length until we pop, only incrementable
	var/queue_max = 0
	/// id
	var/id

/datum/queue_link/New(new_id)
	id = new_id
	return ..()

///adds an atom to the queue, if we are popping this returns TRUE
/datum/queue_link/proc/add(what, max = 0)
	. = FALSE
	if(what in partners)
		return
	partners += what

	queue_max = (max >= queue_max ? max : queue_max)
	
	if(!queue_max || length(partners) < queue_max)
		return
	
	pop()
	return TRUE

/datum/queue_link/proc/pop()
	for(var/atom/item in partners)
		item.MatchedLinks(id, partners)
	qdel(src)

/datum/queue_link/Destroy()
	. = ..()
	partners = null
	

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
/datum/controller/subsystem/queuelinks/proc/add_to_queue(what, id, queue_max = 0)
	if(isnull(id))
		return
	var/datum/queue_link/link
	if(isnull(queues[id]))
		link = new /datum/queue_link(id)
		queues[id] = link
	else
		link = queues[id]

	if(link.add(what, queue_max))
		queues -= id
