// These pins contain a list.  Null is not allowed.
/datum/integrated_io/lists
	name = "list pin"
	data = list()

/datum/integrated_io/lists/ask_for_pin_data(mob/user)
	interact(user)

/datum/integrated_io/lists/proc/interact(mob/user)
	. = ..()
	var/list/my_list = data
	var/t = "<h2>[src]</h2><br>"
	t += "List length: [my_list.len]<br>"
	t += "<a href='?src=[REF(src)]'>\[Refresh\]</a>  |  "
	t += "<a href='?src=[REF(src)];add=1'>\[Add\]</a>  |  "
	t += "<a href='?src=[REF(src)];swap=1'>\[Swap\]</a>  |  "
	t += "<a href='?src=[REF(src)];clear=1'>\[Clear\]</a><br>"
	t += "<hr>"
	var/i = 0
	for(var/line in my_list)
		i++
		t += "#[i] | [display_data(line)] | [display_data(my_list[line])]"
		t += "<a href='?src=[REF(src)];edit=1;pos=[i]'>\[Edit\]</a>  |  "
		t += "<a href='?src=[REF(src)];remove=1;pos=[i]'>\[Remove\]</a><br>"
	user << browse(t, "window=list_pin_[REF(src)];size=500x400")

/datum/integrated_io/lists/proc/add_to_list(mob/user, new_entry, new_value)
	if(!new_entry && user)
		new_entry = ask_for_data_type(user)
	if(!holder.check_interactivity(user))
		return
	var/yes = input(user, "Do you want to set a value?", "List association", "No") as null|anything in list("Yes", "No")
	if(yes == "Yes")
		new_value = ask_for_data_type(user)
	if(is_valid(new_entry))
		Add(new_entry)

/datum/integrated_io/lists/proc/Add(new_entry, new_value)
	var/list/my_list = data
	if(my_list.len > IC_MAX_LIST_LENGTH)
		my_list.Cut(Start=1,End=2)
	my_list.Add(new_entry)
	my_list[new_entry] = new_value

/datum/integrated_io/lists/proc/remove_from_list_by_position(mob/user, position)
	var/list/my_list = data
	if(!my_list.len)
		to_chat(user, "<span class='warning'>The list is empty, there's nothing to remove.</span>")
		return
	if(!position)
		return
	var/target_entry = my_list.Find(position)
	if(target_entry)
		my_list.Remove(target_entry)

/datum/integrated_io/lists/proc/remove_from_list(mob/user, target_entry)
	var/list/my_list = data
	if(!my_list.len)
		to_chat(user, "<span class='warning'>The list is empty, there's nothing to remove.</span>")
		return
	if(!target_entry)
		target_entry = input(user, "Which piece of data do you want to remove?", "Remove") as null|anything in my_list
	if(holder.check_interactivity(user) && target_entry)
		my_list.Remove(target_entry)

/datum/integrated_io/lists/proc/edit_in_list(mob/user, target_entry)
	var/list/my_list = data
	if(!my_list.len)
		to_chat(user, "<span class='warning'>The list is empty, there's nothing to modify.</span>")
		return
	if(!target_entry)
		target_entry = input(user, "Which piece of data do you want to edit?", "Edit") as null|anything in my_list
	if(!holder.check_interactivity(user) || isnull(target_entry))
		return
	var/pos = my_list.Find(target_entry)
	var/mode = input(user, "Key or value?", "List association", "Key") as null|anything in list("Key", "Value")
	var/edited_entry = ask_for_data_type(user, mode == "Key"? target_entry : my_list[target_entry])
	if(edited_entry)
		if(!holder.check_interactivity(user))
			return
		if(mode == "Key")
			my_list[pos] = edited_entry
		else
			my_list[target_entry] = edited_entry


/datum/integrated_io/lists/proc/edit_in_list_by_position(mob/user, position)
	var/list/my_list = data
	if(!my_list.len)
		to_chat(user, "<span class='warning'>The list is empty, there's nothing to modify.</span>")
		return
	if(!position)
		return
	if(!holder.check_interactivity(user))
		return
	var/key = my_list.Find(position)
	var/mode = input(user, "Key or value?", "List association", "Key") as null|anything in list("Key", "Value")
	var/edited_entry = ask_for_data_type(user, mode == "Key"? key : my_list[key])
	if(edited_entry)
		if(!holder.check_interactivity(user))
			return
		if(mode == "Key")
			my_list[position] = edited_entry
		else
			my_list[key] = edited_entry

/datum/integrated_io/lists/proc/swap_inside_list(mob/user, first_target, second_target)
	var/list/my_list = data
	if(my_list.len <= 1)
		to_chat(user, "<span class='warning'>The list is empty, or too small to do any meaningful swapping.</span>")
		return
	if(!first_target)
		first_target = input(user, "Which piece of data do you want to swap? (1)", "Swap") as null|anything in my_list

	if(holder.check_interactivity(user) && first_target)
		if(!second_target)
			second_target = input(user, "Which piece of data do you want to swap? (2)", "Swap") as null|anything in my_list - first_target

		if(holder.check_interactivity(user) && second_target)
			var/first_pos = my_list.Find(first_target)
			var/second_pos = my_list.Find(second_target)
			my_list.Swap(first_pos, second_pos)

/datum/integrated_io/lists/proc/clear_list(mob/user)
	var/list/my_list = data
	my_list.Cut()

/datum/integrated_io/lists/scramble()
	var/list/my_list = data
	my_list = shuffle(my_list)
	push_data()

/datum/integrated_io/lists/write_data_to_pin(new_data)
	if(islist(new_data))
		var/list/new_list = new_data
		data = new_list.Copy(max(1,new_list.len - IC_MAX_LIST_LENGTH+1),0)
		holder.on_data_written()
	else if(isnull(new_data))	// Clear the list
		var/list/my_list = data
		my_list.Cut()
		holder.on_data_written()

/datum/integrated_io/lists/display_pin_type()
	return IC_FORMAT_LIST

/datum/integrated_io/lists/Topic(href, href_list)
	if(!holder.check_interactivity(usr))
		return
	if(..())
		return TRUE

	if(href_list["add"])
		add_to_list(usr)

	if(href_list["swap"])
		swap_inside_list(usr)

	if(href_list["clear"])
		clear_list(usr)

	if(href_list["remove"])
		if(href_list["pos"])
			remove_from_list_by_position(usr, text2num(href_list["pos"]))
		else
			remove_from_list(usr)

	if(href_list["edit"])
		if(href_list["pos"])
			edit_in_list_by_position(usr, text2num(href_list["pos"]))
		else
			edit_in_list(usr)

	holder.interact(usr) // Refresh the main UI,
	interact(usr) // and the list UI.

