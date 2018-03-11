// These pins contain a list.  Null is not allowed.
/datum/integrated_io/lists
	name = "list pin"
	data = list()

/datum/integrated_io/lists/ask_for_pin_data(mob/user)
	interact(user)

/datum/integrated_io/lists/proc/interact(mob/user)
	var/list/my_list = data
	var/t = "<h2>[src]</h2><br>"
	t += "List length: [my_list.len]<br>"
	t += "<a href='?src=[REF(src)]'>\[Refresh\]</a>  |  "
	t += "<a href='?src=[REF(src)];add=1'>\[Add\]</a>  |  "
	t += "<a href='?src=[REF(src)];remove=1'>\[Remove\]</a>  |  "
	t += "<a href='?src=[REF(src)];edit=1'>\[Edit\]</a>  |  "
	t += "<a href='?src=[REF(src)];swap=1'>\[Swap\]</a>  |  "
	t += "<a href='?src=[REF(src)];clear=1'>\[Clear\]</a><br>"
	t += "<hr>"
	var/i = 0
	for(var/line in my_list)
		i++
		t += "#[i] | [display_data(line)]  |  "
		t += "<a href='?src=[REF(src)];edit=1;pos=[i]'>\[Edit\]</a>  |  "
		t += "<a href='?src=[REF(src)];remove=1;pos=[i]'>\[Remove\]</a><br>"
	user << browse(t, "window=list_pin_[REF(src)];size=500x400")

/datum/integrated_io/lists/proc/add_to_list(mob/user, var/new_entry)
	if(!new_entry && user)
		new_entry = ask_for_data_type(user)
	if(is_valid(new_entry))
		Add(new_entry)

/datum/integrated_io/lists/proc/Add(var/new_entry)
	var/list/my_list = data
	if(my_list.len > IC_MAX_LIST_LENGTH)
		my_list.Cut(Start=1,End=2)
	my_list.Add(new_entry)

/datum/integrated_io/lists/proc/remove_from_list_by_position(mob/user, var/position)
	var/list/my_list = data
	if(!my_list.len)
		to_chat(user, "<span class='warning'>The list is empty, there's nothing to remove.</span>")
		return
	if(!position)
		return
	var/target_entry = my_list[position]
	if(target_entry)
		my_list.Remove(target_entry)

/datum/integrated_io/lists/proc/remove_from_list(mob/user, var/target_entry)
	var/list/my_list = data
	if(!my_list.len)
		to_chat(user, "<span class='warning'>The list is empty, there's nothing to remove.</span>")
		return
	if(!target_entry)
		target_entry = input(user, "Which piece of data do you want to remove?", "Remove") as null|anything in my_list
	if(holder.check_interactivity(user) && target_entry)
		my_list.Remove(target_entry)

/datum/integrated_io/lists/proc/edit_in_list(mob/user, var/target_entry)
	var/list/my_list = data
	if(!my_list.len)
		to_chat(user, "<span class='warning'>The list is empty, there's nothing to modify.</span>")
		return
	if(!target_entry)
		target_entry = input(user, "Which piece of data do you want to edit?", "Edit") as null|anything in my_list
	if(holder.check_interactivity(user) && target_entry)
		var/edited_entry = ask_for_data_type(user, target_entry)
		if(edited_entry)
			my_list[my_list.Find(target_entry)] = edited_entry

/datum/integrated_io/lists/proc/edit_in_list_by_position(mob/user, var/position)
	var/list/my_list = data
	if(!my_list.len)
		to_chat(user, "<span class='warning'>The list is empty, there's nothing to modify.</span>")
		return
	if(!position)
		return
	var/target_entry = my_list[position]
	if(target_entry)
		var/edited_entry = ask_for_data_type(user, target_entry)
		if(edited_entry)
			my_list[position] = edited_entry

/datum/integrated_io/lists/proc/swap_inside_list(mob/user, var/first_target, var/second_target)
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

/datum/integrated_io/lists/write_data_to_pin(var/new_data)
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

