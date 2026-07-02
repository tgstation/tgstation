/datum/stack
	var/list/items = list()

/datum/stack/proc/push(item)
	items += item

/datum/stack/proc/any()
	return items.len > 0

/datum/stack/proc/peek()
	if(!items.len)
		return null
	return items[items.len]

/datum/stack/proc/pop()
	if(!length(items))
		return null
	var/item = peek()
	items.Cut(items.len)
	return item

/datum/queue
	var/list/items = list()

/datum/queue/proc/enqueue(item)
	items += item

/datum/queue/proc/dequeue()
	if(!length(items))
		return null
	var/item = peek()
	items.Cut(1, 2)
	return item

/datum/queue/proc/any()
	return items.len > 0

/datum/queue/proc/peek()
	if(!items.len)
		return null
	return items[1]
