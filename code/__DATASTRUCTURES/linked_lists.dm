
//Ok so it's technically a double linked list, bite me.

/datum/linked_list
	var/datum/linked_element/head
	var/datum/linked_element/tail
	var/element_amt = 0


/datum/linked_element
	var/value = null
	var/datum/linked_list/linked_list = null
	var/datum/linked_element/next_element_pointer = null
	var/datum/linked_element/previous_element_pointer = null


/datum/linked_list/proc/is_empty()
	. = element_amt ? 0 : 1


//Add a linked_element (or value, creating a linked_element) at position
//the added element BECOMES the position-th element,
//eg: add("Test",5), the 5th element is now "Test", the previous 5th moves up to become the 6th
/datum/linked_list/proc/add(element, position)
	var/datum/linked_element/adding
	if(istype(element, /datum/linked_element))
		adding = element
	else
		adding = new()
		adding.value = element

	if(!adding.linked_list || (adding.linked_list && (adding.linked_list != src)))
		element_amt++

	adding.linked_list = src

	if(position && position < element_amt)
		//Replacing head
		if(position == 1)
			if(head)
				head.previous_element_pointer = adding
				adding.next_element_pointer = head
			head = adding

		//Replacing any middle element
		else
			var/location = 0
			var/datum/linked_element/at
			while((location != position) && (location <= element_amt))
				if(at)
					if(at.next_element_pointer)
						at = at.next_element_pointer
					else
						break
				else
					at = head
				location++

			//Push at up and assume it's place as the position-th element
			if(at && at.previous_element_pointer)
				at.previous_element_pointer.next_element_pointer = adding
				adding.previous_element_pointer = at.previous_element_pointer
				at.previous_element_pointer = adding
				adding.next_element_pointer = at
		return

	//Replacing tail
	if(tail)
		tail.next_element_pointer = adding
		adding.previous_element_pointer = tail
		if(!tail.previous_element_pointer)
			head = tail
	tail = adding



//Remove a linked_element or the linked_element of a value
//If you specify a value the FIRST ONE is removed
/datum/linked_list/proc/remove(element)
	var/datum/linked_element/removing
	if(istype(element,/datum/linked_element))
		removing = element
	else
		//optimise removing head and tail, no point looping for them, especially the tail
		if(removing == head)
			removing = head
		else if(removing == tail)
			removing = tail
		else
			var/location = 1
			var/current_value = null
			var/datum/linked_element/at = null
			while((current_value != element) && (location <= element_amt))
				if(at)
					if(at.next_element_pointer)
						at = at.next_element_pointer
				else
					at = head
				location++
				if(at)
					current_value = at.value
					if(current_value == element)
						removing = at
						break

	//Adjust pointers of where removing -was- in the chain.
	if(removing)
		if(removing.previous_element_pointer)
			if(removing == tail)
				tail = removing.previous_element_pointer
			if(removing.next_element_pointer)
				if(removing == head)
					head = removing.next_element_pointer
				removing.next_element_pointer.previous_element_pointer = removing.previous_element_pointer
				removing.previous_element_pointer.next_element_pointer = removing.next_element_pointer
			else
				removing.previous_element_pointer.next_element_pointer = null
		else
			if(removing.next_element_pointer)
				if(removing == head)
					head = removing.next_element_pointer
				removing.next_element_pointer.previous_element_pointer = null

		//if this is still true at this point, there's no more elements to replace them with
		if(removing == head)
			head = null
		if(removing == tail)
			tail = null

		removing.next_element_pointer = null
		removing.previous_element_pointer = null
		if(removing.linked_list == src)
			element_amt--
		removing.linked_list = null

		return removing
	return 0


//Removes and deletes a element
/datum/linked_list/proc/removeDelete(element)
	var/datum/linked_element/dead = remove(element)
	if(dead)
		qdel(dead)
		return 1
	return 0


//Empty the linked_list, deleting all elements
/datum/linked_list/proc/empty()
	var/datum/linked_element/e = head
	while(e)
		var/next = e.next_element_pointer
		remove(e)
		qdel(e)
		e = next
	element_amt = 0


//Some debugging tools
/datum/linked_list/proc/check_node_links()
	var/datum/linked_element/e = head
	while(e)
		. = "|[e.value]|"
		if(e.previous_element_pointer)
			. = "[e.previous_element_pointer.value]<-" + .
		if(e.next_element_pointer)
			. += "->[e.next_element_pointer.value]"
		e = e.next_element_pointer
		. += "<BR>"

/datum/linked_list/proc/draw_node_links()
	. = "|<-"
	var/datum/linked_element/e = head
	while(e)
		if(e.previous_element_pointer)
			. += "<-"
		. += "[e.value]"
		if(e.next_element_pointer)
			. += "->"
		e = e.next_element_pointer
	. += "->|"



