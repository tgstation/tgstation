




/datum/datastructures/LinkedListNode
	var/datum/datastructures/LinkedListNode/prev = null
	var/datum/datastructures/LinkedListNode/next = null
	var/object = null


/datum/datastructures/LinkedListNode/New(var/obj)
	object=obj
