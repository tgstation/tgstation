/proc/cycle_inplace(list/c_list) //increases the value of each object in the list by 1 and then puts the final object in the starting location of the first object
	if(!c_list || !c_list.len)
		return
	var/first_obj = c_list[1]
	for(var/i=1, i<c_list.len, ++i)
		c_list[i]=c_list[i+1]
	c_list[c_list.len] = first_obj
