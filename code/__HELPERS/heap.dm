
//////////////////////
//datum/Heap object
//////////////////////

/datum/Heap
	var/list/L
	var/cmp
	var/len2

/datum/Heap/New(compare,size_)
	L = list(size_)
	len2 = 0
	cmp = compare

/datum/Heap/proc/reset(size_)
	len2 = 0
	if(L.len<size_)
		L.len = size_


/datum/Heap/proc/IsEmpty()
	return !L.len

//Insert and place at its position a new node in the heap
/datum/Heap/proc/Insert(atom/A)
	if(L.len >= len2)
		len2 += 1
		L[len2] = A
	else
		L.Add(A)
		len2 = L.len
	Swim(len2)

//removes and returns the first element of the heap
//(i.e the max or the min dependant on the comparison function)
/datum/Heap/proc/Pop()
	if(!len2)
		return 0
	. = L[1]

	L[1] = L[len2]
	len2 -= 1

//Get a node up to its right position in the heap
/datum/Heap/proc/Swim(var/index)
	var/parent = round(index * 0.5)

	while(parent > 0 && (call(cmp)(L[index],L[parent]) > 0))
		L.Swap(index,parent)
		index = parent
		parent = round(index * 0.5)
	return index

//Get a node down to its right position in the heap
/datum/Heap/proc/Sink(var/index)
	var/g_child = GetGreaterChild(index)

	while(g_child > 0 && (call(cmp)(L[index],L[g_child]) < 0))
		L.Swap(index,g_child)
		index = g_child
		g_child = GetGreaterChild(index)

//Returns the greater (relative to the comparison proc) of a node children
//or 0 if there's no child
/datum/Heap/proc/GetGreaterChild(var/index)
	if(index * 2 > len2)
		return 0

	if(index * 2 + 1 > len2)
		return index * 2

	if(call(cmp)(L[index * 2],L[index * 2 + 1]) < 0)
		return index * 2 + 1
	else
		return index * 2

//Replaces a given node so it verify the heap condition
/datum/Heap/proc/ReSort(atom/A)
	var/index = L.Find(A)

	Swim(index)
	Sink(index)

/datum/Heap/proc/List()
	. = L.Copy(1,len2 + 1)
