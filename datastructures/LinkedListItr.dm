/datum/datastructurs/LinkedListItr
	var/datum/datastructurs/LinkedListNode/next = null
	var/datum/datastructurs/LinkedListNode/previous = null
	var/datum/datastructurs/LinkedListNode/lastReturned = null

	var/datum/datastructurs/LinkedList/list

	var/position


/datum/datastructurs/LinkedListItr/New(var/datum/datastructurs/LinkedList/listObj, var/datum/datastructurs/LinkedListNode/p, var/datum/datastructurs/LinkedListNode/n, var/index)
	next = n
	previous = p
	list = listObj
	position = index

//public int nextIndex()
/datum/datastructurs/LinkedListItr/proc/nextIndex()
	return position

//public int previousIndex()
/datum/datastructurs/LinkedListItr/proc/previousIndex()
	return position -1

//public boolean (1/0) hasNext()
/datum/datastructurs/LinkedListItr/proc/hasNext()
	if(next==null)
		return 0
	else
		return 1

/datum/datastructurs/LinkedListItr/proc/hasPrevious()
	if(previous==null)
		return 0
	else
		return 1

//public Object next()
/datum/datastructurs/LinkedListItr/proc/next()
	if(next==null)
		return null
	position++
	lastReturned = next
	previous = next
	next = lastReturned.getNext()
	return lastReturned.getObject()

//public Object previous()
/datum/datastructurs/LinkedListItr/proc/previous()
	if(previous ==null)
		return null
	position--
	next = previous
	lastReturned = next
	previous = lastReturned.getPrev()
	return lastReturned.getObject()

/*  Spent two hours on this, it won't compile because it doesn't believe list is initialized
Here is the Error:
	code\datastructures\LinkedListItr.dm:68:error: removeEntry: invalid expression
	code\datastructures\LinkedListItr.dm:68:warning: list: statement has no effect
Code:
//public void remove()
/datum/datastructurs/LinkedListItr/proc/remove()
	if(lastReturned == null)
		return null

	if(lastReturned == previous)
		position--

	next = lastReturned.getNext()
	previous = lastReturned.getPrev()
	list.removeEntry( lastReturned )

	lastReturned = null
*/


//public void add(Object o)
/datum/datastructurs/LinkedListItr/proc/add(var/o)
	list.size++
	var/datum/datastructurs/LinkedListNode/e = new /datum/datastructurs/LinkedListNode(o)
	e.setPrev(previous)
	e.setNext(next)

	if(previous != null)
		previous.setNext(e)

	if(next!=null)
		next.setPrev(e)
	else
		list.last = e

	lastReturned = null;

/*
 * set is a reserved word so I'm making it setObject
*/
//public void setObject(Object o)
/datum/datastructurs/LinkedListItr/proc/setObject(var/o)
	if(lastReturned!=null)
		lastReturned.setObject(o)
