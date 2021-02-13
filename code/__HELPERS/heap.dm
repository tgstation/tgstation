//////////////////////
//datum/heap object
//////////////////////

/datum/heap
	var/list/L
	var/cmp

/datum/heap/New(compare)
	L = new()
	cmp = compare

/datum/heap/proc/IsEmpty()
	return !length(L)

//Insert and place at its position a new node in the heap
/datum/heap/proc/Insert(atom/A)

	L.Add(A)
	Swim(length(L))

//removes and returns the first element of the heap
//(i.e the max or the min dependant on the comparison function)
/datum/heap/proc/Pop()
	if(!length(L))
		return 0
	. = L[1]

	L[1] = L[length(L)]
	L.Cut(length(L))
	if(length(L))
		Sink(1)

//Get a node up to its right position in the heap
/datum/heap/proc/Swim(index)
	var/parent = round(index * 0.5)

	while(parent > 0 && (call(cmp)(L[index],L[parent]) > 0))
		L.Swap(index,parent)
		index = parent
		parent = round(index * 0.5)

//Get a node down to its right position in the heap
/datum/heap/proc/Sink(index)
	var/g_child = GetGreaterChild(index)

	while(g_child > 0 && (call(cmp)(L[index],L[g_child]) < 0))
		L.Swap(index,g_child)
		index = g_child
		g_child = GetGreaterChild(index)

//Returns the greater (relative to the comparison proc) of a node children
//or 0 if there's no child
/datum/heap/proc/GetGreaterChild(index)
	if(index * 2 > length(L))
		return 0

	if(index * 2 + 1 > length(L))
		return index * 2

	if(call(cmp)(L[index * 2],L[index * 2 + 1]) < 0)
		return index * 2 + 1
	else
		return index * 2

//Replaces a given node so it verify the heap condition
/datum/heap/proc/ReSort(atom/A)
	var/index = L.Find(A)

	Swim(index)
	Sink(index)

/datum/heap/proc/List()
	. = L.Copy()

/// A specific implementation of a heap with the procs for dealing with pathfinding baked in, for maximum performance
/datum/heap/path

/datum/heap/path/Swim(index)
	var/parent = round(index * 0.5)

	while(parent > 0)
		var/datum/jps_node/a_node = L[index]
		var/datum/jps_node/b_node = L[parent]
		if(b_node.f_value - a_node.f_value <= 0)
			break
		L.Swap(index,parent)
		index = parent
		parent = round(index * 0.5)

/datum/heap/path/Sink(index)
	var/g_child = GetGreaterChild(index)

	while(g_child > 0)
		var/datum/jps_node/a_node = L[index]
		var/datum/jps_node/b_node = L[g_child]
		if(b_node.f_value - a_node.f_value >= 0)
			break
		L.Swap(index,g_child)
		index = g_child
		g_child = GetGreaterChild(index)

/datum/heap/path/GetGreaterChild(index)
	if(index * 2 > length(L))
		return 0

	if(index * 2 + 1 > length(L))
		return index * 2

	var/datum/jps_node/a_node = L[index * 2 + 1]
	var/datum/jps_node/b_node = L[index * 2]
	if(b_node.f_value - a_node.f_value < 0)
		return index * 2 + 1
	else
		return index * 2
