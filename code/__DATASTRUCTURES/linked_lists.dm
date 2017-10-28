
//Ok so it's technically a double linked list, bite me.

/datum/linked_list
	var/datum/linked_node/head
	var/datum/linked_node/tail
	var/node_amt = 0


/datum/linked_node
	var/value = null
	var/datum/linked_list/linked_list = null
	var/datum/linked_node/next_node = null
	var/datum/linked_node/previous_node = null


/datum/linked_list/proc/IsEmpty()
	. = (node_amt <= 0)


//Add a linked_node (or value, creating a linked_node) at position
//the added node BECOMES the position-th element,
//eg: add("Test",5), the 5th node is now "Test", the previous 5th moves up to become the 6th
/datum/linked_list/proc/Add(node, position)
	var/datum/linked_node/adding
	if(istype(node, /datum/linked_node))
		adding = node
	else
		adding = new()
		adding.value = node

	if(!adding.linked_list || (adding.linked_list && (adding.linked_list != src)))
		node_amt++

	adding.linked_list = src

	if(position && position < node_amt)
		//Replacing head
		if(position == 1)
			if(head)
				head.previous_node = adding
				adding.next_node = head
			head = adding

		//Replacing any middle node
		else
			var/location = 0
			var/datum/linked_node/at
			while((location != position) && (location <= node_amt))
				if(at)
					if(at.next_node)
						at = at.next_node
					else
						break
				else
					at = head
				location++

			//Push at up and assume it's place as the position-th element
			if(at && at.previous_node)
				at.previous_node.next_node = adding
				adding.previous_node = at.previous_node
				at.previous_node = adding
				adding.next_node = at
		return

	//Replacing tail
	if(tail)
		tail.next_node = adding
		adding.previous_node = tail
		if(!tail.previous_node)
			head = tail
	tail = adding



//Remove a linked_node or the linked_node of a value
//If you specify a value the FIRST ONE is removed
/datum/linked_list/proc/Remove(node)
	var/datum/linked_node/removing
	if(istype(node, /datum/linked_node))
		removing = node
	else
		//optimise removing head and tail, no point looping for them, especially the tail
		if(removing == head)
			removing = head
		else if(removing == tail)
			removing = tail
		else
			var/location = 1
			var/current_value = null
			var/datum/linked_node/at = null
			while((current_value != node) && (location <= node_amt))
				if(at)
					if(at.next_node)
						at = at.next_node
				else
					at = head
				location++
				if(at)
					current_value = at.value
					if(current_value == node)
						removing = at
						break

	//Adjust pointers of where removing -was- in the chain.
	if(removing)
		if(removing.previous_node)
			if(removing == tail)
				tail = removing.previous_node
			if(removing.next_node)
				if(removing == head)
					head = removing.next_node
				removing.next_node.previous_node = removing.previous_node
				removing.previous_node.next_node = removing.next_node
			else
				removing.previous_node.next_node = null
		else
			if(removing.next_node)
				if(removing == head)
					head = removing.next_node
				removing.next_node.previous_node = null

		//if this is still true at this point, there's no more nodes to replace them with
		if(removing == head)
			head = null
		if(removing == tail)
			tail = null

		removing.next_node = null
		removing.previous_node = null
		if(removing.linked_list == src)
			node_amt--
		removing.linked_list = null

		return removing
	return 0


//Removes and deletes a node or value
/datum/linked_list/proc/RemoveDelete(node)
	var/datum/linked_node/dead = Remove(node)
	if(dead)
		qdel(dead)
		return 1
	return 0


//Empty the linked_list, deleting all nodes
/datum/linked_list/proc/Empty()
	var/datum/linked_node/n = head
	while(n)
		var/next = n.next_node
		Remove(n)
		qdel(n)
		n = next
	node_amt = 0


//Some debugging tools
/datum/linked_list/proc/CheckNodeLinks()
	var/datum/linked_node/n = head
	while(n)
		. = "|[n.value]|"
		if(n.previous_node)
			. = "[n.previous_node.value]<-" + .
		if(n.next_node)
			. += "->[n.next_node.value]"
		n = n.next_node
		. += "<BR>"


/datum/linked_list/proc/DrawNodeLinks()
	. = "|<-"
	var/datum/linked_node/n = head
	while(n)
		if(n.previous_node)
			. += "<-"
		. += "[n.value]"
		if(n.next_node)
			. += "->"
		n = n.next_node
	. += "->|"


/datum/linked_list/proc/ToList()
	. = list()
	var/datum/linked_node/n = head
	while(n)
		. += n
		n = n.next_node