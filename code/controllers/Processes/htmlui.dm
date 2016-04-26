var/global/list/html_machines = new/list() //for checking when we should update a mob based on race specific conditions

/datum/controller/process/html
	schedule_interval = 17
	var/list/update = list()

/datum/controller/process/html/setup()
	name = "html"

/datum/controller/process/html/doWork()
	if (update.len)
		var/list/L = list()
		var/key

		for (var/datum/procqueue_item/item in update)
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

		update.Cut()

/datum/controller/process/html/proc/queue(ref, procname, ...)
	var/datum/procqueue_item/item = new/datum/procqueue_item
	item.ref = ref
	item.procname = procname

	if (args.len > 2)
		item.args = args.Copy(3)

	src.update.Insert(1, item)

/datum/procqueue_item
	var/ref
	var/procname
	var/list/args
