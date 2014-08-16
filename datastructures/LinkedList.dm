
// Source has been desinged to mimic java's code base: http://developer.classpath.org/doc/java/util/LinkedList-source.html



/datum/datastructurs/LinkedList


	var/datum/datastructurs/LinkedListNode/first = null
	var/datum/datastructurs/LinkedListNode/last = null
	var/size = 0


/datum/datastructurs/LinkedList/New()

//private
/datum/datastructurs/LinkedList/proc/getEntry(var/n )
	var/datum/datastructurs/LinkedListNode/e = null
	if(n < size / 2)
		e = first
		while (n-->0)
			e = e.getNext()
	else
		e = last
		while (++n<size)
			e = e.getPrev()

	return e

//private
/datum/datastructurs/LinkedList/proc/removeEntry( var/datum/datastructurs/LinkedListNode/e )
	size--
	if(size==0)
		first = null
		last = null
	else
		if(e==first)
			first = e.getNext()
			first.setPrev(null)
		else if(e==last)
			last= e.getPrev()
			last.setNext(null)
		else
			var/datum/datastructurs/LinkedListNode/next = e.getNext()
			var/datum/datastructurs/LinkedListNode/prev = e.getPrev()
			next.setPrev(prev)
			prev.setNext(next)



//public
/datum/datastructurs/LinkedList/proc/getFirst()
	if(size ==0)
		return null

	return first.getObject()


//public
/datum/datastructurs/LinkedList/proc/getLast()
	if(size == 0)
		return null
	return last.getObject()






/datum/datastructurs/LinkedList/proc/removeFirst()
	if (size ==0)
		return null
	size--
	var/datum/datastructurs/LinkedListNode/r = first.getObject()

	var/datum/datastructurs/LinkedListNode/next = first.getNext()

	if(next !=null)
		next.setPrev(null)
	else
		last = null

	first = next

	return r




/datum/datastructurs/LinkedList/proc/removeLast()
	if(size==0)
		return null
	size--

	var/r = last.getObject()
	var/datum/datastructurs/LinkedListNode/prev = last.getPrev()
	if(prev!=null)
		last.setNext(null)
	else
		first = null

	last = prev

	return r



//public
/datum/datastructurs/LinkedList/proc/addFirst(var/o)

	var/datum/datastructurs/LinkedListNode/e = new /datum/datastructurs/LinkedListNode(o)
	if(size ==0)
		first = e
		last = e
	else
		e.setNext(first)
		first.setPrev(e)
		first = e

	size++




//public
/datum/datastructurs/LinkedList/proc/addLast(var/o)
	var e = new /datum/datastructurs/LinkedListNode(o)

	addLastEntry(e)




//private
/datum/datastructurs/LinkedList/proc/addLastEntry(var/datum/datastructurs/LinkedListNode/e)
	if(size == 0)
		first = e
		last = e
	else
		e.setPrev(last)
		last.setNext(e)
		last = e

	size++



/datum/datastructurs/LinkedList/proc/contains(var/o)
	var/datum/datastructurs/LinkedListNode/e = first
	while(e!=null)
		if(o==e.getObject())
			return 1
		e = e.getNext()
	return 0




/datum/datastructurs/LinkedList/proc/size()
	return size


/datum/datastructurs/LinkedList/proc/add(var/o)
	var node = new /datum/datastructurs/LinkedListNode(o)
	addLastEntry(node)
	return 1



/datum/datastructurs/LinkedList/proc/remove(var/o)
	var/datum/datastructurs/LinkedListNode/e = first
	while(e!=null)
		if(o==e.getObject())
			removeEntry(e)
			return 1
		e=e.getNext()
	return 0


//addAll not supported yet



/datum/datastructurs/LinkedList/proc/clear()
	if(size > 0)
		first =null
		last = null
		size = 0



/datum/datastructurs/LinkedList/proc/get(var/index)
	//bounds check
	if(index<0||index>=size())
		return null

	var/datum/datastructurs/LinkedListNode/e = getEntry(index)
	return e.getObject()


/datum/datastructurs/LinkedList/proc/setAtIndex(var/index, var/obj)
	//bounds check
	if(index<0||index>=size())
		return null

	var/datum/datastructurs/LinkedListNode/e = getEntry(index)
	var/old = e.getObject()
	e.setObject(obj)
	return old


/datum/datastructurs/LinkedList/proc/addAtIndex(var/index, var/o)
	//bounds check
	if(index<0||index>=size())
		return null

	var/datum/datastructurs/LinkedListNode/e = new /datum/datastructurs/LinkedListNode(o)
	if(index<size)
		var/datum/datastructurs/LinkedListNode/after = getEntry(index)
		e.setNext(after)
		var/datum/datastructurs/LinkedListNode/previous = after.getPrev()
		e.setPrev(previous)
		if(previous==null)
			first = e
		else
			previous.setNext(e)
		after.setPrev(e)
		size++
	else
		addLastEntry(e)

//public
/datum/datastructurs/LinkedList/proc/removeAtIndex(var/index)
	//bounds check
	if(index<0||index>=size())
		return null

	var/datum/datastructurs/LinkedListNode/e = getEntry(index)
	removeEntry(e)
	return e.getObject()





//public int indexOf(Object o)
/datum/datastructurs/LinkedList/proc/indexOf(var/o)
	var/index = 0
	var/datum/datastructurs/LinkedListNode/e = first
	while(e!=null)
		if(e.getObject()==o)
			return index
		index++
		e=e.getNext()
	return -1


//public int lastIndexOf(Object o)
/datum/datastructurs/LinkedList/proc/lastIndexOf(var/o)
	var/index = size -1
	var/datum/datastructurs/LinkedListNode/e = last
	while(e!=null)
		return index
		index--
		e=e.getPrev()
	return -1



//public LinkedListItr<Object> listIterator(int index)
/datum/datastructurs/LinkedList/proc/listIterator(var/index)

	var/datum/datastructurs/LinkedListItr/toReturn = null;


	if( index == size)
		toReturn = new /datum/datastructurs/LinkedListItr(src,last,null,index)
	else
		var/datum/datastructurs/LinkedListNode/next = getEntry(index)
		toReturn = new /datum/datastructurs/LinkedListItr(src,next.getPrev(),next,index)

	return toReturn


//TODO: add public Object clone()


//Done above this
//public Object poll()
/datum/datastructurs/LinkedList/proc/poll()
	if(size==0)
		return null
	return removeFirst()

/** /datum/datastructurs/LinkedList/proc/remove()
	return removeFirst()
*/

/datum/datastructurs/LinkedList/proc/peekFirst()
	return peek()

/datum/datastructurs/LinkedList/proc/peekLast()

/datum/datastructurs/LinkedList/proc/peek()
	if (first==null)
		return null
	return first.getObject()

/datum/datastructurs/LinkedList/proc/pop()
	if (first==null)
		return null

	//Because first isn't null, we know there is at least one element
	size = size -1

	var/toReturn = first.getObject()

	var/datum/datastructurs/LinkedListNode/next = first.getNext();
	if(next!=null)
		next.setPrev(null)
		first=next

	if(size==0)
		first = null
		last=null;
	return toReturn
