var/datum/subsystem/procqueue/procqueue

/datum/subsystem/procqueue
	var/list/queue = list()

/datum/subsystem/procqueue/New()
	NEW_SS_GLOBAL(procqueue)

/datum/subsystem/procqueue/fire()
	if (queue.len)
		var/list/L = list()
		var/key

		for (var/datum/procqueue_item/item in queue)
			key = "[item.ref]_[item.procname]"

			if (item.args)
				key += "("
				var/first = 1
				for (var/a in item.args)
					if (!first) key += ","
					key += "[a]"
					first = 0
				key += ")"

			if (!(key in L))
				if (item.args) call(item.ref, item.procname)(arglist(item.args))
				else           call(item.ref, item.procname)()

				L.Add(key)

		queue.Cut()

/datum/subsystem/procqueue/proc/queue(ref, procname, ...)
	var/datum/procqueue_item/item = new/datum/procqueue_item
	item.ref = ref
	item.procname = procname

	if (args.len > 2)
		item.args = args.Copy(3)

	src.queue.Insert(1, item)

/datum/procqueue_item/var/ref
/datum/procqueue_item/var/procname
/datum/procqueue_item/var/list/args