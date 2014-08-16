
// Source has been desinged to mimic java's code base: http://developer.classpath.org/doc/java/util/LinkedList-source.html



/datum/datastructures/LinkedList


	var/datum/datastructures/LinkedListNode/first = null
	var/datum/datastructures/LinkedListNode/last = null
	var/size = 0


/datum/datastructures/LinkedList/New()

//private
/datum/datastructures/LinkedList/proc/getEntry(var/n )
	var/datum/datastructures/LinkedListNode/e = null
	if(n < size / 2)
		e = first
		while (n-->0)
			e = e.next
	else
		e = last
		while (++n<size)
			e = e.prev

	return e

//private
/datum/datastructures/LinkedList/proc/removeEntry( var/datum/datastructures/LinkedListNode/e )
	size--
	if(size==0)
		first = null
		last = null
	else
		if(e==first)
			first = e.next
			first.prev = null
		else if(e==last)
			last= e.prev
			last.next = null
		else
			var/datum/datastructures/LinkedListNode/next = e.next
			var/datum/datastructures/LinkedListNode/prev = e.prev
			next.prev = prev
			prev.next =next



//public
/datum/datastructures/LinkedList/proc/getFirst()
	if(size ==0)
		return null

	return first.object


//public
/datum/datastructures/LinkedList/proc/getLast()
	if(size == 0)
		return null
	return last.object





//public
/datum/datastructures/LinkedList/proc/removeFirst()
	if (size ==0)
		return null
	size--
	var/datum/datastructures/LinkedListNode/r = first.object

	var/datum/datastructures/LinkedListNode/next = first.next

	if(next !=null)
		next.prev = null
	else
		last = null

	first = next

	return r



//public
/datum/datastructures/LinkedList/proc/removeLast()
	if(size==0)
		return null
	size--

	var/r = last.object
	var/datum/datastructures/LinkedListNode/prev = last.prev
	if(prev!=null)
		last.next = null
	else
		first = null

	last = prev

	return r



//public
/datum/datastructures/LinkedList/proc/addFirst(var/o)

	var/datum/datastructures/LinkedListNode/e = new /datum/datastructures/LinkedListNode(o)
	if(size ==0)
		first = e
		last = e
	else
		e.next = first
		first.prev = e
		first = e

	size++




//public
/datum/datastructures/LinkedList/proc/addLast(var/o)
	var e = new /datum/datastructures/LinkedListNode(o)

	addLastEntry(e)




//private
/datum/datastructures/LinkedList/proc/addLastEntry(var/datum/datastructures/LinkedListNode/e)
	if(size == 0)
		first = e
		last = e
	else
		e.prev = last
		last.next = e
		last = e

	size++


//public
/datum/datastructures/LinkedList/proc/contains(var/o)
	var/datum/datastructures/LinkedListNode/e = first
	while(e!=null)
		if(o==e.object)
			return 1
		e = e.next
	return 0




/datum/datastructures/LinkedList/proc/size()
	return size


/datum/datastructures/LinkedList/proc/add(var/o)
	var node = new /datum/datastructures/LinkedListNode(o)
	addLastEntry(node)
	return 1



/datum/datastructures/LinkedList/proc/remove(var/o)
	var/datum/datastructures/LinkedListNode/e = first
	while(e!=null)
		if(o==e.object)
			removeEntry(e)
			return 1
		e=e.next
	return 0


//addAll not supported yet



/datum/datastructures/LinkedList/proc/clear()
	if(size > 0)
		first =null
		last = null
		size = 0



/datum/datastructures/LinkedList/proc/get(var/index)
	//bounds check
	if(index<0||index>=size())
		return null

	var/datum/datastructures/LinkedListNode/e = getEntry(index)
	return e.object


/datum/datastructures/LinkedList/proc/setAtIndex(var/index, var/obj)
	//bounds check
	if(index<0||index>=size())
		return null

	var/datum/datastructures/LinkedListNode/e = getEntry(index)
	var/old = e.object
	e.object = obj
	return old


/datum/datastructures/LinkedList/proc/addAtIndex(var/index, var/o)
	//bounds check
	if(index<0||index>=size())
		return null

	var/datum/datastructures/LinkedListNode/e = new /datum/datastructures/LinkedListNode(o)
	if(index<size)
		var/datum/datastructures/LinkedListNode/after = getEntry(index)
		e.next = after
		var/datum/datastructures/LinkedListNode/previous = after.prev
		e.prev =previous
		if(previous==null)
			first = e
		else
			previous.next = e
		after.prev = e
		size++
	else
		addLastEntry(e)

//public
/datum/datastructures/LinkedList/proc/removeAtIndex(var/index)
	//bounds check
	if(index<0||index>=size())
		return null

	var/datum/datastructures/LinkedListNode/e = getEntry(index)
	removeEntry(e)
	return e.object





//public int indexOf(Object o)
/datum/datastructures/LinkedList/proc/indexOf(var/o)
	var/index = 0
	var/datum/datastructures/LinkedListNode/e = first
	while(e!=null)
		if(e.object==o)
			return index
		index++
		e=e.next
	return -1


//public int lastIndexOf(Object o)
/datum/datastructures/LinkedList/proc/lastIndexOf(var/o)
	var/index = size -1
	var/datum/datastructures/LinkedListNode/e = last
	while(e!=null)
		return index
		index--
		e=e.prev
	return -1



//public LinkedListItr<Object> listIterator(int index)
/datum/datastructures/LinkedList/proc/listIterator(var/index)

	var/datum/datastructures/LinkedListItr/toReturn = null;


	if( index == size)
		toReturn = new /datum/datastructures/LinkedListItr(src,last,null,index)
	else
		var/datum/datastructures/LinkedListNode/next = getEntry(index)
		toReturn = new /datum/datastructures/LinkedListItr(src,next.prev,next,index)

	return toReturn


//TODO: add public Object clone()


//Done above this
//public Object poll()
/datum/datastructures/LinkedList/proc/poll()
	if(size==0)
		return null
	return removeFirst()

/** /datum/datastructures/LinkedList/proc/remove()
	return removeFirst()
*/

/datum/datastructures/LinkedList/proc/peekFirst()
	return peek()

/datum/datastructures/LinkedList/proc/peekLast()

/datum/datastructures/LinkedList/proc/peek()
	if (first==null)
		return null
	return first.object

/datum/datastructures/LinkedList/proc/pop()
	if (first==null)
		return null

	//Because first isn't null, we know there is at least one element
	size = size -1

	var/toReturn = first.object

	var/datum/datastructures/LinkedListNode/next = first.next;
	if(next!=null)
		next.prev = null
		first=next

	if(size==0)
		first = null
		last=null;
	return toReturn
