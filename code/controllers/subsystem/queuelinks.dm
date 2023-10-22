/atom/proc/MatchedLinks(id, list/partners)

SUBSYSTEM_DEF(queuelinks)
	name = "Queue Links"
	flags = SS_NO_FIRE
	init_order = INIT_ORDER_QUEUELINKS
	///assoc list of pending queues, id = list()
	var/list/queues = list()

/datum/controller/subsystem/queuelinks/Initialize()
	return SS_INIT_SUCCESS

///Creates or adds to a queue with the id supplied, if the queue is now or above the size supplied in queue_max, calls MatchedLinks and clears queue.
/datum/controller/subsystem/queuelinks/proc/add_to_queue(what, id, queue_max)
	if(isnull(id) || !queue_max)
		return
	if(isnull(queues[id]))
		queues[id] = list()

	queues[id] += what
	if(length(queues[id]) < queue_max)
		return
	// the queue is full!
	for(var/atom/item in queues[id])
		item.MatchedLinks(id, queues[id])

	queues -= id
