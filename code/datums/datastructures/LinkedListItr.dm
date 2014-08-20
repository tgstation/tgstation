/datum/datastructures/LinkedListItr
	var/datum/datastructures/LinkedListNode/next = null
	var/datum/datastructures/LinkedListNode/previous = null
	var/datum/datastructures/LinkedListNode/lastReturned = null

	var/datum/datastructures/LinkedList/parentList

	var/position


/datum/datastructures/LinkedListItr/New(var/datum/datastructures/LinkedList/listObj, var/datum/datastructures/LinkedListNode/p, var/datum/datastructures/LinkedListNode/n, var/index)
	next = n
	previous = p
	parentList = listObj
	position = index

//public int nextIndex()
/datum/datastructures/LinkedListItr/proc/nextIndex()
	return position

//public int previousIndex()
/datum/datastructures/LinkedListItr/proc/previousIndex()
	return position -1

//public boolean (1/0) hasNext()
/datum/datastructures/LinkedListItr/proc/hasNext()
	if(next==null)
		return 0
	else
		return 1

/datum/datastructures/LinkedListItr/proc/hasPrevious()
	if(previous==null)
		return 0
	else
		return 1

//public Object next()
/datum/datastructures/LinkedListItr/proc/next()
	if(next==null)
		return null
	position++
	lastReturned = next
	previous = next
	next = lastReturned.next
	return lastReturned.object

//public Object previous()
/datum/datastructures/LinkedListItr/proc/previous()
	if(previous ==null)
		return null
	position--
	next = previous
	lastReturned = next
	previous = lastReturned.prev
	return lastReturned.object


//public void remove()

/datum/datastructures/LinkedListItr/proc/remove()
	if(lastReturned == null)
		return null

	if(lastReturned == previous)
		position--

	next = lastReturned.next
	previous = lastReturned.prev
	parentList.removeEntry( lastReturned )

	lastReturned = null



//public void add(Object o)
/datum/datastructures/LinkedListItr/proc/add(var/o)
	parentList.size++
	var/datum/datastructures/LinkedListNode/e = new /datum/datastructures/LinkedListNode(o)
	e.prev =previous
	e.next =next

	if(previous != null)
		previous.next = e

	if(next!=null)
		next.prev = e
	else
		parentList.last = e

	lastReturned = null;

/*
 * set is a reserved word so I'm making it setObject
*/
//public void setObject(Object o)
/datum/datastructures/LinkedListItr/proc/setObject(var/o)
	if(lastReturned!=null)
		lastReturned.object = o
