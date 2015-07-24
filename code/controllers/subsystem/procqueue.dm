var/datum/subsystem/procqueue/procqueue

/datum/subsystem/procqueue
	var/list/queue = list()

/datum/subsystem/procqueue/New()
	NEW_SS_GLOBAL(procqueue)

/datum/subsystem/procqueue/fire()
	if (queue.len)
		var/list/L = list()

		for (var/datum/procqueue_item/item in queue)
			if (!item.runafter || item.runafter-- <= 0)
				if (!(item.id in L))
					if (item.args) call(item.ref, item.procname)(arglist(item.args))
					else           call(item.ref, item.procname)()

					L.Add(item.id)

				queue.Remove(item)

/datum/subsystem/procqueue/proc/queue(ref, procname, ...)
	var/list/L = args.Copy()

	L.Insert(1, 0)

	src.schedule(arglist(L))

/datum/subsystem/procqueue/proc/schedule(time, ref, procname, ...)
	var/datum/procqueue_item/item = new/datum/procqueue_item
	item.ref = ref
	item.procname = procname

	if (args.len > 3)
		item.args = args.Copy(4)

	if (time > 0) item.runafter = time / 10

	item.id = "[item.ref]_[item.procname]"

	if (item.args)
		item.id += "("
		var/first = 1
		for (var/a in item.args)
			if (!first) item.id += ","
			item.id += "[a]"
			first = 0
		item.id += ")"

	for (var/datum/procqueue_item/candidate in queue)
		if (candidate.id == item.id)
			return

	src.queue.Insert(1, item)

/datum/procqueue_item/var/id
/datum/procqueue_item/var/runafter
/datum/procqueue_item/var/ref
/datum/procqueue_item/var/procname
/datum/procqueue_item/var/list/args
