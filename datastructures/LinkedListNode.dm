




/datum/datastructurs/LinkedListNode
	var/datum/datastructurs/LinkedListNode/prev = null
	var/datum/datastructurs/LinkedListNode/next = null
	var/key = null


/datum/datastructurs/LinkedListNode/New(var/obj)
	key=obj


/datum/datastructurs/LinkedListNode/proc/getObject()
	return key

/datum/datastructurs/LinkedListNode/proc/getPrev()
	return prev

/datum/datastructurs/LinkedListNode/proc/getNext()
	return next

/datum/datastructurs/LinkedListNode/proc/setNext(var/node)
	next = node

/datum/datastructurs/LinkedListNode/proc/setPrev(var/node)
	prev = node

/datum/datastructurs/LinkedListNode/proc/setObject(var/obj)
	key=obj