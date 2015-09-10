
//////////////////////
//PriorityQueue object
//////////////////////

//an ordered list, using the cmp proc to weight the list elements
/PriorityQueue
	var/list/L //the actual queue
	var/cmp //the weight function used to order the queue

/PriorityQueue/New(compare)
	L = new()
	cmp = compare

/PriorityQueue/proc/IsEmpty()
	return !L.len

//add an element in the list,
//immediatly ordering it to its position using Insertion sort
/PriorityQueue/proc/Enqueue(atom/A)
	var/i
	L.Add(A)
	i = L.len -1
	while(i > 0 &&  call(cmp)(L[i],A) >= 0) //place the element at it's right position using the compare proc
		L.Swap(i,i+1) 						//last inserted element being first in case of ties (optimization)
		i--

//removes and returns the first element in the queue
/PriorityQueue/proc/Dequeue()
	if(!L.len)
		return 0
	. = L[1]
	Remove(.)
	return .

//removes an element
/PriorityQueue/proc/Remove(atom/A)
	return L.Remove(A)

//returns a copy of the elements list
/PriorityQueue/proc/List()
	var/list/ret = L.Copy()
	return ret

//return the position of an element or 0 if not found
/PriorityQueue/proc/Seek(atom/A)
	return L.Find(A)

//return the element at the i_th position
/PriorityQueue/proc/Get(i)
	if(i > L.len || i < 1)
		return 0
	return L[i]

//replace the passed element at it's right position using the cmp proc
/PriorityQueue/proc/ReSort(atom/A)
	var/i = Seek(A)
	if(i == 0)
		return
	while(i < L.len && call(cmp)(L[i],L[i+1]) > 0)
		L.Swap(i,i+1)
		i++
	while(i > 1 && call(cmp)(L[i],L[i-1]) <= 0) //last inserted element being first in case of ties (optimization)
		L.Swap(i,i-1)
		i--