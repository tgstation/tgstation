
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

//return the index the element should be in the priority queue using dichotomic search
/PriorityQueue/proc/FindElementIndex(atom/A)
	var/i = 1
	var/j = L.len
	var/mid

	while(i < j)
		mid = round((i+j)/2)

		if(call(cmp)(L[mid],A) < 0)
			i = mid + 1
		else
			j = mid

	if(i == 1 || i ==  L.len) //edge cases
		return (call(cmp)(L[i],A) > 0) ? i : i+1
	else
		return i


//add an element in the list,
//immediatly ordering it to its position using dichotomic search
/PriorityQueue/proc/Enqueue(atom/A)
	if(!L.len)
		L.Add(A)
		return

	L.Insert(FindElementIndex(A),A)

//removes and returns the first element in the queue
/PriorityQueue/proc/Dequeue()
	if(!L.len)
		return 0
	. = L[1]

	Remove(.)

//removes an element
/PriorityQueue/proc/Remove(atom/A)
	return L.Remove(A)

//returns a copy of the elements list
/PriorityQueue/proc/List()
	. = L.Copy()

//return the position of an element or 0 if not found
/PriorityQueue/proc/Seek(atom/A)
	. = L.Find(A)

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